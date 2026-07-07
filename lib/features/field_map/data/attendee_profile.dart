import '../../../shared/models/dog.dart';
import '../../../shared/models/user_profile.dart';

class AttendeeProfile {
  final UserProfile profile;
  final Dog? dog;

  const AttendeeProfile({
    required this.profile,
    this.dog,
  });
}
