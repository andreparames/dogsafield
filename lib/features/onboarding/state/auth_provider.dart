import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/providers.dart';
import '../../../shared/models/user_profile.dart';
import '../data/auth_service.dart';
import '../data/onboarding_repository.dart';
import 'onboarding_state.dart';

final authRefreshNotifier = ValueNotifier(0);
final suspendedNotifier = ValueNotifier(false);
final isCheckingExistingProfileNotifier = ValueNotifier(false);
final profileCheckFailedNotifier = ValueNotifier(false);
final hasCachedFullProfileNotifier = ValueNotifier(false);

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final signingInProvider = NotifierProvider<SigningInNotifier, bool>(
    SigningInNotifier.new);

class SigningInNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

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
  hasCachedFullProfileNotifier.value = false;
  profileCheckFailedNotifier.value = false;
  print('[AUTH] _checkExistingProfile started');
  try {
    final user = ref.read(authServiceProvider).currentUser;
    print('[AUTH] currentUser=${user?.id}');
    if (user == null) {
      print('[AUTH] no user, returning');
      return;
    }

    final repo = ref.read(onboardingRepositoryProvider);
    UserProfile? existing;
    try {
      print('[AUTH] fetching profile from Supabase...');
      existing = await repo.fetchProfile(user.id);
      print('[AUTH] Supabase profile result: ${existing != null}');
    } catch (e) {
      print('[AUTH] fetchProfile error: $e');
      bool? confirmedNotSuspended;
      try {
        print('[AUTH] checking suspension status...');
        final result = await Supabase.instance.client
            .from('profiles')
            .select('is_suspended')
            .eq('id', user.id)
            .limit(1)
            .single();
        final isSuspended = result['is_suspended'] as bool?;
        print('[AUTH] suspension check: suspended=$isSuspended');
        if (isSuspended == true) {
          suspendedNotifier.value = true;
          return;
        }
        confirmedNotSuspended = isSuspended == false;
      } catch (e2) {
        print('[AUTH] suspension check error: $e2');
      }

      if (confirmedNotSuspended != true) {
        print('[AUTH] could not confirm not suspended -> profileCheckFailed');
        profileCheckFailedNotifier.value = true;
        return;
      }

      print('[AUTH] trying cache...');
      final cache = ref.read(localCacheServiceProvider);
      existing = await cache.getProfile(user.id);
      print('[AUTH] cache profile result: ${existing != null}');
      if (existing == null) {
        print('[AUTH] no cached profile, returning');
        return;
      }
    }

    if (existing == null) {
      print('[AUTH] existing is null, returning');
      return;
    }

    if (existing.isSuspended) {
      print('[AUTH] user is suspended');
      suspendedNotifier.value = true;
      return;
    }

    print('[AUTH] setting user profile and completing onboarding');
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setUserProfile(existing);
    notifier.setStep(OnboardingStep.complete);
  } finally {
    print('[AUTH] _checkExistingProfile done');
    isCheckingExistingProfileNotifier.value = false;
    authRefreshNotifier.value++;
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

  isCheckingExistingProfileNotifier.value = true;

  Timer.run(() {
    if (disposed) return;
    _initFromUser(ref, user);
    _checkExistingProfile(ref);
  });
});
