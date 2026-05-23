import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/word_guessing_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class WordGuessScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const WordGuessScreen({super.key, required this.flashcards});

  @override
  _WordGuessScreenState createState() => _WordGuessScreenState();
}

class _WordGuessScreenState extends State<WordGuessScreen> {
  static const Color _pageBackground = Color(0xFFF6F3FF);
  static const Color _surfaceColor = Colors.white;
  static const Color _borderColor = Color(0xFFE8E0FB);
  static const Color _mutedText = Color(0xFF7C7595);
  static const Color _primaryColor = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    context.read<WordGuessProvider>().load(widget.flashcards);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordGuessProvider>();
    final card = provider.current;

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
              'Đoán chữ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241B4A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Đoán chữ cái còn thiếu trong từ vựng',
              style: GoogleFonts.lexend(fontSize: 12, color: _mutedText),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Container(
            color: _pageBackground,
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
                              'Thử thách đoán chữ',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _primaryColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.auto_fix_high_rounded,
                            color: Color(0xFFFFC857),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Đoán chữ cái bị ẩn',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF241B4A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Quan sát từ đã bị ẩn một phần rồi nhập chữ cái còn thiếu để hoàn thành từ.',
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

                Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Từ đang đoán',
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _mutedText,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          provider.maskedWord,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                            color: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                if (!provider.submitted)
                  Container(
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
                          'Nhập chữ cái',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF241B4A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Chỉ nhập một ký tự để kiểm tra đáp án.',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            color: _mutedText,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          maxLength: 1,
                          decoration: InputDecoration(
                            labelText: 'Nhập chữ cái',
                            labelStyle: GoogleFonts.lexend(
                              color: _primaryColor,
                              fontSize: 13,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: _borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: _primaryColor,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: _borderColor),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFCFBFF),
                            counterText: "",
                            prefixIcon: const Icon(
                              Icons.edit_rounded,
                              color: _primaryColor,
                            ),
                          ),
                          onChanged:
                              context.read<WordGuessProvider>().updateInput,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _primaryColor,
                          ),
                        ),
                      ],
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
                    onPressed: () {
                      if (context.read<WordGuessProvider>().submitted) {
                        context.read<WordGuessProvider>().next();
                      } else {
                        context.read<WordGuessProvider>().submit();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.submitted
                              ? 'Từ tiếp theo'
                              : 'Kiểm tra đáp án',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          provider.submitted
                              ? Icons.arrow_forward_rounded
                              : Icons.check_circle_rounded,
                          size: 22,
                        ),
                      ],
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
                              provider.isCorrect ? 'Chính xác!' : 'Chưa đúng!',
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
                          'Từ đầy đủ',
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _mutedText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          card.question,
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
                          card.answer,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A4563),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
