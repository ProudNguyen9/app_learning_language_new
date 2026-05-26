import 'package:apphoctienganh/features/learning/presentation/providers/speak_question_provider.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/speech_provider.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SpeechQuizScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const SpeechQuizScreen({super.key, required this.flashcards});

  @override
  State<SpeechQuizScreen> createState() => _SpeechQuizScreenState();
}

class _SpeechQuizScreenState extends State<SpeechQuizScreen> {
  static const Color _pageBackground = Color(0xFFF6F3FF);
  static const Color _surfaceColor = Colors.white;
  static const Color _borderColor = Color(0xFFE8E0FB);
  static const Color _mutedText = Color(0xFF7C7595);
  static const Color _primaryColor = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    requestMicPermission();
    final provider = Provider.of<SpeechQuestionProvider>(
      context,
      listen: false,
    );
    provider.loadData(widget.flashcards); // Load flashcards mới từ widget
  }

  Future<void> requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpeechQuestionProvider>(context);

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        foregroundColor: const Color(0xFF241B4A),
        title: Text(
          'Phát âm',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF241B4A),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          provider.currentQuestion.question,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF241B4A),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nghe từ rồi đọc lại thật rõ để kiểm tra phát âm.',
                    style: GoogleFonts.lexend(fontSize: 12, color: _mutedText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (provider.isListening)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderColor),
                ),
                child: Text(
                  'Bạn đã đọc: ${provider.spokenText}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A4563),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        provider.currentIndex > 0
                            ? provider.previousQuestion
                            : null,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: _borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Câu trước',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A4563),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        provider.isLastQuestion ? null : provider.nextQuestion,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: _borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Câu tiếp',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A4563),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final currentQuestion =
                          context
                              .read<SpeechQuestionProvider>()
                              .currentQuestion;
                      context.read<SpeechProvider>().speakTextWithLanguage(
                        currentQuestion.question,
                        currentQuestion.questionLanguage,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      side: const BorderSide(color: _primaryColor, width: 1.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.volume_up_rounded,
                          color: _primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nghe lại',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (provider.isListening) {
                        provider.stopListening();
                        final correct = provider.checkAnswer();
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                title: Text(
                                  correct ? 'Chính xác!' : 'Chưa đúng!',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF241B4A),
                                  ),
                                ),
                                content: Text(
                                  correct
                                      ? 'Bạn đã phát âm đúng từ này.'
                                      : 'Bạn cần luyện thêm. Đáp án đúng là:\n"${provider.currentQuestion.question}"',
                                  style: GoogleFonts.lexend(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: _mutedText,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      if (!provider.isLastQuestion) {
                                        provider.nextQuestion();
                                      }
                                    },
                                    child: Text(
                                      provider.isLastQuestion
                                          ? 'Hoàn tất'
                                          : 'Câu tiếp',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        color: _primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      } else {
                        provider.startListening();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          provider.isListening
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.isListening ? 'Dừng' : 'Thu âm',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.isLastQuestion)
              Text(
                'Bạn đang ở câu cuối cùng.',
                style: GoogleFonts.lexend(fontSize: 12, color: _mutedText),
              ),
          ],
        ),
      ),
    );
  }
}
