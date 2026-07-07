import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_utils.dart';

void main() {
  group('FakeRsvpRepository', () {
    late FakeRsvpRepository repo;

    setUp(() {
      repo = FakeRsvpRepository();
    });

    test('hasRsvp returns false initially', () async {
      expect(await repo.hasRsvp('evt-1'), false);
    });

    test('rsvpToEvent makes hasRsvp return true', () async {
      await repo.rsvpToEvent('evt-1');
      expect(await repo.hasRsvp('evt-1'), true);
    });

    test('cancelRsvp makes hasRsvp return false', () async {
      await repo.rsvpToEvent('evt-1');
      expect(await repo.hasRsvp('evt-1'), true);

      await repo.cancelRsvp('evt-1');
      expect(await repo.hasRsvp('evt-1'), false);
    });

    test('events are independent', () async {
      await repo.rsvpToEvent('evt-1');
      expect(await repo.hasRsvp('evt-1'), true);
      expect(await repo.hasRsvp('evt-2'), false);
    });

    test('throws on shouldFail', () async {
      repo.shouldFail = true;

      expect(() => repo.rsvpToEvent('x'), throwsA(isA<Exception>()));
      expect(() => repo.cancelRsvp('x'), throwsA(isA<Exception>()));
      expect(() => repo.hasRsvp('x'), throwsA(isA<Exception>()));
    });
  });
}
