import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;
import 'package:dogsafield/features/onboarding/presentation/safety_boundaries_screen.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/features/onboarding/state/onboarding_state.dart';
import 'package:dogsafield/shared/models/dog.dart';
import 'package:dogsafield/shared/models/user_profile.dart';
import '../helpers/test_utils.dart';
import 'package:dogsafield/i18n/strings.g.dart';

void main() {
  group('initFromAuth', () {
    test('sets userProfile when null', () {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          onboardingRepositoryProvider.overrideWithValue(fakeOnboardingRepository),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(onboardingProvider).userProfile, isNull);

      container.read(onboardingProvider.notifier).initFromAuth(
        'auth-uuid',
        'test@example.com',
        'Test User',
      );

      final profile = container.read(onboardingProvider).userProfile;
      expect(profile, isNotNull);
      expect(profile!.id, 'auth-uuid');
      expect(profile.email, 'test@example.com');
      expect(profile.displayName, 'Test User');
    });

    test('does not overwrite existing userProfile', () {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          onboardingRepositoryProvider.overrideWithValue(fakeOnboardingRepository),
        ],
      );
      addTearDown(container.dispose);

      container.read(onboardingProvider.notifier).setUserProfile(
        UserProfile(id: 'existing', email: 'old@test.com'),
      );

      container.read(onboardingProvider.notifier).initFromAuth(
        'new-id',
        'new@test.com',
        null,
      );

      expect(container.read(onboardingProvider).userProfile!.id, 'existing');
    });
  });

  group('SafetyBoundariesScreen submission', () {
    testWidgets('shows error when userProfile is null', (WidgetTester tester) async {
      final container = await createContainerWithCache(additionalOverrides: [
        onboardingRepositoryProvider.overrideWithValue(fakeOnboardingRepository),
      ]);
      addTearDown(container.dispose);
      LocaleSettings.setLocaleSync(AppLocale.en);
      container.read(onboardingProvider.notifier).setDog(
        Dog(id: 'd1', ownerId: 'u1', name: 'Buddy'),
      );
      container.read(onboardingProvider.notifier).setBiometricsVerified(true);

      final router = goRouterForTest(
        route: '/test',
        screen: const SafetyBoundariesScreen(),
      );

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

      expect(
        find.text(t.onboarding.safety.error),
        findsOneWidget,
      );
    });

    testWidgets('succeeds when userProfile is set via initFromAuth', (WidgetTester tester) async {
      final container = await createContainerWithCache(additionalOverrides: [
        onboardingRepositoryProvider.overrideWithValue(fakeOnboardingRepository),
      ]);
      addTearDown(container.dispose);
      LocaleSettings.setLocaleSync(AppLocale.en);
      container.read(onboardingProvider.notifier).initFromAuth(
        'u1',
        'a@b.com',
        'Alice',
      );
      container.read(onboardingProvider.notifier).setDog(
        Dog(id: 'd1', ownerId: 'u1', name: 'Buddy'),
      );

      final router = goRouterForTest(
        route: '/test',
        screen: const SafetyBoundariesScreen(),
      );

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

      expect(find.text(t.onboarding.safety.error), findsNothing);
    });
  });

  group('onboardingAutoInitProvider', () {
    testWidgets('activates from redirect and sets userProfile via Timer.run without build-phase error',
        (WidgetTester tester) async {
      final authService = FakeAuthService();
      authService.setAuthenticated(
        value: true,
        user: User(
          id: 'test-uuid',
          appMetadata: {},
          userMetadata: {'full_name': 'Test'},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
          email: 't@t.com',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(authService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          onboardingRepositoryProvider.overrideWithValue(fakeOnboardingRepository),
        ],
      );
      addTearDown(container.dispose);
      LocaleSettings.setLocaleSync(AppLocale.en);

      final router = GoRouter(
        initialLocation: '/onboarding/welcome',
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final auth = container.read(authServiceProvider);
          final authed = auth.isAuthenticated;
          final location = state.uri.toString();

          if (!authed && location != '/onboarding/welcome') return '/onboarding/welcome';
          if (authed && location.startsWith('/onboarding/')) {
            container.read(onboardingAutoInitProvider);
            final onboarding = container.read(onboardingProvider);
            if (onboarding.step == OnboardingStep.complete) return '/';
            if (location == '/onboarding/welcome') return '/onboarding/photo';
          }
          return null;
        },
        routes: [
          GoRoute(path: '/onboarding/welcome', builder: (_, __) => const SizedBox()),
          GoRoute(path: '/onboarding/photo', builder: (_, __) => const SizedBox()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TranslationProvider(
            child: MaterialApp.router(routerConfig: router),
          ),
        ),
      );

      expect(router.state.matchedLocation, '/onboarding/photo');

      await tester.pumpAndSettle();

      expect(container.read(onboardingProvider).userProfile, isNotNull);
      expect(container.read(onboardingProvider).userProfile!.id, 'test-uuid');
    });

    testWidgets('sets step to complete when existing profile found in DB',
        (WidgetTester tester) async {
      addTearDown(() => fakeOnboardingRepository.existingProfile = null);
      fakeOnboardingRepository.existingProfile = UserProfile(
        id: 'existing-uuid',
        email: 'existing@test.com',
        displayName: 'Existing User',
      );

      final authService = FakeAuthService();
      authService.setAuthenticated(
        value: true,
        user: User(
          id: 'existing-uuid',
          appMetadata: {},
          userMetadata: null,
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(authService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          onboardingRepositoryProvider.overrideWithValue(fakeOnboardingRepository),
        ],
      );
      addTearDown(container.dispose);
      LocaleSettings.setLocaleSync(AppLocale.en);

      final router = GoRouter(
        refreshListenable: authRefreshNotifier,
        initialLocation: '/onboarding/welcome',
        redirect: (context, state) {
          final container = ProviderScope.containerOf(context);
          final auth = container.read(authServiceProvider);
          final authed = auth.isAuthenticated;
          final location = state.uri.toString();

          if (!authed && location != '/onboarding/welcome') return '/onboarding/welcome';
          if (authed && location.startsWith('/onboarding/')) {
            container.read(onboardingAutoInitProvider);
            final onboarding = container.read(onboardingProvider);
            if (onboarding.step == OnboardingStep.complete) return '/';
            if (location == '/onboarding/welcome') return '/onboarding/photo';
          }
          return null;
        },
        routes: [
          GoRoute(path: '/onboarding/welcome', builder: (_, __) => const SizedBox()),
          GoRoute(path: '/onboarding/photo', builder: (_, __) => const SizedBox()),
          GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('Home'))),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TranslationProvider(
            child: MaterialApp.router(routerConfig: router),
          ),
        ),
      );

      await tester.pump(); // Timer.run fires -> _checkExistingProfile -> bumps authRefreshNotifier
      await tester.pump(); // redirect re-evaluates -> step=complete -> route to /
      await tester.pumpAndSettle();

      expect(container.read(onboardingProvider).step, OnboardingStep.complete);
      expect(router.state.matchedLocation, '/');
    });
  });
}

GoRouter goRouterForTest({
  required String route,
  required Widget screen,
}) {
  return GoRouter(
    initialLocation: route,
    routes: [
      GoRoute(path: route, builder: (_, __) => screen),
      GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('Home'))),
    ],
  );
}
