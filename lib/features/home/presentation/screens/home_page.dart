import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/auth/presentation/screens/profile_screen.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/list_flashcard.dart';
import 'package:apphoctienganh/features/home/presentation/providers/home_provider.dart';
import 'package:apphoctienganh/features/home/presentation/providers/streak_provider.dart';
import 'package:apphoctienganh/features/skill_listening/presentation/screens/choose_type_listening.dart';
import 'package:apphoctienganh/features/skill_reading/presentation/screens/choose_type_reading.dart';
import 'package:apphoctienganh/features/skill_speaking/presentation/screens/choose_type_speaking.dart';
import 'package:apphoctienganh/features/skill_writing/presentation/screens/writing_practice_screen.dart';
import 'package:apphoctienganh/shared/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.showBottomNavigation = true});

  final bool showBottomNavigation;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeProvider>().loadDataforsetstateinhomepage();
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<HomeProvider>();
    final streakProvider = context.watch<StreakProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: ColorSetting.background,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: ColorSetting.background,
        systemNavigationBarDividerColor: ColorSetting.background,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: ColorSetting.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => const ProfileScreen(
                                        showBottomNavigation: false,
                                      ),
                                ),
                              );
                            },
                            child: ClipOval(
                              child: Image.asset(
                                'assets/uselogo.jpg',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
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
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_active_outlined,
                          color: ColorSetting.colorprimary,
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  momentumStreakCard(streakProvider),

                  const Gap(15),
                  Row(
                    children: [
                      Text(
                        'Các học phần',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF211A3B),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '4 kỹ năng',
                          style: GoogleFonts.plusJakartaSans(
                            color: ColorSetting.colorprimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),
                  Row(
                    children: [
                      Expanded(
                        child: Card_skill(
                          title: 'Đọc hiểu',
                          subtitle: 'Đọc bài viết và đoạn văn',
                          icon: Icons.menu_book_outlined,
                          iconcolor: const Color(0xFF177E9B),
                          iconBackgroundColor: const Color(0xFFEAF8FC),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChooseTypeReading(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card_skill(
                          title: 'Viết',
                          subtitle: 'Luyện viết câu và diễn đạt',
                          icon: Icons.edit_note,
                          iconcolor: const Color(0xFFE66A8D),
                          iconBackgroundColor: const Color(0xFFFFEEF3),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const WritingPracticeScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Card_skill(
                          title: 'Nói',
                          subtitle: 'Cải thiện phát âm mỗi ngày',
                          icon: Icons.mic_none_rounded,
                          iconcolor: const Color(0xFF7A52CC),
                          iconBackgroundColor: const Color(0xFFF1EAFE),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChooseTypeSpeaking(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card_skill(
                          title: 'Nghe',
                          subtitle: 'Luyện nghe qua âm thanh',
                          icon: Icons.headphones,
                          iconcolor: const Color(0xFF3A5BDB),
                          iconBackgroundColor: const Color(0xFFE9EEFF),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ChooseTypeListening(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const Gap(18),
                  const _HomeLearningBoostSection(),
                  const Gap(18),
                  const _MotivationCard(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),

        bottomNavigationBar:
            widget.showBottomNavigation ? null : const SizedBox.shrink(),
      ),
    );
  }

  // card vocal
  Container cardVocal(FlashcardList lesson) {
    final totalCards = lesson.flashcards.length;
    final studiedCards = lesson.studiedCards.clamp(0, totalCards);
    final percentText = '${(lesson.progressPercent * 100).round()}%';
    final recentLabel = _buildRecentLabel(lesson.lastStudiedAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.style_rounded, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Đã học $studiedCards/$totalCards thẻ • $recentLabel',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              percentText,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildRecentLabel(DateTime? value) {
    if (value == null) {
      return 'Chưa học';
    }

    final now = DateTime.now();
    final difference = now.difference(value);
    if (difference.inMinutes < 1) {
      return 'Vừa mới học';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    }
    if (difference.inDays == 1) {
      return 'Hôm qua';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    }
    return 'Tuần trước';
  }
}

class _HomeLearningBoostSection extends StatelessWidget {
  const _HomeLearningBoostSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Gợi ý hôm nay',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF211A3B),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.65),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '15 phút/ngày',
                style: GoogleFonts.plusJakartaSans(
                  color: ColorSetting.colorprimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 1.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _LearningBoostItem(
                icon: Icons.auto_stories_rounded,
                title: 'Đọc 1 đoạn ngắn',
                subtitle: 'Luyện đọc hiểu 5 phút để tăng vốn từ.',
                iconColor: const Color(0xFF177E9B),
                iconBackgroundColor: const Color(0xFFEAF8FC),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChooseTypeReading(),
                    ),
                  );
                },
              ),
              const _SoftDivider(),
              _LearningBoostItem(
                icon: Icons.record_voice_over_rounded,
                title: 'Nói lại 3 câu mẫu',
                subtitle: 'Ghi âm và nghe lại để sửa phát âm.',
                iconColor: const Color(0xFF7A52CC),
                iconBackgroundColor: const Color(0xFFF1EAFE),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChooseTypeSpeaking(),
                    ),
                  );
                },
              ),
              const _SoftDivider(),
              _LearningBoostItem(
                icon: Icons.headphones_rounded,
                title: 'Nghe một đoạn văn',
                subtitle: 'Luyện nghe ngắn để bắt keyword và ngữ điệu.',
                iconColor: const Color(0xFF3A5BDB),
                iconBackgroundColor: const Color(0xFFE9EEFF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChooseTypeListening(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MotivationCard extends StatelessWidget {
  const _MotivationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0ECF8), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            spreadRadius: -6,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFFA726),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bạn đang làm rất tốt!',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF211A3B),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mỗi ngày học một chút, tiếng Anh của bạn sẽ tiến bộ rõ rệt.',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF7B7390),
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class _LearningBoostItem extends StatelessWidget {
  const _LearningBoostItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF211A3B),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF827A99),
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFC1BAD4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Color(0xFFF0ECFA)),
    );
  }
}

Container cardEndingSounds() {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F6FB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.volume_up_outlined,
            color: Colors.teal,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Phát âm Ending Sounds',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Vừa mới học', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        const Icon(Icons.play_circle_outline, color: Colors.blue, size: 30),
      ],
    ),
  );
}

