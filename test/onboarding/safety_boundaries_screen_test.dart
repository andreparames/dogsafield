import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:dogsafield/features/onboarding/presentation/safety_boundaries_screen.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/features/onboarding/state/onboarding_state.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import 'package:dogsafield/shared/models/dog.dart';
import 'package:dogsafield/shared/models/user_profile.dart';
import '../helpers/test_utils.dart';

void main() {
  testWidgets('shows snackbar when no treat policy selected', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const SafetyBoundariesScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.onboarding.safety.completeProfile));
    await tester.pumpAndSettle();

    expect(find.text(t.onboarding.safety.policyRequired), findsOneWidget);
  });

  testWidgets('renders treat policy options', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const SafetyBoundariesScreen()));
    await tester.pumpAndSettle();

    expect(find.text(t.onboarding.safety.title), findsOneWidget);
    expect(find.text(t.onboarding.safety.treatPolicy), findsOneWidget);
    expect(find.textContaining(t.onboarding.safety.okToShare), findsOneWidget);
    expect(find.textContaining(t.onboarding.safety.askBeforeFeeding), findsOneWidget);
    expect(find.text(t.onboarding.safety.completeProfile), findsOneWidget);
  });

  testWidgets('submits and navigates to home with valid data', (WidgetTester tester) async {
    final container = await createContainerWithCache(additionalOverrides: [
      onboardingRepositoryProvider.overrideWithValue(fakeOnboardingRepository),
    ]);
    addTearDown(container.dispose);
    container.read(onboardingProvider.notifier).setUserProfile(
      UserProfile(id: 'u1', email: 'a@b.com', displayName: 'Alice'),
    );
    container.read(onboardingProvider.notifier).setDog(
        Dog(id: 'd1', ownerId: 'u1', name: 'Buddy'),
    );

    final router = GoRouter(
      initialLocation: '/test',
      routes: [
        GoRoute(path: '/test', builder: (_, __) => const SafetyBoundariesScreen()),
        GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('Home'))),
      ],
    );

    LocaleSettings.setLocaleSync(AppLocale.en);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(t.onboarding.safety.okToShare));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.onboarding.safety.completeProfile));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('uploads photo and persists returned URL to state', (WidgetTester tester) async {
    final repo = FakeOnboardingRepository();
    final container = await createContainerWithCache(
      additionalOverrides: [
        onboardingRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    container.read(onboardingProvider.notifier).setUserProfile(
      UserProfile(id: 'u1', email: 'a@b.com', displayName: 'Alice'),
    );
    container.read(onboardingProvider.notifier).setDog(
        Dog(id: 'd1', ownerId: 'u1', name: 'Buddy'),
    );
    container.read(onboardingProvider.notifier).setLocalPhotoPath('/tmp/photo.png');

    final router = GoRouter(
      initialLocation: '/test',
      routes: [
        GoRoute(path: '/test', builder: (_, __) => const SafetyBoundariesScreen()),
        GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('Home'))),
      ],
    );

    LocaleSettings.setLocaleSync(AppLocale.en);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(t.onboarding.safety.okToShare));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.onboarding.safety.completeProfile));
    await tester.pumpAndSettle();

    expect(repo.uploadCallCount, 1);
    expect(container.read(onboardingProvider).photoUrl, 'https://example.com/uploaded.jpg');
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('shows error message when submission fails', (WidgetTester tester) async {
    final repo = FakeOnboardingRepository()..shouldFail = true;
    final container = await createContainerWithCache(
      additionalOverrides: [
        onboardingRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    container.read(onboardingProvider.notifier).setUserProfile(
      UserProfile(id: 'u1', email: 'a@b.com', displayName: 'Alice'),
    );
    container.read(onboardingProvider.notifier).setDog(
        Dog(id: 'd1', ownerId: 'u1', name: 'Buddy'),
    );

    final router = GoRouter(
      initialLocation: '/test',
      routes: [
        GoRoute(path: '/test', builder: (_, __) => const SafetyBoundariesScreen()),
        GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('Home'))),
      ],
    );

    LocaleSettings.setLocaleSync(AppLocale.en);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(t.onboarding.safety.okToShare));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.onboarding.safety.completeProfile));
    await tester.pumpAndSettle();

    expect(find.text(t.onboarding.safety.error), findsOneWidget);
  });
}
