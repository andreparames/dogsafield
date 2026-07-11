import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PackmateSyncResult {
  final Map<String, Set<String>> matches;
  final int failedCount;

  const PackmateSyncResult({required this.matches, required this.failedCount});
}

class VerificationRepository {
  final SupabaseClient _client;

  VerificationRepository(this._client);

  Future<void> submitRollCallEntries(String eventId, List<String> observedIds) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final rows = observedIds.map((id) => {
      'event_id': eventId,
      'observer_id': user.id,
      'observed_id': id,
    }).toList();

    await _client.from('roll_call_entries').upsert(
      rows,
      onConflict: 'event_id, observer_id, observed_id',
      ignoreDuplicates: true,
    );
  }

  Future<List<Map<String, dynamic>>> fetchMyEntries(String eventId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    return _client.from('roll_call_entries')
        .select()
        .eq('event_id', eventId)
        .eq('observer_id', user.id);
  }

  Future<List<Map<String, dynamic>>> fetchAllEntries(String eventId) async {
    return _client.from('roll_call_entries')
        .select()
        .eq('event_id', eventId);
  }

  Future<Map<String, Set<String>>> resolveMatches(String eventId) async {
    final entries = await fetchAllEntries(eventId);

    final observedBy = <String, Set<String>>{};
    final observedWho = <String, Set<String>>{};

    for (final entry in entries) {
      final observerId = entry['observer_id'] as String;
      final observedId = entry['observed_id'] as String;

      observedBy.putIfAbsent(observerId, () => {}).add(observedId);
      observedWho.putIfAbsent(observedId, () => {}).add(observerId);
    }

    final matches = <String, Set<String>>{};
    for (final entry in entries) {
      final a = entry['observer_id'] as String;
      final b = entry['observed_id'] as String;
      if (observedBy[b]?.contains(a) == true) {
        matches.putIfAbsent(a, () => {}).add(b);
        matches.putIfAbsent(b, () => {}).add(a);
      }
    }

    return matches;
  }

  Future<void> setPackmates(String userIdA, String userIdB) async {
    final a = userIdA.compareTo(userIdB) < 0 ? userIdA : userIdB;
    final b = userIdA.compareTo(userIdB) < 0 ? userIdB : userIdA;
    await _client.from('connections').upsert({
      'user_id_a': a,
      'user_id_b': b,
      'are_packmates': true,
      'block_tier': 0,
    }, onConflict: 'user_id_a, user_id_b');
  }

  Future<PackmateSyncResult> resolveAndSaveMatches(String eventId) async {
    final matches = await resolveMatches(eventId);
    final processedKeys = <String>{};
    final failedKeys = <String>{};

    for (final entry in matches.entries) {
      for (final matchedId in entry.value) {
        final key = entry.key.compareTo(matchedId) < 0
            ? '${entry.key}:$matchedId'
            : '$matchedId:${entry.key}';
        if (!processedKeys.add(key)) continue;
        try {
          await setPackmates(entry.key, matchedId);
        } catch (e) {
          failedKeys.add(key);
          debugPrint('Failed to save packmate connection ($key): $e');
        }
      }
    }

    return PackmateSyncResult(matches: matches, failedCount: failedKeys.length);
  }
}
