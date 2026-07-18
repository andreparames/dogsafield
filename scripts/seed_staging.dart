import 'dart:convert';
import 'dart:io';
import 'package:supabase/supabase.dart';

const _password = 'Test123!';

void main(List<String> args) async {
  final supabaseUrl = args.isNotEmpty
      ? args[0]
      : Platform.environment['SUPABASE_URL'];
  final serviceKey = args.length > 1
      ? args[1]
      : Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];

  if (supabaseUrl == null || serviceKey == null) {
    stderr.writeln(
      'Usage: dart run scripts/seed_staging.dart <supabase-url> <service-role-key>\n'
      'Or set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY env vars',
    );
    exit(1);
  }

  final client = SupabaseClient(supabaseUrl, serviceKey);

  try {
    print('Clearing existing data...');
    for (final table in [
      'messages', 'conversations', 'connections',
      'roll_call_entries', 'attendance', 'events',
      'dogs', 'profiles', 'regions',
      'feedback', 'reports',
    ]) {
      await client.from(table).delete().neq('id', '00000000-0000-0000-0000-000000000000');
    }
    await client.from('reviewer_codes').delete().neq('code', '');
    await _clearAuthUsers(supabaseUrl, serviceKey);
    print('✓ existing data cleared');

    print('\nSeeding staging database...\n');

    final userIds = await _createUsers(supabaseUrl, serviceKey);
    print('✓ ${userIds.length} auth users created');

    await _insertProfiles(client, userIds);
    print('✓ ${userIds.length} profiles created');

    final dogCount = await _insertDogs(client, userIds);
    print('✓ $dogCount dogs created');

    final regionIds = await _insertRegions(client);
    print('✓ ${regionIds.length} regions created');

    final eventIds = await _insertEvents(client, userIds, regionIds);
    print('✓ ${eventIds.length} events created');

    final attCount = await _insertAttendance(client, eventIds, userIds);
    print('✓ $attCount attendance records created');

    final convIds = await _insertConversations(client, userIds);
    print('✓ ${convIds.length} conversations created');

    await _insertMessages(client, convIds, userIds);
    print('✓ messages created');

    final connCount = await _insertConnections(client, userIds);
    print('✓ $connCount connections created');

    await _insertReviewerCode(client);
    print('✓ reviewer code created');

    print('\n\u2705 Seeding complete!');
  } catch (e, stack) {
    stderr.writeln('Error: $e');
    stderr.writeln(stack);
    exit(1);
  } finally {
    client.dispose();
  }
}

Future<void> _clearAuthUsers(String baseUrl, String key) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse('$baseUrl/auth/v1/admin/users'));
    request.headers.set('apikey', key);
    request.headers.set('Authorization', 'Bearer $key');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 300) return;
    final users = jsonDecode(body)['users'] as List?;
    if (users == null) return;
    for (final u in users) {
      final id = u['id'] as String?;
      if (id == null) continue;
      try {
        final del = await client.deleteUrl(Uri.parse('$baseUrl/auth/v1/admin/users/$id'));
        del.headers.set('apikey', key);
        del.headers.set('Authorization', 'Bearer $key');
        await del.close();
      } catch (_) {}
    }
  } finally {
    client.close();
  }
}

// ─── Auth Users ──────────────────────────────────────────────────────────────

Future<List<String>> _createUsers(String baseUrl, String key) async {
  final emails = [
    'sarah@test.com', 'mike@test.com', 'jessica@test.com',
    'david@test.com', 'emily@test.com', 'alex@test.com',
    'rachel@test.com', 'chris@test.com',
  ];

  final ids = <String>[];
  for (final email in emails) {
    final id = await _createAuthUser(baseUrl, key, email);
    ids.add(id);
  }
  return ids;
}

Future<String> _createAuthUser(String baseUrl, String key, String email) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('$baseUrl/auth/v1/admin/users'));
    request.headers.set('apikey', key);
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('Content-Type', 'application/json');
    request.write(jsonEncode({
      'email': email,
      'password': _password,
      'email_confirm': true,
    }));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 300) {
      throw HttpException('POST /auth/v1/admin/users $email -> ${response.statusCode}: $body');
    }
    return jsonDecode(body)['id'] as String;
  } finally {
    client.close();
  }
}

// ─── Profiles ────────────────────────────────────────────────────────────────