Widget momentumStreakCard(StreakProvider streakProvider) {
  final streakLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  final streakDays = List.generate(
    streakLabels.length,
    (index) => (streakLabels[index], streakProvider.weeklyActivity[index]),
  );
  final activeDays = streakProvider.weeklyActivity.where((day) => day).length;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFF2ECFF), width: 1),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFB25F), Color(0xFFFF6B6B)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33FF8A3D),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chuỗi học tập',
                    style: TextStyle(
                      color: Color(0xFF211A3B),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Duy trì thói quen mỗi ngày',
                    style: TextStyle(
                      color: Color(0xFF8A83A5),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E8),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                streakProvider.lastStudyDate == null
                    ? 'Bắt đầu'
                    : '${streakProvider.totalStudyDays} ngày học',
                style: const TextStyle(
                  color: Color(0xFFFF7A2F),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${streakProvider.currentStreak}',
              style: const TextStyle(
                color: Color(0xFF211A3B),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(width: 4),
            const Padding(
              padding: EdgeInsets.only(bottom: 1),
              child: Text(
                'ngày liên tiếp',
                style: TextStyle(
                  color: Color(0xFF6F6685),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '$activeDays/7 ngày tuần này',
              style: const TextStyle(
                color: Color(0xFF8A83A5),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final item in streakDays)
              _StreakDayBadge(label: item.$1, isActive: item.$2),
          ],
        ),
      ],
    ),
  );
}

class _StreakDayBadge extends StatelessWidget {
  const _StreakDayBadge({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFFF8A3D) : const Color(0xFFF4F0FA),
            boxShadow:
                isActive
                    ? const [
                      BoxShadow(
                        color: Color(0x2EFF8A3D),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: Icon(
            isActive ? Icons.check_rounded : Icons.circle_outlined,
            color: isActive ? Colors.white : const Color(0xFFC9C1D8),
            size: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF211A3B) : const Color(0xFF9A92AB),
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _TimeFilterTabs extends StatefulWidget {
  const _TimeFilterTabs({required this.labels});

  final List<String> labels;

  @override
  State<_TimeFilterTabs> createState() => _TimeFilterTabsState();
}

class _TimeFilterTabsState extends State<_TimeFilterTabs> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < widget.labels.length; i++) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedIndex = i;
                });
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor:
                    selectedIndex == i
                        ? const Color(0xFF2A4BD9)
                        : const Color.fromARGB(255, 217, 212, 253),
                foregroundColor:
                    selectedIndex == i ? Colors.white : const Color(0xFF5E5E5E),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.labels[i],
                  maxLines: 1,
                  softWrap: false,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        selectedIndex == i
                            ? Colors.white
                            : const Color(0xFF5E5E5E),
                  ),
                ),
              ),
            ),
          ),
          if (i != widget.labels.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}
