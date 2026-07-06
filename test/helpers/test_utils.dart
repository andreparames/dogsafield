import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dogsafield/features/onboarding/data/auth_service.dart';
import 'package:dogsafield/features/onboarding/data/onboarding_repository.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/shared/models/dog.dart';
import 'package:dogsafield/shared/models/user_profile.dart';

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

class FakeOnboardingRepository implements OnboardingRepository {
  @override
  Future<String?> uploadPhoto(String path) async => 'https://example.com/uploaded.jpg';

  @override
  Future<UserProfile> createProfile(UserProfile profile) async => profile;

  @override
  Future<Dog> createDogProfile(Dog dog) async => dog;
}

final fakeAuthService = FakeAuthService();
final fakeOnboardingRepository = FakeOnboardingRepository();

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
      onboardingRepositoryProvider.overrideWithValue(fakeOnboardingRepository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}
