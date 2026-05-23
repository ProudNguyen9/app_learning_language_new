import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.showBottomNavigation = true});

  final bool showBottomNavigation;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<AuthProvider>().getCurrentUserProfile();
    final imageUrl = userProfile?['photoURL'] ?? '';
    final email = userProfile?['email'] ?? 'Email chưa có';
    final rawDisplayName =
        (userProfile?['displayName'] ?? '').toString().trim();
    final displayName =
        rawDisplayName.isNotEmpty ? rawDisplayName : _buildNameFromEmail(email);
    final firstChar =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'Q';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFEDE6FF),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/uselogo.jpg',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Anh Lish',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ColorSetting.colorprimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: ColorSetting.colorprimary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x2217163A),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child:
                                imageUrl.isNotEmpty
                                    ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return _buildFallbackAvatar(firstChar);
                                      },
                                    )
                                    : _buildFallbackAvatar(firstChar),
                          ),
                        ),
                        Positioned(
                          right: -6,
                          bottom: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA621),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'PRO',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF27214F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Người học tiếng Anh từ tháng 01/2025',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: const Color(0xFF7B7599),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: Color(0xFF4A6CF7),
                      value: '5,240',
                      label: 'XP',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.whatshot_rounded,
                      iconColor: Color(0xFFB67D18),
                      value: '14',
                      label: 'CHUỖI',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.workspace_premium_outlined,
                      iconColor: Color(0xFF1AA8C8),
                      value: '12',
                      label: 'HUY HIỆU',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4D67F5), Color(0xFF7C8FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x264A63F3),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trình độ hiện tại',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Level 12',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Nâng cao',
                            style: GoogleFonts.lexend(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '75% để lên cấp 13',
                            style: GoogleFonts.lexend(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.92),
                            ),
                          ),
                        ),
                        Text(
                          '1,250 / 2,000 XP',
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: 0.75,
                        minHeight: 7,
                        backgroundColor: Colors.white.withOpacity(0.24),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF9CFFD1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_filled_rounded,
                          size: 15,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '48 giờ học tích lũy',
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Thành tích gần đây',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2B2554),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Xem tất cả',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ColorSetting.colorprimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const SizedBox(
                height: 86,
                child: Row(
                  children: [
                    Expanded(
                      child: _AchievementCard(
                        icon: Icons.wb_sunny_outlined,
                        iconColor: Color(0xFFC79A2C),
                        title: 'Early Bird',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _AchievementCard(
                        icon: Icons.bolt_rounded,
                        iconColor: Color(0xFF4A6CF7),
                        title: 'Fast Learner',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _AchievementCard(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: Color(0xFF21B3C5),
                        title: 'Streak',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: const [
                    _ProfileMenuTile(
                      icon: Icons.style_outlined,
                      iconColor: Color(0xFF4D67F5),
                      backgroundColor: Color(0xFFEFF2FF),
                      title: 'Bộ thẻ của tôi',
                    ),
                    _ProfileMenuTile(
                      icon: Icons.favorite_border_rounded,
                      iconColor: Color(0xFF2CA6A4),
                      backgroundColor: Color(0xFFE9FBF9),
                      title: 'Bài học yêu thích',
                    ),
                    _ProfileMenuTile(
                      icon: Icons.card_giftcard_rounded,
                      iconColor: Color(0xFFC19334),
                      backgroundColor: Color(0xFFFFF4DE),
                      title: 'Mời bạn bè',
                    ),
                    _ProfileMenuTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: Color(0xFF7A67E8),
                      backgroundColor: Color(0xFFF2EEFF),
                      title: 'Trung tâm trợ giúp',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    context.read<AuthProvider>().signOut(context);
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFE74863),
                    size: 18,
                  ),
                  label: Text(
                    'Đăng xuất',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE74863),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          widget.showBottomNavigation ? null : const SizedBox.shrink(),
    );
  }

  Widget _buildFallbackAvatar(String firstChar) {
    return Container(
      color: const Color(0xFF2B2554),
      alignment: Alignment.center,
      child: Text(
        firstChar,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  String _buildNameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty || localPart == 'Email chưa có') {
      return 'Người dùng Anh Lish';
    }

    final normalized = localPart.replaceAll(RegExp(r'[._-]+'), ' ').trim();
    final words =
        normalized
            .split(RegExp(r'\s+'))
            .where((word) => word.isNotEmpty)
            .map(
              (word) => word[0].toUpperCase() + word.substring(1).toLowerCase(),
            )
            .toList();

    return words.isEmpty ? 'Người dùng Anh Lish' : words.join(' ');
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF27214F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: const Color(0xFFA09AB9),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  final IconData icon;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4C4667),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2A244F),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF8A85A5),
      ),
      onTap: () {},
    );
  }
}
