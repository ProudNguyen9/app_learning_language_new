import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/flashcard/presentation/widgets/flashcard_screen_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlashcardFaceWidget extends StatelessWidget {
  const FlashcardFaceWidget({
    super.key,
    required this.text,
    required this.pathImage,
    required this.onSpeak,
    required this.languageCode,
  });

  final String text;
  final String? pathImage;
  final VoidCallback onSpeak;
  final String languageCode;

  String get _languageFlag {
    final countryCode = languageCode.split('-').last.toUpperCase();
    if (countryCode.length != 2) return '🌐';

    return String.fromCharCodes(
      countryCode.codeUnits.map((codeUnit) => codeUnit + 127397),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: FlashcardScreenStyles.cardBackground,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: FlashcardScreenStyles.borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF241B4A),
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (pathImage != null)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(pathImage!, fit: BoxFit.cover),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 22,
          left: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: FlashcardScreenStyles.accentSoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_languageFlag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  languageCode,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ColorSetting.colorprimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 22,
          right: 24,
          child: Container(
            decoration: BoxDecoration(
              color: FlashcardScreenStyles.accentSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: const Icon(Icons.volume_up_rounded),
              color: ColorSetting.colorprimary,
              onPressed: onSpeak,
            ),
          ),
        ),
      ],
    );
  }
}
