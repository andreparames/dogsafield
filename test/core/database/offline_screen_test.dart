import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dogsafield/core/database/connectivity_service.dart';
import 'package:dogsafield/core/database/database.dart';
import 'package:dogsafield/core/database/local_cache_service.dart';
import 'package:dogsafield/core/database/providers.dart';
import 'package:dogsafield/core/notifications/notification_service.dart';
import 'package:dogsafield/core/notifications/providers.dart';
import 'package:dogsafield/features/field_map/data/gathering_repository.dart';
import 'package:dogsafield/features/field_map/presentation/gathering_details_screen.dart';
import 'package:dogsafield/features/field_map/state/gathering_providers.dart';
import 'package:dogsafield/features/field_map/state/rsvp_providers.dart';
import 'package:dogsafield/features/connections/state/connection_providers.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/shared/models/event.dart';
import 'package:dogsafield/shared/models/user_profile.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../../helpers/test_utils.dart';

class _OfflineConnectivity implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.none];
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService(SharedPreferences prefs)
      : super(FlutterLocalNotificationsPlugin(), prefs);

  @override
  Future<void> cancelRollCallReminder(String eventId) async {}

  @override
  Future<void> scheduleRollCallReminder({
    required String eventId,
    required DateTime eventDateTime,
    required String eventTitle,
  }) async {}
}

class _DummySupabaseClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError('SupabaseClient should not be called in offline test');
  }
}

Widget _createTestApp(Widget child) {
  return TranslationProvider(
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('GatheringDetailsScreen shows cached event when offline',
      (tester) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cache = LocalCacheService(db: db, prefs: prefs);
    final offlineConnectivity = ConnectivityService(
      connectivity: _OfflineConnectivity(),
    );
    final dummyClient = _DummySupabaseClient();

    final event = DogEvent(
      id: 'evt-1',
      hostId: 'host-1',
      type: EventType.packWalk,
      title: 'Offline Park Walk',
      locationName: 'Central Park',
      latitude: 40.0,
      longitude: -74.0,
      dateTime: DateTime.now().add(const Duration(days: 1)),
      maxAttendees: 10,
    );
    final host = UserProfile(
      id: 'host-1',
      email: 'host@test.com',
      displayName: 'Alice',
    );
    await cache.upsertEvents([event]);
    await cache.upsertProfiles([host]);

    final gatheringRepo = GatheringRepository(
      dummyClient,
      cache,
      offlineConnectivity,
    );

    addTearDown(() async {
      await db.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          gatheringRepositoryProvider.overrideWithValue(gatheringRepo),
          rsvpRepositoryProvider.overrideWithValue(FakeRsvpRepository()),
          blockedUserIdsProvider.overrideWith((ref) => Future.value(<String>{})),
          blockerIdsProvider.overrideWith((ref) => Future.value(<String>{})),
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationServiceProvider.overrideWithValue(
            _FakeNotificationService(prefs),
          ),
        ],
        child: _createTestApp(GatheringDetailsScreen(eventId: 'evt-1')),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Offline Park Walk'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
  });
}
