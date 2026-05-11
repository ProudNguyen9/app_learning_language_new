import 'package:apphoctienganh/features/auth/presentation/providers/auth_provider.dart';
import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EnterEmailScreen extends StatefulWidget {
  const EnterEmailScreen({super.key});

  @override
  State<EnterEmailScreen> createState() => _EnterEmailScreenState();
}

class _EnterEmailScreenState extends State<EnterEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorSetting.background,
        appBar: AppBar(
          backgroundColor: ColorSetting.background,
          centerTitle: true,
          title: Text(
            'Đặt lại mật khẩu',
            style: GoogleFonts.rubikStorm(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: ColorSetting.colorprimary,
            ),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhập email để nhận liên kết đặt lại mật khẩu.',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel("Email"),
                const SizedBox(height: 10),
                _buildEmailField(),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    height: 52,
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorSetting.colorprimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await authProvider.sendResetPasswordEmail(
                              _emailController.text.trim(),
                              context,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                      child: Text(
                        'Gửi yêu cầu',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: _inputDecoration("Email"),
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Vui lòng nhập email';
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) return 'Email không hợp lệ';
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.black.withOpacity(0.5),
      ),
    );
  }
}
