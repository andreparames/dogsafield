import '../../../shared/models/dog.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/user_profile.dart';

class GatheringDetail {
  final DogEvent event;
  final UserProfile host;
  final Dog? hostDog;

  const GatheringDetail({
    required this.event,
    required this.host,
    this.hostDog,
  });
}
