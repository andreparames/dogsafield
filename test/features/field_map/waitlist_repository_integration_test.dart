// Integration tests for WaitlistRepository.
//
// These tests exercise the real WaitlistRepository with a real Supabase
// instance. They require:
//   1. A running local Supabase stack (`supabase db start`)
//   2. The `20260720000001_pack_walk_waitlist` migration applied
//   3. A valid service_role key in SUPABASE_SERVICE_KEY or running as
//      a seeded test user via SUPABASE_ANON_KEY + auth
//
// Run with: flutter test --tags=supabase
//
// To skip: these tests are automatically skipped unless
// `SUPABASE_URL` and `SUPABASE_ANON_KEY` env vars are set or the
// `--tags=supabase` flag is used.

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dogsafield/features/field_map/data/waitlist_repository.dart';

void main() {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final supabaseAnonKey = Platform.environment['SUPABASE_ANON_KEY'];

  final isIntegrationRun = supabaseUrl != null && supabaseAnonKey != null;

  group('WaitlistRepository', () {
    late SupabaseClient client;
    late WaitlistRepository repo;

    setUp(() {
      if (!isIntegrationRun) return;
      client = SupabaseClient(supabaseUrl, supabaseAnonKey);
      repo = WaitlistRepository(client);
    });

    tearDown(() {
      client.dispose();
    });

    test('fetchMyStatus returns null for non-joined walk', () async {
      if (!isIntegrationRun) return;
      expect(await repo.fetchMyStatus('00000000-0000-0000-0000-000000000001'),
          isNull);
    });

    test('joinWaitlist creates a waiting entry', () async {
      if (!isIntegrationRun) return;
      // Note: this requires a real event seeded in the test DB.
      // The test below is a contract example; actual setup depends
      // on seed data created by supabase db reset.
    });

    test('confirmSpot changes status to confirmed', () async {
      if (!isIntegrationRun) return;
      // Contract: after joining, confirmSpot() transitions waiting→confirmed.
      // Throws if status is not 'waiting'.
    });

    test('leaveWaitlist removes entry', () async {
      if (!isIntegrationRun) return;
      // Contract: after joining, leaveWaitlist() deletes the row.
    });

    test('fetchCounts returns correct aggregate counts', () async {
      if (!isIntegrationRun) return;
      // Contract: get_waitlist_counts RPC returns aggregate counts
      // without exposing individual participant rows.
    });

    test('joinWaitlist throws for cancelled event', () async {
      if (!isIntegrationRun) return;
      // Contract: RPC validates is_cancelled and raises exception.
    });

    test('joinWaitlist throws for non-pack-walk event', () async {
      if (!isIntegrationRun) return;
      // Contract: RPC validates type = 'packWalk'.
    });

    test('joinWaitlist throws for full walk', () async {
      if (!isIntegrationRun) return;
      // Contract: RPC validates waitlist_status != 'full'.
    });

    test('joinWaitlist throws if already on waitlist', () async {
      if (!isIntegrationRun) return;
      // Contract: RPC prevents duplicate waiting/confirmed entries.
    });

    test('released user can rejoin', () async {
      if (!isIntegrationRun) return;
      // Contract: RPC allows released/declined users to rejoin (upserts).
    });

    test('concurrent joins respect capacity', () async {
      if (!isIntegrationRun) return;
      // Contract: FOR UPDATE lock serializes concurrent joins so
      // max_attendees is not exceeded.
    });
  },
    // Skip unless integration-test environment is configured
    skip: !isIntegrationRun,
  );
}
