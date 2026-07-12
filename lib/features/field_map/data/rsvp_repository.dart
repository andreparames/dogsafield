import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/connectivity_service.dart';
import '../../../core/database/local_cache_service.dart';
import '../../../shared/models/attendance_status.dart';

class RsvpRepository {
  final SupabaseClient _client;
  final LocalCacheService? _cache;
  final ConnectivityService? _connectivity;

  RsvpRepository(this._client, [this._cache, this._connectivity]);

  Future<Set<String>> fetchMyRsvpIds() async {
    final user = _client.auth.currentUser;
    if (user == null) return {};

    if (_cache != null && _connectivity != null) {
      final online = await _connectivity.isOnline;
      if (!online) {
        return _cache.getMyRsvpIds(user.id);
      }
    }

    final rows = await _client
        .from('attendance')
        .select('event_id, user_id, status')
        .eq('user_id', user.id)
        .eq('status', 'confirmed');

    final ids = rows.map((r) => r['event_id'] as String).toSet();

    if (_cache != null) {
      for (final row in rows) {
        final s = row['status'] as String;
        await _cache.upsertAttendance(
          row['event_id'] as String,
          row['user_id'] as String,
          AttendanceStatus.values.firstWhere((e) => e.name == s),
        );
      }
    }

    return ids;
  }

  Future<void> rsvpToEvent(String eventId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _client.from('attendance').insert({
      'event_id': eventId,
      'user_id': user.id,
      'status': 'confirmed',
    });

    if (_cache != null) {
      await _cache.upsertAttendance(eventId, user.id, AttendanceStatus.confirmed);
    }
  }

  Future<void> cancelRsvp(String eventId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _client
        .from('attendance')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', user.id);

    if (_cache != null) {
      await _cache.deleteAttendance(eventId, user.id);
    }
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
