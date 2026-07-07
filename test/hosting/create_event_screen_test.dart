import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:dogsafield/features/hosting/presentation/create_event_screen.dart';
import 'package:dogsafield/features/hosting/state/hosting_provider.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import '../helpers/test_utils.dart';

void main() {
  group('CreateEventScreen', () {
    testWidgets('shows validation error when title is empty', (WidgetTester tester) async {
      final repo = FakeHostingRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          hostingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(path: '/test', builder: (_, __) => const CreateEventScreen()),
          GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('Home'))),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Publish to Field'));
      await tester.pumpAndSettle();

      expect(repo.createCallCount, 0);
    });

    testWidgets('creates event with valid data', (WidgetTester tester) async {
      final repo = FakeHostingRepository();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          hostingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(path: '/test', builder: (_, __) => const CreateEventScreen(initialLatitude: 38.7, initialLongitude: -9.1)),
          GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('Home'))),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dog Picnic'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('eventTitle')), 'Morning Meetup');
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Publish to Field'));
      await tester.pumpAndSettle();

      expect(repo.createCallCount, 1);
    });

    testWidgets('shows snackbar on create failure', (WidgetTester tester) async {
      final repo = FakeHostingRepository()..shouldFail = true;
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          hostingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(path: '/test', builder: (_, __) => const CreateEventScreen(initialLatitude: 38.7, initialLongitude: -9.1)),
          GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('Home'))),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dog Picnic'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('eventTitle')), 'Event');
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Publish to Field'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to create event'), findsOneWidget);
    });
  });
}
