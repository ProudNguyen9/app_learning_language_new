import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/flashcard/presentation/widgets/flashcard_screen_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlashcardTermItem extends StatelessWidget {
  const FlashcardTermItem({
    super.key,
    required this.question,
    required this.answer,
    required this.onSpeak,
  });

  final String question;
  final String answer;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FlashcardScreenStyles.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FlashcardScreenStyles.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thuật ngữ',
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: FlashcardScreenStyles.mutedText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      question,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF221B4B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 12),
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
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: FlashcardScreenStyles.borderColor),
          ),
          Text(
            'Nghĩa',
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: FlashcardScreenStyles.mutedText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A4563),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
