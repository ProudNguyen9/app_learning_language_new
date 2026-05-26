import 'package:apphoctienganh/features/learning/presentation/providers/question_answer_provider.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class QuestionAnswerScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  const QuestionAnswerScreen({super.key, required this.flashcards});

  @override
  State<QuestionAnswerScreen> createState() => _QuestionAnswerScreenState();
}

// ... giữ nguyên các import và class đầu

class _QuestionAnswerScreenState extends State<QuestionAnswerScreen> {
  late TextEditingController controller;

  static const Color _pageBackground = Color(0xFFF6F3FF);
  static const Color _surfaceColor = Colors.white;
  static const Color _borderColor = Color(0xFFE8E0FB);
  static const Color _mutedText = Color(0xFF7C7595);
  static const Color _primaryColor = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<QuestionAnswerProvider>(
      context,
      listen: false,
    );
    controller = TextEditingController(text: provider.userAnswer);
    context.read<QuestionAnswerProvider>().loadData(widget.flashcards);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuestionAnswerProvider>(context);

    // Giữ đồng bộ controller với userAnswer
    controller.value = controller.value.copyWith(
      text: provider.userAnswer,
      selection: TextSelection.collapsed(offset: provider.userAnswer.length),
    );

    return Scaffold(
      backgroundColor: _pageBackground,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        titleSpacing: 20,
        backgroundColor: _pageBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF241B4A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Học hỏi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241B4A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Điền đáp án theo từ đang hiển thị',
              style: GoogleFonts.lexend(fontSize: 12, color: _mutedText),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(28),
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
                                  'Câu ${provider.currentIndex + 1}/${provider.cards.length}',
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryColor,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.lightbulb_rounded,
                                color: const Color(0xFFFFC857),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Thuật ngữ',
                            style: GoogleFonts.lexend(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _mutedText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.currentCard.question,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 29,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                              color: const Color(0xFF241B4A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Nhập nghĩa chính xác nhất cho từ hoặc cụm từ này.',
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Câu trả lời của bạn',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF241B4A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Điền đáp án rồi bấm kiểm tra để xem kết quả.',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              color: _mutedText,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: controller,
                            onChanged: provider.updateAnswer,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF241B4A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Nhập nghĩa của từ ở đây',
                              hintStyle: GoogleFonts.lexend(
                                color: _mutedText,
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFCFBFF),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color:
                                      provider.submitted
                                          ? provider.isCorrect
                                              ? const Color(0xFF2FBF71)
                                              : const Color(0xFFFF6B6B)
                                          : _borderColor,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                  color:
                                      provider.submitted
                                          ? provider.isCorrect
                                              ? const Color(0xFF2FBF71)
                                              : const Color(0xFFFF6B6B)
                                          : _borderColor,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: _primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (provider.submitted && !provider.isCorrect) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFFFDFDF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bạn đã nhập',
                              style: GoogleFonts.lexend(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFB65A5A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.userAnswer,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF8E3F3F),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6FAF1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFB7EFD7)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đáp án đúng',
                              style: GoogleFonts.lexend(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E8E68),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.currentCard.answer,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                color: const Color(0xFF12B886),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (provider.submitted && provider.isCorrect) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAFBF2),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFBCEFD6)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF24B273),
                              size: 26,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Chính xác rồi. Bạn có thể sang câu tiếp theo.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E8E68),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: provider.checkAnswer,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        side: const BorderSide(
                          color: _primaryColor,
                          width: 1.6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'Kiểm tra',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        final continued = provider.nextQuestion();
                        if (!continued) {
                          Alert(
                            context: context,
                            type: AlertType.success,
                            title: "Kết thúc bài kiểm tra!",
                            desc:
                                "Điểm của bạn: ${provider.score}/${provider.cards.length}",
                            buttons: [
                              DialogButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                width: 120,
                                child: const Text(
                                  "OK",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ).show();
                        }
                      },
                      child: Text(
                        'Câu tiếp theo',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
