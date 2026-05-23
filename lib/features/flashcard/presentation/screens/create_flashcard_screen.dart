import 'package:apphoctienganh/features/flashcard/presentation/providers/flashcard_provider.dart';
import 'package:apphoctienganh/features/flashcard/presentation/widgets/ai_magic_flashcard_bottom_sheet.dart';
import 'package:apphoctienganh/features/flashcard/presentation/widgets/flashcard_item_widget.dart';
import 'package:apphoctienganh/features/flashcard/presentation/widgets/import_bottom_sheet.dart';
import 'package:apphoctienganh/features/home/presentation/providers/home_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';

class CreateFlashcard extends StatefulWidget {
  const CreateFlashcard({super.key, this.showBottomNavigation = true});

  final bool showBottomNavigation;

  @override
  State<CreateFlashcard> createState() => _CreateFlashcardState();
}

class _CreateFlashcardState extends State<CreateFlashcard> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int currentIndex = 2;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showSaveFlashcardMessage({
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
    //  function in here

    Future<void> showImportBottonSheet(BuildContext context) {
      return showModalBottomSheet(
        context: context,
        builder: (context) => importBottomSheet(),
        isScrollControlled: true,
      );
    }

    Future<void> showAiMagicFlashcardBottomSheet(BuildContext context) {
      return showModalBottomSheet(
        context: context,
        builder: (context) => const AiMagicFlashcardBottomSheet(),
        isScrollControlled: true,
      );
    }
    //  function in here

    return Scaffold(
      backgroundColor: ColorSetting.background,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Flashcard',
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
                        final messageresult = await context
                            .read<FlashcardProvider>()
                            .save_list_flashcard_async(
                              title: _titleController.text.trim(),
                              description: _descriptionController.text.trim(),
                            );
                        if (!mounted) return;

                        final isSuccess = messageresult.contains('thành công');

                        if (isSuccess) {
                          _titleController.clear();
                          _descriptionController.clear();
                          FocusScope.of(context).unfocus();
                          await context
                              .read<HomeProvider>()
                              .loadDataforsetstateinhomepage();
                        }

                        if (!mounted) return;

                        _showSaveFlashcardMessage(
                          message: messageresult,
                          isSuccess: isSuccess,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 15, 15, 237),
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
              Gap(5),
              Text(
                'Tiêu đề',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF5A5781),
                ),
              ),
              SizedBox(height: 5),
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
              SizedBox(height: 15),
              Text(
                'Mô tả',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF5A5781),
                ),
              ),
              SizedBox(height: 5),
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
              Gap(15),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFF3EEFF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nhập nhanh',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F2A5A),
                      ),
                    ),
                    Gap(10),
                    Text(
                      'Chuyển đổi ngay lập tức các ghi chú hoặc tài liệu thành thẻ học tập bằng Quizii AI.',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xFF5A5781),
                      ),
                    ),
                    Gap(5),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F2FF),
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              showImportBottonSheet(context);
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFFE6E1F5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.description_outlined,
                                          color: Color(0xFF4A67FF),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Nhập dữ liệu của bạn',
                                            style: GoogleFonts.lexend(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2F2A5A),
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFFB9B4DA),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              showAiMagicFlashcardBottomSheet(context);
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFFE6E1F5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.auto_awesome_outlined,
                                          color: Color(0xFFC58B00),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'AI Magic Flashcard',
                                            style: GoogleFonts.lexend(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2F2A5A),
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFFB9B4DA),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Gap(10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Flashcard',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF2F2A5A),
                    ),
                  ),
                  const Icon(
                    Icons.swap_vert_rounded,
                    color: Color(0xFF5A5781),
                    size: 22,
                  ),
                ],
              ),
              Gap(5),

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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
