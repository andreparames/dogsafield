import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/field_map/data/gathering_detail.dart';
import 'package:dogsafield/shared/models/dog.dart';
import 'package:dogsafield/shared/models/event.dart';
import 'package:dogsafield/shared/models/user_profile.dart';
import '../../helpers/test_utils.dart';

void main() {
  group('FakeGatheringRepository', () {
    late FakeGatheringRepository repo;

    setUp(() {
      repo = FakeGatheringRepository();
    });

    test('returns detail when set', () async {
      final detail = GatheringDetail(
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
        ),
        host: UserProfile(
          id: 'host-1',
          email: 'host@test.com',
          displayName: 'Jane',
        ),
        hostDogs: [
          Dog(
            id: 'dog-1',
            ownerId: 'host-1',
            name: 'Buddy',
            breed: 'Golden Retriever',
            vibe: SocialVibe.zoomieKing,
          ),
        ],
      );
      repo.detail = detail;

      final result = await repo.fetchGatheringDetail('evt-1');

      expect(result.event.id, 'evt-1');
      expect(result.host.displayName, 'Jane');
      expect(result.hostDogs.first.name, 'Buddy');
    });

    test('throws when shouldFail is true', () async {
      repo.shouldFail = true;

      expect(
        () => repo.fetchGatheringDetail('x'),
        throwsA(isA<Exception>()),
      );
    });

    test('throws when detail is null', () async {
      expect(
        () => repo.fetchGatheringDetail('missing'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
