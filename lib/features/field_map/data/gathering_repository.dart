import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/dog.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/user_profile.dart';
import 'attendee_profile.dart';
import 'gathering_detail.dart';

class GatheringRepository {
  final SupabaseClient _client;

  GatheringRepository(this._client);

  Future<GatheringDetail> fetchGatheringDetail(String eventId) async {
    final event = await _fetchEvent(eventId);
    final host = await _fetchProfile(event.hostId);
    final hostDog = await _fetchDog(event.hostId);
    final attendees = await _fetchAttendees(eventId);
    return GatheringDetail(
      event: event,
      host: host,
      hostDog: hostDog,
      attendees: attendees,
    );
  }

  Future<DogEvent> _fetchEvent(String id) async {
    final response = await _client
        .from('events')
        .select()
        .eq('id', id)
        .single();

    return _rowToEvent(response);
  }

  Future<UserProfile> _fetchProfile(String id) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .single();

    return _rowToProfile(response);
  }

  Future<Dog?> _fetchDog(String ownerId) async {
    final response = await _client
        .from('dogs')
        .select()
        .eq('owner_id', ownerId)
        .limit(1);

    if (response.isEmpty) return null;
    return _rowToDog(response.first);
  }

  Future<List<AttendeeProfile>> _fetchAttendees(String eventId) async {
    final attendanceRows = await _client
        .from('attendance')
        .select('user_id')
        .eq('event_id', eventId)
        .eq('status', 'confirmed');

    if (attendanceRows.isEmpty) return [];

    final userIds = attendanceRows.map((r) => r['user_id'] as String).toList();

    final profileRows = await _client
        .from('profiles')
        .select()
        .inFilter('id', userIds);
    final profileMap = <String, UserProfile>{};
    for (final row in profileRows) {
      final profile = _rowToProfile(row);
      profileMap[profile.id] = profile;
    }

    final dogRows = await _client
        .from('dogs')
        .select()
        .inFilter('owner_id', userIds);
    final dogMap = <String, Dog>{};
    for (final row in dogRows) {
      final ownerId = row['owner_id'] as String;
      dogMap.putIfAbsent(ownerId, () => _rowToDog(row));
    }

    return userIds.map((uid) {
      final profile = profileMap[uid];
      if (profile == null) return null;
      return AttendeeProfile(
        profile: profile,
        dog: dogMap[uid],
      );
    }).whereType<AttendeeProfile>().toList();
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

  UserProfile _rowToProfile(Map<String, dynamic> row) {
    return UserProfile(
      id: row['id'] as String,
      email: row['email'] as String,
      displayName: row['display_name'] as String?,
      photoUrl: row['photo_url'] as String?,
      isVerified: row['is_verified'] as bool? ?? false,
      trialRsvpsUsed: row['trial_rsvps_used'] as int? ?? 0,
      isFoundingPack: row['is_founding_pack'] as bool? ?? false,
      treatPolicy: row['treat_policy'] != null
          ? TreatPolicy.values.firstWhere((e) => e.name == row['treat_policy'])
          : null,
    );
  }

  Dog _rowToDog(Map<String, dynamic> row) {
    return Dog(
      id: row['id'] as String,
      name: row['name'] as String,
      age: row['age'] as int?,
      breed: row['breed'] as String?,
      vibe: row['vibe'] != null
          ? SocialVibe.values.firstWhere((e) => e.name == row['vibe'])
          : null,
      icebreakerAnswer: row['icebreaker_answer'] as String?,
    );
  }
}
