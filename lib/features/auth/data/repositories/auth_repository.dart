import 'package:apphoctienganh/features/auth/data/models/user_profile_model.dart';
import 'package:apphoctienganh/features/auth/domain/entities/user_profile.dart';
import 'package:apphoctienganh/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    _user = UserProfileModel.fromSupabaseUser(user).toEntity();

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
    return await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback/',
    );
  }

  @override
  UserProfile? getCurrentUserProfile() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      _user = UserProfileModel.fromSupabaseUser(user).toEntity();
    }

    return _user;
  }
}
