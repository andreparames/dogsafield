import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/event.dart';

class HostingRepository {
  final SupabaseClient _client;

  HostingRepository(this._client);

  Future<DogEvent> createEvent(DogEvent event) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client.from('events').insert({
      'host_id': user.id,
      'type': event.type.name,
      'title': event.title,
      'description': event.description,
      'location_name': event.locationName,
      'latitude': event.latitude,
      'longitude': event.longitude,
      'date_time': event.dateTime.toUtc().toIso8601String(),
      'max_attendees': event.maxAttendees,
      'what_to_bring': event.whatToBring,
      'amenity_tags': event.amenityTags,
    }).select().single();

    return _rowToEvent(response);
  }

  Future<List<DogEvent>> fetchMyEvents() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client.from('events')
        .select()
        .eq('host_id', user.id)
        .order('date_time', ascending: true);

    return response.map((row) => _rowToEvent(row)).toList();
  }

  DogEvent _rowToEvent(Map<String, dynamic> row) {
    return DogEvent(
      id: row['id'] as String,
      hostId: row['host_id'] as String,
      type: EventType.values.firstWhere((e) => e.name == row['type']),
      title: row['title'] as String,
      description: row['description'] as String?,
      locationName: row['location_name'] as String,
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
      dateTime: DateTime.parse(row['date_time'] as String),
      maxAttendees: row['max_attendees'] as int,
      whatToBring: (row['what_to_bring'] as List<dynamic>?)?.cast<String>() ?? [],
      amenityTags: (row['amenity_tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
