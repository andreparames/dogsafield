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

  Future<DogEvent> updateEvent(DogEvent event) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client.from('events')
        .update({
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
        })
        .eq('id', event.id)
        .eq('host_id', user.id)
        .select()
        .single();

    return _rowToEvent(response);
  }

  Future<void> cancelEvent(String eventId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final result = await _client.from('events')
        .update({'is_cancelled': true})
        .eq('id', eventId)
        .eq('host_id', user.id)
        .select();

    if (result.isEmpty) throw Exception('Event not found or not authorized');
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

  Future<List<Map<String, dynamic>>> fetchAttendees(String eventId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final response = await _client.from('attendance')
        .select('user_id')
        .eq('event_id', eventId);

    if (response.isEmpty) return [];

    final userIds = response.map((r) => r['user_id'] as String).toList();
    final profiles = await _client.from('profiles_public')
        .select('id, display_name, photo_url')
        .inFilter('id', userIds);

    final profileMap = {for (final p in profiles) p['id'] as String: p};

    final dogs = await _client.from('dogs')
        .select('owner_id, name, breed')
        .inFilter('owner_id', userIds);

    final dogMap = <String, List<Map<String, dynamic>>>{};
    for (final d in dogs) {
      (dogMap[d['owner_id'] as String] ??= []).add(d);
    }

    final result = <Map<String, dynamic>>[];
    for (final uid in userIds) {
      final profile = profileMap[uid];
      if (profile == null) continue;
      final entry = <String, dynamic>{
        'user_id': uid,
        'profiles': {
          'id': profile['id'],
          'display_name': profile['display_name'],
          'photo_url': profile['photo_url'],
          'dogs': dogMap[uid] ?? [],
        },
      };
      result.add(entry);
    }
    return result;
  }

  Future<void> removeAttendee(String eventId, String userId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _client.from('attendance')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);
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
      isCancelled: row['is_cancelled'] as bool? ?? false,
    );
  }
}
