import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dogsafield/features/onboarding/data/auth_service.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';

class FakeAuthService extends AuthService {
  FakeAuthService() : super.test();

  @override
  User? get currentUser => null;

  @override
  bool get isAuthenticated => false;

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

final fakeAuthService = FakeAuthService();

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
    overrides: [
      authServiceProvider.overrideWithValue(fakeAuthService),
      authStateProvider.overrideWith((ref) => Stream.empty()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}
