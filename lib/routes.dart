import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/onboarding/routes.dart';
import 'features/onboarding/state/auth_provider.dart';
import 'features/onboarding/state/onboarding_state.dart';
import 'features/field_map/presentation/field_map_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/account/presentation/suspend_screen.dart';
import 'features/account/routes.dart';
import 'features/field_map/routes.dart';
import 'features/hosting/routes.dart';
import 'features/info/routes.dart';
import 'features/verification_loop/routes.dart';
import 'features/connections/routes.dart';
import 'features/messaging/routes.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

final _appRouter = GoRouter(
  navigatorKey: _navigatorKey,
  refreshListenable: authRefreshNotifier,
  initialLocation: '/onboarding/welcome',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final auth = container.read(authServiceProvider);
    final authed = auth.isAuthenticated;
    final location = state.uri.path;

    if (!authed && location != '/onboarding/welcome' && location != '/onboarding/reviewer-login') return '/onboarding/welcome';
    if (suspendedNotifier.value && location != '/account/suspended') return '/account/suspended';

    if (authed) {
      container.read(onboardingAutoInitProvider);

      if (isCheckingExistingProfileNotifier.value) {
        if (location != '/splash') return '/splash';
        return null;
      }

      if (profileCheckFailedNotifier.value) {
        if (location != '/splash') return '/splash';
        return null;
      }

      final onboarding = container.read(onboardingProvider);

      final profile = onboarding.userProfile;
      if (onboarding.step == OnboardingStep.complete) {
        if (profile != null && !profile.hasSeenFieldIntro) {
          if (location != '/field/intro') return '/field/intro';
          return null;
        }
        if (location != '/') return '/';
        return null;
      }

      if (!location.startsWith('/onboarding/')) return '/onboarding/welcome';
      if (location == '/onboarding/welcome') return '/onboarding/photo';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const FieldMapScreen(),
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/account/suspended',
      builder: (context, state) => const SuspendScreen(),
    ),
    ...onboardingRoutes,
    ...accountRoutes,
    ...fieldMapRoutes,
    ...hostingRoutes,
    ...infoRoutes,
    ...verificationLoopRoutes,
    ...connectionsRoutes,
    ...messagingRoutes,
  ],
);

GoRouter get appRouter => _appRouter;

void navigateToEvent(String eventId) {
  _navigatorKey.currentContext?.go('/field/gathering/$eventId');
}
