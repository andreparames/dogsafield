enum EventType { packWalk, dogPicnic, fieldGames }

class DogEvent {
  final String id;
  final String hostId;
  final EventType type;
  final String title;
  final String? description;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime dateTime;
  final int maxAttendees;
  final List<String> whatToBring;
  final List<String> amenityTags;
  final List<String> attendeeIds;
  final bool isCancelled;

  const DogEvent({
    required this.id,
    required this.hostId,
    required this.type,
    required this.title,
    this.description,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.dateTime,
    required this.maxAttendees,
    this.whatToBring = const [],
    this.amenityTags = const [],
    this.attendeeIds = const [],
    this.isCancelled = false,
  });

  DogEvent copyWith({
    String? id,
    String? hostId,
    EventType? type,
    String? title,
    String? description,
    String? locationName,
    double? latitude,
    double? longitude,
    DateTime? dateTime,
    int? maxAttendees,
    List<String>? whatToBring,
    List<String>? amenityTags,
    List<String>? attendeeIds,
    bool? isCancelled,
  }) {
    return DogEvent(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dateTime: dateTime ?? this.dateTime,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      whatToBring: whatToBring ?? this.whatToBring,
      amenityTags: amenityTags ?? this.amenityTags,
      attendeeIds: attendeeIds ?? this.attendeeIds,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }
}
