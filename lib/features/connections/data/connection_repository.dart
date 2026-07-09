import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectionRepository {
  final SupabaseClient _client;

  ConnectionRepository(this._client);

  Future<void> setBlockTier(String targetUserId, int tier, {String? reportReason}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    if (tier == 0) {
      await _client.from('connections')
          .delete()
          .eq('user_id_a', user.id)
          .eq('user_id_b', targetUserId);
      return;
    }

    await _client.from('connections').upsert({
      'user_id_a': user.id,
      'user_id_b': targetUserId,
      'block_tier': tier,
      'are_packmates': false,
      'report_reason': reportReason,
    }, onConflict: 'user_id_a, user_id_b');
  }

  Future<List<Map<String, dynamic>>> fetchBlockedUsers() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client.from('connections')
        .select('''
          *,
          profiles!user_id_b (
            id,
            email,
            display_name,
            photo_url,
            is_verified,
            trial_rsvps_used,
            is_founding_pack,
            treat_policy
          )
        ''')
        .eq('user_id_a', user.id)
        .gt('block_tier', 0);

    return response;
  }

  Future<List<Map<String, dynamic>>> fetchBlockers() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client.from('connections')
        .select()
        .eq('user_id_b', user.id)
        .gt('block_tier', 0);

    return response;
  }
}