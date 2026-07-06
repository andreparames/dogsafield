import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Widget createTestApp(Widget child) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(path: '/test', builder: (_, __) => child),
      GoRoute(path: '/onboarding/welcome', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/onboarding/photo', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/onboarding/profile', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/onboarding/icebreaker', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/onboarding/safety', builder: (_, __) => const SizedBox()),
      GoRoute(path: '/', builder: (_, __) => const SizedBox()),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(routerConfig: router),
  );
}
