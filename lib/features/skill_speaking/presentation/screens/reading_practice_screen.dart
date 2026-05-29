import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/speech_provider.dart';
import 'package:apphoctienganh/features/home/presentation/providers/streak_provider.dart';
import 'package:apphoctienganh/features/skill_speaking/domain/entities/speaking_lesson.dart';
import 'package:apphoctienganh/features/skill_speaking/presentation/providers/reading_practice_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ReadingPracticeScreen extends StatefulWidget {
  const ReadingPracticeScreen({super.key, required this.lesson});

  final SpeakingLesson lesson;

  @override
  State<ReadingPracticeScreen> createState() => _ReadingPracticeScreenState();
}

class _ReadingPracticeScreenState extends State<ReadingPracticeScreen> {
  bool _isShowingResultDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestMicPermission();
      if (!mounted) return;
      await context.read<ReadingPracticeProvider>().loadLesson(widget.lesson);
      if (!mounted) return;
      await _checkInStreak();
    });
  }

  Future<void> _requestMicPermission() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _checkInStreak() async {
    final result = await context.read<StreakProvider>().recordStudySession();
    if (!mounted || !result.isNewDay) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Điểm danh học tập',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF20254D),
            ),
          ),
          content: Text(
            'Bạn đã hoàn thành check-in hôm nay. Chuỗi hiện tại là ${result.streakDays} ngày.',
            style: GoogleFonts.plusJakartaSans(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Tuyệt vời',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5B5FEF),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showResultDialog(double score) async {
    final roundedScore = score.clamp(0, 100).toStringAsFixed(0);
    final message =
        score >= 85
            ? 'Bạn đọc rất tốt, tiếp tục giữ nhịp như vậy nhé.'
            : score >= 65
            ? 'Bạn đọc khá ổn rồi, chỉ cần rõ nhịp và chính xác hơn một chút.'
            : 'Bạn nên đọc chậm hơn và bám theo chữ karaoke để tăng độ chính xác.';

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Kết quả bài đọc',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF20254D),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Điểm của bạn: $roundedScore%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF5B5FEF),
                ),
              ),
              const Gap(10),
              Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF606788),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Đóng',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5B5FEF),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReadingPracticeProvider>();
    final speechProvider = context.read<SpeechProvider>();
    final lesson = provider.lesson ?? widget.lesson;

    if (provider.isCompleted && !_isShowingResultDialog) {
      _isShowingResultDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _showResultDialog(provider.score);
        if (!mounted) return;
        context.read<ReadingPracticeProvider>().markResultHandled();
        _isShowingResultDialog = false;
      });
    }

    return Scaffold(
      backgroundColor: ColorSetting.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
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
                        'Luyện đọc',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: ColorSetting.colorprimary,
                        ),
                      ),
                    ),
                  ),
                  _CircleIconButton(
                    icon: Icons.replay_rounded,
                    onTap: () => provider.resetAll(),
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
                    colors: [Color(0xFFEEF2FF), Color(0xFFF8F2FF)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeaderChip(label: lesson.level),
                        _HeaderChip(label: lesson.estimatedDuration),
                        _HeaderChip(
                          label:
                              '${provider.currentSegmentIndex + 1}/${provider.segments.isEmpty ? 1 : provider.segments.length} đoạn',
                        ),
                      ],
                    ),
                    const Gap(14),
                    Text(
                      lesson.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF20254D),
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Nhấn bắt đầu là hiệu ứng karaoke tự chạy ngay, bạn đọc theo và cuối bài sẽ hiện điểm.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6C7298),
                      ),
                    ),
                    const Gap(16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: provider.progress.clamp(0, 1),
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.65),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF5B5FEF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(18),
              _SectionLabel(
                icon: Icons.play_lesson_rounded,
                iconColor: const Color(0xFF5B5FEF),
                iconBackground: const Color(0xFFECEBFF),
                title: 'Điều khiển bài luyện',
                subtitle:
                    'Nhấn bắt đầu để karaoke chạy tự động, mic mở luôn và hệ thống tự chấm ở cuối bài.',
              ),
              const Gap(10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          provider.isStarted
                              ? null
                              : () => provider.startPractice(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B5FEF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: Text(
                        'Bắt đầu karaoke',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        speechProvider.speakTextWithLanguage(
                          provider.currentSegment.isEmpty
                              ? lesson.content
                              : provider.currentSegment,
                          'en-US',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5B5FEF),
                        side: const BorderSide(color: Color(0xFFCFD4F9)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.volume_up_rounded, size: 18),
                      label: Text(
                        'Nghe mẫu',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(18),
              _SectionLabel(
                icon: Icons.lyrics_rounded,
                iconColor: const Color(0xFFE27A2C),
                iconBackground: const Color(0xFFFFF1E7),
                title: 'Chế độ karaoke',
                subtitle:
                    'Sau khi bắt đầu, chữ sẽ tự chạy như karaoke để bạn đọc bám theo.',
              ),
              const Gap(10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE7E2F6)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF20254D).withValues(alpha: 0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.isStarted
                          ? 'Karaoke đang chạy tự động'
                          : 'Nhấn bắt đầu để vào bài luyện',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7A809E),
                      ),
                    ),
                    const Gap(10),
                    if (!provider.isStarted)
                      Text(
                        lesson.content,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7292),
                        ),
                      )
                    else
                      _KaraokeWheelView(provider: provider),
                  ],
                ),
              ),
              const Gap(18),
              _SectionLabel(
                icon: Icons.mic_rounded,
                iconColor: const Color(0xFF00A67E),
                iconBackground: const Color(0xFFE8FFF8),
                title: 'Ghi âm và chấm điểm',
                subtitle:
                    'Đọc theo khi karaoke đang chạy, cuối bài hệ thống sẽ tự hiện điểm.',
              ),
              const Gap(10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE7E2F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ScoreChip(
                          label:
                              provider.isListening
                                  ? 'Đang nghe bạn đọc'
                                  : 'Sẵn sàng',
                          color:
                              provider.isListening
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF1F9D55),
                          background:
                              provider.isListening
                                  ? const Color(0xFFFFECEC)
                                  : const Color(0xFFEAF9F0),
                        ),
                        _ScoreChip(
                          label: 'Điểm ${provider.score.toStringAsFixed(0)}%',
                          color: const Color(0xFF5B5FEF),
                          background: const Color(0xFFEFEEFF),
                        ),
                      ],
                    ),
                    const Gap(14),
                    Text(
                      provider.recognizedText.trim().isEmpty
                          ? 'Nhấn bắt đầu để karaoke chạy và phần bạn đọc sẽ hiện ở đây.'
                          : provider.recognizedText.trim(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        height: 1.65,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3E4668),
                      ),
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                !provider.isStarted || !provider.isListening
                                    ? null
                                    : () => provider.stopListeningAndScore(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  provider.isListening
                                      ? const Color(0xFFE53935)
                                      : const Color(0xFF00A67E),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: Icon(
                              provider.isListening
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              size: 18,
                            ),
                            label: Text(
                              provider.isListening
                                  ? 'Kết thúc & chấm điểm'
                                  : 'Đang chờ bắt đầu',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                provider.isStarted
                                    ? () => provider.goNextSegment()
                                    : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF5B5FEF),
                              side: const BorderSide(color: Color(0xFFD6DAF9)),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(Icons.skip_next_rounded, size: 18),
                            label: Text(
                              'Kết thúc bài',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed:
                            provider.isStarted
                                ? () => provider.retryCurrentSegment()
                                : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B728D),
                          side: const BorderSide(color: Color(0xFFE1E5F2)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        icon: const Icon(Icons.restart_alt_rounded, size: 18),
                        label: Text(
                          'Đọc lại từ đầu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF5B5F88),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: const Color(0xFF2D325A),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: const Color(0xFF8A90AE),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _KaraokeWheelView extends StatelessWidget {
  const _KaraokeWheelView({required this.provider});

  final ReadingPracticeProvider provider;

  @override
  Widget build(BuildContext context) {
    final currentIndex = provider.currentSegmentIndex;
    final previousIndex = currentIndex > 0 ? currentIndex - 1 : null;
    final nextIndex =
        currentIndex < provider.segments.length - 1 ? currentIndex + 1 : null;

    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Column(
                children: [
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.18),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Column(
                key: ValueKey(currentIndex),
                mainAxisSize: MainAxisSize.min,
                children: [
                  _WheelSentenceCard(
                    text:
                        previousIndex == null
                            ? ''
                            : provider.segments[previousIndex],
                    matchedWordCount:
                        previousIndex == null
                            ? 0
                            : provider.highlightedWordCountForSegment(
                              previousIndex,
                            ),
                    isActive: false,
                    opacity: previousIndex == null ? 0 : 0.26,
                    scale: 0.9,
                  ),
                  const Gap(8),
                  _WheelSentenceCard(
                    text: provider.segments[currentIndex],
                    matchedWordCount: provider.highlightedWordCountForSegment(
                      currentIndex,
                    ),
                    isActive: true,
                    opacity: 1,
                    scale: 1,
                  ),
                  const Gap(8),
                  _WheelSentenceCard(
                    text: nextIndex == null ? '' : provider.segments[nextIndex],
                    matchedWordCount: 0,
                    isActive: false,
                    opacity: nextIndex == null ? 0 : 0.32,
                    scale: 0.92,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelSentenceCard extends StatelessWidget {
  const _WheelSentenceCard({
    required this.text,
    required this.matchedWordCount,
    required this.isActive,
    required this.opacity,
    required this.scale,
  });

  final String text;
  final int matchedWordCount;
  final bool isActive;
  final double opacity;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 280),
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: isActive ? 84 : 52),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isActive ? 14 : 10,
          ),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF4F1FF) : const Color(0xFFFAFBFF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  isActive ? const Color(0xFF8A76F1) : const Color(0xFFE8EBF6),
            ),
          ),
          child:
              text.trim().isEmpty
                  ? const SizedBox.shrink()
                  : isActive
                  ? _AutoScrollHighlightedSegmentText(
                    expectedText: text,
                    matchedWordCount: matchedWordCount,
                  )
                  : _HighlightedSegmentText(
                    expectedText: text,
                    matchedWordCount: matchedWordCount,
                    isActive: false,
                    maxLines: 2,
                  ),
        ),
      ),
    );
  }
}

