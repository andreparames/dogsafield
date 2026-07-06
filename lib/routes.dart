import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/onboarding/routes.dart';
import 'features/onboarding/state/auth_provider.dart';
import 'features/onboarding/state/onboarding_state.dart';
import 'features/field_map/presentation/field_map_screen.dart';
import 'features/account/routes.dart';
import 'features/field_map/routes.dart';
import 'features/hosting/routes.dart';
import 'features/verification_loop/routes.dart';
import 'features/connections/routes.dart';
import 'features/messaging/routes.dart';

final authRefreshNotifier = ValueNotifier(0);

final _appRouter = GoRouter(
  refreshListenable: authRefreshNotifier,
  initialLocation: '/onboarding/welcome',
  redirect: (context, state) {
    final auth = ProviderScope.containerOf(context).read(authServiceProvider);
    final authed = auth.isAuthenticated;
    final location = state.uri.toString();

    if (!authed && location != '/onboarding/welcome') return '/onboarding/welcome';
    if (authed && location == '/onboarding/welcome') {
      final onboarding = ProviderScope.containerOf(context).read(onboardingProvider);
      if (onboarding.step == OnboardingStep.complete) return '/';
      return '/onboarding/photo';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const FieldMapScreen(),
    ),
    ...onboardingRoutes,
    ...accountRoutes,
    ...fieldMapRoutes,
    ...hostingRoutes,
    ...verificationLoopRoutes,
    ...connectionsRoutes,
    ...messagingRoutes,
  ],
);

GoRouter get appRouter => _appRouter;
