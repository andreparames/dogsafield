import '../../../shared/models/dog.dart';
import '../../../shared/models/user_profile.dart';

class AttendeeProfile {
  final UserProfile profile;
  final List<Dog> dogs;

  const AttendeeProfile({
    required this.profile,
    this.dogs = const [],
  });
}
