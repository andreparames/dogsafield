import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dogsafield/core/services/location_provider.dart';
import 'package:dogsafield/features/field_map/state/field_map_providers.dart';
import 'package:dogsafield/features/field_map/state/rsvp_providers.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/shared/models/event.dart';
import '../../helpers/test_utils.dart';

final fakePosition = Position(
  latitude: 38.7,
  longitude: -9.1,
  timestamp: DateTime(2026, 7, 7),
  accuracy: 10,
  altitude: 0,
  altitudeAccuracy: 10,
  heading: 0,
  headingAccuracy: 10,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  late FakeFieldMapRepository fieldRepo;
  late FakeRsvpRepository rsvpRepo;

  setUp(() {
    fieldRepo = FakeFieldMapRepository();
    rsvpRepo = FakeRsvpRepository();
  });

  group('rsvpFilterProvider', () {
    test('defaults to false (Nearby)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(rsvpFilterProvider), false);
    });

    test('can be toggled to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(rsvpFilterProvider.notifier).state = true;
      expect(container.read(rsvpFilterProvider), true);
    });
  });

  group('myRsvpIdsProvider', () {
    test('returns RSVPd event IDs', () async {
      rsvpRepo.rsvpEvents = {'evt-1', 'evt-2'};

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          rsvpRepositoryProvider.overrideWithValue(rsvpRepo),
        ],
      );
      addTearDown(container.dispose);

      final ids = await container.read(myRsvpIdsProvider.future);
      expect(ids, {'evt-1', 'evt-2'});
    });
  });

  group('discoveredEventsProvider', () {
    test('returns all events when filter is false', () async {
      final events = [
        DogEvent(
          id: '1', hostId: 'host1', type: EventType.packWalk,
          title: 'Morning Walk', locationName: 'Park',
          latitude: 38.7, longitude: -9.1,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          maxAttendees: 10,
        ),
      ];
      fieldRepo.nearbyEvents = events;

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          fieldMapRepositoryProvider.overrideWithValue(fieldRepo),
          rsvpRepositoryProvider.overrideWithValue(rsvpRepo),
          currentPositionProvider.overrideWith((ref) async => fakePosition),
        ],
      );
      addTearDown(container.dispose);

      container.read(rsvpFilterProvider.notifier).state = false;
      final result = await container.read(discoveredEventsProvider.future);

      expect(result, events);
    });

    test('filters locally when filter is true', () async {
      final allEvents = [
        DogEvent(
          id: '1', hostId: 'host1', type: EventType.packWalk,
          title: 'Morning Walk', locationName: 'Park',
          latitude: 38.7, longitude: -9.1,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          maxAttendees: 10,
        ),
        DogEvent(
          id: '2', hostId: 'host2', type: EventType.dogPicnic,
          title: 'Picnic', locationName: 'Garden',
          latitude: 38.8, longitude: -9.2,
          dateTime: DateTime.now().add(const Duration(days: 2)),
          maxAttendees: 20,
        ),
      ];
      fieldRepo.nearbyEvents = allEvents;
      rsvpRepo.rsvpEvents = {'1'};

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          fieldMapRepositoryProvider.overrideWithValue(fieldRepo),
          rsvpRepositoryProvider.overrideWithValue(rsvpRepo),
          currentPositionProvider.overrideWith((ref) async => fakePosition),
        ],
      );
      addTearDown(container.dispose);

      container.read(rsvpFilterProvider.notifier).state = true;
      final result = await container.read(discoveredEventsProvider.future);

      expect(result.length, 1);
      expect(result.single.id, '1');
    });

    test('filters locally without re-fetching when toggle changes', () async {
      final events = [
        DogEvent(
          id: '1', hostId: 'host1', type: EventType.packWalk,
          title: 'Walk', locationName: 'Park',
          latitude: 38.7, longitude: -9.1,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          maxAttendees: 10,
        ),
      ];
      fieldRepo.nearbyEvents = events;
      rsvpRepo.rsvpEvents = {};

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          fieldMapRepositoryProvider.overrideWithValue(fieldRepo),
          rsvpRepositoryProvider.overrideWithValue(rsvpRepo),
          currentPositionProvider.overrideWith((ref) async => fakePosition),
        ],
      );
      addTearDown(container.dispose);

      container.read(rsvpFilterProvider.notifier).state = false;
      final nearby = await container.read(discoveredEventsProvider.future);
      expect(nearby, events);

      fieldRepo.nearbyEvents = []; // would be a new fetch if re-fetching

      container.read(rsvpFilterProvider.notifier).state = true;
      final myRsvps = await container.read(discoveredEventsProvider.future);
      expect(myRsvps, isEmpty); // still sees original events list, not the mutated one
    });

    test('throws when repository fails', () async {
      fieldRepo.shouldFail = true;

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          fieldMapRepositoryProvider.overrideWithValue(fieldRepo),
          rsvpRepositoryProvider.overrideWithValue(rsvpRepo),
          currentPositionProvider.overrideWith((ref) async => fakePosition),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(discoveredEventsProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
