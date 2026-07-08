import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dogsafield/features/hosting/state/hosting_provider.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/shared/models/event.dart';
import '../helpers/test_utils.dart';

void main() {
  group('HostingActionNotifier', () {
 test('createEvent transitions through states on success', () async {
    final repo = FakeHostingRepository();
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(fakeAuthService),
        authStateProvider.overrideWith((ref) => Stream.empty()),
        hostingRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(hostingActionProvider.notifier);
    expect(container.read(hostingActionProvider), isA<HostingActionIdle>());

    final event = DogEvent(
      id: '', hostId: '', type: EventType.dogPicnic,
      title: 'Test', locationName: 'Park',
      latitude: 40.0, longitude: -73.0,
      dateTime: DateTime(2026, 7, 15), maxAttendees: 20,
    );

      notifier.createEvent(event);
      expect(container.read(hostingActionProvider), isA<HostingActionLoading>());

      await Future<void>.delayed(Duration.zero);
      expect(container.read(hostingActionProvider), isA<HostingActionSuccess>());
      expect(repo.createCallCount, 1);
    });

    test('createEvent transitions to error on failure', () async {
      final repo = FakeHostingRepository()..shouldFail = true;
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          hostingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(hostingActionProvider.notifier);

      final event = DogEvent(
        id: '', hostId: '', type: EventType.packWalk,
        title: 'Fail', locationName: 'Park',
        latitude: 40.0, longitude: -73.0,
        dateTime: DateTime(2026, 7, 15), maxAttendees: 20,
      );

      notifier.createEvent(event);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(hostingActionProvider);
      expect(state, isA<HostingActionError>());
      expect((state as HostingActionError).message, contains('Failed to create event'));
    });

    test('updateEvent transitions through states on success', () async {
      final repo = FakeHostingRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          hostingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(hostingActionProvider.notifier);

      final event = DogEvent(
        id: '1', hostId: 'me', type: EventType.fieldGames,
        title: 'Updated', locationName: 'Field',
        latitude: 40.0, longitude: -73.0,
        dateTime: DateTime(2026, 7, 15), maxAttendees: 20,
      );

      await notifier.updateEvent(event);
      expect(container.read(hostingActionProvider), isA<HostingActionSuccess>());
      expect(repo.updateCallCount, 1);
    });

    test('cancelEvent transitions through states on success', () async {
      final repo = FakeHostingRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          hostingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(hostingActionProvider.notifier);

      await notifier.cancelEvent('1');
      expect(container.read(hostingActionProvider), isA<HostingActionSuccess>());
      expect(repo.cancelCallCount, 1);
    });

    test('re-entrancy guard prevents concurrent calls', () async {
      final repo = FakeHostingRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          hostingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(hostingActionProvider.notifier);
      expect(container.read(hostingActionProvider), isA<HostingActionIdle>());

      final event = DogEvent(
        id: '', hostId: '', type: EventType.dogPicnic,
        title: 'Test', locationName: 'Park',
        latitude: 40.0, longitude: -73.0,
        dateTime: DateTime(2026, 7, 15), maxAttendees: 20,
      );

      notifier.createEvent(event);
      notifier.createEvent(event);

      await Future<void>.delayed(Duration.zero);
      expect(repo.createCallCount, 1);
    });

    test('reset returns to idle', () async {
      final repo = FakeHostingRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          hostingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(hostingActionProvider.notifier);
      notifier.reset();
      expect(container.read(hostingActionProvider), isA<HostingActionIdle>());
    });
  });

  group('myEventsProvider', () {
    test('returns events from repository', () async {
      final repo = FakeHostingRepository();
      repo.myEvents = [
        DogEvent(
          id: '1', hostId: 'me', type: EventType.dogPicnic,
          title: 'Event 1', locationName: 'Park',
          latitude: 0, longitude: 0, dateTime: DateTime(2026, 7, 15),
          maxAttendees: 20,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          hostingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final events = await container.read(myEventsProvider.future);
      expect(events.length, 1);
      expect(events.first.title, 'Event 1');
    });

    test('activeEventsProvider filters out cancelled events', () async {
      final repo = FakeHostingRepository();
      repo.myEvents = [
        DogEvent(
          id: '1', hostId: 'me', type: EventType.dogPicnic,
          title: 'Active', locationName: 'Park',
          latitude: 0, longitude: 0, dateTime: DateTime(2026, 7, 15),
          maxAttendees: 20,
        ),
        DogEvent(
          id: '2', hostId: 'me', type: EventType.packWalk,
          title: 'Cancelled One', locationName: 'Beach',
          latitude: 0, longitude: 0, dateTime: DateTime(2026, 7, 16),
          maxAttendees: 20, isCancelled: true,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          hostingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(myEventsProvider.future);
      final activeAsync = container.read(activeEventsProvider);
      final active = activeAsync.requireValue;
      expect(active.length, 1);
      expect(active.first.title, 'Active');
    });
  });
}
