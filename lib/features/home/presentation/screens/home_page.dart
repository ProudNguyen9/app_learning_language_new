import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/auth/presentation/screens/profile_screen.dart';
import 'package:apphoctienganh/features/home/presentation/providers/home_provider.dart';
import 'package:apphoctienganh/features/skill_speaking/presentation/screens/choose_type_speaking.dart';
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
    final flashcardLists = context.watch<HomeProvider>().flashcardLists;
    final recentFlashcardLists = flashcardLists.take(2).toList();

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
                  momentumStreakCard(),
                  const SizedBox(height: 14),
                  const SectionHeading(text: 'HỌC GẦN ĐÂY'),
                  const SizedBox(height: 5),
                  const _TimeFilterTabs(
                    labels: ['Mới đây', 'Hôm qua', 'Tuần trước'],
                  ),
                  const Gap(15),
                  if (recentFlashcardLists.isNotEmpty)
                    cardVocal()
                  else
                    _EmptyRecentFlashcardCard(),
                  const Gap(15),
                  cardEndingSounds(),
                  const Gap(15),
                  const SectionHeading(text: 'CÁC HỌC PHẦN'),
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
                          onTap: null,
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
                          onTap: null,
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
                          onTap: null,
                        ),
                      ),
                    ],
                  ),

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
  Container cardVocal() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // ICON
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.menu_book, color: Colors.orange),
          ),

          SizedBox(width: 16),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Từ vựng Du lịch",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text("Đã học 15/20 từ", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          // % BADGE
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "85%",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecentFlashcardCard extends StatelessWidget {
  const _EmptyRecentFlashcardCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'Bạn chưa có học phần gần đây. Hãy nhấn nút + để tạo flashcard đầu tiên.',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF5E5E5E),
          fontWeight: FontWeight.w500,
        ),
      ),
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

Widget momentumStreakCard() {
  final streakDays = [
    ('Mon', true),
    ('Tue', true),
    ('Wed', true),
    ('Thu', true),
    ('Fri', false),
    ('Sat', false),
    ('Sun', true),
  ];

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4A63F6), Color(0xFF6F87FF), Color(0xFF93A4FF)],
      ),
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x243E5CE7),
          blurRadius: 10,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          top: -2,
          right: -2,
          child: Icon(
            Icons.local_fire_department_rounded,
            size: 38,
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        Positioned(
          bottom: -8,
          left: -8,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MOMENTUM STREAK',
              style: TextStyle(
                color: Color(0xFFDCE2FF),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text(
                  '12',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: const Text(
                    'ngày hoạt động',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final item in streakDays)
                    _StreakDayBadge(label: item.$1, isActive: item.$2),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Học ngay',
                    style: TextStyle(
                      color: Color(0xFF3657E8),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
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
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isActive
                    ? const Color(0xFFFFB347)
                    : Colors.white.withOpacity(0.14),
            boxShadow:
                isActive
                    ? const [
                      BoxShadow(
                        color: Color(0x40FF9F43),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ]
                    : null,
          ),
          child: Icon(
            isActive
                ? Icons.local_fire_department_rounded
                : Icons.local_fire_department_outlined,
            color: isActive ? Colors.white : const Color(0xFFD8DEFF),
            size: 11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFD8DEFF),
            fontSize: 8,
            fontWeight: FontWeight.w700,
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
