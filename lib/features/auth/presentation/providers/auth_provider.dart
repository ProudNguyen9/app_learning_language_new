import 'package:apphoctienganh/features/auth/data/repositories/auth_repository.dart';
import 'package:apphoctienganh/features/auth/domain/entities/user_profile.dart';
import 'package:apphoctienganh/features/auth/domain/repositories/auth_repository.dart';
import 'package:apphoctienganh/features/auth/presentation/screens/login_screen.dart';
import 'package:apphoctienganh/features/auth/presentation/screens/register_screen.dart';
import 'package:apphoctienganh/features/auth/presentation/screens/send_email_password_screen.dart';
import 'package:apphoctienganh/features/home/presentation/screens/centerhome.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? LocalAuthRepository();

  final AuthRepository _repository;

  UserProfile? _user;
  UserProfile? get user => _user;

  bool _isObscure = true;
  bool get isObscure => _isObscure;

  Future<void> signIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    _user = await _repository.signIn(email, password);
    notifyListeners();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CenterHome()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> registerAccount(
    String email,
    String password,
    BuildContext context,
  ) async {
    await _repository.registerAccount(email, password);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void goToRegisterPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Register_Screen()),
    );
  }

  void goToResetpassPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EnterEmailScreen()),
    );
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _repository.signOut();
      _user = _repository.getCurrentUserProfile();
      notifyListeners();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Đăng xuất thất bại: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi đăng xuất!')),
      );
    }
  }

  void toggleObscure() {
    _isObscure = !_isObscure;
    notifyListeners();
  }

  Future<void> sendResetPasswordEmail(
    String email,
    BuildContext context,
  ) async {
    await _repository.sendResetPasswordEmail(email);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã ghi nhận yêu cầu đặt lại mật khẩu (UI local).'),
      ),
    );
  }

  Future<bool> signInWithGoogle() async {
    final success = await _repository.signInWithGoogle();
    if (!success) return false;

    _user = _repository.getCurrentUserProfile();
    notifyListeners();
    return success;
  }

  UserProfile? getCurrentUserProfile() {
    return _repository.getCurrentUserProfile();
  }
}
