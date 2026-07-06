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
