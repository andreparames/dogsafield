import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/dog.dart';
import '../../../shared/models/user_profile.dart';

class OnboardingRepository {
  final SupabaseClient _client;
  final ImagePicker _picker;

  OnboardingRepository(this._client, this._picker);

  Future<String?> uploadPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return null;
    final userId = _client.auth.currentUser!.id;
    final path = 'verification_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage.from('photos').upload(path, File(picked.path));
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
    await _client.from('dogs').insert({
      'id': dog.id,
      'owner_id': _client.auth.currentUser!.id,
      'name': dog.name,
      'age': dog.age,
      'breed': dog.breed,
      'vibe': dog.vibe?.name,
      'icebreaker_answer': dog.icebreakerAnswer,
    });
    return dog;
  }
}
