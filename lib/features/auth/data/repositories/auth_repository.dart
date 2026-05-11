import 'package:supabase_flutter/supabase_flutter.dart';

typedef UserProfile = Map<String, dynamic>;

abstract interface class AuthRepository {
  Future<UserProfile> signIn(String email, String password);

  Future<void> registerAccount(String email, String password);

  Future<void> signOut();

  Future<void> sendResetPasswordEmail(String email);

  Future<bool> signInWithGoogle();

  UserProfile? getCurrentUserProfile();
}

final class LocalAuthRepository implements AuthRepository {
  UserProfile? _user;
  final supabase = Supabase.instance.client;

  @override
  Future<UserProfile> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Đăng nhập thất bại, vui lòng thử lại.');
    }

    _user = _mapSupabaseUser(user);

    return _user!;
  }

  @override
  Future<void> registerAccount(String email, String password) async {
    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );
      final Session? session = res.session;

      if (session == null) {
        print('Check your inbox for confirmation email!');
      }
    } catch (e) {
      print('Registration failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
    _user = null;
  }

  @override
  Future<void> sendResetPasswordEmail(String email) async {
    // TODO: Thay bằng call REST API/Supabase thực tế
  }

  @override
  Future<bool> signInWithGoogle() async {
    final started = await supabase.auth.signInWithOAuth(OAuthProvider.google);

    final user = supabase.auth.currentUser;
    if (user != null) {
      _user = _mapSupabaseUser(user);
    }

    return started;
  }

  @override
  UserProfile? getCurrentUserProfile() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      _user = _mapSupabaseUser(user);
    }

    return _user;
  }

  UserProfile _mapSupabaseUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};

    return {
      'uid': user.id,
      'email': user.email,
      'displayName': metadata['full_name'] ?? metadata['name'] ?? user.email,
      'photoURL': metadata['avatar_url'] ?? metadata['picture'],
      'phoneNumber': user.phone,
      'isEmailVerified': user.emailConfirmedAt != null,
    };
  }
}
