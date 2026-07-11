import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../onboarding/state/auth_provider.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../data/account_repository.dart';
import '../../../shared/models/dog.dart';
import '../../../shared/models/user_profile.dart';

class AccountDetail {
  final UserProfile profile;
  final Dog? dog;

  const AccountDetail({required this.profile, this.dog});
}

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(Supabase.instance.client);
});

final accountDetailProvider = FutureProvider<AccountDetail>((ref) async {
  final repo = ref.watch(accountRepositoryProvider);
  final auth = ref.watch(authServiceProvider);
  final user = auth.currentUser;
  if (user == null) throw Exception('Not authenticated');
  final profile = await repo.fetchProfile(user.id);
  final dog = await repo.fetchDog(user.id);
  return AccountDetail(profile: profile, dog: dog);
});

sealed class AccountActionState {
  const AccountActionState();
}

class AccountActionIdle extends AccountActionState {
  const AccountActionIdle();
}

class AccountActionLoading extends AccountActionState {
  const AccountActionLoading();
}

class AccountActionSuccess extends AccountActionState {
  const AccountActionSuccess();
}

class AccountActionError extends AccountActionState {
  final String message;
  const AccountActionError(this.message);
}

class AccountActionNotifier extends Notifier<AccountActionState> {
  @override
  AccountActionState build() => const AccountActionIdle();

  Future<void> suspendAccount() async {
    if (state is AccountActionLoading) return;
    state = const AccountActionLoading();
    try {
      final repo = ref.read(accountRepositoryProvider);
      await repo.suspendAccount();
      state = const AccountActionSuccess();
    } catch (e) {
      state = AccountActionError(t.errors.failedToSuspend);
    }
  }

  Future<void> deleteAccount() async {
    if (state is AccountActionLoading) return;
    state = const AccountActionLoading();
    try {
      final repo = ref.read(accountRepositoryProvider);
      await repo.deleteAccount();
      state = const AccountActionSuccess();
    } catch (e) {
      state = AccountActionError(t.errors.failedToDelete);
    }
  }

  void reset() => state = const AccountActionIdle();
}

final accountActionProvider =
    NotifierProvider<AccountActionNotifier, AccountActionState>(
        AccountActionNotifier.new);
