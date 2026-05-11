import 'package:apphoctienganh/features/auth/data/repositories/auth_repository.dart';
import 'package:apphoctienganh/features/auth/presentation/screens/login_screen.dart';
import 'package:apphoctienganh/features/auth/presentation/screens/register_screen.dart';
import 'package:apphoctienganh/features/auth/presentation/screens/send_email_password_screen.dart';
import 'package:apphoctienganh/features/home/presentation/screens/home_page.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? LocalAuthRepository();

  final AuthRepository _repository;

  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  //  hide password in client
  bool _isObscure = true;
  bool get isObscure => _isObscure;

  Future<void> signIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    _user = await _repository.signIn(email, password);
    notifyListeners();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  // Đăng ký tài khoản mới
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

  // Đăng xuất khỏi Google cả  phần email
  Future<void> signOut(BuildContext context) async {
    try {
      await _repository.signOut();
      _user = _repository.getCurrentUserProfile();
      notifyListeners();

      // Điều hướng tường minh về màn hình đăng nhập
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, // Xóa toàn bộ stack
      );
    } catch (e) {
      print('Đăng xuất thất bại: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra khi đăng xuất!')));
    }
  }

  // method hide  password
  void toggleObscure() {
    _isObscure = !_isObscure;
    notifyListeners();
  }

  // Phương thức gửi email reset mật khẩu
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

  // Đăng nhập giả lập với Google (UI local)
  Future<bool> signInWithGoogle() async {
    final success = await _repository.signInWithGoogle();
    if (!success) return false;

    _user = _repository.getCurrentUserProfile();
    notifyListeners();
    return success;
  }

  // lấy profile
  Map<String, dynamic>? getCurrentUserProfile() {
    return _repository.getCurrentUserProfile();
  }
}
