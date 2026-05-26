import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/ai/presentation/screens/ai_screen.dart';
import 'package:apphoctienganh/features/skill_speaking/domain/entities/speaking_lesson.dart';
import 'package:apphoctienganh/features/skill_speaking/presentation/providers/speaking_lesson_provider.dart';
import 'package:apphoctienganh/features/skill_speaking/presentation/screens/reading_practice_screen.dart';
import 'package:apphoctienganh/features/skill_speaking/widget/ai_create_excecite_speak.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChooseTypeSpeaking extends StatefulWidget {
  const ChooseTypeSpeaking({super.key});

  @override
  State<ChooseTypeSpeaking> createState() => _ChooseTypeSpeakingState();
}

class _ChooseTypeSpeakingState extends State<ChooseTypeSpeaking> {
  String _selectedFilter = 'Mặc định';
  final TextEditingController _searchController = TextEditingController();

  Future<void> _openCreateLesson() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const createSpeakingLesson()),
    );

    if (saved == true && mounted) {
      await context.read<SpeakingLessonProvider>().loadLessons();
    }
  }

  Future<void> _openEditLesson(SpeakingLesson lesson) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => createSpeakingLesson(initialLesson: lesson),
      ),
    );

    if (saved == true && mounted) {
      await context.read<SpeakingLessonProvider>().loadLessons();
    }
  }

  Future<void> _deleteLesson(SpeakingLesson lesson) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Xóa bài luyện đọc',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF242A4A),
            ),
          ),
          content: Text(
            'Bạn có chắc muốn xóa "${lesson.title}" khỏi danh sách không?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6C7298),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Hủy',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7A809E),
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE5484D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Xóa',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final result = await context.read<SpeakingLessonProvider>().deleteLesson(
      lesson.id,
    );

    if (!mounted) return;

    final isSuccess = result.contains('thành công');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor:
              isSuccess ? const Color(0xFF10B981) : const Color(0xFFE5484D),
        ),
      );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SpeakingLessonProvider>().loadLessons();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonProvider = context.watch<SpeakingLessonProvider>();
    final filteredLessons = lessonProvider.filterLessons(
      query: _searchController.text,
      filter: _selectedFilter,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Kĩ năng nói',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: ColorSetting.colorprimary,
                        ),
                      ),
                    ),
                  ),
                  ClipOval(
                    child: Image.asset(
                      'assets/uselogo.jpg',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const Gap(20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEEF2FF), Color(0xFFF7F3FF)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Speaking practice',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5B5F88),
                        ),
                      ),
                    ),
                    const Gap(14),
                    Text(
                      'Luyện nói mỗi ngày theo cách nhẹ nhàng và dễ bắt đầu.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF20254D),
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Chọn chế độ phù hợp để luyện phản xạ, đọc thành tiếng và cải thiện phát âm từng bước.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6C7298),
                      ),
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        const Expanded(
                          child: _MiniInfoCard(
                            value: '2',
                            label: 'Chế độ',
                            icon: Icons.grid_view_rounded,
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: _MiniInfoCard(
                            value: '${lessonProvider.lessons.length}',
                            label: 'Bài đọc ',
                            icon: Icons.menu_book_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(22),
              Text(
                'Chế độ luyện tập',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF242A4A),
                ),
              ),
              const Gap(6),
              Text(
                'Bắt đầu từ chế độ phù hợp với mục tiêu của bạn.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7A809E),
                ),
              ),
              const Gap(14),
              Row(
                children: [
                  Expanded(
                    child: _SpeakingModeCard(
                      accentColors: const [
                        Color(0xFF5B5FEF),
                        Color(0xFF7C6CFF),
                      ],
                      leadingIcon: Icons.auto_awesome_rounded,
                      trailingIcon: Icons.smart_toy_rounded,
                      title: 'Chat AI',
                      description: 'Luyện hội thoại nhanh cùng AI.',
                      actionLabel: 'Bắt đầu',
                      badge: 'Giao tiếp',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AiScreen()),
                        );
                      },
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _SpeakingModeCard(
                      accentColors: const [
                        Color(0xFF14B8A6),
                        Color(0xFF2DD4BF),
                      ],
                      leadingIcon: Icons.record_voice_over_rounded,
                      trailingIcon: Icons.menu_book_rounded,
                      title: 'Tạo bài đọc',
                      description: 'Đọc to, rõ và đều hơn mỗi ngày.',
                      actionLabel: 'Bắt đầu',
                      badge: 'Đọc to',
                      onTap: _openCreateLesson,
                    ),
                  ),
                ],
              ),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bài luyện đọc',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF242A4A),
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'Nhấn vào bài để vào màn karaoke, ghi âm và chấm điểm.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7A809E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _selectedFilter = value;
                      });
                    },
                    itemBuilder:
                        (context) => const [
                          PopupMenuItem(
                            value: 'Mặc định',
                            child: Text('Mặc định'),
                          ),
                          PopupMenuItem(
                            value: 'Mới đây',
                            child: Text('Mới đây'),
                          ),
                          PopupMenuItem(
                            value: 'Mức độ bình thường',
                            child: Text('Mức độ bình thường'),
                          ),
                          PopupMenuItem(
                            value: 'Mức độ khó',
                            child: Text('Mức độ khó'),
                          ),
                        ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE3E7F3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: Color(0xFF2C2A51),
                          ),
                          const Gap(8),
                          Text(
                            _selectedFilter,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C2A51),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE8ECF5)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    icon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: Color(0xFF7A809E),
                    ),
                    hintText: 'Tìm bài luyện đọc',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF98A0B8),
                    ),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF242A4A),
                  ),
                ),
              ),
              const Gap(14),
              if (!lessonProvider.isLoaded)
                const _LoadingLessonCard()
              else if (filteredLessons.isEmpty)
                _EmptyLessonCard(onTapCreate: _openCreateLesson)
              else
                ...List.generate(filteredLessons.length, (index) {
                  final lesson = filteredLessons[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == filteredLessons.length - 1 ? 0 : 12,
                    ),
                    child: _ReadingLessonCard(
                      lesson: lesson,
                      subtitle: lesson.preview,
                      onEdit: () => _openEditLesson(lesson),
                      onDelete: () => _deleteLesson(lesson),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 18, color: ColorSetting.colorprimary),
        ),
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  const _MiniInfoCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE9EDFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: ColorSetting.colorprimary),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF242A4A),
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7A809E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeakingModeCard extends StatelessWidget {
  const _SpeakingModeCard({
    required this.accentColors,
    required this.leadingIcon,
    required this.trailingIcon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.badge,
    required this.onTap,
  });

  final List<Color> accentColors;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final String title;
  final String description;
  final String actionLabel;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEEF1F7)),
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                offset: const Offset(0, 6),
                color: const Color(0xFF1F2A44).withOpacity(0.04),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: accentColors),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(leadingIcon, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  Icon(trailingIcon, size: 22, color: const Color(0xFFD4D9E6)),
                ],
              ),
              const Gap(16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: accentColors.first.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: accentColors.first,
                  ),
                ),
              ),
              const Gap(10),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF202548),
                ),
              ),
              const Gap(6),
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7C839D),
                ),
              ),
              const Gap(18),
              Row(
                children: [
                  Text(
                    actionLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2447),
                    ),
                  ),
                  const Gap(5),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: accentColors.last,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingLessonCard extends StatelessWidget {
  const _ReadingLessonCard({
    required this.lesson,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });

  final SpeakingLesson lesson;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReadingPracticeScreen(lesson: lesson),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.035),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF3FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.volume_up_rounded,
                  color: Color(0xFF4F46E5),
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF242A4A),
                      ),
                    ),
                    const Gap(6),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7A809E),
                      ),
                    ),
                    const Gap(10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(label: lesson.level),
                        _InfoChip(label: lesson.estimatedDuration),
                        _InfoChip(
                          label: lesson.source == 'ai' ? 'AI tạo' : 'Nhập tay',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(8),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                    return;
                  }
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder:
                    (context) => const [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 18),
                            Gap(8),
                            Text('Sửa bài'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 18),
                            Gap(8),
                            Text('Xóa bài'),
                          ],
                        ),
                      ),
                    ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: Colors.white,
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: Color(0xFF9DA5C0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5FB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF68708F),
        ),
      ),
    );
  }
}

class _EmptyLessonCard extends StatelessWidget {
  const _EmptyLessonCard({required this.onTapCreate});

  final VoidCallback onTapCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EAF4)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF4F46E5),
            ),
          ),
          const Gap(12),
          Text(
            'Chưa có bài luyện đọc nào',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF242A4A),
            ),
          ),
          const Gap(6),
          Text(
            'Tạo bài đầu tiên bằng AI hoặc nhập tay rồi bấm lưu để hiện ở đây.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7A809E),
            ),
          ),
          const Gap(14),
          ElevatedButton.icon(
            onPressed: onTapCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B5FEF),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(
              'Tạo bài luyện đọc',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingLessonCard extends StatelessWidget {
  const _LoadingLessonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4FA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Gap(8),
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4FA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
