import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_utils.dart';

void main() {
  group('FakeWaitlistRepository', () {
    late FakeWaitlistRepository repo;

    setUp(() {
      repo = FakeWaitlistRepository();
    });

    test('fetchMyStatus returns null initially', () async {
      expect(await repo.fetchMyStatus('walk-1'), isNull);
    });

    test('joinWaitlist creates a waiting entry', () async {
      final entry = await repo.joinWaitlist('walk-1');
      expect(entry.status, 'waiting');
      expect(entry.walkId, 'walk-1');
    });

    test('confirmSpot changes status to confirmed', () async {
      await repo.joinWaitlist('walk-1');
      await repo.confirmSpot('walk-1');
      final entry = await repo.fetchMyStatus('walk-1');
      expect(entry?.status, 'confirmed');
      expect(entry?.confirmedAt, isNotNull);
    });

    test('leaveWaitlist removes entry', () async {
      await repo.joinWaitlist('walk-1');
      await repo.leaveWaitlist('walk-1');
      expect(await repo.fetchMyStatus('walk-1'), isNull);
    });

    test('fetchCounts returns correct counts', () async {
      await repo.joinWaitlist('walk-1');
      var counts = await repo.fetchCounts('walk-1');
      expect(counts['waiting'], 1);
      expect(counts['confirmed'], 0);

      await repo.confirmSpot('walk-1');
      counts = await repo.fetchCounts('walk-1');
      expect(counts['waiting'], 0);
      expect(counts['confirmed'], 1);
    });

    test('throws on shouldFail', () async {
      repo.shouldFail = true;

      expect(() => repo.joinWaitlist('x'), throwsA(isA<Exception>()));
      expect(() => repo.confirmSpot('x'), throwsA(isA<Exception>()));
      expect(() => repo.leaveWaitlist('x'), throwsA(isA<Exception>()));
      expect(() => repo.fetchMyStatus('x'), throwsA(isA<Exception>()));
      expect(() => repo.fetchCounts('x'), throwsA(isA<Exception>()));
    });
  });
}
