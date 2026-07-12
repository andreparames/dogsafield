import '../../../shared/models/dog.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/user_profile.dart';
import 'attendee_profile.dart';

class GatheringDetail {
  final DogEvent event;
  final UserProfile host;
  final List<Dog> hostDogs;
  final List<AttendeeProfile> attendees;

  const GatheringDetail({
    required this.event,
    required this.host,
    this.hostDogs = const [],
    this.attendees = const [],
  });
}
