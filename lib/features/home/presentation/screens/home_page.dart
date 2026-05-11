import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/auth/presentation/screens/profile_screen.dart';
import 'package:apphoctienganh/features/flashcard/presentation/screens/create_flashcard_screen.dart';
import 'package:apphoctienganh/features/home/presentation/providers/home_provider.dart';
import 'package:apphoctienganh/shared/widgets/section_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Expanded(child: cardListeningSkills()),
                    const SizedBox(width: 8),
                    Expanded(child: cardListeningSkills()),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: cardReadingSkills()),
                    const SizedBox(width: 8),
                    Expanded(child: cardWritingSkills()),
                  ],
                ),
                const SizedBox(height: 20),
                momentumStreakCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          width: 45,
          height: 45,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateFlashcard()),
              );
            },
            backgroundColor: const Color.fromRGBO(83, 209, 197, 1),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: currentIndex,
            onTap: (index) {
              if (index == currentIndex) return;

              setState(() {
                currentIndex = index;
              });

              Widget nextPage;
              if (index == 0) {
                nextPage = const HomePage();
              } else if (index == 1) {
                nextPage = const HomePage();
              } else if (index == 2) {
                nextPage = CreateFlashcard();
              } else {
                nextPage = const ProfileScreen();
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => nextPage),
              );
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome),
                label: 'AI',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book),
                label: 'Flashcard',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tôi'),
            ],
            selectedItemColor: const Color(0xFF13A8A8),
            unselectedItemColor: const Color(0xFFA6A6A6),
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
        ),
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

Widget cardListeningSkills() {
  return AspectRatio(
    aspectRatio: 0.95,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE9EEFF),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.headphones,
              color: Color(0xFF3A5BDB),
              size: 26,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Nghe',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2F2F5F),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Listening skills',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF6F7296),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget cardReadingSkills() {
  return AspectRatio(
    aspectRatio: 0.95,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8FC),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: Color(0xFF177E9B),
              size: 26,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Đọc',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2F2F5F),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Reading skills',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF6F7296),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget cardWritingSkills() {
  return AspectRatio(
    aspectRatio: 0.95,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEF3),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.edit_note,
              color: Color(0xFFE66A8D),
              size: 26,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Viết',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2F2F5F),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Writing skills',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF6F7296),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget momentumStreakCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF4963F0), Color(0xFF8D9CFF)],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MOMENTUM STREAK',
                style: TextStyle(
                  color: Color(0xFFD5DBFF),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '12 Ngày',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Đừng bỏ lỡ bài học hôm nay để\n duy trì chuỗi!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Học Ngay',
                  style: TextStyle(
                    color: Color(0xFF3657E8),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Icon(
            Icons.local_fire_department_outlined,
            size: 72,
            color: Colors.white.withOpacity(0.18),
          ),
        ),
      ],
    ),
  );
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
