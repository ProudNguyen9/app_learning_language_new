import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/ai/presentation/screens/ai_screen.dart';
import 'package:apphoctienganh/features/flashcard/presentation/screens/create_flashcard_screen.dart';
import 'package:apphoctienganh/features/file/presentation/screens/file_library_screen.dart';
import 'package:apphoctienganh/features/home/presentation/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class CenterHome extends StatefulWidget {
  const CenterHome({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<CenterHome> createState() => _CenterHomeState();
}

class _CenterHomeState extends State<CenterHome> {
  late int _currentIndex;

  late final List<Widget> _pages = [
    const HomePage(showBottomNavigation: false),
    const CreateFlashcard(showBottomNavigation: false),
    const AiScreen(),
    FileLibraryScreen(
      onCreateFlashcard: () {
        setState(() {
          _currentIndex = 1;
        });
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _pages.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedLabelStyle: GoogleFonts.lexend(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house, size: 22),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidRectangleList, size: 22),
            label: 'Flashcard',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.wandMagicSparkles, size: 22),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidFolderOpen, size: 22),
            label: 'File',
          ),
        ],
        selectedItemColor: ColorSetting.colorprimary,
        unselectedItemColor: Color(0xFFAEA8C7),
        backgroundColor: Color(0xFFF7F3FF),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
    );
  }
}
