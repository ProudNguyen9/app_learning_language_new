import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/quiz_provider.dart';

class QuizPage extends StatefulWidget {
  final List<Flashcard> flashcards;
  const QuizPage({super.key, required this.flashcards});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  static const Color _pageBackground = Color(0xFFF6F3FF);
  static const Color _surfaceColor = Colors.white;
  static const Color _borderColor = Color(0xFFE8E0FB);
  static const Color _mutedText = Color(0xFF7C7595);
  static const Color _primaryColor = Color(0xFF6C63FF);

  void _handleAnswer(BuildContext context, String selectedAnswer) {
    final quizProvider = context.read<QuizProvider>();

    final isCorrect = quizProvider.isCorrect(selectedAnswer);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        backgroundColor:
            isCorrect ? const Color(0xFF1E8E68) : const Color(0xFFC94B4B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        duration: const Duration(milliseconds: 800),
        content: Text(
          isCorrect
              ? 'Chính xác! Bạn đã chọn đúng đáp án.'
              : 'Chưa đúng, thử lại nhé.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!quizProvider.isLastQuestion) {
        quizProvider.nextQuestion();
      } else {
        Alert(
          context: context,
          type: AlertType.success,
          style: AlertStyle(
            animationType: AnimationType.grow,
            isCloseButton: false,
            isOverlayTapDismiss: false,
            backgroundColor: Colors.white,
            alertBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            titleStyle: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF241B4A),
            ),
            descStyle: GoogleFonts.lexend(
              fontSize: 13,
              height: 1.5,
              color: _mutedText,
            ),
          ),
          title: "Hoàn thành bài luyện tập!",
          desc:
              "Bạn đã đi hết ${quizProvider.allflashcard.length} câu hỏi và có ${quizProvider.incorrectAnswers} đáp án sai.",
          buttons: [
            DialogButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              color: _primaryColor,
              radius: BorderRadius.circular(16),
              width: 160,
              child: Text(
                "Hoàn tất",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ).show();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Load flashcards into the provider when the screen is initialized
    context.read<QuizProvider>().load(widget.flashcards);
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final question = quizProvider.currentflashcard;

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        foregroundColor: const Color(0xFF241B4A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bài luyện tập',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241B4A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Chọn đáp án đúng cho từng câu hỏi',
              style: GoogleFonts.lexend(fontSize: 12, color: _mutedText),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _borderColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1EEFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Câu ${quizProvider.currentIndex + 1}/${quizProvider.allflashcard.length}',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Sai: ${quizProvider.incorrectAnswers}',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: _mutedText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value:
                          (quizProvider.currentIndex + 1) /
                          quizProvider.allflashcard.length,
                      backgroundColor: const Color(0xFFE8E1FA),
                      color: _primaryColor,
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Câu hỏi',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _mutedText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.question,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF241B4A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy chọn đáp án đúng nhất trong các lựa chọn bên dưới.',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      height: 1.45,
                      color: _mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Lựa chọn đáp án',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241B4A),
              ),
            ),

            const SizedBox(height: 14),
            if (quizProvider.currentOptions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFD7D7)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFFF6B6B),
                      size: 30,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Không đủ dữ liệu để tạo đáp án',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8E3F3F),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children:
                    quizProvider.currentOptions.map((opt) {
                      return OptionButton(
                        text: opt,
                        onPressed: () => _handleAnswer(context, opt),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const OptionButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF241B4A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE8E0FB)),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF1EEFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF6C63FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
