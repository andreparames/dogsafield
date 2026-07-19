import 'package:supabase_flutter/supabase_flutter.dart';

class WaitlistEntry {
  final String id;
  final String walkId;
  final String userId;
  final String status;
  final DateTime? confirmedAt;
  final DateTime createdAt;

  const WaitlistEntry({
    required this.id,
    required this.walkId,
    required this.userId,
    required this.status,
    this.confirmedAt,
    required this.createdAt,
  });
}

class WaitlistRepository {
  final SupabaseClient _client;

  WaitlistRepository(this._client);

  Future<WaitlistEntry> joinWaitlist(String walkId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client.from('waitlist').insert({
      'walk_id': walkId,
      'user_id': user.id,
      'status': 'waiting',
    }).select().single();

    return _rowToEntry(response);
  }

  Future<void> confirmSpot(String walkId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client.from('waitlist').update({
      'status': 'confirmed',
      'confirmed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('walk_id', walkId).eq('user_id', user.id).eq('status', 'waiting').select();

    if (response.isEmpty) throw Exception('No waiting entry found to confirm');
  }

  Future<void> leaveWaitlist(String walkId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _client.from('waitlist').delete()
        .eq('walk_id', walkId)
        .eq('user_id', user.id);
  }

  Future<WaitlistEntry?> fetchMyStatus(String walkId) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client.from('waitlist').select()
        .eq('walk_id', walkId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (response == null) return null;
    return _rowToEntry(response);
  }

  Future<Map<String, int>> fetchCounts(String walkId) async {
    final rows = await _client.from('waitlist').select('status')
        .eq('walk_id', walkId);

    int waiting = 0, confirmed = 0, released = 0;
    for (final r in rows) {
      switch (r['status'] as String) {
        case 'waiting': waiting++; break;
        case 'confirmed': confirmed++; break;
        case 'released': released++; break;
      }
    }
    return {
      'waiting': waiting,
      'confirmed': confirmed,
      'released': released,
    };
  }

  WaitlistEntry _rowToEntry(Map<String, dynamic> row) {
    return WaitlistEntry(
      id: row['id'] as String,
      walkId: row['walk_id'] as String,
      userId: row['user_id'] as String,
      status: row['status'] as String,
      confirmedAt: row['confirmed_at'] != null
          ? DateTime.parse(row['confirmed_at'] as String)
          : null,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
