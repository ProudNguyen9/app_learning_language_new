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
            color: const Color(0xFFF8F6FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(21),
            ),
            elevation: 2,
            shadowColor: const Color(0x1F6B5ECD),
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
                  Text(
                    'Mặt trước',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFF5A5781),
                    ),
                  ),
                  Gap(2),
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
                  Text(
                    'Mặt sau',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFF5A5781),
                    ),
                  ),
                  Gap(2),
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
}
