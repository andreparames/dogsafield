import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/field_map/data/attendee_profile.dart';
import 'package:dogsafield/features/field_map/data/gathering_detail.dart';
import 'package:dogsafield/features/connections/state/connection_providers.dart';
import 'package:dogsafield/features/field_map/state/gathering_providers.dart';
import 'package:dogsafield/features/onboarding/state/auth_provider.dart';
import 'package:dogsafield/shared/models/event.dart';
import 'package:dogsafield/shared/models/user_profile.dart';
import '../../helpers/test_utils.dart';

void main() {
  late FakeGatheringRepository repo;

  setUp(() {
    repo = FakeGatheringRepository();
  });

  group('gatheringDetailProvider', () {
    test('returns detail for given eventId', () async {
      final detail = GatheringDetail(
        event: DogEvent(
          id: 'evt-1',
          hostId: 'host-1',
          type: EventType.dogPicnic,
          title: 'Picnic',
          locationName: 'Garden',
          latitude: 38.8,
          longitude: -9.2,
          dateTime: DateTime(2026, 7, 11, 14, 0),
          maxAttendees: 10,
        ),
        host: UserProfile(
          id: 'host-1',
          email: 'host@test.com',
          displayName: 'John',
        ),
      );
      repo.detail = detail;

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          gatheringRepositoryProvider.overrideWithValue(repo),
          blockerIdsProvider.overrideWith((ref) => Future.value(<String>{})),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(gatheringDetailProvider('evt-1').future);

      expect(result.event.id, 'evt-1');
      expect(result.event.title, 'Picnic');
      expect(result.host.displayName, 'John');
    });

    test('filters out blockerIds but not blockedIds from attendees', () async {
      final detail = GatheringDetail(
        event: DogEvent(
          id: 'evt-2',
          hostId: 'host-2',
          type: EventType.packWalk,
          title: 'Walk',
          locationName: 'Trail',
          latitude: 38.7,
          longitude: -9.1,
          dateTime: DateTime(2026, 7, 12, 10, 0),
          maxAttendees: 10,
        ),
        host: UserProfile(id: 'host-2', email: 'host@test.com', displayName: 'Host'),
        attendees: [
          AttendeeProfile(
            profile: UserProfile(id: 'blocked-user', email: '', displayName: 'Blocked'),
          ),
          AttendeeProfile(
            profile: UserProfile(id: 'blocker-user', email: '', displayName: 'Blocker'),
          ),
          AttendeeProfile(
            profile: UserProfile(id: 'normal-user', email: '', displayName: 'Normal'),
          ),
        ],
      );
      repo.detail = detail;

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          gatheringRepositoryProvider.overrideWithValue(repo),
          blockedUserIdsProvider.overrideWith((ref) => Future.value(<String>{'blocked-user'})),
          blockerIdsProvider.overrideWith((ref) => Future.value(<String>{'blocker-user'})),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(gatheringDetailProvider('evt-2').future);

      expect(result.attendees.length, 2);
      expect(result.attendees.any((a) => a.profile.id == 'blocked-user'), isTrue);
      expect(result.attendees.any((a) => a.profile.id == 'blocker-user'), isFalse);
      expect(result.attendees.any((a) => a.profile.id == 'normal-user'), isTrue);
    });

    test('throws when eventId does not exist', () async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          gatheringRepositoryProvider.overrideWithValue(repo),
          blockerIdsProvider.overrideWith((ref) => Future.value(<String>{})),
        ],
      );
      addTearDown(container.dispose);

      final provider = gatheringDetailProvider('missing');
      
      final completer = Completer<void>();
      final sub = container.listen(provider, (prev, next) {
        if (next.hasError && !completer.isCompleted) {
          completer.completeError(next.error!, next.stackTrace);
        } else if (!next.isLoading && next.hasValue && !completer.isCompleted) {
          completer.complete();
        }
      });
      
      await expectLater(completer.future, throwsA(isA<Exception>()));
      
      sub.close();
    });
  });
}
