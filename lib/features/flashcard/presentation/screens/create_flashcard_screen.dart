import 'package:apphoctienganh/features/flashcard/presentation/providers/flashcard_provider.dart';
import 'package:apphoctienganh/features/flashcard/presentation/widgets/flashcard_item_widget.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      fontWeight: FontWeight.w700,
                      fontSize: 21,
                      color: ColorSetting.colorprimary,
                    ),
                  ),
                  SizedBox(
                    width: 89,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {},
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
                minLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText:
                      'Viết tiêu đề cho bộ flashcard của bạn ví dụ: "Flashcard về động từ bất quy tắc"',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
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
                minLines: 2,
                controller: _descriptionController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: 'Viết mô tả cho bộ flashcard của bạn',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
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
                          Row(
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
                                          'Nhập từ tài liệu',
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
                          const SizedBox(height: 12),
                          Row(
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
                                          'AI Magic Paste',
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
              Consumer<FlashcardProvider>(
                builder: (context, myProvider, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: myProvider.flashcardList.length,
                    itemBuilder: (context, index) {
                      final flashcard = myProvider.flashcardList[index];
                      return FlashcardItem_Widget(
                        key: ValueKey(flashcard.id),
                        flashcard: flashcard,
                        index: index,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  context.read<FlashcardProvider>().addFlashcard();
                },
                child: DottedBorder(
                  color: const Color(0xFFD8D1F7),
                  strokeWidth: 1.5,
                  dashPattern: const [7, 5],
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F6FF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2DCFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 32,
                            color: Color(0xFF5A5781),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Thêm thẻ mới',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4A4672),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nhấn để thêm nhanh một thẻ mới',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9B97BC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2DCFF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.note_add_outlined,
                        color: Color(0xFF3E3A67),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CSV / Excel',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3E3A67),
                        ),
                      ),
                    ],
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
