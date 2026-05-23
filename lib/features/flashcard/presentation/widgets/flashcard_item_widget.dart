import 'package:apphoctienganh/features/flashcard/presentation/widgets/image_picker_button.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:apphoctienganh/features/flashcard/presentation/providers/flashcard_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FlashcardItem_Widget extends StatefulWidget {
  final Flashcard flashcard;
  final int index;

  const FlashcardItem_Widget({
    super.key,
    required this.flashcard,
    required this.index,
  });

  @override
  _FlashcardItem_WidgetState createState() => _FlashcardItem_WidgetState();
}

class _FlashcardItem_WidgetState extends State<FlashcardItem_Widget> {
  static const List<_LanguageOption> _languageOptions = [
    _LanguageOption(code: 'en-US', name: 'English', flag: '🇺🇸'),
    _LanguageOption(code: 'vi-VN', name: 'Tiếng Việt', flag: '🇻🇳'),
    _LanguageOption(code: 'ja-JP', name: '日本語', flag: '🇯🇵'),
    _LanguageOption(code: 'ko-KR', name: '한국어', flag: '🇰🇷'),
    _LanguageOption(code: 'zh-CN', name: '中文', flag: '🇨🇳'),
    _LanguageOption(code: 'fr-FR', name: 'Français', flag: '🇫🇷'),
    _LanguageOption(code: 'de-DE', name: 'Deutsch', flag: '🇩🇪'),
    _LanguageOption(code: 'es-ES', name: 'Español', flag: '🇪🇸'),
    _LanguageOption(code: 'it-IT', name: 'Italiano', flag: '🇮🇹'),
    _LanguageOption(code: 'pt-BR', name: 'Português', flag: '🇧🇷'),
    _LanguageOption(code: 'pt-PT', name: 'Português PT', flag: '🇵🇹'),
    _LanguageOption(code: 'ru-RU', name: 'Русский', flag: '🇷🇺'),
    _LanguageOption(code: 'th-TH', name: 'ไทย', flag: '🇹🇭'),
    _LanguageOption(code: 'id-ID', name: 'Indonesia', flag: '🇮🇩'),
    _LanguageOption(code: 'ms-MY', name: 'Bahasa Melayu', flag: '🇲🇾'),
    _LanguageOption(code: 'hi-IN', name: 'हिन्दी', flag: '🇮🇳'),
    _LanguageOption(code: 'bn-BD', name: 'বাংলা', flag: '🇧🇩'),
    _LanguageOption(code: 'ur-PK', name: 'اردو', flag: '🇵🇰'),
    _LanguageOption(code: 'ar-SA', name: 'العربية', flag: '🇸🇦'),
    _LanguageOption(code: 'nl-NL', name: 'Nederlands', flag: '🇳🇱'),
    _LanguageOption(code: 'pl-PL', name: 'Polski', flag: '🇵🇱'),
    _LanguageOption(code: 'tr-TR', name: 'Türkçe', flag: '🇹🇷'),
    _LanguageOption(code: 'sv-SE', name: 'Svenska', flag: '🇸🇪'),
    _LanguageOption(code: 'da-DK', name: 'Dansk', flag: '🇩🇰'),
    _LanguageOption(code: 'fi-FI', name: 'Suomi', flag: '🇫🇮'),
    _LanguageOption(code: 'no-NO', name: 'Norsk', flag: '🇳🇴'),
    _LanguageOption(code: 'cs-CZ', name: 'Čeština', flag: '🇨🇿'),
    _LanguageOption(code: 'el-GR', name: 'Ελληνικά', flag: '🇬🇷'),
    _LanguageOption(code: 'he-IL', name: 'עברית', flag: '🇮🇱'),
    _LanguageOption(code: 'hu-HU', name: 'Magyar', flag: '🇭🇺'),
    _LanguageOption(code: 'ro-RO', name: 'Română', flag: '🇷🇴'),
    _LanguageOption(code: 'sk-SK', name: 'Slovenčina', flag: '🇸🇰'),
    _LanguageOption(code: 'uk-UA', name: 'Українська', flag: '🇺🇦'),
    _LanguageOption(code: 'ca-ES', name: 'Català', flag: '🇪🇸'),
    _LanguageOption(code: 'es-MX', name: 'Español MX', flag: '🇲🇽'),
    _LanguageOption(code: 'en-GB', name: 'English UK', flag: '🇬🇧'),
    _LanguageOption(code: 'en-AU', name: 'English AU', flag: '🇦🇺'),
    _LanguageOption(code: 'en-CA', name: 'English CA', flag: '🇨🇦'),
    _LanguageOption(code: 'fr-CA', name: 'Français CA', flag: '🇨🇦'),
  ];

