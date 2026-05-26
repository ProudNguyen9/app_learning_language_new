import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/flashcard/presentation/widgets/flashcard_screen_styles.dart';
import 'package:flutter/material.dart';

class FlashcardNavButton extends StatelessWidget {
  const FlashcardNavButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlashcardScreenStyles.accentSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: ColorSetting.colorprimary,
        iconSize: 20,
        onPressed: onTap,
      ),
    );
  }
}