class _AutoScrollHighlightedSegmentText extends StatefulWidget {
  const _AutoScrollHighlightedSegmentText({
    required this.expectedText,
    required this.matchedWordCount,
  });

  final String expectedText;
  final int matchedWordCount;

  @override
  State<_AutoScrollHighlightedSegmentText> createState() =>
      _AutoScrollHighlightedSegmentTextState();
}

class _AutoScrollHighlightedSegmentTextState
    extends State<_AutoScrollHighlightedSegmentText> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant _AutoScrollHighlightedSegmentText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.matchedWordCount != widget.matchedWordCount ||
        oldWidget.expectedText != widget.expectedText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        final maxExtent = _scrollController.position.maxScrollExtent;
        if (maxExtent <= 0) return;

        final words =
            widget.expectedText
                .split(RegExp(r'\s+'))
                .where((word) => word.trim().isNotEmpty)
                .length;
        final progress =
            words == 0
                ? 0.0
                : (widget.matchedWordCount / words).clamp(0.0, 1.0);
        final targetOffset = maxExtent * progress;

        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: _HighlightedSegmentText(
          expectedText: widget.expectedText,
          matchedWordCount: widget.matchedWordCount,
          isActive: true,
        ),
      ),
    );
  }
}

class _HighlightedSegmentText extends StatelessWidget {
  const _HighlightedSegmentText({
    required this.expectedText,
    required this.matchedWordCount,
    required this.isActive,
    this.maxLines,
  });

  final String expectedText;
  final int matchedWordCount;
  final bool isActive;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final expectedWords = expectedText.split(RegExp(r'\s+'));

    return RichText(
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
      text: TextSpan(
        children: List.generate(expectedWords.length, (index) {
          final word = expectedWords[index];
          final isMatched = index < matchedWordCount;

          return TextSpan(
            text: '$word${index == expectedWords.length - 1 ? '' : ' '}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: isActive ? 15 : 13,
              height: isActive ? 1.7 : 1.5,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
              color:
                  isMatched
                      ? const Color(0xFF10B981)
                      : isActive
                      ? const Color(0xFF30375B)
                      : const Color(0xFF737A97),
              backgroundColor:
                  isMatched ? const Color(0xFFDFF8EC) : Colors.transparent,
            ),
          );
        }),
      ),
    );
  }
}
