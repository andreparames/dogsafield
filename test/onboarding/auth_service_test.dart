import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/onboarding/data/auth_service.dart';

void main() {
  group('AuthService', () {
    test('kAuthRedirectUrl is defined and non-empty', () {
      expect(kAuthRedirectUrl, isNotEmpty);
    });

    test('kAuthRedirectUrl uses expected scheme', () {
      expect(kAuthRedirectUrl, contains('://'));
      expect(kAuthRedirectUrl, startsWith('io.supabase'));
    });
  });
}
