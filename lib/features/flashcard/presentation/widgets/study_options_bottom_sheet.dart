import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/flashcard/flashcard.dart';
import 'package:apphoctienganh/features/learning/learning.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudyOptionsBottomSheet extends StatelessWidget {
  const StudyOptionsBottomSheet({super.key, required this.flashcards});

  final List<Flashcard> flashcards;

  @override
  Widget build(BuildContext context) {
    final items = <_StudyOptionData>[
      _StudyOptionData(
        icon: Icons.psychology_rounded,
        title: 'Học hỏi',
        subtitle: 'Điền nghĩa từ vựng theo từng câu hỏi',
        color: const Color(0xFFE96AA8),
        onTap:
            () => _open(context, QuestionAnswerScreen(flashcards: flashcards)),
      ),
      _StudyOptionData(
        icon: Icons.assignment_rounded,
        title: 'Bài luyện tập',
        subtitle: 'Luyện tập trắc nghiệm nhanh theo bộ thẻ',
        color: const Color(0xFF4C8BF5),
        onTap: () => _open(context, QuizPage(flashcards: flashcards)),
      ),
      _StudyOptionData(
        icon: Icons.auto_fix_high_rounded,
        title: 'Đoán chữ',
        subtitle: 'Đoán chữ còn thiếu dựa trên nghĩa',
        color: const Color(0xFF32B87A),
        onTap: () => _open(context, WordGuessScreen(flashcards: flashcards)),
      ),
      _StudyOptionData(
        icon: Icons.extension_rounded,
        title: 'Ghép hình',
        subtitle: 'Tìm các cặp thẻ giống nhau thật nhanh',
        color: const Color(0xFFF4A340),
        onTap: () => _open(context, Popupscreen(flashcards: flashcards)),
      ),
      _StudyOptionData(
        icon: Icons.mic_rounded,
        title: 'Phát âm',
        subtitle: 'Luyện đọc và phát âm từ vựng rõ hơn',
        color: const Color(0xFF4C8BF5),
        onTap: () => _open(context, SpeechQuizScreen(flashcards: flashcards)),
      ),
      _StudyOptionData(
        icon: Icons.grid_view_rounded,
        title: 'Xếp chữ',
        subtitle: 'Sắp xếp chữ để tạo thành từ đúng',
        color: const Color(0xFFFF7E67),
        onTap: () => _open(context, WordScrambleScreen(flashcards: flashcards)),
      ),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.48,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: FlashcardScreenStyles.pageBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 54,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8D1EC),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: FlashcardScreenStyles.accentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Chế độ học',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ColorSetting.colorprimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chọn cách học phù hợp',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF241B4A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ôn tập bộ thẻ của bạn bằng nhiều chế độ khác nhau để đỡ nhàm chán và nhớ lâu hơn.',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        height: 1.5,
                        color: FlashcardScreenStyles.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _StudyOptionTile(item: item);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _StudyOptionTile extends StatelessWidget {
  const _StudyOptionTile({required this.item});

  final _StudyOptionData item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: item.onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FlashcardScreenStyles.cardBackground,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: FlashcardScreenStyles.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const Spacer(),
              Text(
                item.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF221B4B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  height: 1.4,
                  color: FlashcardScreenStyles.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudyOptionData {
  const _StudyOptionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}
