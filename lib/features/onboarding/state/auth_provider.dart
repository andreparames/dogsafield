import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_service.dart';
import '../data/onboarding_repository.dart';
import 'onboarding_state.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final signingInProvider = StateProvider<bool>((ref) => false);

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(Supabase.instance.client);
});

final onboardingAutoInitProvider = Provider<void>((ref) {
  final auth = ref.read(authServiceProvider);

  ref.listen(authServiceProvider, (prev, next) {
    if (!next.isAuthenticated) return;
    final user = next.currentUser;
    if (user == null) return;
    final notifier = ref.read(onboardingProvider.notifier);
    if (ref.read(onboardingProvider).userProfile == null) {
      notifier.initFromAuth(
        user.id,
        user.email ?? '',
        user.userMetadata?['full_name'] as String?,
      );
    }
  });

  if (!auth.isAuthenticated) return;
  final user = auth.currentUser;
  if (user == null) return;
  Timer.run(() {
    final notifier = ref.read(onboardingProvider.notifier);
    if (ref.read(onboardingProvider).userProfile == null) {
      notifier.initFromAuth(
        user.id,
        user.email ?? '',
        user.userMetadata?['full_name'] as String?,
      );
    }
  });
});