Future<void> _insertProfiles(SupabaseClient client, List<String> userIds) async {
  final names = [
    ('Sarah', 'Johnson'), ('Mike', 'Chen'), ('Jessica', 'Williams'),
    ('David', 'Martinez'), ('Emily', 'Brown'), ('Alex', 'Patel'),
    ('Rachel', 'Kim'), ('Chris', 'Thompson'),
  ];

  final emails = [
    'sarah@test.com', 'mike@test.com', 'jessica@test.com',
    'david@test.com', 'emily@test.com', 'alex@test.com',
    'rachel@test.com', 'chris@test.com',
  ];

  for (var i = 0; i < userIds.length; i++) {
    await client.from('profiles').insert({
      'id': userIds[i],
      'email': emails[i],
      'display_name': '${names[i].$1} ${names[i].$2}',
      'photo_url': null,
      'is_verified': i < 3,
      'treat_policy': i.isEven ? 'okToShare' : 'askBeforeFeeding',
      'trial_rsvps_used': i < 2 ? 3 : 0,
      'is_founding_pack': i < 2,
      'has_seen_field_intro': i < 4,
      'has_seen_host_intro': i < 3,
    });
  }
}

// ─── Dogs ────────────────────────────────────────────────────────────────────

Future<int> _insertDogs(SupabaseClient client, List<String> userIds) async {
  final seeds = [
    (0, 'Rex', 4, 'Labrador Retriever', 'zoomieKing', 'Loves chasing balls!'),
    (1, 'Lua', 2, 'Beagle', 'loungeLizard', null),
    (2, 'Max', 3, 'Golden Retriever', 'socialLearner', 'Friendly with everyone'),
    (2, 'Nina', 1, 'Poodle', 'loungeLizard', null),
    (3, 'Thor', 5, 'German Shepherd', 'zoomieKing', null),
    (4, 'Bella', 3, 'Labradoodle', 'loungeLizard', 'Loves belly rubs'),
    (5, 'Simba', 2, 'Mixed Breed', 'socialLearner', 'Shy at first'),
    (6, 'Kika', 4, 'French Bulldog', 'loungeLizard', null),
    (7, 'Toby', 1, 'Border Collie', 'socialLearner', 'Needs lots of exercise'),
  ];

  for (final s in seeds) {
    await client.from('dogs').insert({
      'owner_id': userIds[s.$1],
      'name': s.$2,
      'age': s.$3,
      'breed': s.$4,
      'vibe': s.$5,
      'icebreaker_answer': s.$6,
    });
  }
  return seeds.length;
}

// ─── Regions ─────────────────────────────────────────────────────────────────

Future<List<String>> _insertRegions(SupabaseClient client) async {
  final ids = <String>[];
  for (final r in [
    ('San Francisco', 37.7749, -122.4194, 50.0),
  ]) {
    final resp = await client.from('regions').insert({
      'name': r.$1,
      'center_lat': r.$2,
      'center_lng': r.$3,
      'radius_km': r.$4,
      'is_enabled': true,
    }).select('id').single();
    ids.add(resp['id'] as String);
  }
  return ids;
}

// ─── Events ──────────────────────────────────────────────────────────────────

Future<List<String>> _insertEvents(
  SupabaseClient client,
  List<String> userIds,
  List<String> regionIds,
) async {
  final seeds = [
    (userIds[0], regionIds[0], 'packWalk',
      'Morning Pack Walk - Golden Gate Park',
      'A relaxing morning walk through the park',
      'Golden Gate Park', 37.7694, -122.4862,
      _daysFromNow(-14), 15, ['Water', 'Poop bags', 'Treats'],
      ['Parking', 'Shade', 'Water fountain']),
    (userIds[2], regionIds[0], 'dogPicnic',
      'Beach Day at Baker Beach',
      'Fun day at the dog-friendly beach',
      'Baker Beach', 37.7935, -122.4834,
      _daysFromNow(-7), 20, ['Towels', 'Fresh water', 'Sun protection'],
      ['Dog-friendly beach', 'Parking']),
    (userIds[5], regionIds[0], 'fieldGames',
      'Field Games at Golden Gate Park',
      'Agility and fetch games on the big field',
      'Golden Gate Park', 37.7694, -122.4862,
      _daysFromNow(10), 12, ['Frisbee', 'Balls', 'Water bowl'],
      ['Large field', 'Parking', 'Dog park']),
    (userIds[0], regionIds[0], 'packWalk',
      'Evening Stroll - Crissy Field',
      'Sunset walk along the waterfront',
      'Crissy Field', 37.8044, -122.4474,
      _daysFromNow(21), 10, ['Water', 'Poop bags', 'Flashlight'],
      ['Waterfront', 'Paved paths', 'Great views']),
  ];

  final ids = <String>[];
  for (final s in seeds) {
    final resp = await client.from('events').insert({
      'host_id': s.$1,
      'type': s.$3,
      'title': s.$4,
      'description': s.$5,
      'location_name': s.$6,
      'latitude': s.$7,
      'longitude': s.$8,
      'date_time': s.$9.toIso8601String(),
      'max_attendees': s.$10,
      'what_to_bring': s.$11,
      'amenity_tags': s.$12,
    }).select('id').single();
    ids.add(resp['id'] as String);
  }
  return ids;
}

