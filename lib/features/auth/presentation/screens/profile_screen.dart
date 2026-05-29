import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/auth/presentation/providers/auth_provider.dart';
import 'package:apphoctienganh/features/home/presentation/providers/home_provider.dart';
import 'package:apphoctienganh/features/home/presentation/providers/streak_provider.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeProvider>().loadDataforsetstateinhomepage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<AuthProvider>().getCurrentUserProfile();
    final streakProvider = context.watch<StreakProvider>();
    final homeProvider = context.watch<HomeProvider>();
    final lists = homeProvider.flashcardLists;
    final studiedCards = lists.fold<int>(
      0,
      (sum, item) => sum + item.studiedCards,
    );
    final estimatedStudyMinutes = (studiedCards * 1.5).round();
    final studyHoursLabel =
        estimatedStudyMinutes < 60
            ? '$estimatedStudyMinutes phút học tích lũy'
            : '${(estimatedStudyMinutes / 60).toStringAsFixed(1)} giờ học tích lũy';

    final xpFromStudy =
        (studiedCards * 10) + (streakProvider.totalStudyDays * 20);
    final level = _computeLevel(xpFromStudy);
    final levelFloorXp = (level - 1) * 200;
    final xpInLevel = (xpFromStudy - levelFloorXp).clamp(0, 200);
    final levelProgress = (xpInLevel / 200).clamp(0.0, 1.0);
    final nextLevelPercent = (levelProgress * 100).round();
    final weeklyActiveDays =
        streakProvider.weeklyActivity.where((item) => item).length;
    final imageUrl = userProfile?.photoUrl ?? '';
    final email = userProfile?.email ?? 'Email chưa có';
    final rawDisplayName = (userProfile?.displayName ?? '').trim();
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
                      email,
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
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: const Color(0xFF4A6CF7),
                      value: '$xpFromStudy',
                      label: 'XP',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.whatshot_rounded,
                      iconColor: const Color(0xFFB67D18),
                      value: '${streakProvider.currentStreak}',
                      label: 'CHUỖI',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.workspace_premium_outlined,
                      iconColor: const Color(0xFF1AA8C8),
                      value: '$weeklyActiveDays',
                      label: 'TUẦN',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProfileStreakCard(streakProvider: streakProvider),
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
                                'Level $level',
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
                            level >= 10 ? 'Nâng cao' : 'Đang phát triển',
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
                            '$nextLevelPercent% để lên cấp ${level + 1}',
                            style: GoogleFonts.lexend(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.92),
                            ),
                          ),
                        ),
                        Text(
                          '$xpInLevel / 200 XP',
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
                        value: levelProgress,
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
                          studyHoursLabel,
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
              SizedBox(
                height: 86,
                child: Row(
                  children: [
                    const Expanded(
                      child: _AchievementCard(
                        icon: Icons.wb_sunny_outlined,
                        iconColor: Color(0xFFC79A2C),
                        title: 'Early Bird',
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: _AchievementCard(
                        icon: Icons.bolt_rounded,
                        iconColor: Color(0xFF4A6CF7),
                        title: 'Fast Learner',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AchievementCard(
                        icon: Icons.local_fire_department_rounded,
                        iconColor: const Color(0xFF21B3C5),
                        title: 'Streak ${streakProvider.currentStreak}',
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
                  children: [
                    _ProfileMenuTile(
                      icon: Icons.style_outlined,
                      iconColor: const Color(0xFF4D67F5),
                      backgroundColor: const Color(0xFFEFF2FF),
                      title: 'Bộ thẻ của tôi',
                      onTap: () {
                        Navigator.of(context).maybePop();
                      },
                    ),
                    _ProfileMenuTile(
                      icon: Icons.favorite_border_rounded,
                      iconColor: const Color(0xFF2CA6A4),
                      backgroundColor: const Color(0xFFE9FBF9),
                      title: 'Bài học yêu thích',
                      onTap: () {
                        _showInfo(
                          'Chức năng bài học yêu thích sẽ được cập nhật sớm.',
                        );
                      },
                    ),
                    _ProfileMenuTile(
                      icon: Icons.card_giftcard_rounded,
                      iconColor: const Color(0xFFC19334),
                      backgroundColor: const Color(0xFFFFF4DE),
                      title: 'Mời bạn bè',
                      onTap: () {
                        _showInfo('Tính năng mời bạn bè đang được phát triển.');
                      },
                    ),
                    _ProfileMenuTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: const Color(0xFF7A67E8),
                      backgroundColor: const Color(0xFFF2EEFF),
                      title: 'Trung tâm trợ giúp',
                      onTap: () {
                        _showInfo(
                          'Liên hệ hỗ trợ qua email: support@anhlish.app',
                        );
                      },
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

  int _computeLevel(int xp) {
    if (xp <= 0) return 1;
    return (xp ~/ 200) + 1;
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

class _ProfileStreakCard extends StatelessWidget {
  const _ProfileStreakCard({required this.streakProvider});

  final StreakProvider streakProvider;

  @override
  Widget build(BuildContext context) {
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: const Color(0xFFFF9F43),
              ),
              const SizedBox(width: 8),
              Text(
                'Chuỗi học tập',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF27214F),
                ),
              ),
              const Spacer(),
              Text(
                '${streakProvider.currentStreak} ngày',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ColorSetting.colorprimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            streakProvider.lastStudyDate == null
                ? 'Bạn chưa bắt đầu streak. Hãy vào một bài học để điểm danh ngày đầu tiên.'
                : 'Bạn đã học ${streakProvider.totalStudyDays} ngày. Tiếp tục duy trì để không đứt chuỗi nhé.',
            style: GoogleFonts.lexend(
              fontSize: 12,
              height: 1.5,
              color: const Color(0xFF7B7599),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(labels.length, (index) {
              final isActive = streakProvider.weeklyActivity[index];
              return _ProfileWeekDayBadge(
                label: labels[index],
                isActive: isActive,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ProfileWeekDayBadge extends StatelessWidget {
  const _ProfileWeekDayBadge({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFFFB347) : const Color(0xFFF1EEFB),
          ),
          child: Icon(
            isActive
                ? Icons.local_fire_department_rounded
                : Icons.local_fire_department_outlined,
            size: 16,
            color: isActive ? Colors.white : const Color(0xFFA09AB9),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF7B7599),
          ),
        ),
      ],
    );
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
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final VoidCallback onTap;

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
      onTap: onTap,
    );
  }
}
