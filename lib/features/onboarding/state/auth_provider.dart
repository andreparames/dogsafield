import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_service.dart';
import '../data/onboarding_repository.dart';
import 'onboarding_state.dart';

final authRefreshNotifier = ValueNotifier(0);
final suspendedNotifier = ValueNotifier(false);

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

void _initFromUser(Ref ref, User user) {
  final notifier = ref.read(onboardingProvider.notifier);
  if (ref.read(onboardingProvider).userProfile != null) return;
  notifier.initFromAuth(
    user.id,
    user.email ?? '',
    user.userMetadata?['full_name'] as String?,
  );
}

Future<void> _checkExistingProfile(Ref ref) async {
  final user = ref.read(authServiceProvider).currentUser;
  if (user == null) return;
  final repo = ref.read(onboardingRepositoryProvider);
  try {
    final existing = await repo.fetchProfile(user.id);
    if (existing == null) return;
    if (existing.isSuspended) {
      suspendedNotifier.value = true;
      return;
    }
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setUserProfile(existing);
    notifier.setStep(OnboardingStep.complete);
    authRefreshNotifier.value++;
  } catch (_) {
  }
}

final onboardingAutoInitProvider = Provider<void>((ref) {
  final auth = ref.read(authServiceProvider);

  var disposed = false;
  ref.onDispose(() => disposed = true);

  ref.listen<AsyncValue<AuthState>>(authStateProvider, (_, next) {
    next.whenData((authState) {
      if (authState.session case final session?) {
        _initFromUser(ref, session.user);
      }
    });
  });

  if (!auth.isAuthenticated) return;
  final user = auth.currentUser;
  if (user == null) return;
  Timer.run(() {
    if (disposed) return;
    _initFromUser(ref, user);
    _checkExistingProfile(ref);
  });
});
