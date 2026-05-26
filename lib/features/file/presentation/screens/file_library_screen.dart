import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/home/presentation/providers/home_provider.dart';
import 'package:apphoctienganh/features/flashcard/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class FileLibraryScreen extends StatefulWidget {
  const FileLibraryScreen({super.key, required this.onCreateFlashcard});

  final VoidCallback onCreateFlashcard;

  @override
  State<FileLibraryScreen> createState() => _FileLibraryScreenState();
}

class _FileLibraryScreenState extends State<FileLibraryScreen> {
  Future<void> _refreshLessons() {
    return context.read<HomeProvider>().loadDataforsetstateinhomepage();
  }

  void _showDeleteConfirm(FlashcardList lesson) {
    Alert(
      context: context,
      type: AlertType.warning,
      style: AlertStyle(
        animationType: AnimationType.grow,
        isCloseButton: false,
        isOverlayTapDismiss: false,
        backgroundColor: Colors.white,
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleStyle: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF241B4A),
        ),
        descStyle: GoogleFonts.lexend(
          fontSize: 13,
          height: 1.5,
          color: const Color(0xFF726D8E),
        ),
      ),
      title: 'Xóa bộ thẻ nhớ này?',
      desc:
          'Bộ "${lesson.title}" và các thẻ liên quan sẽ bị xóa vĩnh viễn khỏi hệ thống.',
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: const Color(0xFFE8E0FB),
          radius: BorderRadius.circular(16),
          child: Text(
            'Hủy',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF241B4A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        DialogButton(
          onPressed: () async {
            Navigator.pop(context);

            final message = await context
                .read<HomeProvider>()
                .deleteFlashcardListById(lesson.id);

            if (!mounted) return;

            await _refreshLessons();

            final isSuccess =
                message.contains('thành công') || message.contains('trên máy');
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  backgroundColor:
                      isSuccess
                          ? const Color(0xFF1E8E68)
                          : const Color(0xFFC94B4B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  content: Text(
                    message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
          },
          color: const Color(0xFFC94B4B),
          radius: BorderRadius.circular(16),
          child: Text(
            'Xóa',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ).show();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshLessons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessons = context.watch<HomeProvider>().flashcardLists;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F1FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/uselogo.jpg',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Anh Lish',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: ColorSetting.colorprimary,
                    ),
                  ),
                ],
              ),

              const Gap(10),
              Text(
                'Thư viện của tôi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF261F52),
                ),
              ),
              const Gap(6),
              Text(
                'Quản lý và ôn tập các bộ thẻ nhớ của bạn.',
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF726D8E),
                ),
              ),
              const Gap(14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: widget.onCreateFlashcard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorSetting.colorprimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: Text(
                    'Tạo bộ thẻ mới',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Gap(14),
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Tìm kiếm bộ thẻ...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const Gap(12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tất cả', true),
                    const SizedBox(width: 8),
                    _buildFilterChip('Gần đây', false),
                    const SizedBox(width: 8),
                    _buildFilterChip('Thư mục', false),
                  ],
                ),
              ),
              const Gap(16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshLessons,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: lessons.length + 2,
                    itemBuilder: (context, index) {
                      if (index < lessons.length) {
                        final lesson = lessons[index];
                        final progress =
                            lesson.flashcards.isEmpty
                                ? 0.0
                                : (lesson.flashcards.length % 10) / 10;

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => FlashcardScreen(
                                      flashcards: lesson.flashcards,
                                      flashcardList: lesson,
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4EEFF),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        '${lesson.flashcards.length} thẻ',
                                        style: GoogleFonts.lexend(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF7A6DAD),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(999),
                                      onTap: () => _showDeleteConfirm(lesson),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFFE5E5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.delete_forever_rounded,
                                          color: Color(0xFFC94B4B),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF1DC),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.lock_open_rounded,
                                        color: Color(0xFFCF9A2C),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lesson.title,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF221B4B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            lesson.description.isEmpty
                                                ? 'Không có mô tả'
                                                : lesson.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lexend(
                                              fontSize: 12,
                                              color: const Color(0xFF8179A4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(12),
                                Text(
                                  'Tiến độ',
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF625D7A),
                                  ),
                                ),
                                const Gap(6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LinearProgressIndicator(
                                    value: progress == 0 ? 0.15 : progress,
                                    minHeight: 7,
                                    backgroundColor: const Color(0xFFE9E3FA),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ColorSetting.colorprimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (index == lessons.length) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(vertical: 26),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFD8CEF9)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFECE6FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Color(0xFF8B79EA),
                                ),
                              ),
                              const Gap(12),
                              Text(
                                'Tạo bộ thẻ mới',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2B2555),
                                ),
                              ),
                              const Gap(6),
                              Text(
                                'Bắt đầu học tốt hơn với bộ từ vựng của riêng bạn',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: const Color(0xFF837DA1),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17113C),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC63B),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Gợi ý hôm nay',
                                style: GoogleFonts.lexend(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF352500),
                                ),
                              ),
                            ),
                            const Gap(12),
                            Text(
                              'Vượt qua giới hạn với thuật toán lặp lại ngắt quãng.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              'Dựa trên dữ liệu học tập của bạn, chúng tôi đề xuất nên ôn lại các bộ thẻ nhớ gần đây.',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                height: 1.5,
                                color: const Color(0xFFC6C1E2),
                              ),
                            ),
                            const Gap(14),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2B63F1),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Text(
                                'Ôn tập ngay',
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? ColorSetting.colorprimary : const Color(0xFFE8E1FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF655F85),
        ),
      ),
    );
  }
}
