import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/dog.dart';
import '../../shared/models/event.dart';
import '../../shared/models/user_profile.dart';
import 'database.dart';

class LocalCacheService {
  final AppDatabase _db;
  final SharedPreferences _prefs;

  LocalCacheService({required AppDatabase db, required SharedPreferences prefs})
      : _db = db,
        _prefs = prefs;

  Future<void> upsertEvents(List<DogEvent> events) async {
    for (final event in events) {
      await _db.into(_db.eventsTable).insertOnConflictUpdate(
        EventsTableCompanion(
          id: Value(event.id),
          hostId: Value(event.hostId),
          type: Value(event.type.name),
          title: Value(event.title),
          description: Value<String?>(event.description),
          eventDate: Value(event.dateTime.toUtc().toIso8601String()),
          locationName: Value(event.locationName),
          latitude: Value(event.latitude),
          longitude: Value(event.longitude),
          maxAttendees: Value(event.maxAttendees),
          whatToBring: Value<String?>(jsonEncode(event.whatToBring)),
          amenityTags: Value<String?>(jsonEncode(event.amenityTags)),
          isCancelled: Value<int?>(event.isCancelled ? 1 : 0),
        ),
      );
    }
    await _setLastSync('events');
  }

  Future<void> upsertProfiles(List<UserProfile> profiles) async {
    for (final profile in profiles) {
      await _db.into(_db.profilesTable).insertOnConflictUpdate(
        ProfilesTableCompanion(
          id: Value(profile.id),
          email: Value(profile.email),
          displayName: Value(profile.displayName),
          photoUrl: Value(profile.photoUrl),
          isVerified: Value<int?>(profile.isVerified ? 1 : 0),
          trialRsvpsUsed: Value<int?>(profile.trialRsvpsUsed),
          isFoundingPack: Value<int?>(profile.isFoundingPack ? 1 : 0),
          isSuspended: Value<int?>(profile.isSuspended ? 1 : 0),
          hasSeenFieldIntro: Value<int?>(profile.hasSeenFieldIntro ? 1 : 0),
          hasSeenHostIntro: Value<int?>(profile.hasSeenHostIntro ? 1 : 0),
          treatPolicy: Value(profile.treatPolicy?.name),
        ),
      );
    }
    await _setLastSync('profiles');
  }

  Future<void> upsertDogs(List<Dog> dogs) async {
    for (final dog in dogs) {
      await _db.into(_db.dogsTable).insertOnConflictUpdate(
        DogsTableCompanion(
          id: Value(dog.id),
          ownerId: Value(dog.ownerId),
          name: Value(dog.name),
          age: Value(dog.age),
          breed: Value(dog.breed),
          vibe: Value(dog.vibe?.name),
          icebreakerAnswer: Value(dog.icebreakerAnswer),
        ),
      );
    }
    await _setLastSync('dogs');
  }

  Future<void> upsertAttendance(String eventId, String userId, String status) async {
    await _db.into(_db.attendanceTable).insertOnConflictUpdate(
      AttendanceTableCompanion(
        eventId: Value(eventId),
        userId: Value(userId),
        status: Value<String?>(status),
      ),
    );
    await _setLastSync('attendance');
  }

  Future<void> deleteAttendance(String eventId, String userId) async {
    await (_db.delete(_db.attendanceTable)
      ..where((t) => t.eventId.equals(eventId))
      ..where((t) => t.userId.equals(userId))
    ).go();
    await _setLastSync('attendance');
  }

  Future<void> upsertAttendanceBatch(List<(String eventId, String userId, String status)> rows) async {
    for (final r in rows) {
      await _db.into(_db.attendanceTable).insertOnConflictUpdate(
        AttendanceTableCompanion(
          eventId: Value(r.$1),
          userId: Value(r.$2),
          status: Value<String?>(r.$3),
        ),
      );
    }
    await _setLastSync('attendance');
  }

  Future<List<DogEvent>> getNearbyEvents({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
  }) async {
    const double kmPerDegree = 111.0;
    final double latDelta = radiusKm / kmPerDegree;
    final double lonDelta = radiusKm / (kmPerDegree * cos(latitude * pi / 180));

    final latLow = Variable(latitude - latDelta);
    final latHigh = Variable(latitude + latDelta);
    final lonLow = Variable(longitude - lonDelta);
    final lonHigh = Variable(longitude + lonDelta);
    final query = _db.select(_db.eventsTable)
      ..where((t) => t.latitude.isBetween(latLow, latHigh))
      ..where((t) => t.longitude.isBetween(lonLow, lonHigh));

    final rows = await query.get();
    final now = DateTime.now().toUtc().toIso8601String();
    return rows
        .where((r) => r.eventDate.compareTo(now) >= 0)
        .map(_toDogEvent)
        .toList();
  }

