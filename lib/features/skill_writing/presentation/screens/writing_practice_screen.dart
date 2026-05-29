import 'dart:convert';

import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class WritingPracticeScreen extends StatefulWidget {
  const WritingPracticeScreen({super.key});

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen> {
  String get _baseUrl => _getEnvValue(
    key: 'AI_OPENAI_BASE_URL',
    fallback: 'http://10.0.2.2:8317/v1',
  );
  String get _apiKey => _getEnvValue(key: 'AI_OPENAI_API_KEY', fallback: '');
  String get _model =>
      _getEnvValue(key: 'AI_OPENAI_MODEL', fallback: 'gpt-5.4');

  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  String _mode = 'sentence';
  bool _isGenerating = false;
  bool _isGrading = false;
  String _feedback = '';
  int? _score;

  String _getEnvValue({required String key, required String fallback}) {
    try {
      return dotenv.env[key] ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _promptController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _generatePrompt() async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
      _feedback = '';
      _score = null;
    });

    try {
      final modeLabel =
          _mode == 'sentence' ? 'Sentence Writing' : 'Paragraph Writing';
      final topic =
          _topicController.text.trim().isEmpty
              ? 'đời sống hằng ngày'
              : _topicController.text.trim();

      final prompt = jsonEncode({
        'task': 'generate_writing_prompt',
        'instruction':
            'Tạo đề luyện viết đúng ngôn ngữ người dùng mong muốn trong topic. Trả về JSON thuần.',
        'input': {'mode': modeLabel, 'topic': topic},
        'requirements': {
          'prompt':
              _mode == 'sentence'
                  ? 'Một yêu cầu viết 1 câu ngắn, rõ ràng, dễ hiểu.'
                  : 'Một yêu cầu viết 1 đoạn 4-7 câu theo chủ đề.',
          'tips': '2-3 gợi ý ngắn để viết tốt hơn',
        },
        'format': {
          'prompt': 'string',
          'tips': ['string'],
        },
      });

      final raw = await _sendAiRequest(prompt, temperature: 0.7);
      final decoded = _extractJson(raw);
      final generatedPrompt = (decoded['prompt'] ?? '').toString().trim();
      final tips =
          decoded['tips'] is List
              ? (decoded['tips'] as List)
                  .map((e) => e.toString().trim())
                  .where((e) => e.isNotEmpty)
                  .toList()
              : <String>[];

      if (generatedPrompt.isEmpty) {
        throw const FormatException('AI chưa tạo đề hợp lệ');
      }

      if (!mounted) return;
      setState(() {
        _promptController.text =
            tips.isEmpty
                ? generatedPrompt
                : '$generatedPrompt\n\nGợi ý:\n- ${tips.join('\n- ')}';
      });
    } catch (e) {
      if (!mounted) return;
      _showMessage('Không thể tạo đề viết: $e', false);
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _gradeWriting() async {
    if (_isGrading) return;

    final promptText = _promptController.text.trim();
    final answer = _answerController.text.trim();

    if (promptText.isEmpty || answer.isEmpty) {
      _showMessage(
        'Vui lòng tạo/nhập đề và viết câu trả lời trước khi chấm.',
        false,
      );
      return;
    }

    setState(() {
      _isGrading = true;
      _feedback = '';
      _score = null;
    });

    try {
      final modeLabel =
          _mode == 'sentence' ? 'Sentence Writing' : 'Paragraph Writing';
      final gradingPrompt = jsonEncode({
        'task': 'grade_writing',
        'instruction':
            'Bạn là giám khảo viết. Chấm đúng theo mode, nhận xét ngắn gọn, dễ hiểu. Trả về JSON thuần.',
        'input': {
          'mode': modeLabel,
          'prompt': promptText,
          'user_answer': answer,
        },
        'criteria': ['grammar', 'vocabulary', 'task_response', 'naturalness'],
        'format': {
          'score': 'number',
          'feedback': 'string',
          'better_version': 'string',
        },
      });

      final raw = await _sendAiRequest(gradingPrompt, temperature: 0.3);
      final decoded = _extractJson(raw);

      if (!mounted) return;
      setState(() {
        _score = ((decoded['score'] ?? 0) as num).round().clamp(0, 100);
        final feedback = (decoded['feedback'] ?? '').toString().trim();
        final better = (decoded['better_version'] ?? '').toString().trim();
        _feedback = [
          if (feedback.isNotEmpty) feedback,
          if (better.isNotEmpty) 'Bản viết gợi ý:\n$better',
        ].join('\n\n');
      });
      _showMessage('Đã chấm xong bài viết.', true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Không thể chấm bài viết: $e', false);
    } finally {
      if (mounted) {
        setState(() {
          _isGrading = false;
        });
      }
    }
  }

  Future<String> _sendAiRequest(
    String prompt, {
    required double temperature,
  }) async {
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
                    'Bạn là trợ lý luyện viết. Luôn tuân thủ ngôn ngữ người dùng yêu cầu và trả JSON thuần.',
              },
              {'role': 'user', 'content': prompt},
            ],
            'temperature': temperature,
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

  Map<String, dynamic> _extractJson(String raw) {
    final cleaned = raw.replaceAll('```json', '').replaceAll('```', '').trim();
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw const FormatException('Invalid JSON');
    }
    final jsonText = cleaned.substring(start, end + 1);
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid payload');
    }
    return decoded;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FE),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Kĩ năng viết',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: ColorSetting.colorprimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(),
            const Gap(14),
            _SectionCard(
              title: 'Chế độ luyện viết',
              icon: Icons.tune_rounded,
              child: Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      title: 'Sentence Writing',
                      subtitle: 'Viết 1 câu ngắn',
                      icon: Icons.short_text_rounded,
                      selected: _mode == 'sentence',
                      onTap: () => setState(() => _mode = 'sentence'),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: _ModeButton(
                      title: 'Paragraph Writing',
                      subtitle: 'Viết 1 đoạn 4-7 câu',
                      icon: Icons.notes_rounded,
                      selected: _mode == 'paragraph',
                      onTap: () => setState(() => _mode = 'paragraph'),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(14),
            _SectionCard(
              title: 'Chủ đề',
              icon: Icons.topic_rounded,
              child: TextField(
                controller: _topicController,
                decoration: _inputDecoration(
                  'Ví dụ: công việc mơ ước bằng tiếng Việt',
                ),
              ),
            ),
            const Gap(14),
            _SectionCard(
              title: 'Đề viết',
              icon: Icons.auto_awesome_rounded,
              child: Column(
                children: [
                  TextField(
                    controller: _promptController,
                    minLines: 3,
                    maxLines: 6,
                    decoration: _inputDecoration('Đề viết sẽ hiện ở đây...'),
                  ),
                  const Gap(12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isGenerating ? null : _generatePrompt,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(
                          color: ColorSetting.colorprimary.withOpacity(0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        foregroundColor: ColorSetting.colorprimary,
                      ),
                      icon:
                          _isGenerating
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.auto_awesome_rounded),
                      label: Text(
                        _isGenerating ? 'AI đang tạo đề...' : 'Tạo đề bằng AI',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(14),
            _SectionCard(
              title:
                  _mode == 'sentence'
                      ? 'Viết câu của bạn'
                      : 'Viết đoạn của bạn',
              icon: Icons.edit_note_rounded,
              child: TextField(
                controller: _answerController,
                minLines: 6,
                maxLines: 10,
                decoration: _inputDecoration(
                  _mode == 'sentence'
                      ? 'Viết 1 câu theo đề...'
                      : 'Viết 1 đoạn theo đề...',
                ),
              ),
            ),
            const Gap(14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGrading ? null : _gradeWriting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorSetting.colorprimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon:
                    _isGrading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.rate_review_rounded),
                label: Text(
                  _isGrading ? 'AI đang chấm...' : 'Chấm bài viết',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (_score != null || _feedback.isNotEmpty) ...[
              const Gap(14),
              _buildResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    final modeText =
        _mode == 'sentence' ? 'Luyện viết từng câu' : 'Luyện viết đoạn văn';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorSetting.colorprimary.withOpacity(0.94),
            const Color(0xFF8E6BFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4AFF).withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit_rounded, color: Colors.white),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Writing Practice',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(4),
                Text(
                  modeText,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final score = _score ?? 0;
    final progress = (score / 100).clamp(0.0, 1.0);
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
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: Color(0xFF334155)),
              const Gap(8),
              Text(
                'Kết quả đánh giá',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          if (_score != null) ...[
            const Gap(12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: const Color(0xFFE9EEFF),
                valueColor: AlwaysStoppedAnimation<Color>(
                  score >= 75
                      ? const Color(0xFF22C55E)
                      : (score >= 50
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFEF4444)),
                ),
              ),
            ),
            const Gap(8),
            Text(
              'Điểm: $score/100',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
          if (_feedback.isNotEmpty) ...[
            const Gap(10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                _feedback,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  height: 1.6,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.icon});

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8ECF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: const Color(0xFF5B6285)),
                const Gap(8),
              ],
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF20254D),
                ),
              ),
            ],
          ),
          const Gap(12),
          child,
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF1EDFF) : const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF7C5CFF) : const Color(0xFFE3E8F5),
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    selected
                        ? const Color(0xFFE9E2FF)
                        : const Color(0xFFEFF3FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF4A5280)),
            ),
            const Gap(8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF27304A),
              ),
            ),
            const Gap(2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
