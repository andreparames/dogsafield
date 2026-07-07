import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/dog.dart';
import '../../../shared/models/user_profile.dart';

class AccountRepository {
  final SupabaseClient _client;

  AccountRepository(this._client);

  Future<UserProfile> fetchProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return _rowToProfile(response);
  }

  Future<Dog?> fetchDog(String ownerId) async {
    final response = await _client
        .from('dogs')
        .select()
        .eq('owner_id', ownerId)
        .limit(1);

    if (response.isEmpty) return null;
    return _rowToDog(response.first);
  }

  Future<void> suspendAccount() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    await _client
        .from('profiles')
        .update({'is_suspended': true})
        .eq('id', user.id);
    await _client.auth.signOut();
  }

  Future<void> reactivateAccount() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    await _client
        .from('profiles')
        .update({'is_suspended': false})
        .eq('id', user.id);
  }

  Future<void> deleteAccount() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    await _client.rpc('delete_my_account');
    try {
      await _client.auth.signOut();
    } catch (_) {
    }
  }

  UserProfile _rowToProfile(Map<String, dynamic> row) {
    return UserProfile(
      id: row['id'] as String,
      email: row['email'] as String,
      displayName: row['display_name'] as String?,
      photoUrl: row['photo_url'] as String?,
      isVerified: row['is_verified'] as bool? ?? false,
      trialRsvpsUsed: row['trial_rsvps_used'] as int? ?? 0,
      isFoundingPack: row['is_founding_pack'] as bool? ?? false,
      isSuspended: row['is_suspended'] as bool? ?? false,
      treatPolicy: row['treat_policy'] != null
          ? TreatPolicy.values.firstWhere((e) => e.name == row['treat_policy'])
          : null,
    );
  }

  Dog _rowToDog(Map<String, dynamic> row) {
    return Dog(
      id: row['id'] as String,
      name: row['name'] as String,
      age: row['age'] as int?,
      breed: row['breed'] as String?,
      vibe: row['vibe'] != null
          ? SocialVibe.values.firstWhere((e) => e.name == row['vibe'])
          : null,
      icebreakerAnswer: row['icebreaker_answer'] as String?,
    );
  }
}
