import 'package:apphoctienganh/features/auth/domain/entities/user_profile.dart';

abstract interface class AuthRepository {
  Future<UserProfile> signIn(String email, String password);

  Future<void> registerAccount(String email, String password);

  Future<void> signOut();

  Future<void> sendResetPasswordEmail(String email);

  Future<bool> signInWithGoogle();

  UserProfile? getCurrentUserProfile();
}
