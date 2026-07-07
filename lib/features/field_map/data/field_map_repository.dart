import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/event.dart';

class FieldMapRepository {
  final SupabaseClient _client;

  FieldMapRepository(this._client);

  Future<List<DogEvent>> fetchEventsNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
  }) async {
    const double kmPerDegree = 111.0;
    final double latDelta = radiusKm / kmPerDegree;
    final double lonDelta = radiusKm / (kmPerDegree * cos(latitude * pi / 180));

    final response = await _client
        .from('events')
        .select()
        .gte('latitude', latitude - latDelta)
        .lte('latitude', latitude + latDelta)
        .gte('longitude', longitude - lonDelta)
        .lte('longitude', longitude + lonDelta)
        .gte('date_time', DateTime.now().toUtc().toIso8601String())
        .order('date_time', ascending: true);

    return response.map((row) => _rowToEvent(row)).toList();
  }

  Future<List<DogEvent>> fetchMyRsvps() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final attendanceRows = await _client
        .from('attendance')
        .select('event_id')
        .eq('user_id', user.id)
        .eq('status', 'confirmed');

    if (attendanceRows.isEmpty) return [];

    final eventIds = attendanceRows.map((r) => r['event_id'] as String).toList();

    final response = await _client
        .from('events')
        .select()
        .inFilter('id', eventIds)
        .gte('date_time', DateTime.now().toUtc().toIso8601String())
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
