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

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
