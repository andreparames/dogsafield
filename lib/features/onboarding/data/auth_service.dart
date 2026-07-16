import 'package:supabase_flutter/supabase_flutter.dart';

const kAuthRedirectUrl = 'io.supabase.dogsafield://login-callback';

class AuthService {
  late final SupabaseClient _client;

  AuthService(SupabaseClient client) : _client = client;

  AuthService.test();

  User? get currentUser => _client.auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kAuthRedirectUrl,
    );
  }

  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: kAuthRedirectUrl,
    );
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<String?> validateReviewerCode(String code) async {
    final result = await _client.rpc('validate_reviewer_code', params: {
      'p_code': code,
    });
    return result as String?;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
