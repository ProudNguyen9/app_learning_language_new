import 'dart:convert';

import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/skill_reading/domain/entities/reading_lesson.dart';
import 'package:apphoctienganh/features/skill_reading/presentation/providers/reading_lesson_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CreateReadingLessonScreen extends StatefulWidget {
  const CreateReadingLessonScreen({super.key, this.initialLesson});

  final ReadingLesson? initialLesson;

  bool get isEditMode => initialLesson != null;

  @override
  State<CreateReadingLessonScreen> createState() =>
      _CreateReadingLessonScreenState();
}

class _CreateReadingLessonScreenState extends State<CreateReadingLessonScreen> {
  String get _baseUrl => _getEnvValue(
    key: 'AI_OPENAI_BASE_URL',
    fallback: 'http://10.0.2.2:8317/v1',
  );
  String get _apiKey => _getEnvValue(key: 'AI_OPENAI_API_KEY', fallback: '');
  String get _model =>
      _getEnvValue(key: 'AI_OPENAI_MODEL', fallback: 'gpt-5.4');

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _useAi = true;
  bool _isGenerating = false;
  String _selectedLevel = 'Cơ bản';

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
    final lesson = widget.initialLesson;
    if (lesson != null) {
      _titleController.text = lesson.title;
      _contentController.text = lesson.content;
      _selectedLevel = lesson.level;
      _useAi = lesson.source == 'ai';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _generateWithAi() async {
    if (_isGenerating) return;

    final provider = context.read<ReadingLessonProvider>();
    final prompt = provider.buildAiPrompt(
      topic: _topicController.text,
      level: _selectedLevel,
    );

    setState(() {
      _isGenerating = true;
    });

    try {
      final content = await _sendAiRequest(prompt);
      final parsed = _extractLessonPayload(content);
      if (!mounted) return;

      setState(() {
        if (_titleController.text.trim().isEmpty) {
          _titleController.text = parsed['title'] ?? '';
        }
        _contentController.text = parsed['content'] ?? '';
        _selectedLevel =
            parsed['level']?.trim().isNotEmpty == true
                ? parsed['level']!.trim()
                : _selectedLevel;
      });

      _showMessage(
        message: 'Đã tạo nội dung đọc hiểu bằng AI, bấm lưu để dùng bài luyện.',
        isSuccess: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        message: 'Không thể tạo bài đọc hiểu bằng AI: $e',
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
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
                    'Bạn là trợ lý tạo bài đọc hiểu cho app học ngoại ngữ. '
                    'Phải dùng đúng ngôn ngữ mà người dùng yêu cầu trong prompt/topic. '
                    'Nếu người dùng ghi bằng tiếng Việt, hoặc yêu cầu một ngôn ngữ bất kỳ như Nhật, Hàn, Trung, Pháp..., thì content phải đúng ngôn ngữ đó và không được tự ý đổi sang tiếng Anh. '
                    'Chỉ khi người dùng không nói rõ ngôn ngữ thì mới mặc định dùng tiếng Anh. '
                    'Luôn trả về JSON thuần, không markdown, không giải thích thêm. '
                    'Định dạng bắt buộc: {"title":"...","content":"...","level":"..."}.',
              },
              {'role': 'user', 'content': prompt},
            ],
            'temperature': 0.8,
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

  Map<String, String> _extractLessonPayload(String rawContent) {
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

    final title =
        (decoded['title'] ?? decoded['lesson_title'] ?? decoded['topic'] ?? '')
            .toString()
            .trim();
    final content =
        (decoded['content'] ??
                decoded['lesson'] ??
                decoded['passage'] ??
                decoded['text'] ??
                '')
            .toString()
            .trim();
    final level =
        (decoded['level'] ?? decoded['difficulty'] ?? _selectedLevel)
            .toString()
            .trim();

    if (content.isEmpty) {
      throw const FormatException('AI trả về thiếu nội dung bài đọc hiểu');
    }

    return {'title': title, 'content': content, 'level': level};
  }

  Future<void> _saveLesson() async {
    final lessonProvider = context.read<ReadingLessonProvider>();
    final result =
        widget.isEditMode
            ? await lessonProvider.updateLesson(
              id: widget.initialLesson!.id,
              title: _titleController.text,
              content: _contentController.text,
              level: _selectedLevel,
              source: _useAi ? 'ai' : 'manual',
              translationMode: 'full_passage',
            )
            : await lessonProvider.saveLesson(
              title: _titleController.text,
              content: _contentController.text,
              level: _selectedLevel,
              source: _useAi ? 'ai' : 'manual',
              translationMode: 'full_passage',
            );

    if (!mounted) return;

    final isSuccess = result.contains('thành công');
    _showMessage(message: result, isSuccess: isSuccess);

    if (!isSuccess) return;

    FocusScope.of(context).unfocus();
    Navigator.pop(context, true);
  }

  void _showMessage({required String message, required bool isSuccess}) {
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
    final provider = context.watch<ReadingLessonProvider>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorSetting.background,
        body: SingleChildScrollView(
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
                        widget.isEditMode
                            ? 'Chỉnh sửa bài đọc hiểu'
                            : 'Tạo bài đọc hiểu',
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
                    icon:
                        provider.isSaving
                            ? Icons.hourglass_top_rounded
                            : Icons.save_rounded,
                    onTap: provider.isSaving ? () {} : _saveLesson,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.isEditMode
                            ? 'Chỉnh sửa thủ công'
                            : 'Lưu thủ công',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5B5F88),
                        ),
                      ),
                    ),
                    const Gap(14),
                    Text(
                      widget.isEditMode
                          ? 'Chỉnh lại nội dung bài đọc hiểu rồi bấm lưu để cập nhật ngay trong danh sách.'
                          : 'Tạo nội dung trước, kiểm tra lại rồi bấm lưu như màn bài nói.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 19,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF20254D),
                      ),
                    ),
                    const Gap(8),
                    Text(
                      widget.isEditMode
                          ? 'Bạn có thể đổi tiêu đề, mức độ, nội dung hoặc tạo lại bằng AI trước khi cập nhật bài đọc hiểu.'
                          : 'Không còn tự động lưu. Bạn có thể tạo nhanh bằng AI hoặc tự nhập tay toàn bộ nội dung bài đọc hiểu.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6C7298),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),
              _SectionLabel(
                icon: Icons.auto_awesome_rounded,
                iconColor: const Color(0xFF6F63FF),
                iconBackground: const Color(0xFFEEEBFF),
                title: 'Chế độ tạo nội dung',
                subtitle: 'Chọn AI hoặc tự nhập tay.',
              ),
              const Gap(10),
              Row(
                children: [
                  Expanded(
                    child: _ModeOptionCard(
                      title: 'AI Magic',
                      subtitle: 'Tạo bài đọc tự động',
                      icon: Icons.auto_awesome_rounded,
                      selected: _useAi,
                      onTap: () {
                        setState(() {
                          _useAi = true;
                        });
                      },
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _ModeOptionCard(
                      title: 'Tự nhập tay',
                      subtitle: 'Soạn nội dung theo ý bạn',
                      icon: Icons.edit_note_rounded,
                      selected: !_useAi,
                      onTap: () {
                        setState(() {
                          _useAi = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const Gap(18),
              _SectionLabel(
                icon: Icons.title_rounded,
                iconColor: const Color(0xFF5B5FEF),
                iconBackground: const Color(0xFFECEBFF),
                title: 'Tiêu đề bài đọc hiểu',
                subtitle: 'Đặt tên ngắn gọn để dễ tìm lại sau khi lưu.',
              ),
              const Gap(10),
              _InputCard(
                child: TextFormField(
                  controller: _titleController,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2B315A),
                  ),
                  decoration: _inputDecoration(
                    hintText: 'Ví dụ: Email xin nghỉ phép',
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFF8A76F1),
                  ),
                ),
              ),
              const Gap(18),
              _SectionLabel(
                icon: Icons.stacked_bar_chart_rounded,
                iconColor: const Color(0xFF00A67E),
                iconBackground: const Color(0xFFE8FFF8),
                title: 'Mức độ',
                subtitle: 'Chọn độ khó phù hợp.',
              ),
              const Gap(10),
              _InputCard(
                child: DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  items:
                      const ['Cơ bản', 'Trung bình', 'Nâng cao']
                          .map(
                            (level) => DropdownMenuItem<String>(
                              value: level,
                              child: Text(level),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedLevel = value;
                    });
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF8A90AE),
                  ),
                  decoration: _inputDecoration(
                    hintText: 'Chọn mức độ',
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFF00A67E),
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2B315A),
                  ),
                  dropdownColor: Colors.white,
                ),
              ),
              const Gap(18),
              if (_useAi) ...[
                _SectionLabel(
                  icon: Icons.lightbulb_outline_rounded,
                  iconColor: const Color(0xFFE27A2C),
                  iconBackground: const Color(0xFFFFF1E7),
                  title: 'Chủ đề cho AI',
                  subtitle: 'Nhập chủ đề để AI tạo bài đọc gần đúng mong muốn.',
                ),
                const Gap(10),
                _InputCard(
                  child: TextFormField(
                    controller: _topicController,
                    maxLines: 3,
                    minLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2B315A),
                    ),
                    decoration: _inputDecoration(
                      hintText: 'Ví dụ: du lịch, công việc, bạn bè',
                      icon: Icons.tips_and_updates_rounded,
                      iconColor: const Color(0xFFE27A2C),
                    ),
                  ),
                ),
                const Gap(12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateWithAi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111827),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon:
                        _isGenerating
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
                      _isGenerating ? 'AI đang tạo...' : 'Tạo nội dung bằng AI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Gap(18),
              ],
              _SectionLabel(
                icon: Icons.notes_rounded,
                iconColor: const Color(0xFF3E8BFF),
                iconBackground: const Color(0xFFEAF2FF),
                title: 'Nội dung bài đọc hiểu',
                subtitle:
                    'Nhập đoạn văn tiếng Anh để người học đọc, hiểu nghĩa rồi trả lời.',
              ),
              const Gap(10),
              _InputCard(
                child: TextFormField(
                  controller: _contentController,
                  minLines: 10,
                  maxLines: 16,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2B315A),
                  ),
                  decoration: _inputDecoration(
                    hintText:
                        'Nhập đoạn văn tiếng Anh để người học dịch nghĩa và nhận chấm điểm từ AI.',
                    icon: Icons.article_outlined,
                    iconColor: const Color(0xFF3E8BFF),
                  ).copyWith(alignLabelWithHint: true),
                ),
              ),
              const Gap(20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: const Color(0xFF8A76F1),
                    ),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        _useAi
                            ? 'Sau khi AI tạo xong, hãy kiểm tra lại tiêu đề và nội dung trước khi lưu.'
                            : 'Bạn có thể nhập tay toàn bộ bài đọc hiểu rồi bấm lưu để xuất hiện trong danh sách bài luyện.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6C7298),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isSaving ? null : _saveLesson,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorSetting.colorprimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    provider.isSaving
                        ? 'Đang lưu...'
                        : widget.isEditMode
                        ? 'Cập nhật bài đọc hiểu'
                        : 'Lưu bài đọc hiểu',
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
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE9EAF5)),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF2F2A5A)),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const Gap(12),
        Expanded(
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
              const Gap(2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7A809E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeOptionCard extends StatelessWidget {
  const _ModeOptionCard({
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
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEEF1FF) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? const Color(0xFF7C7DFF) : const Color(0xFFE8EAF5),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color:
                    selected
                        ? const Color(0xFFDDE3FF)
                        : const Color(0xFFF4F5FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF5A63F6), size: 20),
            ),
            const Gap(12),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF20254D),
              ),
            ),
            const Gap(4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                height: 1.4,
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

class _InputCard extends StatelessWidget {
  const _InputCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9EAF5)),
      ),
      child: child,
    );
  }
}

InputDecoration _inputDecoration({
  required String hintText,
  required IconData icon,
  required Color iconColor,
}) {
  return InputDecoration(
    border: InputBorder.none,
    hintText: hintText,
    hintStyle: GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF9AA1BC),
    ),
    prefixIcon: Icon(icon, color: iconColor, size: 20),
  );
}
