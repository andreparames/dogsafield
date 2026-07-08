import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:dogsafield/features/hosting/presentation/my_events_screen.dart';
import 'package:dogsafield/features/hosting/state/hosting_provider.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/shared/models/event.dart';
import '../helpers/test_utils.dart';

Widget _createTestApp(Widget child) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(path: '/test', builder: (_, __) => child),
      GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('Home'))),
      GoRoute(path: '/hosting/manage-attendees', builder: (_, __) => const Scaffold(body: Text('Manage'))),
      GoRoute(path: '/hosting/edit', builder: (_, __) => const Scaffold(body: Text('Edit'))),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  group('MyEventsScreen', () {
    testWidgets('shows empty state when no events', (WidgetTester tester) async {
      final repo = FakeHostingRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          hostingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _createTestApp(const MyEventsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No events yet'), findsOneWidget);
    });

    testWidgets('shows active events', (WidgetTester tester) async {
      final repo = FakeHostingRepository();
      repo.myEvents = [
        DogEvent(
          id: '1', hostId: 'me', type: EventType.dogPicnic,
          title: 'Park Picnic', locationName: 'Central Park',
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

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _createTestApp(const MyEventsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Park Picnic'), findsOneWidget);
      expect(find.text('Active Events'), findsOneWidget);
    });

    testWidgets('shows cancelled events', (WidgetTester tester) async {
      final repo = FakeHostingRepository();
      repo.myEvents = [
        DogEvent(
          id: '1', hostId: 'me', type: EventType.packWalk,
          title: 'Walk Cancelled', locationName: 'Beach',
          latitude: 0, longitude: 0, dateTime: DateTime(2026, 7, 15),
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

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _createTestApp(const MyEventsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Walk Cancelled'), findsOneWidget);
      expect(find.text('Cancelled'), findsWidgets);
    });

    testWidgets('shows error state on failure', (WidgetTester tester) async {
      final repo = FakeHostingRepository()..shouldFail = true;
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          hostingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _createTestApp(const MyEventsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Could not load events'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (WidgetTester tester) async {
      final repo = FakeHostingRepository();
      repo.myEvents = [
        DogEvent(
          id: '1', hostId: 'me', type: EventType.fieldGames,
          title: 'Games', locationName: 'Park',
          latitude: 0, longitude: 0, dateTime: DateTime(2026, 7, 20),
          maxAttendees: 10,
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

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _createTestApp(const MyEventsScreen()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Games'), findsOneWidget);
    });
  });
}
