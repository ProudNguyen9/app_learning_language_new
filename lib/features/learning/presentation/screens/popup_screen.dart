import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/popup_provider.dart';
import 'dart:async';

import 'package:rflutter_alert/rflutter_alert.dart';

class Popupscreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  const Popupscreen({super.key, required this.flashcards});

  @override
  State<Popupscreen> createState() => _PopupscreenState();
}

class _PopupscreenState extends State<Popupscreen> {
  Timer? _timer;
  double _seconds = 0.0;
  static const Color _pageBackground = Color(0xFFF6F3FF);
  static const Color _surfaceColor = Colors.white;
  static const Color _borderColor = Color(0xFFE8E0FB);
  static const Color _mutedText = Color(0xFF7C7595);
  static const Color _primaryColor = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();

    // Gọi hàm load dữ liệu từ provider
    context.read<Popupprovider>().loadInitialFlashcards(widget.flashcards);
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _seconds += 0.1;
      });

      final flashcardProvider = context.read<Popupprovider>();
      final flashcards = flashcardProvider.flashcards;

      if (flashcardProvider.matchedIndexes.length == flashcards.length) {
        timer.cancel();
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
          title: "Hoàn thành!",
          desc:
              "Bạn đã ghép đúng toàn bộ thẻ trong ${_seconds.toStringAsFixed(1)} giây.",
          buttons: [
            DialogButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(context).pop(); // Quay lại màn hình trước
              },
              width: 160,
              color: _primaryColor,
              radius: BorderRadius.circular(16),
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashcards = context.watch<Popupprovider>().flashcards;
    final flashcardProvider = context.read<Popupprovider>();

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
              'Ghép hình',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241B4A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Ghép các cặp từ và nghĩa tương ứng',
              style: GoogleFonts.lexend(fontSize: 12, color: _mutedText),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            'Ghép đúng tất cả các cặp',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Thời gian',
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _mutedText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_seconds.toStringAsFixed(1)} giây',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF241B4A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F4FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      FontAwesomeIcons.clock,
                      size: 22,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: flashcards.length,
                itemBuilder: (_, index) {
                  final flashcard = flashcards[index];
                  final isSelected = flashcardProvider.selectedIndexes.contains(
                    index,
                  );
                  final isIncorrect = flashcardProvider.incorrectIndexes
                      .contains(index);
                  final isMatched = flashcardProvider.matchedIndexes.contains(
                    index,
                  );
                  final isQuestion = flashcard.id.endsWith('_q');
                  final text =
                      isQuestion ? flashcard.question : flashcard.answer;

                  return GestureDetector(
                    onTap: () {
                      flashcardProvider.selectCard(index);
                    },
                    child: FlashcardTile(
                      text: text,
                      isSelected: isSelected,
                      isIncorrect: isIncorrect,
                      isMatched: isMatched,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isIncorrect;
  final bool isMatched;

  const FlashcardTile({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isIncorrect,
    required this.isMatched,
  });

  @override
  Widget build(BuildContext context) {
    if (isMatched) {
      return const SizedBox.shrink();
    }

    return Opacity(
      opacity: isSelected ? 0.4 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color:
              isMatched
                  ? const Color(0xFFEAFBF2)
                  : isIncorrect
                  ? const Color(0xFFFFF1F1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                isMatched
                    ? const Color(0xFFBCEFD6)
                    : isIncorrect
                    ? const Color(0xFFFFD0D0)
                    : const Color(0xFFE8E0FB),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF241B4A),
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
