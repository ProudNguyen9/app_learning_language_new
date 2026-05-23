import 'dart:math' as math;

import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController
  _friendDescriptionController = TextEditingController(
    text:
        'Một người bạn luyện tiếng Anh vui vẻ, kiên nhẫn, hay động viên và giải thích dễ hiểu.',
  );

  late final AnimationController _animationController;

  final List<_AiPersonality> _personalities = const [
    _AiPersonality(
      title: 'Vui vẻ',
      modeTitle: 'Chế độ Vui vẻ',
      description:
          'AI sẽ trò chuyện một cách năng động, sử dụng nhiều biểu cảm và khích lệ bạn liên tục trong suốt quá trình luyện tập.',
      icon: FontAwesomeIcons.faceSmile,
      color: Color(0xFF3D5CFF),
    ),
    _AiPersonality(
      title: 'Cục súc',
      modeTitle: 'Chế độ Cục súc',
      description:
          'AI phản hồi ngắn gọn, thẳng vấn đề và thúc bạn học nghiêm túc hơn nhưng vẫn giữ nội dung hữu ích.',
      icon: FontAwesomeIcons.faceMeh,
      color: Color(0xFFFF8A3D),
    ),
    _AiPersonality(
      title: 'Chân thành',
      modeTitle: 'Chế độ Chân thành',
      description:
          'AI giao tiếp nhẹ nhàng, kiên nhẫn, giải thích kỹ và tập trung động viên bạn tiến bộ từng chút một.',
      icon: FontAwesomeIcons.heart,
      color: Color(0xFF7B61FF),
    ),
  ];

  int _selectedPersonalityIndex = 0;
  bool _isListening = false;
  String _friendDescription =
      'Một người bạn luyện tiếng Anh vui vẻ, kiên nhẫn, hay động viên và giải thích dễ hiểu.';

  _AiPersonality get _selectedPersonality =>
      _personalities[_selectedPersonalityIndex];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _friendDescriptionController.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      _animationController.repeat();
    } else {
      _animationController
        ..stop()
        ..reset();
    }
  }

  void _openPersonalitySettings() {
    var temporaryIndex = _selectedPersonalityIndex;
    final descriptionController = TextEditingController(
      text: _friendDescription,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final temporaryPersonality = _personalities[temporaryIndex];
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F3FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCD5F2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const Gap(18),
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E1FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.sliders,
                                  size: 18,
                                  color: ColorSetting.colorprimary,
                                ),
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cài đặt bạn AI',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF241B4A),
                                    ),
                                  ),
                                  const Gap(3),
                                  Text(
                                    'Chọn tính cách và mô tả người bạn trò chuyện.',
                                    style: GoogleFonts.lexend(
                                      fontSize: 12,
                                      color: const Color(0xFF7D7697),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(18),
                        Text(
                          'Cá tính',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: const Color(0xFF4C4772),
                          ),
                        ),
                        const Gap(10),
                        Row(
                          children: List.generate(_personalities.length, (
                            index,
                          ) {
                            final personality = _personalities[index];
                            final isSelected = index == temporaryIndex;

                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right:
                                      index == _personalities.length - 1
                                          ? 0
                                          : 8,
                                ),
                                child: _PersonalityOptionCard(
                                  personality: personality,
                                  isSelected: isSelected,
                                  onTap: () {
                                    setModalState(() {
                                      temporaryIndex = index;
                                    });
                                  },
                                ),
                              ),
                            );
                          }),
                        ),
                        const Gap(14),
                        _PersonalityDescriptionCard(
                          personality: temporaryPersonality,
                          friendDescription: descriptionController.text,
                        ),
                        const Gap(16),
                        Text(
                          'Mô tả người bạn trò chuyện',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2D2755),
                          ),
                        ),
                        const Gap(8),
                        TextField(
                          controller: descriptionController,
                          minLines: 3,
                          maxLines: 5,
                          onChanged: (_) => setModalState(() {}),
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            height: 1.45,
                            color: const Color(0xFF2D2755),
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Ví dụ: Một người bạn nói chuyện nhẹ nhàng, hay sửa lỗi phát âm và đưa ví dụ ngắn...',
                            hintStyle: GoogleFonts.lexend(
                              fontSize: 12,
                              height: 1.45,
                              color: const Color(0xFF9B94B7),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5DDF8),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5DDF8),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: ColorSetting.colorprimary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const Gap(18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              final value = descriptionController.text.trim();
                              setState(() {
                                _selectedPersonalityIndex = temporaryIndex;
                                _friendDescription =
                                    value.isEmpty
                                        ? 'Một người bạn luyện tiếng Anh thân thiện, dễ nói chuyện và luôn hỗ trợ bạn.'
                                        : value;
                                _friendDescriptionController.text =
                                    _friendDescription;
                              });
                              descriptionController.dispose();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorSetting.colorprimary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Lưu cài đặt',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(descriptionController.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final personality = _selectedPersonality;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, _) {
            final pulse =
                (math.sin(_animationController.value * math.pi * 2) + 1) / 2;
            final waveScale = _isListening ? 0.96 + pulse * 0.06 : 1.0;
            final glowOpacity = _isListening ? 0.12 + pulse * 0.12 : 0.10;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: ColorSetting.colorprimary,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'AI Trò Chuyện',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: ColorSetting.colorprimary,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _openPersonalitySettings,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/uselogo.jpg',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(28),
                  if (_isListening)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.86),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFE6DFFC)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: ColorSetting.colorprimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              'Đang lắng nghe...',
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF5F5A93),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 34),
                  const Gap(24),
                  Center(
                    child: Transform.scale(
                      scale: waveScale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _PulseCircle(
                            size: 270,
                            color: ColorSetting.colorprimary.withOpacity(
                              glowOpacity,
                            ),
                          ),
                          _PulseCircle(
                            size: 220,
                            color: const Color(0xFFD8D1FF).withOpacity(0.72),
                          ),
                          _PulseCircle(
                            size: 166,
                            color: Colors.white.withOpacity(0.72),
                          ),
                          Container(
                            width: 136,
                            height: 136,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  ColorSetting.colorprimary,
                                  personality.color,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: personality.color.withOpacity(0.34),
                                  blurRadius: 30,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/AI persona.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(28),
                  Center(
                    child: _AiListeningButton(
                      isListening: _isListening,
                      onTap: _toggleListening,
                    ),
                  ),
                  const Gap(26),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'CÁ TÍNH CỦA AI',
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: const Color(0xFF4C4772),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _openPersonalitySettings,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFE5DDF8)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 15,
                                color: ColorSetting.colorprimary,
                              ),
                              const Gap(6),
                              Text(
                                'Tùy chỉnh',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: ColorSetting.colorprimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Gap(14),
                  _PersonalityDescriptionCard(
                    personality: personality,
                    friendDescription: _friendDescription,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AiPersonality {
  const _AiPersonality({
    required this.title,
    required this.modeTitle,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String modeTitle;
  final String description;
  final IconData icon;
  final Color color;
}

class _PersonalityOptionCard extends StatelessWidget {
  const _PersonalityOptionCard({
    required this.personality,
    required this.isSelected,
    required this.onTap,
  });

  final _AiPersonality personality;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ColorSetting.colorprimary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              personality.icon,
              size: 18,
              color:
                  isSelected
                      ? ColorSetting.colorprimary
                      : const Color(0xFF6F688B),
            ),
            const Gap(8),
            Text(
              personality.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color:
                    isSelected
                        ? ColorSetting.colorprimary
                        : const Color(0xFF6F688B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalityDescriptionCard extends StatelessWidget {
  const _PersonalityDescriptionCard({
    required this.personality,
    required this.friendDescription,
  });

  final _AiPersonality personality;
  final String friendDescription;

  @override
  Widget build(BuildContext context) {
    final friendText =
        friendDescription.trim().isEmpty
            ? 'Chưa có mô tả riêng cho người bạn trò chuyện.'
            : friendDescription.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2DAFB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE1DAFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.wandMagicSparkles,
                color: ColorSetting.colorprimary,
                size: 18,
              ),
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personality.modeTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2755),
                  ),
                ),
                const Gap(6),
                Text(
                  personality.description,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    height: 1.5,
                    color: const Color(0xFF777097),
                  ),
                ),
                const Gap(10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    friendText,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      height: 1.45,
                      color: const Color(0xFF5D5779),
                    ),
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

class _PulseCircle extends StatelessWidget {
  const _PulseCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _AiListeningButton extends StatelessWidget {
  const _AiListeningButton({required this.isListening, required this.onTap});

  final bool isListening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isListening ? const Color(0xFFC94B4B) : ColorSetting.colorprimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.24),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isListening ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 22,
            ),
            const Gap(8),
            Text(
              isListening ? 'Dừng' : 'Bắt đầu',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
