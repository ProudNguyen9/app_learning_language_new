import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/word_scramble_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class WordScrambleScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const WordScrambleScreen({super.key, required this.flashcards});

  @override
  State<WordScrambleScreen> createState() => _WordScrambleScreenState();
}

class _WordScrambleScreenState extends State<WordScrambleScreen> {
  late WordScrambleProvider provider;
  static const Color _pageBackground = Color(0xFFF6F3FF);
  static const Color _surfaceColor = Colors.white;
  static const Color _borderColor = Color(0xFFE8E0FB);
  static const Color _mutedText = Color(0xFF7C7595);
  static const Color _primaryColor = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    provider = WordScrambleProvider();
    provider.loadData(widget.flashcards); // Load flashcards and shuffle
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: Scaffold(
        backgroundColor: _pageBackground,
        appBar: AppBar(
          backgroundColor: _pageBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 20,
          foregroundColor: const Color(0xFF241B4A),
          title: Text(
            'Xếp chữ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF241B4A),
            ),
          ),
        ),
        body: Consumer<WordScrambleProvider>(
          builder: (context, provider, _) {
            return Padding(
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
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF4FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.sort_by_alpha_rounded,
                                color: _primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Sắp xếp đúng từ này',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF241B4A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chủ đề: ${provider.currentCard.answer}',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            color: _mutedText,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3EEFF),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              provider.originalWord.length,
                              (index) {
                                return DragTarget<LetterUnit>(
                                  onAcceptWithDetails: (letterDetails) {
                                    final letter = letterDetails.data;
                                    final fromIndex = provider.userAnswer
                                        .indexOf(letter);
                                    if (fromIndex != -1) {
                                      provider.moveLetterBetweenTargets(
                                        letter,
                                        fromIndex,
                                        index,
                                      );
                                    } else {
                                      provider.acceptLetter(letter, index);
                                    }
                                  },
                                  builder: (_, accepted, rejected) {
                                    final letter =
                                        index < provider.userAnswer.length
                                            ? provider.userAnswer[index]
                                            : null;
                                    return Container(
                                      width: 54,
                                      height: 54,
                                      margin: const EdgeInsets.all(2),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: _borderColor),
                                        color: Colors.white,
                                      ),
                                      child:
                                          letter != null
                                              ? Draggable<LetterUnit>(
                                                data: letter,
                                                feedback: Material(
                                                  color: Colors.transparent,
                                                  child: _letterBox(
                                                    letter.char,
                                                  ),
                                                ),
                                                childWhenDragging:
                                                    const SizedBox.shrink(),
                                                child: Text(
                                                  letter.char,
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: _primaryColor,
                                                      ),
                                                ),
                                                onDragCompleted: () {
                                                  provider
                                                      .removeLetterFromAnswer(
                                                        index,
                                                      );
                                                },
                                              )
                                              : null,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  Center(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          provider.shuffledLetters.map((letter) {
                            return ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 100),
                              child: Draggable<LetterUnit>(
                                data: letter,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: _letterBox(letter.char),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: _letterBox(letter.char),
                                ),
                                child: _letterBox(letter.char),
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed:
                          provider.submitted
                              ? () {
                                if (!provider.next()) {
                                  provider.reset();
                                }
                              }
                              : provider.submit,
                      child: Text(
                        provider.submitted ? 'Từ khác' : 'Kiểm tra đáp án',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  if (provider.submitted)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color:
                            provider.isCorrect
                                ? const Color(0xFFEAFBF2)
                                : const Color(0xFFFFF4E8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              provider.isCorrect
                                  ? const Color(0xFFBCEFD6)
                                  : const Color(0xFFFFD7A8),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                provider.isCorrect
                                    ? Icons.check_circle_rounded
                                    : Icons.error_rounded,
                                color:
                                    provider.isCorrect
                                        ? const Color(0xFF24B273)
                                        : const Color(0xFFEF8A17),
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                provider.isCorrect
                                    ? 'Chính xác!'
                                    : 'Chưa đúng!',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      provider.isCorrect
                                          ? const Color(0xFF1E8E68)
                                          : const Color(0xFFB86A10),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(height: 1, color: Color(0xFFE8E0FB)),
                          ),
                          Text(
                            'Từ gốc',
                            style: GoogleFonts.lexend(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _mutedText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            provider.currentCard.question,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF241B4A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nghĩa',
                            style: GoogleFonts.lexend(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _mutedText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            provider.currentCard.answer,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4A4563),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Dialog when retrying wrong answers
                  if (provider.isLast && provider.wrongCount > 0)
                    Builder(
                      builder: (context) {
                        Future.delayed(
                          Duration.zero,
                          () =>
                              Alert(
                                context: context,
                                type: AlertType.warning,
                                title: "Bạn có muốn làm lại các câu sai không?",
                                buttons: [
                                  DialogButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      provider.retryWrongQuestions();
                                    },
                                    color: Colors.blue,
                                    child: const Text(
                                      "Làm lại",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  DialogButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    color: Colors.red,
                                    child: const Text(
                                      "Không",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ).show(),
                        );
                        return const SizedBox.shrink(); // Return an empty widget
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _letterBox(String letter) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Text(
        letter,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: _primaryColor,
        ),
      ),
    );
  }
}
