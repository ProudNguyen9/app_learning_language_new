import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/speech_provider.dart';
import 'package:apphoctienganh/features/skill_listening/domain/entities/listening_lesson.dart';
import 'package:apphoctienganh/features/home/presentation/providers/streak_provider.dart';
import 'package:apphoctienganh/features/skill_listening/presentation/providers/listening_practice_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ListeningPracticeScreen extends StatefulWidget {
  const ListeningPracticeScreen({super.key, required this.lesson});

  final ListeningLesson lesson;

  @override
  State<ListeningPracticeScreen> createState() =>
      _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends State<ListeningPracticeScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ListeningPracticeProvider>().loadLesson(widget.lesson);
      if (!mounted) return;
      await _checkInStreak();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
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
              child: const Text('Tuyệt vời'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _playCurrentSentence() async {
    final provider = context.read<ListeningPracticeProvider>();
    final speechProvider = context.read<SpeechProvider>();
    await speechProvider.speakTextWithLanguage(
      provider.currentSegment,
      'en-US',
    );
  }

  Future<void> _showCompleteDialog(BuildContext context) async {
    final provider = context.read<ListeningPracticeProvider>();
    final total = provider.segments.length;
    final score =
        total == 0 ? 0 : ((provider.correctCount / total) * 100).round();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Hoàn thành bài nghe',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF20254D),
            ),
          ),
          content: Text(
            'Bạn đúng ${provider.correctCount}/$total câu - tương đương $score%.',
            style: GoogleFonts.plusJakartaSans(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListeningPracticeProvider>();
    final lesson = provider.lesson ?? widget.lesson;

    if (provider.isCompleted && !_resultShown) {
      _resultShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _showCompleteDialog(context);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FE),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Luyện nghe',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: ColorSetting.colorprimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              _answerController.clear();
              _resultShown = false;
              await provider.resetPractice();
            },
            icon: const Icon(Icons.replay_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAF0FF), Color(0xFFF6EEFF)],
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
                      _InfoChip(label: lesson.level),
                      _InfoChip(label: lesson.estimatedDuration),
                      _InfoChip(
                        label:
                            '${provider.currentSegmentIndex + 1}/${provider.segments.isEmpty ? 1 : provider.segments.length} câu',
                      ),
                    ],
                  ),
                  const Gap(12),
                  Text(
                    lesson.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF20254D),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Nghe từng câu, nhập lại nội dung bạn nghe được. Có thể bật gợi ý nếu cần.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      height: 1.5,
                      color: const Color(0xFF6C7298),
                    ),
                  ),
                  const Gap(16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: provider.progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Câu đang luyện',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF20254D),
                    ),
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              provider.isCompleted
                                  ? null
                                  : _playCurrentSentence,
                          icon: const Icon(Icons.volume_up_rounded),
                          label: const Text('Nghe câu này'),
                        ),
                      ),
                      const Gap(12),
                      OutlinedButton.icon(
                        onPressed:
                            provider.isCompleted
                                ? null
                                : () => provider.toggleHint(),
                        icon: const Icon(Icons.lightbulb_outline_rounded),
                        label: Text(
                          provider.showHint ? 'Ẩn gợi ý' : 'Xem gợi ý',
                        ),
                      ),
                    ],
                  ),
                  if (provider.showHint) ...[
                    const Gap(14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        provider.currentHint,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8A6D1E),
                        ),
                      ),
                    ),
                  ],
                  const Gap(14),
                  TextField(
                    controller: _answerController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Nhập câu bạn nghe được...',
                      filled: true,
                      fillColor: const Color(0xFFFAFBFF),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE3E8F5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE3E8F5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: ColorSetting.colorprimary.withOpacity(0.65),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          provider.isCompleted
                              ? null
                              : () {
                                _answerController.text =
                                    provider.currentSegment;
                              },
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Xem đáp án câu này'),
                    ),
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              provider.isCompleted
                                  ? null
                                  : () {
                                    final ok = provider.submitAnswer(
                                      _answerController.text,
                                    );
                                    if (ok) {
                                      _answerController.clear();
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorSetting.colorprimary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Kiểm tra'),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              provider.isCompleted
                                  ? null
                                  : () {
                                    _answerController.clear();
                                    provider.skipToNext();
                                  },
                          child: const Text('Bỏ qua'),
                        ),
                      ),
                    ],
                  ),
                  if (provider.feedbackMessage.isNotEmpty) ...[
                    const Gap(14),
                    Text(
                      provider.feedbackMessage,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5B5FEF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