  late TextEditingController _questionController;
  late TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với giá trị ban đầu của flashcard
    _questionController = TextEditingController(
      text: widget.flashcard.question,
    );
    _answerController = TextEditingController(text: widget.flashcard.answer);
  }

  @override
  void didUpdateWidget(FlashcardItem_Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kiểm tra nếu flashcard đã thay đổi và cập nhật lại controller
    if (oldWidget.flashcard.question != widget.flashcard.question) {
      _questionController.text = widget.flashcard.question;
    }
    if (oldWidget.flashcard.answer != widget.flashcard.answer) {
      _answerController.text = widget.flashcard.answer;
    }
  }

  @override
  void dispose() {
    // Đừng quên dispose controller khi widget bị hủy
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFF0E3EA), width: 1.4),
              borderRadius: BorderRadius.circular(21),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: Center(
                          child: Text(
                            "${widget.index + 1}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.gripVertical,
                            color: const Color(0xFFB3AECF),
                            size: 14,
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              context
                                  .read<FlashcardProvider>()
                                  .duplicateFlashcardById(widget.flashcard.id);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(
                                FontAwesomeIcons.clone,
                                color: Color(0xFF5A5781),
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              context
                                  .read<FlashcardProvider>()
                                  .deleteFlashcardById(widget.flashcard.id);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(
                                FontAwesomeIcons.solidTrashCan,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Gap(8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Mặt trước',
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF5A5781),
                          ),
                        ),
                      ),
                      _buildLanguageDropdown(
                        value: widget.flashcard.questionLanguage,
                        onChanged: (value) {
                          if (value == null) return;
                          context
                              .read<FlashcardProvider>()
                              .updateFlashcardContent(
                                id: widget.flashcard.id,
                                questionLanguage: value,
                              );
                        },
                      ),
                    ],
                  ),
                  Gap(8),
                  Row(
                    children: <Widget>[
                      ImagePickerButton(
                        idFlashcard: widget.flashcard.id,
                        isQuestionImage: true,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _questionController,
                          onChanged: (value) {
                            context
                                .read<FlashcardProvider>()
                                .updateFlashcardContent(
                                  id: widget.flashcard.id,
                                  question: value,
                                );
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 1,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFFFFFF),
                            hintText: 'Thuật ngữ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFFE8E3F6),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF8B7CF6),
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Mặt sau',
                          style: GoogleFonts.lexend(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF5A5781),
                          ),
                        ),
                      ),
                      _buildLanguageDropdown(
                        value: widget.flashcard.answerLanguage,
                        onChanged: (value) {
                          if (value == null) return;
                          context
                              .read<FlashcardProvider>()
                              .updateFlashcardContent(
                                id: widget.flashcard.id,
                                answerLanguage: value,
                              );
                        },
                      ),
                    ],
                  ),
                  Gap(8),
                  Row(
                    children: <Widget>[
                      ImagePickerButton(
                        idFlashcard: widget.flashcard.id,
                        isQuestionImage: false,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _answerController,
                          onChanged: (value) {
                            context
                                .read<FlashcardProvider>()
                                .updateFlashcardContent(
                                  id: widget.flashcard.id,
                                  answer: value,
                                );
                          },
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 1,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFFFFFF),
                            hintText: 'Định nghĩa',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFFE8E3F6),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF8B7CF6),
                                width: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    final selectedLanguage = _languageOptions.firstWhere(
      (language) => language.code == value,
      orElse: () => _languageOptions.first,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap:
          () => _showLanguagePicker(
            selectedCode: selectedLanguage.code,
            onSelected: onChanged,
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedLanguage.flag, style: const TextStyle(fontSize: 18)),
            const Gap(5),
            Text(
              selectedLanguage.name,
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5A5781),
              ),
            ),
            const Gap(2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 17,
              color: Color(0xFF8A84A8),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLanguagePicker({
    required String selectedCode,
    required ValueChanged<String?> onSelected,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.82,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chọn ngôn ngữ phát âm',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2F2A5A),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _languageOptions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final language = _languageOptions[index];
                        final isSelected = language.code == selectedCode;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(
                            language.flag,
                            style: const TextStyle(fontSize: 22),
                          ),
                          title: Text(
                            language.name,
                            style: GoogleFonts.lexend(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2F2A5A),
                            ),
                          ),
                          subtitle: Text(language.code),
                          trailing:
                              isSelected
                                  ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF3D5AFE),
                                  )
                                  : null,
                          onTap: () => Navigator.pop(context, language.code),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selected != null) {
      onSelected(selected);
    }
  }
}

class _LanguageOption {
  final String code;
  final String name;
  final String flag;

  const _LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
  });
}