DateTime _daysFromNow(int days) =>
    DateTime.now().toUtc().add(Duration(days: days));

// ─── Attendance ──────────────────────────────────────────────────────────────

Future<int> _insertAttendance(
  SupabaseClient client,
  List<String> eventIds,
  List<String> userIds,
) async {
  var count = 0;
  // Event 0: 5 attendees (past, mark as attended)
  for (var i = 0; i < 5; i++) {
    if (i == 0) continue; // host doesn't attend their own event
    await client.from('attendance').insert({
      'event_id': eventIds[0],
      'user_id': userIds[i],
      'status': 'attended',
      'roll_call_submitted': true,
    });
    count++;
  }
  // Event 1: 4 attendees (past)
  for (var i = 1; i < 5; i++) {
    await client.from('attendance').insert({
      'event_id': eventIds[1],
      'user_id': userIds[i],
      'status': i == 4 ? 'noShow' : 'attended',
      'roll_call_submitted': i != 4,
    });
    count++;
  }
  // Event 2: 3 confirmed (future)
  for (var i = 1; i < 4; i++) {
    await client.from('attendance').insert({
      'event_id': eventIds[2],
      'user_id': userIds[i],
      'status': 'confirmed',
      'roll_call_submitted': false,
    });
    count++;
  }
  // Event 3: 2 confirmed (future)
  for (var i = 2; i < 4; i++) {
    await client.from('attendance').insert({
      'event_id': eventIds[3],
      'user_id': userIds[i],
      'status': 'confirmed',
      'roll_call_submitted': false,
    });
    count++;
  }
  return count;
}

// ─── Conversations & Messages ────────────────────────────────────────────────

Future<List<String>> _insertConversations(
  SupabaseClient client,
  List<String> userIds,
) async {
  final pairs = [(0, 1), (2, 3)];
  final ids = <String>[];
  for (final p in pairs) {
    final resp = await client.from('conversations').insert({
      'user_a': userIds[p.$1],
      'user_b': userIds[p.$2],
    }).select('id').single();
    ids.add(resp['id'] as String);
  }
  return ids;
}

Future<void> _insertMessages(
  SupabaseClient client,
  List<String> convIds,
  List<String> userIds,
) async {
  // Conversation 0: Sarah (0) and Mike (1)
  final msgs0 = [
    (0, 1, 'Hey Mike! Are you going to the pack walk on Saturday?'),
    (1, 0, 'Hey Sarah! Yeah, I\'m bringing Luna. She loves those walks!'),
    (0, 1, 'Awesome! Rex too. See you there!'),
    (1, 0, 'For sure! I\'ll bring extra treats.'),
  ];
  for (final m in msgs0) {
    await client.from('messages').insert({
      'conversation_id': convIds[0],
      'sender_id': userIds[m.$2],
      'content': m.$3,
    });
  }
  // Conversation 1: Jessica (2) and David (3)
  final msgs1 = [
    (2, 3, 'David, is Thor doing okay after the beach day?'),
    (3, 2, 'Yeah, he loved it! Slept the whole afternoon after.'),
    (2, 3, 'Nina too! Let\'s do it again?'),
    (3, 2, 'Definitely! There\'s a new event at Central Park.'),
    (2, 3, 'I saw that! I\'ll RSVP now.'),
  ];
  for (final m in msgs1) {
    await client.from('messages').insert({
      'conversation_id': convIds[1],
      'sender_id': userIds[m.$2],
      'content': m.$3,
    });
  }
}

// ─── Connections ─────────────────────────────────────────────────────────────

Future<int> _insertConnections(
  SupabaseClient client,
  List<String> userIds,
) async {
  final seeds = [
    (0, 4, true, 0, null),   // Maria & Sofia → packmates
    (1, 4, true, 0, null),   // João & Sofia → packmates
    (2, 5, false, 0, null),  // Ana & Miguel → regular connection
  ];
  for (final s in seeds) {
    await client.from('connections').insert({
      'user_id_a': userIds[s.$1],
      'user_id_b': userIds[s.$2],
      'are_packmates': s.$3,
      'block_tier': s.$4,
      'report_reason': s.$5,
    });
  }
  return seeds.length;
}

// ─── Reviewer Code ──────────────────────────────────────────────────────────

Future<void> _insertReviewerCode(SupabaseClient client) async {
  await client.from('reviewer_codes').insert({
    'code': 'STAGING_REVIEW_2026',
    'email': 'reviewer@dogsafield.app',
    'active': true,
  });
}
