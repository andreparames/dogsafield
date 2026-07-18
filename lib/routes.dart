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

    print('[REDIRECT] path=$location authed=$authed');

    if (!authed && location != '/onboarding/welcome' && location != '/onboarding/reviewer-login') {
      print('[REDIRECT] -> /onboarding/welcome (not authed)');
      return '/onboarding/welcome';
    }
    if (suspendedNotifier.value && location != '/account/suspended') {
      print('[REDIRECT] -> /account/suspended');
      return '/account/suspended';
    }

    if (authed) {
      container.read(onboardingAutoInitProvider);

      if (isCheckingExistingProfileNotifier.value) {
        print('[REDIRECT] checking existing profile, loc=$location');
        if (location != '/splash') {
          print('[REDIRECT] -> /splash');
          return '/splash';
        }
        print('[REDIRECT] already on splash, staying');
        return null;
      }

      if (profileCheckFailedNotifier.value) {
        print('[REDIRECT] profile check failed');
        if (location != '/splash') {
          print('[REDIRECT] -> /splash');
          return '/splash';
        }
        return null;
      }

      final onboarding = container.read(onboardingProvider);
      print('[REDIRECT] step=${onboarding.step} hasProfile=${onboarding.userProfile != null}');

      final profile = onboarding.userProfile;
      if (onboarding.step == OnboardingStep.complete) {
        if (profile != null && !profile.hasSeenFieldIntro) {
          if (location != '/field/intro') {
            print('[REDIRECT] -> /field/intro (intro needed)');
            return '/field/intro';
          }
          return null;
        }
        if (location == '/splash' || location == '/onboarding/welcome') {
          print('[REDIRECT] -> / (field map)');
          return '/';
        }
        print('[REDIRECT] allowing navigation to $location');
        return null;
      }

      if (!location.startsWith('/onboarding/')) {
        print('[REDIRECT] -> /onboarding/welcome (incomplete)');
        return '/onboarding/welcome';
      }
      if (location == '/onboarding/welcome') {
        print('[REDIRECT] -> /onboarding/photo');
        return '/onboarding/photo';
      }
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
