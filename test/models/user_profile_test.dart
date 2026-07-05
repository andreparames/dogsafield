import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/shared/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('creates with required fields', () {
      final profile = UserProfile(id: 'u1', email: 'a@b.com');
      expect(profile.id, 'u1');
      expect(profile.email, 'a@b.com');
      expect(profile.displayName, isNull);
      expect(profile.isVerified, false);
      expect(profile.trialRsvpsUsed, 0);
      expect(profile.isFoundingPack, false);
    });

    test('creates with all fields', () {
      final profile = UserProfile(
        id: 'u1',
        email: 'a@b.com',
        displayName: 'Alice',
        photoUrl: 'https://example.com/photo.jpg',
        isVerified: true,
        trialRsvpsUsed: 2,
        isFoundingPack: true,
        treatPolicy: TreatPolicy.okToShare,
      );
      expect(profile.displayName, 'Alice');
      expect(profile.photoUrl, 'https://example.com/photo.jpg');
      expect(profile.isVerified, true);
      expect(profile.trialRsvpsUsed, 2);
      expect(profile.isFoundingPack, true);
      expect(profile.treatPolicy, TreatPolicy.okToShare);
    });

    group('copyWith', () {
      test('overrides provided fields', () {
        final profile = UserProfile(id: 'u1', email: 'a@b.com');
        final copy = profile.copyWith(displayName: 'Alice', isVerified: true);
        expect(copy.displayName, 'Alice');
        expect(copy.isVerified, true);
      });

      test('preserves unset fields', () {
        final profile = UserProfile(
          id: 'u1',
          email: 'a@b.com',
          displayName: 'Alice',
          treatPolicy: TreatPolicy.okToShare,
        );
        final copy = profile.copyWith(treatPolicy: TreatPolicy.askBeforeFeeding);
        expect(copy.displayName, 'Alice');
        expect(copy.treatPolicy, TreatPolicy.askBeforeFeeding);
      });
    });
  });
}
