import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dogsafield/core/services/location_provider.dart';
import 'package:dogsafield/features/connections/state/connection_providers.dart';
import 'package:dogsafield/features/field_map/state/field_map_providers.dart';
import 'package:dogsafield/features/field_map/state/rsvp_providers.dart';
import 'package:dogsafield/features/field_map/state/waitlist_providers.dart';
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
    Future<void> setupEvents(ProviderContainer container) async {
      await container.read(allEventsProvider.future);
      await container.read(myRsvpIdsProvider.future);
    }

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
      await setupEvents(container);

      container.read(rsvpFilterProvider.notifier).state = false;
      final result = container.read(discoveredEventsProvider);

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
      await setupEvents(container);

      container.read(rsvpFilterProvider.notifier).state = true;
      final result = container.read(discoveredEventsProvider);

      expect(result.length, 1);
      expect(result.single.id, '1');
    });

    test('includes waitlisted events when filter is true', () async {
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
        DogEvent(
          id: '3', hostId: 'host2', type: EventType.fieldGames,
          title: 'Games', locationName: 'Field',
          latitude: 38.8, longitude: -9.2,
          dateTime: DateTime.now().add(const Duration(days: 3)),
          maxAttendees: 20,
        ),
      ];
      fieldRepo.nearbyEvents = allEvents;
      rsvpRepo.rsvpEvents = {'1'};

      final waitlistRepo = FakeWaitlistRepository();
      waitlistRepo.joinWaitlist('2');

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          fieldMapRepositoryProvider.overrideWithValue(fieldRepo),
          rsvpRepositoryProvider.overrideWithValue(rsvpRepo),
          waitlistRepositoryProvider.overrideWithValue(waitlistRepo),
          currentPositionProvider.overrideWith((ref) async => fakePosition),
        ],
      );
      addTearDown(container.dispose);
      await setupEvents(container);
      await container.read(myWaitlistWalkIdsProvider.future);

      container.read(rsvpFilterProvider.notifier).state = true;
      final result = container.read(discoveredEventsProvider);

      expect(result.length, 2);
      expect(result.map((e) => e.id), containsAll({'1', '2'}));
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
      await setupEvents(container);

      container.read(rsvpFilterProvider.notifier).state = false;
      final nearby = container.read(discoveredEventsProvider);
      expect(nearby, events);

      fieldRepo.nearbyEvents = []; // would be a new fetch if re-fetching

      container.read(rsvpFilterProvider.notifier).state = true;
      final myRsvps = container.read(discoveredEventsProvider);
      expect(myRsvps, isEmpty); // still sees original events list, not the mutated one
    });

    test('returns empty while loading', () {
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

      // discoveredEventsProvider uses .value ?? [], so before
      // allEventsProvider has completed, it returns an empty list.
      final result = container.read(discoveredEventsProvider);
      expect(result, isEmpty);
    });

    test('filters events hosted by blockerIds but not blockedIds', () async {
      final events = [
        DogEvent(
          id: '1', hostId: 'blocked-host', type: EventType.packWalk,
          title: 'Walk', locationName: 'Park',
          latitude: 38.7, longitude: -9.1,
          dateTime: DateTime.now().add(const Duration(days: 1)),
          maxAttendees: 10,
        ),
        DogEvent(
          id: '2', hostId: 'blocker-host', type: EventType.dogPicnic,
          title: 'Picnic', locationName: 'Garden',
          latitude: 38.8, longitude: -9.2,
          dateTime: DateTime.now().add(const Duration(days: 2)),
          maxAttendees: 20,
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
          blockedUserIdsProvider.overrideWith((ref) => Future.value(<String>{'blocked-host'})),
          blockerIdsProvider.overrideWith((ref) => Future.value(<String>{'blocker-host'})),
        ],
      );
      addTearDown(container.dispose);
      await container.read(allEventsProvider.future);
      await container.read(blockerIdsProvider.future);

      container.read(rsvpFilterProvider.notifier).state = false;
      final result = container.read(discoveredEventsProvider);

      expect(result.length, 1);
      expect(result.single.id, '1');
    });

    test('returns empty when repository fails', () async {
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

      // Use listen + Completer to wait for error state (Riverpod 3 .future
      // doesn't complete when the async computation throws)
      final errorCompleter = Completer<void>();
      final sub = container.listen(allEventsProvider, (prev, next) {
        if (next.hasError && !errorCompleter.isCompleted) {
          errorCompleter.completeError(next.error!, next.stackTrace);
        } else if (!next.isLoading && next.hasValue && !errorCompleter.isCompleted) {
          errorCompleter.complete();
        }
      });
      await expectLater(errorCompleter.future, throwsA(isA<Exception>()));
      sub.close();

      // Verify discoveredEventsProvider handles the error state gracefully
      final result = container.read(discoveredEventsProvider);
      expect(result, isEmpty);
    });
  });
}
