import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dogsafield/core/database/connectivity_service.dart';
import 'package:dogsafield/core/database/local_cache_service.dart';
import 'package:dogsafield/core/database/database.dart';
import 'package:dogsafield/features/field_map/data/field_map_repository.dart';
import 'package:dogsafield/features/field_map/data/gathering_repository.dart';
import 'package:dogsafield/shared/models/dog.dart';
import 'package:dogsafield/shared/models/event.dart';
import 'package:dogsafield/shared/models/user_profile.dart';

class _OfflineConnectivity implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.none];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late LocalCacheService cache;
  late ConnectivityService offlineConnectivity;
  late SupabaseClient dummyClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(executor: NativeDatabase.memory());
    final prefs = await SharedPreferences.getInstance();
    cache = LocalCacheService(db: db, prefs: prefs);
    offlineConnectivity = ConnectivityService(
      connectivity: _OfflineConnectivity(),
    );
    dummyClient = SupabaseClient('http://localhost', 'fake-key');
  });

  tearDown(() async {
    await db.close();
  });

  group('FieldMapRepository offline', () {
    test('fetchEventsNearby returns cached events when offline', () async {
      final cachedEvent = DogEvent(
        id: 'evt-1',
        hostId: 'host-1',
        type: EventType.packWalk,
        title: 'Cached Walk',
        description: 'From cache',
        locationName: 'Park',
        latitude: 40.0,
        longitude: -74.0,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        maxAttendees: 10,
      );
      await cache.upsertEvents([cachedEvent]);

      final repo = FieldMapRepository(
        dummyClient,
        cache,
        offlineConnectivity,
      );

      final result = await repo.fetchEventsNearby(
        latitude: 40.0,
        longitude: -74.0,
        radiusKm: 50,
      );

      expect(result.length, 1);
      expect(result.first.id, 'evt-1');
      expect(result.first.title, 'Cached Walk');
    });

    test('fetchEventsNearby returns empty list from cache when no cached events match', () async {
      final repo = FieldMapRepository(
        dummyClient,
        cache,
        offlineConnectivity,
      );

      final result = await repo.fetchEventsNearby(
        latitude: 40.0,
        longitude: -74.0,
        radiusKm: 50,
      );

      expect(result, isEmpty);
    });
  });

  group('GatheringRepository offline', () {
    test('fetchGatheringDetail returns cached event detail when offline', () async {
      final event = DogEvent(
        id: 'evt-1',
        hostId: 'host-1',
        type: EventType.packWalk,
        title: 'Offline Walk',
        locationName: 'Park',
        latitude: 40.0,
        longitude: -74.0,
        dateTime: DateTime.now().add(const Duration(days: 1)),
        maxAttendees: 10,
      );
      final host = UserProfile(
        id: 'host-1',
        email: 'host@test.com',
        displayName: 'Host Name',
      );
      final hostDog = Dog(
        id: 'dog-1',
        ownerId: 'host-1',
        name: 'Rex',
        breed: 'Labrador',
      );
      await cache.upsertEvents([event]);
      await cache.upsertProfiles([host]);
      await cache.upsertDogs([hostDog]);

      final repo = GatheringRepository(
        dummyClient,
        cache,
        offlineConnectivity,
      );

      final detail = await repo.fetchGatheringDetail('evt-1');

      expect(detail.event.id, 'evt-1');
      expect(detail.event.title, 'Offline Walk');
      expect(detail.host.id, 'host-1');
      expect(detail.host.displayName, 'Host Name');
      expect(detail.hostDogs.length, 1);
      expect(detail.hostDogs.first.name, 'Rex');
    });

    test('fetchGatheringDetail throws when event not in cache', () async {
      final repo = GatheringRepository(
        dummyClient,
        cache,
        offlineConnectivity,
      );

      expect(
        () => repo.fetchGatheringDetail('nonexistent'),
        throwsException,
      );
    });
  });
}
