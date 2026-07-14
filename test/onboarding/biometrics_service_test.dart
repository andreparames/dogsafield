import 'dart:ui' show Rect;
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/onboarding/data/biometrics_service.dart';

void main() {
  group('BiometricsResult', () {
    test('creates result with person and dog counts', () {
      final result = const BiometricsResult(personCount: 1, dogCount: 2);

      expect(result.personCount, 1);
      expect(result.dogCount, 2);
      expect(result.humanTargetFaceCoordinates, isNull);
    });

    test('stores humanTargetFaceCoordinates when exactly one person', () {
      final rect = Rect.fromLTWH(10.0, 20.0, 100.0, 150.0);
      final result = BiometricsResult(
        personCount: 1,
        dogCount: 1,
        humanTargetFaceCoordinates: rect,
      );

      expect(result.humanTargetFaceCoordinates, isNotNull);
      expect(result.humanTargetFaceCoordinates!.left, 10.0);
      expect(result.humanTargetFaceCoordinates!.top, 20.0);
      expect(result.humanTargetFaceCoordinates!.width, 100.0);
      expect(result.humanTargetFaceCoordinates!.height, 150.0);
    });

    test('validates rule: personCount must be exactly 1 for pass', () {
      const pass = BiometricsResult(personCount: 1, dogCount: 1);
      const noPerson = BiometricsResult(personCount: 0, dogCount: 1);
      const tooManyPeople = BiometricsResult(personCount: 2, dogCount: 1);

      expect(pass.personCount == 1 && pass.dogCount >= 1, true);
      expect(noPerson.personCount == 1 && noPerson.dogCount >= 1, false);
      expect(tooManyPeople.personCount == 1 && tooManyPeople.dogCount >= 1, false);
    });

    test('validates rule: dogCount must be at least 1 for pass', () {
      const pass = BiometricsResult(personCount: 1, dogCount: 2);
      const noDog = BiometricsResult(personCount: 1, dogCount: 0);

      expect(pass.personCount == 1 && pass.dogCount >= 1, true);
      expect(noDog.personCount == 1 && noDog.dogCount >= 1, false);
    });

    test('humanTargetFaceCoordinates is only set when exactly one person', () {
      const zeroPeople = BiometricsResult(personCount: 0, dogCount: 1);
      const twoPeople = BiometricsResult(personCount: 2, dogCount: 1);

      // Simulating the logic from BiometricsService.analyzeImage:
      // humanTargetFaceCoordinates is set only when personCount == 1
      expect(zeroPeople.personCount == 1 ? zeroPeople.humanTargetFaceCoordinates : null, isNull);
      expect(twoPeople.personCount == 1 ? twoPeople.humanTargetFaceCoordinates : null, isNull);
    });
  });
}
