import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogsafield/core/database/providers.dart';
import 'package:dogsafield/core/notifications/notification_service.dart';
import 'package:dogsafield/core/notifications/providers.dart';
import 'package:dogsafield/features/field_map/data/attendee_profile.dart';
import 'package:dogsafield/features/field_map/data/gathering_detail.dart';
import 'package:dogsafield/features/connections/state/connection_providers.dart';
import 'package:dogsafield/features/field_map/presentation/gathering_details_screen.dart';
import 'package:dogsafield/features/field_map/state/gathering_providers.dart';
import 'package:dogsafield/features/field_map/state/rsvp_providers.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/shared/models/dog.dart';
import 'package:dogsafield/shared/models/event.dart';
import 'package:dogsafield/shared/models/user_profile.dart';
import '../../helpers/test_utils.dart';

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

Widget createTestApp(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  late FakeGatheringRepository gatheringRepo;
  late FakeRsvpRepository rsvpRepo;
  late SharedPreferences prefs;

  setUp(() async {
    gatheringRepo = FakeGatheringRepository();
    rsvpRepo = FakeRsvpRepository();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildScreen(String eventId) {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(fakeAuthService),
        authStateProvider.overrideWith((ref) => Stream.empty()),
        gatheringRepositoryProvider.overrideWithValue(gatheringRepo),
        rsvpRepositoryProvider.overrideWithValue(rsvpRepo),
        blockedUserIdsProvider.overrideWith((ref) => Future.value(<String>{})),
        blockerIdsProvider.overrideWith((ref) => Future.value(<String>{})),
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(
          _FakeNotificationService(prefs),
        ),
      ],
      child: createTestApp(GatheringDetailsScreen(eventId: eventId)),
    );
  }

  group('GatheringDetailsScreen', () {
    testWidgets('displays event title and type', (tester) async {
      gatheringRepo.detail = GatheringDetail(
        event: DogEvent(
          id: 'evt-1',
          hostId: 'host-1',
          type: EventType.packWalk,
          title: 'Morning Walk',
          locationName: 'Park',
          latitude: 38.7,
          longitude: -9.1,
          dateTime: DateTime(2026, 7, 10, 15, 0),
          maxAttendees: 20,
          amenityTags: ['Heavy Shade'],
          whatToBring: ['Water', 'Leash'],
        ),
        host: UserProfile(
          id: 'host-1',
          email: 'host@test.com',
          displayName: 'Jane',
        ),
        hostDog: Dog(
          id: 'dog-1',
          ownerId: 'host-1',
          name: 'Buddy',
          breed: 'Golden Retriever',
          vibe: SocialVibe.zoomieKing,
        ),
      );

      await tester.pumpWidget(buildScreen('evt-1'));
      await tester.pumpAndSettle();

      expect(find.text('Morning Walk'), findsOneWidget);
      expect(find.text('Pack Walk'), findsOneWidget);
    });

    testWidgets('displays date and location', (tester) async {
      gatheringRepo.detail = GatheringDetail(
        event: DogEvent(
          id: 'evt-1',
          hostId: 'host-1',
          type: EventType.dogPicnic,
          title: 'Picnic',
          locationName: 'Riverside Park',
          latitude: 38.7,
          longitude: -9.1,
          dateTime: DateTime(2026, 7, 10, 15, 0),
          maxAttendees: 20,
        ),
        host: UserProfile(id: 'host-1', email: 'host@test.com'),
      );

      await tester.pumpWidget(buildScreen('evt-1'));
      await tester.pumpAndSettle();

      expect(find.text('Riverside Park'), findsOneWidget);
      expect(find.textContaining('7/10/2026'), findsOneWidget);
    });

    testWidgets('displays host info', (tester) async {
      gatheringRepo.detail = GatheringDetail(
        event: DogEvent(
          id: 'evt-1',
          hostId: 'host-1',
          type: EventType.packWalk,
          title: 'Walk',
          locationName: 'Park',
          latitude: 38.7,
          longitude: -9.1,
          dateTime: DateTime(2026, 7, 10, 15, 0),
          maxAttendees: 20,
        ),
        host: UserProfile(
          id: 'host-1',
          email: 'host@test.com',
          displayName: 'Jane Doe',
        ),
        hostDog: Dog(
          id: 'dog-1',
          ownerId: 'host-1',
          name: 'Buddy',
          breed: 'Golden Retriever',
          vibe: SocialVibe.zoomieKing,
        ),
      );

      await tester.pumpWidget(buildScreen('evt-1'));
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.textContaining('Buddy'), findsOneWidget);
      expect(find.textContaining('Golden Retriever'), findsOneWidget);
    });

    testWidgets('displays amenity tags as chips', (tester) async {
      gatheringRepo.detail = GatheringDetail(
        event: DogEvent(
          id: 'evt-1',
          hostId: 'host-1',
          type: EventType.fieldGames,
          title: 'Games',
          locationName: 'Field',
          latitude: 38.7,
          longitude: -9.1,
          dateTime: DateTime(2026, 7, 10, 15, 0),
          maxAttendees: 20,
          amenityTags: ['Heavy Shade', 'Fenced Area'],
        ),
        host: UserProfile(id: 'host-1', email: 'host@test.com'),
      );

      await tester.pumpWidget(buildScreen('evt-1'));
      await tester.pumpAndSettle();

      expect(find.text('Heavy Shade'), findsOneWidget);
      expect(find.text('Fenced Area'), findsOneWidget);
    });

    testWidgets('displays what to bring items', (tester) async {
      gatheringRepo.detail = GatheringDetail(
        event: DogEvent(
          id: 'evt-1',
          hostId: 'host-1',
          type: EventType.packWalk,
          title: 'Walk',
          locationName: 'Park',
          latitude: 38.7,
          longitude: -9.1,
          dateTime: DateTime(2026, 7, 10, 15, 0),
          maxAttendees: 20,
          whatToBring: ['Water', 'Long leash', 'Treats'],
        ),
        host: UserProfile(id: 'host-1', email: 'host@test.com'),
      );

      await tester.pumpWidget(buildScreen('evt-1'));
      await tester.pumpAndSettle();

      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Long leash'), findsOneWidget);
      expect(find.text('Treats'), findsOneWidget);
    });

    testWidgets('displays attendance count and attendee names', (tester) async {
      gatheringRepo.detail = GatheringDetail(
        event: DogEvent(
          id: 'evt-1',
          hostId: 'host-1',
          type: EventType.packWalk,
          title: 'Walk',
          locationName: 'Park',
          latitude: 38.7,
          longitude: -9.1,
          dateTime: DateTime(2026, 7, 10, 15, 0),
          maxAttendees: 20,
        ),
        host: UserProfile(id: 'host-1', email: 'host@test.com'),
        attendees: [
          AttendeeProfile(
            profile: UserProfile(id: 'u1', email: 'u1@test.com', displayName: 'Alice'),
          ),
          AttendeeProfile(
            profile: UserProfile(id: 'u2', email: 'u2@test.com', displayName: 'Bob'),
          ),
          AttendeeProfile(
            profile: UserProfile(id: 'u3', email: 'u3@test.com', displayName: 'Carol'),
          ),
        ],
      );

      await tester.pumpWidget(buildScreen('evt-1'));
      await tester.pumpAndSettle();

      expect(find.text('3 / 20 attending'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
    });

    testWidgets('displays attendee dog info and icebreaker answers', (tester) async {
      gatheringRepo.detail = GatheringDetail(
        event: DogEvent(
          id: 'evt-1',
          hostId: 'host-1',
          type: EventType.packWalk,
          title: 'Walk',
          locationName: 'Park',
          latitude: 38.7,
          longitude: -9.1,
          dateTime: DateTime(2026, 7, 10, 15, 0),
          maxAttendees: 20,
        ),
        host: UserProfile(id: 'host-1', email: 'host@test.com'),
        attendees: [
          AttendeeProfile(
            profile: UserProfile(id: 'u1', email: 'u1@test.com', displayName: 'Dave'),
            dog: Dog(
              id: 'dog-1',
              ownerId: 'u1',
              name: 'Rex',
              breed: 'German Shepherd',
              vibe: SocialVibe.zoomieKing,
              icebreakerAnswer: 'Loves to fetch sticks!',
            ),
          ),
        ],
      );

      await tester.pumpWidget(buildScreen('evt-1'));
      await tester.pumpAndSettle();

      expect(find.text('Dave'), findsOneWidget);
      expect(find.textContaining('Rex'), findsOneWidget);
      expect(find.textContaining('German Shepherd'), findsOneWidget);
      expect(find.textContaining('Loves to fetch sticks!'), findsOneWidget);
    });

    testWidgets('shows error UI on failure', (tester) async {
      gatheringRepo.shouldFail = true;

      await tester.pumpWidget(buildScreen('evt-1'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to load event'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows Join Pack button when not RSVPd', (tester) async {
      gatheringRepo.detail = GatheringDetail(
        event: DogEvent(
          id: 'evt-1',
          hostId: 'host-1',
          type: EventType.packWalk,
          title: 'Walk',
          locationName: 'Park',
          latitude: 38.7,
          longitude: -9.1,
          dateTime: DateTime(2026, 7, 10, 15, 0),
          maxAttendees: 20,
        ),
        host: UserProfile(id: 'host-1', email: 'host@test.com'),
      );

      await tester.pumpWidget(buildScreen('evt-1'));
      await tester.pumpAndSettle();

      expect(find.text('Join Pack'), findsOneWidget);
    });

    testWidgets('shows Leave Pack after joining', (tester) async {
      gatheringRepo.detail = GatheringDetail(
        event: DogEvent(
          id: 'evt-1',
          hostId: 'host-1',
          type: EventType.packWalk,
          title: 'Walk',
          locationName: 'Park',
          latitude: 38.7,
          longitude: -9.1,
          dateTime: DateTime(2026, 7, 10, 15, 0),
          maxAttendees: 20,
        ),
        host: UserProfile(id: 'host-1', email: 'host@test.com'),
      );
      await rsvpRepo.rsvpToEvent('evt-1');

      await tester.pumpWidget(buildScreen('evt-1'));
      await tester.pumpAndSettle();

      expect(find.text('Leave Pack'), findsOneWidget);
    });

    testWidgets('tapping Join Pack calls RSVP and shows Leave Pack', (tester) async {
      gatheringRepo.detail = GatheringDetail(
        event: DogEvent(
          id: 'evt-1',
          hostId: 'host-1',
          type: EventType.packWalk,
          title: 'Walk',
          locationName: 'Park',
          latitude: 38.7,
          longitude: -9.1,
          dateTime: DateTime(2026, 7, 10, 15, 0),
          maxAttendees: 20,
        ),
        host: UserProfile(id: 'host-1', email: 'host@test.com'),
      );

      await tester.pumpWidget(buildScreen('evt-1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Join Pack'));
      await tester.pumpAndSettle();

      expect(rsvpRepo.rsvpEvents.contains('evt-1'), true);
      expect(find.text('Leave Pack'), findsOneWidget);
    });
  });
}
