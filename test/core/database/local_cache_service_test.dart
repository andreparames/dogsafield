import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:dogsafield/core/database/database.dart';
import 'package:dogsafield/core/database/local_cache_service.dart';
import 'package:dogsafield/shared/models/dog.dart';
import 'package:dogsafield/shared/models/event.dart';
import 'package:dogsafield/shared/models/user_profile.dart';

void main() {
  late AppDatabase db;
  late LocalCacheService cache;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(executor: NativeDatabase.memory());
    cache = LocalCacheService(db: db, prefs: await SharedPreferences.getInstance());
  });

  tearDown(() async {
    await db.close();
  });

  group('upsertEvents / getEventsByIds', () {
    test('stores and retrieves events', () async {
      final event = DogEvent(
        id: 'evt-1',
        hostId: 'host-1',
        type: EventType.packWalk,
        title: 'Morning Walk',
        locationName: 'Park',
        latitude: 40.0,
        longitude: -73.0,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        maxAttendees: 10,
      );

      await cache.upsertEvents([event]);
      final result = await cache.getEventsByIds(['evt-1']);

      expect(result.length, 1);
      expect(result.first.id, 'evt-1');
      expect(result.first.title, 'Morning Walk');
    });

    test('returns empty list for unknown ids', () async {
      final result = await cache.getEventsByIds(['unknown']);
      expect(result, isEmpty);
    });
  });

  group('getEventById', () {
    test('returns null for missing event', () async {
      final result = await cache.getEventById('nonexistent');
      expect(result, isNull);
    });

    test('stores and retrieves all event fields round-trip', () async {
      final event = DogEvent(
        id: 'evt-full',
        hostId: 'host-1',
        type: EventType.packWalk,
        title: 'Full Event',
        description: 'A detailed description',
        locationName: 'Park',
        latitude: 40.0,
        longitude: -73.0,
        dateTime: DateTime.utc(2026, 7, 10, 12, 0),
        maxAttendees: 10,
        whatToBring: ['water', 'snacks'],
        amenityTags: ['parking', 'shade'],
        isCancelled: true,
      );
      await cache.upsertEvents([event]);
      final result = await cache.getEventById('evt-full');
      expect(result, isNotNull);
      expect(result!.description, 'A detailed description');
      expect(result.whatToBring, ['water', 'snacks']);
      expect(result.amenityTags, ['parking', 'shade']);
      expect(result.isCancelled, isTrue);
    });
  });

  group('getNearbyEvents', () {
    test('returns events within radius', () async {
      final center = DogEvent(
        id: 'center',
        hostId: 'h1',
        type: EventType.packWalk,
        title: 'Center',
        locationName: 'Loc',
        latitude: 40.0,
        longitude: -73.0,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        maxAttendees: 10,
      );
      await cache.upsertEvents([center]);
      final result = await cache.getNearbyEvents(latitude: 40.0, longitude: -73.0, radiusKm: 10);
      expect(result.length, 1);
    });

    test('excludes events outside radius', () async {
      final far = DogEvent(
        id: 'far',
        hostId: 'h1',
        type: EventType.packWalk,
        title: 'Far',
        locationName: 'Loc',
        latitude: 50.0,
        longitude: -73.0,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        maxAttendees: 10,
      );
      await cache.upsertEvents([far]);
      final result = await cache.getNearbyEvents(latitude: 40.0, longitude: -73.0, radiusKm: 10);
      expect(result, isEmpty);
    });
  });

  group('upsertProfiles / getProfile', () {
    test('stores and retrieves profile', () async {
      const profile = UserProfile(id: 'user-1', email: 'a@b.com', displayName: 'Alice');
      await cache.upsertProfiles([profile]);

      final result = await cache.getProfile('user-1');
      expect(result, isNotNull);
      expect(result!.email, 'a@b.com');
      expect(result.displayName, 'Alice');
    });

    test('returns null for missing profile', () async {
      expect(await cache.getProfile('missing'), isNull);
    });
  });

  group('upsertDogs / getDog', () {
    test('stores and retrieves dog by ownerId', () async {
      final dog = Dog(id: 'dog-1', ownerId: 'owner-1', name: 'Buddy');
      await cache.upsertDogs([dog]);

      final result = await cache.getDog('owner-1');
      expect(result, isNotNull);
      expect(result!.name, 'Buddy');
    });

    test('returns null for missing owner', () async {
      expect(await cache.getDog('unknown'), isNull);
    });
  });

  group('upsertAttendance / getAttendeeIds / getMyRsvpIds', () {
    test('stores attendance and retrieves attendee IDs', () async {
      await cache.upsertAttendance('evt-1', 'user-1', 'confirmed');
      final ids = await cache.getAttendeeIds('evt-1');
      expect(ids, ['user-1']);
    });

    test('getMyRsvpIds returns event IDs for user', () async {
      await cache.upsertAttendance('evt-1', 'user-1', 'confirmed');
      await cache.upsertAttendance('evt-2', 'user-1', 'confirmed');

      final ids = await cache.getMyRsvpIds('user-1');
      expect(ids, {'evt-1', 'evt-2'});
    });

    test('getMyRsvpIds returns empty set for unknown user', () async {
      final ids = await cache.getMyRsvpIds('unknown');
      expect(ids, isEmpty);
    });

    test('getMyRsvpEvents returns events for user RSVPs', () async {
      final event = DogEvent(
        id: 'rsvp-evt',
        hostId: 'h1',
        type: EventType.packWalk,
        title: 'RSVP Event',
        locationName: 'Loc',
        latitude: 40.0,
        longitude: -73.0,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        maxAttendees: 10,
      );
      await cache.upsertEvents([event]);
      await cache.upsertAttendance('rsvp-evt', 'user-1', 'confirmed');
      final result = await cache.getMyRsvpEvents('user-1');
      expect(result.length, 1);
      expect(result.first.id, 'rsvp-evt');
    });
  });

  group('upsertAttendanceBatch', () {
    test('inserts multiple rows', () async {
      await cache.upsertAttendanceBatch([
        ('evt-1', 'user-1', 'confirmed'),
        ('evt-1', 'user-2', 'confirmed'),
      ]);
      final ids = await cache.getAttendeeIds('evt-1');
      expect(ids, ['user-1', 'user-2']);
    });
  });

  group('deleteAttendance', () {
    test('removes attendance record', () async {
      await cache.upsertAttendance('evt-1', 'user-1', 'confirmed');
      await cache.deleteAttendance('evt-1', 'user-1');
      final ids = await cache.getAttendeeIds('evt-1');
      expect(ids, isEmpty);
    });
  });

  group('sync timestamps', () {
    test('getLastSync returns null initially', () async {
      final ts = await cache.getLastSync('events');
      expect(ts, isNull);
    });

    test('getLastSync returns non-null after upsert', () async {
      final event = DogEvent(
        id: 'evt-sync',
        hostId: 'h1',
        type: EventType.dogPicnic,
        title: 'Sync Test',
        locationName: 'Loc',
        latitude: 0,
        longitude: 0,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        maxAttendees: 5,
      );
      await cache.upsertEvents([event]);
      final ts = await cache.getLastSync('events');
      expect(ts, isNotNull);
    });
  });
}
