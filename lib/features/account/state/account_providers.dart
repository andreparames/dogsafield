import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../onboarding/state/auth_provider.dart';
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
