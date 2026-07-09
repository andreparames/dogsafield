import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/connectivity_service.dart';
import '../../../core/database/local_cache_service.dart';
import '../../../shared/models/event.dart';

class FieldMapRepository {
  final SupabaseClient _client;
  final LocalCacheService? _cache;
  final ConnectivityService? _connectivity;

  FieldMapRepository(this._client, [this._cache, this._connectivity]);

  Future<List<DogEvent>> fetchEventsNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
  }) async {
    if (_cache != null && _connectivity != null) {
      final online = await _connectivity.isOnline;
      if (!online) {
        return _cache.getNearbyEvents(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        );
      }
    }

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

    final events = response.map((row) => _rowToEvent(row)).toList();

    if (_cache != null) {
      await _cache.upsertEvents(events);
    }

    return events;
  }

  Future<List<DogEvent>> fetchMyRsvps() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    if (_cache != null && _connectivity != null) {
      final online = await _connectivity.isOnline;
      if (!online) {
        return _cache.getMyRsvpEvents(user.id);
      }
    }

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

    final events = response.map((row) => _rowToEvent(row)).toList();

    if (_cache != null) {
      for (final row in attendanceRows) {
        await _cache.upsertAttendance(
          row['event_id'] as String,
          user.id,
          'confirmed',
        );
      }
      await _cache.upsertEvents(events);
    }

    return events;
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
