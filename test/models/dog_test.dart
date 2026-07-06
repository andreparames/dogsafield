import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/shared/models/dog.dart';

void main() {
  group('Dog', () {
    test('creates with required fields', () {
      final dog = Dog(id: '1', name: 'Buddy');
      expect(dog.id, '1');
      expect(dog.name, 'Buddy');
      expect(dog.age, isNull);
      expect(dog.breed, isNull);
      expect(dog.vibe, isNull);
      expect(dog.icebreakerAnswer, isNull);
    });

    test('creates with all fields', () {
      final dog = Dog(
        id: '1',
        name: 'Buddy',
        age: 3,
        breed: 'Labrador',
        vibe: SocialVibe.zoomieKing,
        icebreakerAnswer: 'Stole a pizza',
      );
      expect(dog.age, 3);
      expect(dog.breed, 'Labrador');
      expect(dog.vibe, SocialVibe.zoomieKing);
      expect(dog.icebreakerAnswer, 'Stole a pizza');
    });

    group('copyWith', () {
      test('returns same instance when no args', () {
        final dog = Dog(id: '1', name: 'Buddy');
        final copy = dog.copyWith();
        expect(copy.id, dog.id);
        expect(copy.name, dog.name);
      });

      test('overrides provided fields', () {
        final dog = Dog(id: '1', name: 'Buddy', age: 3);
        final copy = dog.copyWith(name: 'Max', age: 5);
        expect(copy.id, '1');
        expect(copy.name, 'Max');
        expect(copy.age, 5);
      });

      test('preserves unset fields', () {
        final dog = Dog(id: '1', name: 'Buddy', breed: 'Lab');
        final copy = dog.copyWith(age: 4);
        expect(copy.breed, 'Lab');
        expect(copy.icebreakerAnswer, isNull);
      });
    });
  });
}
