import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/connectivity_service.dart';
import '../../../core/database/local_cache_service.dart';
import '../../../shared/models/dog.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/user_profile.dart';
import 'attendee_profile.dart';
import 'gathering_detail.dart';

class GatheringRepository {
  final SupabaseClient _client;
  final LocalCacheService? _cache;
  final ConnectivityService? _connectivity;

  GatheringRepository(this._client, [this._cache, this._connectivity]);

  Future<GatheringDetail> fetchGatheringDetail(String eventId) async {
    if (_cache != null && _connectivity != null) {
      final online = await _connectivity.isOnline;
      if (!online) {
        return _buildFromCache(eventId);
      }
    }

    final event = await _fetchEvent(eventId);
    final host = await _fetchProfile(event.hostId);
    final hostDog = await _fetchDog(event.hostId);
    final attendees = await _fetchAttendees(eventId);

    if (_cache != null) {
      final attendanceRows = await _client
          .from('attendance')
          .select('user_id')
          .eq('event_id', eventId)
          .eq('status', 'confirmed');
      for (final row in attendanceRows) {
        await _cache.upsertAttendance(
          eventId,
          row['user_id'] as String,
          'confirmed',
        );
      }
      await _cache.upsertEvents([event]);
      await _cache.upsertProfiles([host]);
      if (hostDog != null) await _cache.upsertDogs([hostDog]);
      await _cache.upsertProfiles(attendees.map((a) => a.profile).toList());
      await _cache.upsertDogs(
        attendees.where((a) => a.dog != null).map((a) => a.dog!).toList(),
      );
    }

    return GatheringDetail(
      event: event,
      host: host,
      hostDog: hostDog,
      attendees: attendees,
    );
  }

  Future<GatheringDetail> _buildFromCache(String eventId) async {
    final c = _cache;
    if (c == null) throw Exception('Cache not available');
    final event = await c.getEventById(eventId);
    if (event == null) throw Exception('Event not found in cache');

    final host = await c.getProfile(event.hostId);
    if (host == null) throw Exception('Host not found in cache');

    final hostDog = await c.getDog(event.hostId);
    final attendeeIds = await c.getAttendeeIds(eventId);

    final attendees = <AttendeeProfile>[];
    for (final uid in attendeeIds) {
      final profile = await c.getProfile(uid);
      if (profile == null) continue;
      final dog = await c.getDog(uid);
      attendees.add(AttendeeProfile(profile: profile, dog: dog));
    }

    return GatheringDetail(
      event: event,
      host: host,
      hostDog: hostDog,
      attendees: attendees,
    );
  }

  Future<DogEvent> _fetchEvent(String id) async {
    final response = await _client
        .from('events')
        .select()
        .eq('id', id)
        .single();

    return _rowToEvent(response);
  }

  Future<UserProfile> _fetchProfile(String id) async {
    final response = await _client
        .from('profiles_public')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) throw Exception('Profile not found or not visible');
    return _rowToProfile(response);
  }

  Future<Dog?> _fetchDog(String ownerId) async {
    final response = await _client
        .from('dogs')
        .select()
        .eq('owner_id', ownerId)
        .limit(1);

    if (response.isEmpty) return null;
    return _rowToDog(response.first);
  }

  Future<List<AttendeeProfile>> _fetchAttendees(String eventId) async {
    final attendanceRows = await _client
        .from('attendance')
        .select('user_id')
        .eq('event_id', eventId)
        .eq('status', 'confirmed');

    if (attendanceRows.isEmpty) return [];

    final userIds = attendanceRows.map((r) => r['user_id'] as String).toList();

    final results = await Future.wait([
      _client.from('profiles_public').select().inFilter('id', userIds),
      _client.from('dogs').select().inFilter('owner_id', userIds),
    ]);
    final profileMap = <String, UserProfile>{};
    for (final row in results[0]) {
      final profile = _rowToProfile(row);
      profileMap[profile.id] = profile;
    }
    final dogMap = <String, Dog>{};
    for (final row in results[1]) {
      final ownerId = row['owner_id'] as String;
      dogMap.putIfAbsent(ownerId, () => _rowToDog(row));
    }

    return userIds.map((uid) {
      final profile = profileMap[uid];
      if (profile == null) return null;
      return AttendeeProfile(
        profile: profile,
        dog: dogMap[uid],
      );
    }).whereType<AttendeeProfile>().toList();
  }

  DogEvent _rowToEvent(Map<String, dynamic> row) {
    return DogEvent(
      id: row['id'] as String,
      hostId: row['host_id'] as String,
      type: EventType.values.firstWhere((e) => e.name == row['type']),
      title: row['title'] as String,
      description: row['description'] as String?,
      locationName: row['location_name'] as String,
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      dateTime: DateTime.parse(row['date_time'] as String),
      maxAttendees: row['max_attendees'] as int,
      whatToBring: (row['what_to_bring'] as List<dynamic>?)?.cast<String>() ?? [],
      amenityTags: (row['amenity_tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  UserProfile _rowToProfile(Map<String, dynamic> row) {
    return UserProfile(
      id: row['id'] as String,
      email: '',
      displayName: row['display_name'] as String?,
      photoUrl: row['photo_url'] as String?,
      isFoundingPack: row['is_founding_pack'] as bool? ?? false,
      treatPolicy: row['treat_policy'] != null
          ? TreatPolicy.values.firstWhere((e) => e.name == row['treat_policy'])
          : null,
    );
  }

  Dog _rowToDog(Map<String, dynamic> row) {
    return Dog(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      name: row['name'] as String,
      age: row['age'] as int?,
      breed: row['breed'] as String?,
      vibe: row['vibe'] != null
          ? SocialVibe.values.firstWhere((e) => e.name == row['vibe'])
          : null,
      icebreakerAnswer: row['icebreaker_answer'] as String?,
    );
  }
}
