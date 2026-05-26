import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/flashcard.dart';
import '../providers/flashcard_provider.dart';

class importBottomSheet extends StatefulWidget {
  const importBottomSheet({super.key});

  @override
  State<importBottomSheet> createState() => _importBottomSheetState();
}

class _importBottomSheetState extends State<importBottomSheet> {
  final TextEditingController importController = TextEditingController();
  String selectedTermDefinitionSeparator = "Tab";
  String selectedCardSeparator = "Dòng mới";
  List<Flashcard> previewFlashcards = [];
  List<Flashcard> _parseImportText(String text) {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      return [];
    }

    final cardSeparator = selectedCardSeparator == 'Dấu Chấm phẩy' ? ';' : '\n';
    final termSeparator = switch (selectedTermDefinitionSeparator) {
      'Tab' => '\t',
      'Dấu gạch ngang' => '-',
      'Dấu phẩy' => ',',
      _ => '\t',
    };

    final rows =
        trimmedText
            .split(cardSeparator)
            .map((row) => row.trim())
            .where((row) => row.isNotEmpty)
            .toList();

    return rows.asMap().entries.map((entry) {
      final index = entry.key;
      final row = entry.value;
      final parts = row.split(termSeparator);

      return Flashcard(
        id: 'preview-$index',
        question: parts.isNotEmpty ? parts.first.trim() : '',
        answer:
            parts.length > 1 ? parts.sublist(1).join(termSeparator).trim() : '',
        questionLanguage: 'en-US',
        answerLanguage: 'vi-VN',
      );
    }).toList();
  }

  void _updatePreviewFlashcards() {
    previewFlashcards = _parseImportText(importController.text);
  }

  Future<void> _showImportOptionDialog() async {
    if (previewFlashcards.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chưa có thẻ nào để thêm.')));
      return;
    }

    final shouldReplace = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3EEFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.playlist_add_rounded,
                  color: Color(0xFF3D5AFE),
                  size: 22,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  'Thêm thẻ học',
                  style: GoogleFonts.lexend(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2F2A5A),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Bạn muốn thêm ${previewFlashcards.length} thẻ vào danh sách hiện tại bằng cách nào?',
            style: GoogleFonts.lexend(
              fontSize: 14,
              height: 1.45,
              color: const Color(0xFF5A5781),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF5A5781),
                textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w700),
              ),
              child: const Text('Nối tiếp'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorSetting.colorprimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w700),
              ),
              child: const Text('Ghi đè'),
            ),
          ],
        );
      },
    );

    if (shouldReplace == null || !mounted) return;

    context.read<FlashcardProvider>().importFlashcards(
      previewFlashcards,
      replace: shouldReplace,
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    importController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                  Expanded(
                    child: Text(
                      'Nhập dữ liệu của bạn',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: const Color(0xFF2F2A5A),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Text(
                'Tạo học phần mới trong chớp mắt.',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: ColorSetting.colorprimary,
                ),
              ),
              Gap(5),
              Text(
                '''Sao chép và dán danh sách thuật ngữ
    và định nghĩa của bạn vào đây. Chúng
    tôi sẽ tự động xử lý phần còn lại.''',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF5A5781),
                ),
              ),
              Gap(15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1ECF8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: TextField(
                  onChanged: (_) {
                    setState(() {
                      _updatePreviewFlashcards();
                    });
                  },
                  controller: importController,
                  maxLines: 8,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText:
                        'Ví dụ:\nApple - Quả táo\nBanana - Quả chuối\nCherry - Quả anh đào',
                  ),
                ),
              ),
              Gap(10),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFF3EEFF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Row(
                      children: [
                        const Icon(
                          Icons.space_bar,
                          size: 18,
                          color: Color(0xFF3D5AFE),
                        ),

                        const Gap(8),

                        const Text(
                          'Giữa Thuật ngữ & Định nghĩa',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const Gap(16),

                    // Buttons
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildChip(
                          text: 'Dấu Tab',
                          isSelected: selectedTermDefinitionSeparator == 'Tab',
                          onTap: () {
                            setState(() {
                              selectedTermDefinitionSeparator = 'Tab';
                              _updatePreviewFlashcards();
                            });
                          },
                        ),
                        _buildChip(
                          text: 'Dấu gạch ngang (-)',
                          isSelected:
                              selectedTermDefinitionSeparator ==
                              'Dấu gạch ngang',
                          onTap: () {
                            setState(() {
                              selectedTermDefinitionSeparator =
                                  'Dấu gạch ngang';
                              _updatePreviewFlashcards();
                            });
                          },
                        ),
                        _buildChip(
                          text: 'Dấu phẩy (,)',
                          isSelected:
                              selectedTermDefinitionSeparator == 'Dấu phẩy',
                          onTap: () {
                            setState(() {
                              selectedTermDefinitionSeparator = 'Dấu phẩy';
                              _updatePreviewFlashcards();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Gap(10),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFF3EEFF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Row(
                      children: [
                        const Icon(
                          Icons.keyboard_return,
                          size: 18,
                          color: Color(0xFF3D5AFE),
                        ),

                        const Gap(8),

                        const Text(
                          'Giữa các thẻ ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    Gap(16),

                    // Buttons
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildChip(
                          text: 'Dòng mới',
                          isSelected: selectedCardSeparator == 'Dòng mới',
                          onTap: () {
                            setState(() {
                              selectedCardSeparator = 'Dòng mới';
                              _updatePreviewFlashcards();
                            });
                          },
                        ),
                        _buildChip(
                          text: 'Dấu Chấm phẩy (;)',
                          isSelected: selectedCardSeparator == 'Dấu Chấm phẩy',
                          onTap: () {
                            setState(() {
                              selectedCardSeparator = 'Dấu Chấm phẩy';
                              _updatePreviewFlashcards();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Gap(14),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Xem trước (${previewFlashcards.length}) thẻ',
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF2F2A5A),
                  ),
                ),
              ),
              Gap(14),
              if (previewFlashcards.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: previewFlashcards.length,
                  itemBuilder: (context, index) {
                    return FlashcardPreviewItem(
                      index: index,
                      term: previewFlashcards[index].question,
                      definition: previewFlashcards[index].answer,
                    );
                  },
                ),

              Gap(14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFB8ECFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Color(0xFF006D9C),
                ),
              ),

              const Gap(14),

              const Text(
                'Mẹo nhỏ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              const Gap(6),

              Text(
                'Mỗi dòng là một thẻ. Ví dụ: Apple - Quả táo. Chọn đúng dấu phân cách để tách dữ liệu.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const Gap(28),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE3BF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: Color(0xFFB56A00),
                ),
              ),

              const Gap(14),

              const Text(
                'Tách dữ liệu tự động',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              const Gap(6),

              const Text(
                'Nội dung đã dán sẽ được tự động tách ra thành các flashcard khi bạn nhấn Nhập.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              Gap(10),
              SizedBox(
                height: 50,
                width: 180,
                child: ElevatedButton(
                  onPressed: _showImportOptionDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorSetting.colorprimary,
                  ),
                  child: Text(
                    'Thêm thẻ học',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildChip({
  required String text,
  bool isSelected = false,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF3D5AFE) : const Color(0xFFDCD6F7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

class FlashcardPreviewItem extends StatelessWidget {
  final int index;
  final String term;
  final String definition;

  const FlashcardPreviewItem({
    super.key,
    required this.index,
    required this.term,
    required this.definition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E3F6), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF3D5AFE),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPreviewText(
                  label: 'Thuật ngữ',
                  value: term.isEmpty ? 'Chưa có thuật ngữ' : term,
                ),
                const Gap(8),
                _buildPreviewText(
                  label: 'Định nghĩa',
                  value: definition.isEmpty ? 'Chưa có định nghĩa' : definition,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewText({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8A84A8),
          ),
        ),
        const Gap(2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2F2A5A),
          ),
        ),
      ],
    );
  }
}
