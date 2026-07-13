import 'dart:io';
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

  Future<List<Dog>> fetchDogs(String ownerId) async {
    final response = await _client
        .from('dogs')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at');
    return response.map((row) => _rowToDog(row)).toList();
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> fields) async {
    await _client.from('profiles').update(fields).eq('id', userId);
  }

  Future<void> updateDog(String dogId, Map<String, dynamic> fields) async {
    await _client.from('dogs').update(fields).eq('id', dogId);
  }

  Future<void> addDog(Map<String, dynamic> fields) async {
    await _client.from('dogs').insert(fields);
  }

  Future<String> uploadDogPhoto(String dogId, String localPath) async {
    final ext = localPath.split('.').last;
    final path = 'dog_photos/$dogId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    final previous = await _fetchDogPhotoUrl(dogId);
    final oldPath = previous != null ? _storagePathFromUrl(previous) : null;
    await _client.storage.from('photos').upload(path, File(localPath));
    final url = _client.storage.from('photos').getPublicUrl(path);
    try {
      await _client.from('dogs').update({'photo_url': url}).eq('id', dogId);
    } catch (_) {
      await _client.storage.from('photos').remove([path]);
      rethrow;
    }
    if (oldPath != null) {
      try {
        await _client.storage.from('photos').remove([oldPath]);
      } catch (_) {
      }
    }
    return url;
  }

  Future<void> removeDogPhoto(String dogId) async {
    final current = await _fetchDogPhotoUrl(dogId);
    await _client.from('dogs').update({'photo_url': null}).eq('id', dogId);
    if (current != null) {
      final oldPath = _storagePathFromUrl(current);
      if (oldPath != null) {
        try {
          await _client.storage.from('photos').remove([oldPath]);
        } catch (_) {
        }
      }
    }
  }

  Future<void> deleteDog(String dogId) async {
    final url = await _fetchDogPhotoUrl(dogId);
    await _client.from('dogs').delete().eq('id', dogId);
    if (url != null) {
      final path = _storagePathFromUrl(url);
      if (path != null) {
        try {
          await _client.storage.from('photos').remove([path]);
        } catch (_) {
        }
      }
    }
  }

  Future<String?> _fetchDogPhotoUrl(String dogId) async {
    final row = await _client
        .from('dogs')
        .select('photo_url')
        .eq('id', dogId)
        .maybeSingle();
    return row?['photo_url'] as String?;
  }

  String? _storagePathFromUrl(String url) {
    final prefix = _client.storage.from('photos').getPublicUrl('');
    if (!url.startsWith(prefix)) return null;
    return url.substring(prefix.length);
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

  Future<void> markFieldIntroSeen(String userId) async {
    await _client.from('profiles').update({'has_seen_field_intro': true}).eq('id', userId);
  }

  Future<void> markHostIntroSeen(String userId) async {
    await _client.from('profiles').update({'has_seen_host_intro': true}).eq('id', userId);
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
      hasSeenFieldIntro: row['has_seen_field_intro'] as bool? ?? false,
      hasSeenHostIntro: row['has_seen_host_intro'] as bool? ?? false,
      treatPolicy: row['treat_policy'] != null
          ? TreatPolicy.values.firstWhere((e) => e.name == row['treat_policy'])
          : null,
    );
  }

  Dog _rowToDog(Map<String, dynamic> row) {
    return Dog(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      name: row['name'] as String,
      age: row['age'] as int?,
      breed: row['breed'] as String?,
      vibe: row['vibe'] != null
          ? SocialVibe.values.firstWhere((e) => e.name == row['vibe'])
          : null,
      icebreakerAnswer: row['icebreaker_answer'] as String?,
      photoUrl: row['photo_url'] as String?,
    );
  }
}
