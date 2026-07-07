import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dogsafield/core/services/location_provider.dart';
import 'package:dogsafield/features/field_map/state/field_map_providers.dart';
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
  late FakeFieldMapRepository repo;

  setUp(() {
    repo = FakeFieldMapRepository();
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

  group('discoveredEventsProvider', () {
    test('returns nearby events when filter is false', () async {
      final events = [
        DogEvent(
          id: '1',
          hostId: 'host1',
          type: EventType.packWalk,
          title: 'Morning Walk',
          locationName: 'Park',
          latitude: 38.7,
          longitude: -9.1,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          maxAttendees: 10,
        ),
      ];
      repo.nearbyEvents = events;

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          fieldMapRepositoryProvider.overrideWithValue(repo),
          currentPositionProvider.overrideWith((ref) async => fakePosition),
        ],
      );
      addTearDown(container.dispose);

      container.read(rsvpFilterProvider.notifier).state = false;
      final result = await container.read(discoveredEventsProvider.future);

      expect(result, events);
    });

    test('returns RSVPs when filter is true', () async {
      final events = [
        DogEvent(
          id: '2',
          hostId: 'host2',
          type: EventType.dogPicnic,
          title: 'Picnic',
          locationName: 'Garden',
          latitude: 38.8,
          longitude: -9.2,
          dateTime: DateTime.now().add(const Duration(days: 2)),
          maxAttendees: 20,
        ),
      ];
      repo.rsvpEvents = events;

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          fieldMapRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      container.read(rsvpFilterProvider.notifier).state = true;
      final result = await container.read(discoveredEventsProvider.future);

      expect(result, events);
    });

    test('re-fetches when filter toggles', () async {
      final events = [
        DogEvent(
          id: '3',
          hostId: 'host3',
          type: EventType.fieldGames,
          title: 'Games',
          locationName: 'Field',
          latitude: 38.9,
          longitude: -9.3,
          dateTime: DateTime.now().add(const Duration(days: 3)),
          maxAttendees: 30,
        ),
      ];
      repo.nearbyEvents = events;

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          fieldMapRepositoryProvider.overrideWithValue(repo),
          currentPositionProvider.overrideWith((ref) async => fakePosition),
        ],
      );
      addTearDown(container.dispose);

      container.read(rsvpFilterProvider.notifier).state = false;
      final nearby = await container.read(discoveredEventsProvider.future);
      expect(nearby, events);

      final rsvpEvents = [
        DogEvent(
          id: '4',
          hostId: 'host4',
          type: EventType.packWalk,
          title: 'Rsvp Walk',
          locationName: 'Trail',
          latitude: 39.0,
          longitude: -9.4,
          dateTime: DateTime.now().add(const Duration(days: 4)),
          maxAttendees: 15,
        ),
      ];
      repo.rsvpEvents = rsvpEvents;

      container.read(rsvpFilterProvider.notifier).state = true;
      final myRsvps = await container.read(discoveredEventsProvider.future);
      expect(myRsvps, rsvpEvents);
    });

    test('throws when repository fails', () async {
      repo.shouldFail = true;

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          fieldMapRepositoryProvider.overrideWithValue(repo),
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
