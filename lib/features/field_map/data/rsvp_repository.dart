import 'package:supabase_flutter/supabase_flutter.dart';

class RsvpRepository {
  final SupabaseClient _client;

  RsvpRepository(this._client);

  Future<Set<String>> fetchMyRsvpIds() async {
    final user = _client.auth.currentUser;
    if (user == null) return {};

    final rows = await _client
        .from('attendance')
        .select('event_id')
        .eq('user_id', user.id)
        .eq('status', 'confirmed');

    return rows.map((r) => r['event_id'] as String).toSet();
  }

  Future<void> rsvpToEvent(String eventId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _client.from('attendance').insert({
      'event_id': eventId,
      'user_id': user.id,
      'status': 'confirmed',
    });
  }

  Future<void> cancelRsvp(String eventId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _client
        .from('attendance')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', user.id);
  }

  Future<bool> hasRsvp(String eventId) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final response = await _client
        .from('attendance')
        .select('id')
        .eq('event_id', eventId)
        .eq('user_id', user.id)
        .maybeSingle();

    return response != null;
  }
}
