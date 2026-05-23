import 'package:apphoctienganh/features/flashcard/flashcard.dart';
import 'package:apphoctienganh/features/home/presentation/providers/home_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';

class EditFlashCard extends StatefulWidget {
  final FlashcardList flashcardList;
  const EditFlashCard({super.key, required this.flashcardList});

  @override
  State<EditFlashCard> createState() => _EditFlashCardState();
}

class _EditFlashCardState extends State<EditFlashCard> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FlashcardProvider>().loadData(widget.flashcardList.flashcards);
    _titleController.text = widget.flashcardList.title;
    _descriptionController.text = widget.flashcardList.description;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showEditFlashcardMessage({
    required String message,
    required bool isSuccess,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    isSuccess
                        ? const Color(0xFFD8F5E2)
                        : const Color(0xFFFFD6D6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isSuccess
                            ? const Color(0xFFE9FAF0)
                            : const Color(0xFFFFEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess
                        ? Icons.check_rounded
                        : Icons.error_outline_rounded,
                    color:
                        isSuccess
                            ? const Color(0xFF1F9D55)
                            : const Color(0xFFE53935),
                    size: 20,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F2A5A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final myProvider = context.watch<FlashcardProvider>();

    return Scaffold(
      backgroundColor: ColorSetting.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chỉnh sửa Flashcard',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: ColorSetting.colorprimary,
                    ),
                  ),
                  SizedBox(
                    width: 89,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        final editedFlashcards = List<Flashcard>.from(
                          context.read<FlashcardProvider>().flashcardList,
                        );
                        final editedFlashcardList = FlashcardList(
                          id: widget.flashcardList.id,
                          title: _titleController.text.trim(),
                          description: _descriptionController.text.trim(),
                          flashcards: editedFlashcards,
                          userId: widget.flashcardList.userId,
                        );

                        final result = await context
                            .read<FlashcardProvider>()
                            .saveForEditFlashcardListAsync(
                              id: widget.flashcardList.id,
                              title: _titleController.text.trim(),
                              description: _descriptionController.text.trim(),
                            );

                        if (!mounted) return;

                        final isSuccess = result.contains('thành công');

                        if (isSuccess) {
                          await context
                              .read<HomeProvider>()
                              .loadDataforsetstateinhomepage();
                        }

                        if (!mounted) return;

                        _showEditFlashcardMessage(
                          message: result,
                          isSuccess: isSuccess,
                        );

                        if (isSuccess) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => FlashcardScreen(
                                    flashcardList: editedFlashcardList,
                                    flashcards: editedFlashcards,
                                  ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 15, 15, 237),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Lưu',
                        style: GoogleFonts.lexend(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(5),
              Text(
                'Tiêu đề',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: const Color(0xFF5A5781),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _titleController,
                maxLines: null,
                minLines: 1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Viết tiêu đề cho bộ flashcard của bạn',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFF0E3EA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xFFD99BB5),
                      width: 1.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Mô tả',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: const Color(0xFF5A5781),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                maxLines: null,
                minLines: 3,
                controller: _descriptionController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Viết mô tả cho bộ flashcard của bạn',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFF0E3EA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xFFD99BB5),
                      width: 1.3,
                    ),
                  ),
                ),
              ),
              const Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Flashcard',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: const Color(0xFF2F2A5A),
                    ),
                  ),
                  const Icon(
                    Icons.swap_vert_rounded,
                    color: Color(0xFF5A5781),
                    size: 22,
                  ),
                ],
              ),
              const Gap(5),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myProvider.flashcardList.length,
                itemBuilder: (context, index) {
                  final flashcard = myProvider.flashcardList[index];
                  return FlashcardItem_Widget(
                    key: ValueKey(flashcard.id),
                    flashcard: flashcard,
                    index: index,
                  );
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  context.read<FlashcardProvider>().addFlashcard();
                },
                child: DottedBorder(
                  color: const Color(0xFFB7A7F2),
                  strokeWidth: 1.8,
                  dashPattern: const [7, 5],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 26,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2EEFF),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD9D0FF),
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 30,
                            color: Color(0xFF6A5ACD),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Thêm thẻ mới',
                          style: GoogleFonts.lexend(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3F356B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Chạm để thêm một flashcard mới vào bộ thẻ của bạn',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: const Color(0xFF8B85B3),
                          ),
                        ),
                      ],
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
