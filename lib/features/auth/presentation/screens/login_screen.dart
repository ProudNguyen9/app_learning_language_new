import 'package:apphoctienganh/features/auth/presentation/providers/auth_provider.dart';
import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/home/presentation/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String error = "";
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorSetting.background,
        appBar: AppBar(
          backgroundColor: ColorSetting.background,
          centerTitle: true,
          title: Text(
            'Đăng nhập',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: ColorSetting.colorprimary,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Chào mừng",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.waving_hand, color: Colors.orange, size: 21),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Hãy để chúng tôi giúp bạn kết nối các điểm trong quá trình học tập của bạn.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Email',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      final pattern =
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                      final regex = RegExp(pattern);
                      if (!regex.hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Mật khẩu',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return TextFormField(
                        controller: passwordController,
                        obscureText: authProvider.isObscure,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Mật khẩu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              authProvider.isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 21,
                            ),
                            onPressed: authProvider.toggleObscure,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).goToResetpassPage(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Quên mật khẩu ?",
                            style: GoogleFonts.plusJakartaSans(fontSize: 14),
                          ),
                          Gap(5),
                          Text(
                            "Đặt lại",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Center(
                    child: SizedBox(
                      height: 52,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorSetting.colorprimary,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              await authProvider.signIn(
                                emailController.text.trim(),
                                passwordController.text,
                                context,
                              );
                            } catch (e) {
                              setState(() {
                                error = e.toString();
                              });
                            }
                          }
                        },
                        child: Text(
                          "Đăng nhập",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: SizedBox(
                      height: 52,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: OutlinedButton(
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );

                          try {
                            final success =
                                await authProvider.signInWithGoogle();
                            if (success) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đăng nhập thất bại!'),
                                ),
                              );
                            }
                          } catch (e) {
                            print('Lỗi đăng nhập Google: $e');
                          }
                        },

                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.black),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: Image.asset('assets/logo google.png'),
                            ),
                            const Text(
                              ' Tiếp tục với Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).goToRegisterPage(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Bạn chưa có tài khoản?",
                            style: GoogleFonts.plusJakartaSans(fontSize: 14),
                          ),
                          Gap(5),
                          Text(
                            "Đăng ký",
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
