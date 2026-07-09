import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/dog.dart';
import '../../../shared/models/user_profile.dart';

class OnboardingRepository {
  final SupabaseClient _client;

  OnboardingRepository(this._client);

  Future<String> uploadPhoto(String localPath) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    final ext = localPath.split('.').last;
    final path = 'verification_photos/${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('photos').upload(path, File(localPath));
    return _client.storage.from('photos').getPublicUrl(path);
  }

  Future<UserProfile?> fetchProfile(String id) async {
    final rows = await _client.from('profiles').select().eq('id', id).limit(1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return UserProfile(
      id: row['id'] as String,
      email: row['email'] as String,
      displayName: row['display_name'] as String?,
      photoUrl: row['photo_url'] as String?,
      hasSeenFieldIntro: row['has_seen_field_intro'] as bool? ?? false,
      hasSeenHostIntro: row['has_seen_host_intro'] as bool? ?? false,
      treatPolicy: (row['treat_policy'] as String?) != null
          ? TreatPolicy.values.cast<TreatPolicy?>().firstWhere((e) => e!.name == row['treat_policy'], orElse: () => null)
          : null,
    );
  }

  Future<UserProfile> createProfile(UserProfile profile) async {
    await _client.from('profiles').upsert({
      'id': profile.id,
      'email': profile.email,
      'display_name': profile.displayName,
      'photo_url': profile.photoUrl,
      'treat_policy': profile.treatPolicy?.name,
    });
    return profile;
  }

  Future<Dog> createDogProfile(Dog dog) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    await _client.from('dogs').insert({
      'id': dog.id,
      'owner_id': user.id,
      'name': dog.name,
      'age': dog.age,
      'breed': dog.breed,
      'vibe': dog.vibe?.name,
      'icebreaker_answer': dog.icebreakerAnswer,
    });
    return dog;
  }
}
