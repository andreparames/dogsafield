import 'dart:convert';
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

    final response = await _client.rpc('join_waitlist', params: {
      'p_walk_id': walkId,
    }).single();

    return _rpcRowToEntry(response);
  }

  Future<void> confirmSpot(String walkId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _client.rpc('confirm_waitlist_spot', params: {
      'p_walk_id': walkId,
    });
  }

  Future<void> leaveWaitlist(String walkId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _client.rpc('leave_waitlist', params: {
      'p_walk_id': walkId,
    });
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
    final response = await _client.rpc('get_waitlist_counts', params: {
      'p_walk_id': walkId,
    }).single();

    return {
      'waiting': (response['waiting'] as num).toInt(),
      'confirmed': (response['confirmed'] as num).toInt(),
      'released': (response['released'] as num).toInt(),
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

  WaitlistEntry _rpcRowToEntry(dynamic row) {
    if (row is Map<String, dynamic>) return _rowToEntry(row);
    if (row is String) return _rowToEntry(jsonDecode(row) as Map<String, dynamic>);
    throw Exception('Unexpected RPC response type: ${row.runtimeType}');
  }
}
