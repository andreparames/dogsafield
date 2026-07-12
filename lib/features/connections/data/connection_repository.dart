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
          .or('and(user_id_a.eq.${user.id},user_id_b.eq.$targetUserId),and(user_id_a.eq.$targetUserId,user_id_b.eq.${user.id})');
      return;
    }

    // Remove any existing row in the opposite direction to prevent duplicate
    // packmate/block rows for the same pair.
    await _client.from('connections')
        .delete()
        .eq('user_id_a', targetUserId)
        .eq('user_id_b', user.id);

    await _client.from('connections').upsert({
      'user_id_a': user.id,
      'user_id_b': targetUserId,
      'block_tier': tier,
      'are_packmates': false,
      'report_reason': reportReason,
    }, onConflict: 'user_id_a, user_id_b');

    if (tier == 3 && reportReason != null) {
      await _client.from('reports').insert({
        'reporter_id': user.id,
        'reported_id': targetUserId,
        'reason': reportReason,
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchBlockedUsers() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client.from('connections')
        .select()
        .eq('user_id_a', user.id)
        .gt('block_tier', 0);

    if (response.isEmpty) return [];

    final userIds = response.map((r) => r['user_id_b'] as String).toList();
    final profiles = await _client.from('profiles_public')
        .select()
        .inFilter('id', userIds);

    final profileMap = {for (final p in profiles) p['id'] as String: p};

    for (final row in response) {
      final profile = profileMap[row['user_id_b']];
      if (profile != null) {
        row['profiles'] = profile;
      }
    }
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