  Future<List<DogEvent>> getMyRsvpEvents(String userId) async {
    final rsvpIds = await getMyRsvpIds(userId);
    if (rsvpIds.isEmpty) return [];
    return getEventsByIds(rsvpIds.toList());
  }

  Future<List<DogEvent>> getEventsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final query = _db.select(_db.eventsTable)
      ..where((t) => t.id.isIn(ids));
    final rows = await query.get();
    return rows.map(_toDogEvent).toList();
  }

  Future<DogEvent?> getEventById(String id) async {
    final query = _db.select(_db.eventsTable)
      ..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _toDogEvent(row) : null;
  }

  Future<UserProfile?> getProfile(String id) async {
    final query = _db.select(_db.profilesTable)
      ..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _toProfile(row) : null;
  }

  Future<Dog?> getDog(String ownerId) async {
    final query = _db.select(_db.dogsTable)
      ..where((t) => t.ownerId.equals(ownerId))
        ..limit(1);
    final rows = await query.get();
    if (rows.isEmpty) return null;
    return _toDog(rows.first);
  }

  Future<List<String>> getAttendeeIds(String eventId) async {
    final query = _db.select(_db.attendanceTable)
      ..where((t) => t.eventId.equals(eventId))
      ..where((t) => t.status.equals('confirmed'));
    final rows = await query.get();
    return rows.map((r) => r.userId).toList();
  }

  Future<Set<String>> getMyRsvpIds(String userId) async {
    final query = _db.select(_db.attendanceTable)
      ..where((t) => t.userId.equals(userId))
      ..where((t) => t.status.equals('confirmed'));
    final rows = await query.get();
    return rows.map((r) => r.eventId).toSet();
  }

  Future<DateTime?> getLastSync(String table) async {
    final ms = _prefs.getInt('sync_ts_$table');
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  Future<void> _setLastSync(String table) async {
    await _prefs.setInt('sync_ts_$table', DateTime.now().millisecondsSinceEpoch);
  }

  T? _safeEnum<T extends Enum>(List<T> values, String? name) {
    if (name == null) return null;
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }

  DogEvent _toDogEvent(EventsTableData row) {
    return DogEvent(
      id: row.id,
      hostId: row.hostId,
      type: _safeEnum(EventType.values, row.type) ?? EventType.packWalk,
      title: row.title,
      description: row.description,
      locationName: row.locationName,
      latitude: row.latitude,
      longitude: row.longitude,
      dateTime: DateTime.parse(row.eventDate),
      maxAttendees: row.maxAttendees,
      whatToBring: row.whatToBring != null
          ? (jsonDecode(row.whatToBring!) as List<dynamic>).cast<String>()
          : [],
      amenityTags: row.amenityTags != null
          ? (jsonDecode(row.amenityTags!) as List<dynamic>).cast<String>()
          : [],
      isCancelled: row.isCancelled == 1,
    );
  }

  UserProfile _toProfile(ProfilesTableData row) {
    return UserProfile(
      id: row.id,
      email: row.email,
      displayName: row.displayName,
      photoUrl: row.photoUrl,
      isVerified: row.isVerified == 1,
      trialRsvpsUsed: row.trialRsvpsUsed ?? 0,
      isFoundingPack: row.isFoundingPack == 1,
      isSuspended: row.isSuspended == 1,
      hasSeenFieldIntro: row.hasSeenFieldIntro == 1,
      hasSeenHostIntro: row.hasSeenHostIntro == 1,
      treatPolicy: _safeEnum(TreatPolicy.values, row.treatPolicy),
    );
  }

  Dog _toDog(DogsTableData row) {
    return Dog(
      id: row.id,
      ownerId: row.ownerId,
      name: row.name,
      age: row.age,
      breed: row.breed,
      vibe: _safeEnum(SocialVibe.values, row.vibe),
      icebreakerAnswer: row.icebreakerAnswer,
    );
  }
}
