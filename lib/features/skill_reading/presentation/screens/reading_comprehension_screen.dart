import 'dart:convert';

import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/home/presentation/providers/streak_provider.dart';
import 'package:apphoctienganh/features/skill_reading/domain/entities/reading_feedback.dart';
import 'package:apphoctienganh/features/skill_reading/domain/entities/reading_lesson.dart';
import 'package:apphoctienganh/features/skill_reading/presentation/providers/reading_comprehension_provider.dart';
import 'package:apphoctienganh/features/skill_reading/presentation/providers/reading_lesson_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ReadingComprehensionScreen extends StatefulWidget {
  const ReadingComprehensionScreen({super.key, required this.lesson});

  final ReadingLesson lesson;

  @override
  State<ReadingComprehensionScreen> createState() =>
      _ReadingComprehensionScreenState();
}

class _ReadingComprehensionScreenState
    extends State<ReadingComprehensionScreen> {
  String get _baseUrl => _getEnvValue(
    key: 'AI_OPENAI_BASE_URL',
    fallback: 'http://10.0.2.2:8317/v1',
  );
  String get _apiKey => _getEnvValue(key: 'AI_OPENAI_API_KEY', fallback: '');
  String get _model =>
      _getEnvValue(key: 'AI_OPENAI_MODEL', fallback: 'gpt-5.4');

  final TextEditingController _meaningController = TextEditingController();
  String _selectedTranslationMode = 'full_passage';
  int _currentSegmentIndex = 0;
  final Map<String, List<String>> _modeAnswers = {
    'sentence': <String>[],
    'word': <String>[],
    'paragraph': <String>[],
  };

  String _getEnvValue({required String key, required String fallback}) {
    try {
      return dotenv.env[key] ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ReadingComprehensionProvider>().loadLesson(
        widget.lesson,
      );
      if (!mounted) return;
      await _checkInStreak();
    });
  }

  @override
  void dispose() {
    _meaningController.dispose();
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

  Future<void> _submitForGrading() async {
    final comprehensionProvider = context.read<ReadingComprehensionProvider>();
    final lessonProvider = context.read<ReadingLessonProvider>();
    final lesson = comprehensionProvider.lesson ?? widget.lesson;
    _syncCurrentSegmentAnswer();
    final userMeaning = _currentUserMeaning().trim();

    if (userMeaning.isEmpty) {
      _showMessage(
        'Vui lòng nhập nghĩa của đoạn văn trước khi chấm AI.',
        false,
      );
      return;
    }

    comprehensionProvider.updateMeaning(userMeaning);
    comprehensionProvider.setSubmitting(true);

    try {
      final prompt = lessonProvider.buildGradingPrompt(
        lessonTitle: lesson.title,
        originalText: lesson.content,
        userMeaning: userMeaning,
        translationMode: _selectedTranslationMode,
      );
      final raw = await _sendAiRequest(prompt);
      final feedback = _parseFeedback(raw);
      if (!mounted) return;
      comprehensionProvider.applyFeedback(feedback);
      _showMessage('AI đã chấm xong bài đọc hiểu.', true);
    } catch (e) {
      if (!mounted) return;
      comprehensionProvider.setSubmitting(false);
      _showMessage('Không thể chấm bài bằng AI: $e', false);
    }
  }

  Future<String> _sendAiRequest(String prompt) async {
    if (_apiKey.trim().isEmpty) {
      throw Exception('thiếu AI_OPENAI_API_KEY trong file .env');
    }

    final response = await http
        .post(
          Uri.parse('$_baseUrl/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'model': _model,
            'messages': [
              {
                'role': 'system',
                'content':
                    'Bạn là trợ lý chấm bài đọc hiểu tiếng Anh sang tiếng Việt. '
                    'Hãy đánh giá ngắn gọn, dễ hiểu và ưu tiên đúng nghĩa toàn đoạn. '
                    'Bắt buộc trả JSON thuần, không markdown, không giải thích ngoài JSON. '
                    'Định dạng: {"score":90,"short_comment":"...","overall_meaning":"...","word_meanings":[{"word":"...","meaning":"..."}]}.',
              },
              {'role': 'user', 'content': prompt},
            ],
            'temperature': 0.3,
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API lỗi ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final content = decoded['choices']?[0]?['message']?['content'];

    if (content is String && content.trim().isNotEmpty) {
      return content.trim();
    }

    if (content is List) {
      final buffer = StringBuffer();
      for (final item in content) {
        if (item is Map && item['type'] == 'text') {
          buffer.write((item['text'] ?? '').toString());
        }
      }
      final merged = buffer.toString().trim();
      if (merged.isNotEmpty) {
        return merged;
      }
    }

    throw Exception('AI chưa trả về nội dung hợp lệ');
  }

  ReadingFeedback _parseFeedback(String rawContent) {
    final cleaned =
        rawContent.replaceAll('```json', '').replaceAll('```', '').trim();
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');

    if (start == -1 || end == -1 || end <= start) {
      throw const FormatException('Invalid JSON');
    }

    final jsonText = cleaned.substring(start, end + 1);
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map) {
      throw const FormatException('Invalid payload');
    }

    final rawWordMeanings = decoded['word_meanings'];
    final wordMeanings =
        rawWordMeanings is List
            ? rawWordMeanings
                .whereType<Map>()
                .map(
                  (item) => WordMeaning(
                    word: (item['word'] ?? '').toString().trim(),
                    meaning: (item['meaning'] ?? '').toString().trim(),
                  ),
                )
                .where(
                  (item) => item.word.isNotEmpty && item.meaning.isNotEmpty,
                )
                .toList()
            : <WordMeaning>[];

    return ReadingFeedback(
      score: ((decoded['score'] ?? 0) as num).round().clamp(0, 100),
      shortComment: (decoded['short_comment'] ?? '').toString().trim(),
      overallMeaning: (decoded['overall_meaning'] ?? '').toString().trim(),
      wordMeanings: wordMeanings,
    );
  }

  void _showMessage(String message, bool isSuccess) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isSuccess ? const Color(0xFF10B981) : const Color(0xFFE5484D),
          content: Text(message),
        ),
      );
  }

  void _handleModeChanged(String mode) {
    _syncCurrentSegmentAnswer();
    setState(() {
      _selectedTranslationMode = mode;
      _currentSegmentIndex = 0;
      _meaningController.text = _currentSegmentAnswer();
      _meaningController.selection = TextSelection.fromPosition(
        TextPosition(offset: _meaningController.text.length),
      );
    });
  }

  void _syncCurrentSegmentAnswer() {
    if (_selectedTranslationMode == 'full_passage') {
      return;
    }

    final segments = _activeSegments();
    if (segments.isEmpty) {
      return;
    }

    final answers = _answersForMode(_selectedTranslationMode, segments.length);
    answers[_currentSegmentIndex.clamp(0, answers.length - 1)] =
        _meaningController.text.trim();
  }

  String _currentUserMeaning() {
    if (_selectedTranslationMode == 'full_passage') {
      return _meaningController.text.trim();
    }

    final segments = _activeSegments();
    final answers = _answersForMode(_selectedTranslationMode, segments.length);
    return answers
        .asMap()
        .entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .map(
          (entry) =>
              '${_segmentLabel(_selectedTranslationMode, entry.key)}: ${entry.value.trim()}',
        )
        .join('\n\n');
  }

  List<String> _activeSegments() {
    final content =
        (context.read<ReadingComprehensionProvider>().lesson ?? widget.lesson)
            .content;
    switch (_selectedTranslationMode) {
      case 'sentence':
        return _splitSentences(content);
      case 'word':
        return _splitWords(content);
      case 'paragraph':
        return _splitParagraphs(content);
      default:
        return <String>[];
    }
  }

  List<String> _answersForMode(String mode, int length) {
    final answers = _modeAnswers.putIfAbsent(mode, () => <String>[]);
    while (answers.length < length) {
      answers.add('');
    }
    if (answers.length > length) {
      answers.removeRange(length, answers.length);
    }
    return answers;
  }

  String _currentSegmentAnswer() {
    if (_selectedTranslationMode == 'full_passage') {
      return _meaningController.text;
    }

    final segments = _activeSegments();
    if (segments.isEmpty) {
      return '';
    }

    final answers = _answersForMode(_selectedTranslationMode, segments.length);
    return answers[_currentSegmentIndex.clamp(0, answers.length - 1)];
  }

  void _goToSegment(int nextIndex) {
    _syncCurrentSegmentAnswer();
    final segments = _activeSegments();
    if (segments.isEmpty) {
      return;
    }

    final boundedIndex = nextIndex.clamp(0, segments.length - 1);
    setState(() {
      _currentSegmentIndex = boundedIndex;
      _meaningController.text = _currentSegmentAnswer();
      _meaningController.selection = TextSelection.fromPosition(
        TextPosition(offset: _meaningController.text.length),
      );
    });
  }

  List<String> _splitParagraphs(String content) {
    return content
        .split(RegExp(r'\n\s*\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> _splitSentences(String content) {
    return content
        .split(RegExp(r'(?<=[.!?…])\s+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<String> _splitWords(String content) {
    final matches = RegExp(r"[\p{L}0-9']+", unicode: true).allMatches(content);
    final words =
        matches
            .map((match) => match.group(0)?.trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toList();

    if (words.isEmpty) {
      return <String>[];
    }

    const groupSize = 6;
    final groups = <String>[];
    for (var i = 0; i < words.length; i += groupSize) {
      final end = (i + groupSize > words.length) ? words.length : i + groupSize;
      groups.add(words.sublist(i, end).join(', '));
    }
    return groups;
  }

  String _segmentLabel(String mode, int index) {
    switch (mode) {
      case 'sentence':
        return 'Câu ${index + 1}';
      case 'word':
        return 'Cụm từ ${index + 1}';
      case 'paragraph':
        return 'Đoạn ${index + 1}';
      default:
        return 'Phần ${index + 1}';
    }
  }

  String _segmentSectionTitle(String mode) {
    switch (mode) {
      case 'sentence':
        return 'Câu cần dịch';
      case 'word':
        return 'Từ / cụm từ cần dịch';
      case 'paragraph':
        return 'Đoạn cần dịch';
      default:
        return 'Nhập nghĩa của bạn';
    }
  }

  String _segmentInputLabel(String mode) {
    switch (mode) {
      case 'sentence':
        return 'Bản dịch cho câu hiện tại';
      case 'word':
        return 'Nghĩa cho cụm từ hiện tại';
      case 'paragraph':
        return 'Bản dịch cho đoạn hiện tại';
      default:
        return 'Nhập nghĩa của bạn';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReadingComprehensionProvider>();
    final lesson = provider.lesson ?? widget.lesson;
    final feedback = provider.feedback;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FE),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Đọc hiểu',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: ColorSetting.colorprimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _meaningController.clear();
              _modeAnswers.updateAll((key, value) => <String>[]);
              _currentSegmentIndex = 0;
              provider.reset();
              setState(() {});
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
                  colors: [Color(0xFFE9F8FC), Color(0xFFF0F8FF)],
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
                        label: _translationModeLabel(_selectedTranslationMode),
                      ),
                      _InfoChip(
                        label: lesson.source == 'ai' ? 'AI tạo' : 'Nhập tay',
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
                    'Đọc đoạn văn, nhập nghĩa bằng tiếng Việt rồi để AI chấm và nhận xét ngắn.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      height: 1.5,
                      color: const Color(0xFF6C7298),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(18),
            _SectionCard(
              title: 'Đoạn văn gốc',
              child: Text(
                lesson.content,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  height: 1.75,
                  color: const Color(0xFF27304A),
                ),
              ),
            ),
            const Gap(16),
            _SectionCard(
              title: 'Chế độ làm bài',
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 10) / 2;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        _translationModes
                            .map(
                              (mode) => SizedBox(
                                width: itemWidth,
                                child: _TranslationModeChip(
                                  title: mode.label,
                                  subtitle: mode.description,
                                  selected:
                                      _selectedTranslationMode == mode.value,
                                  onTap: () => _handleModeChanged(mode.value),
                                ),
                              ),
                            )
                            .toList(),
                  );
                },
              ),
            ),
            const Gap(16),
            if (_selectedTranslationMode != 'full_passage') ...[
              Builder(
                builder: (context) {
                  final segments = _activeSegments();
                  final hasSegments = segments.isNotEmpty;
                  final safeIndex =
                      hasSegments
                          ? _currentSegmentIndex.clamp(0, segments.length - 1)
                          : 0;
                  final currentSegment = hasSegments ? segments[safeIndex] : '';

                  return Column(
                    children: [
                      _SectionCard(
                        title: _segmentSectionTitle(_selectedTranslationMode),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_segmentLabel(_selectedTranslationMode, safeIndex)} / ${segments.length}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF7C3AED),
                              ),
                            ),
                            const Gap(10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE6EBF6),
                                ),
                              ),
                              child: Text(
                                currentSegment,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: const Color(0xFF27304A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Gap(12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        safeIndex > 0
                                            ? () => _goToSegment(safeIndex - 1)
                                            : null,
                                    icon: const Icon(Icons.arrow_back_rounded),
                                    label: const Text('Lùi'),
                                  ),
                                ),
                                const Gap(10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        safeIndex < segments.length - 1
                                            ? () => _goToSegment(safeIndex + 1)
                                            : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ColorSetting.colorprimary,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                    ),
                                    label: const Text('Next'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                    ],
                  );
                },
              ),
            ],
            _SectionCard(
              title: _segmentInputLabel(_selectedTranslationMode),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đang làm theo chế độ: ${_translationModeLabel(_selectedTranslationMode)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                  const Gap(10),
                  TextField(
                    controller: _meaningController,
                    minLines: 6,
                    maxLines: 10,
                    onChanged: (_) {
                      if (_selectedTranslationMode == 'full_passage') {
                        provider.updateMeaning(_meaningController.text);
                        return;
                      }
                      _syncCurrentSegmentAnswer();
                      provider.updateMeaning(_currentUserMeaning());
                    },
                    decoration: InputDecoration(
                      hintText: _meaningHint(_selectedTranslationMode),
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
                  const Gap(14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          provider.isSubmitting ? null : _submitForGrading,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorSetting.colorprimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon:
                          provider.isSubmitting
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.auto_awesome_rounded),
                      label: Text(
                        provider.isSubmitting
                            ? 'AI đang chấm...'
                            : 'Chấm bằng AI',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (provider.hasResult) ...[
              const Gap(16),
              _SectionCard(
                title: 'Kết quả chấm',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Điểm: ${feedback.score}/100',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2E5BFF),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Text(
                      feedback.shortComment,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              _SectionCard(
                title: 'Nghĩa từng từ / cụm từ',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      feedback.wordMeanings
                          .map(
                            (item) => Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE6EBF6),
                                ),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: const Color(0xFF374151),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${item.word}: ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(text: item.meaning),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const Gap(16),
              _SectionCard(
                title: 'Ghép lại nghĩa cuối cùng',
                child: Text(
                  feedback.overallMeaning,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    height: 1.7,
                    color: const Color(0xFF27304A),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _translationModeLabel(String value) {
    switch (value) {
      case 'sentence':
        return 'Dịch từng câu';
      case 'word':
        return 'Dịch từng chữ';
      case 'paragraph':
        return 'Dịch từng đoạn';
      default:
        return 'Dịch full đoạn';
    }
  }

  String _meaningHint(String value) {
    switch (value) {
      case 'sentence':
        return 'Nhập bản dịch theo từng câu, mỗi câu có thể xuống dòng riêng...';
      case 'word':
        return 'Nhập nghĩa theo từng chữ hoặc từng cụm từ quan trọng...';
      case 'paragraph':
        return 'Nhập bản dịch theo từng đoạn để AI chấm theo từng khối ý...';
      default:
        return 'Nhập bản dịch/ý hiểu của bạn bằng tiếng Việt...';
    }
  }
}

const List<_TranslationModeOption> _translationModes = [
  _TranslationModeOption(
    value: 'sentence',
    label: 'Dịch từng câu',
    description: 'Tách ý theo từng câu riêng.',
  ),
  _TranslationModeOption(
    value: 'word',
    label: 'Dịch từng chữ',
    description: 'Ưu tiên từ vựng và cụm ngắn.',
  ),
  _TranslationModeOption(
    value: 'paragraph',
    label: 'Dịch từng đoạn',
    description: 'Dịch theo từng khối nội dung.',
  ),
  _TranslationModeOption(
    value: 'full_passage',
    label: 'Dịch full đoạn',
    description: 'Dịch toàn bài một lần.',
  ),
];

class _TranslationModeOption {
  const _TranslationModeOption({
    required this.value,
    required this.label,
    required this.description,
  });

  final String value;
  final String label;
  final String description;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF20254D),
            ),
          ),
          const Gap(12),
          child,
        ],
      ),
    );
  }
}

class _TranslationModeChip extends StatelessWidget {
  const _TranslationModeChip({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2E9FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFB95CF4) : const Color(0xFFE8EAF5),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF20254D),
              ),
            ),
            const Gap(4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF7A809E),
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
