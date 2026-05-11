import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2C2A51),
        letterSpacing: 1.1,
        height: 1.2,
      ),
    );
  }
}
