enum EventType { packWalk, dogPicnic, fieldGames }

class DogEvent {
  final String id;
  final String hostId;
  final EventType type;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime dateTime;
  final int maxAttendees;
  final List<String> attendeeIds;

  const DogEvent({
    required this.id,
    required this.hostId,
    required this.type,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.dateTime,
    required this.maxAttendees,
    this.attendeeIds = const [],
  });
}
