import 'package:apphoctienganh/features/auth/presentation/screens/profile_screen.dart';
import 'package:apphoctienganh/features/flashcard/presentation/screens/create_flashcard_screen.dart';
import 'package:apphoctienganh/features/home/presentation/screens/home_page.dart';
import 'package:flutter/material.dart';

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
    const _AiPlaceholderScreen(),
    const CreateFlashcard(showBottomNavigation: false),
    const ProfileScreen(showBottomNavigation: false),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI'),
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
    );
  }
}

class _AiPlaceholderScreen extends StatelessWidget {
  const _AiPlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'Màn hình AI',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
