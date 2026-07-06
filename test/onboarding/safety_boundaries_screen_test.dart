import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:dogsafield/features/onboarding/presentation/safety_boundaries_screen.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/features/onboarding/state/onboarding_state.dart';
import 'package:dogsafield/shared/models/dog.dart';
import 'package:dogsafield/shared/models/user_profile.dart';
import '../helpers/test_utils.dart';

void main() {
  testWidgets('shows snackbar when no treat policy selected', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const SafetyBoundariesScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Please select a treat policy'), findsOneWidget);
  });

  testWidgets('renders treat policy options', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const SafetyBoundariesScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Safety Boundaries'), findsOneWidget);
    expect(find.text('Treat Policy'), findsOneWidget);
    expect(find.textContaining('Okay to share'), findsOneWidget);
    expect(find.textContaining('Ask before feeding'), findsOneWidget);
    expect(find.text('Complete Profile'), findsOneWidget);
  });

  testWidgets('submits and navigates to home with valid data', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(fakeAuthService),
        authStateProvider.overrideWith((ref) => Stream.empty()),
        onboardingRepositoryProvider.overrideWithValue(fakeOnboardingRepository),
      ],
    );
    container.read(onboardingProvider.notifier).setUserProfile(
      UserProfile(id: 'u1', email: 'a@b.com', displayName: 'Alice'),
    );
    container.read(onboardingProvider.notifier).setDog(
      Dog(id: 'd1', name: 'Buddy'),
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/test',
      routes: [
        GoRoute(path: '/test', builder: (_, __) => const SafetyBoundariesScreen()),
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

    await tester.tap(find.textContaining('Okay to share'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}
