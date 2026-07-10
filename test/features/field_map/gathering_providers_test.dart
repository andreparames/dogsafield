import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
          blockedUserIdsProvider.overrideWith((ref) => Future.value(<String>{})),
          blockerIdsProvider.overrideWith((ref) => Future.value(<String>{})),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(gatheringDetailProvider('evt-1').future);

      expect(result.event.id, 'evt-1');
      expect(result.event.title, 'Picnic');
      expect(result.host.displayName, 'John');
    });

    test('throws when eventId does not exist', () async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(fakeAuthService),
          authStateProvider.overrideWith((ref) => Stream.empty()),
          gatheringRepositoryProvider.overrideWithValue(repo),
          blockedUserIdsProvider.overrideWith((ref) => Future.value(<String>{})),
          blockerIdsProvider.overrideWith((ref) => Future.value(<String>{})),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(gatheringDetailProvider('missing').future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
