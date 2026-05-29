import 'dart:convert';

import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/skill_speaking/domain/entities/speaking_lesson.dart';
import 'package:apphoctienganh/features/skill_speaking/presentation/providers/speaking_lesson_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class createSpeakingLesson extends StatefulWidget {
  const createSpeakingLesson({super.key, this.initialLesson});

  final SpeakingLesson? initialLesson;

  bool get isEditMode => initialLesson != null;

  @override
  State<createSpeakingLesson> createState() => _CreateSpeakingLessonState();
}

class _CreateSpeakingLessonState extends State<createSpeakingLesson> {
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

    final provider = context.read<SpeakingLessonProvider>();
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
        message: 'Đã tạo nội dung bằng AI, bấm lưu để lưu bài đọc',
        isSuccess: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        message: 'Không thể tạo bài đọc bằng AI: $e',
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
                    'Bạn là trợ lý tạo bài luyện đọc cho app học ngoại ngữ. '
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
      throw const FormatException('AI trả về thiếu nội dung bài đọc');
    }

    return {'title': title, 'content': content, 'level': level};
  }

  Future<void> _saveLesson() async {
    final lessonProvider = context.read<SpeakingLessonProvider>();
    final result =
        widget.isEditMode
            ? await lessonProvider.updateLesson(
              id: widget.initialLesson!.id,
              title: _titleController.text,
              content: _contentController.text,
              level: _selectedLevel,
              source: _useAi ? 'ai' : 'manual',
            )
            : await lessonProvider.saveLesson(
              title: _titleController.text,
              content: _contentController.text,
              level: _selectedLevel,
              source: _useAi ? 'ai' : 'manual',
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    isSuccess
                        ? const Color(0xFFD8F5E2)
                        : const Color(0xFFFFD6D6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isSuccess
                            ? const Color(0xFFE9FAF0)
                            : const Color(0xFFFFEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess
                        ? Icons.check_rounded
                        : Icons.error_outline_rounded,
                    color:
                        isSuccess
                            ? const Color(0xFF1F9D55)
                            : const Color(0xFFE53935),
                    size: 20,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F2A5A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SpeakingLessonProvider>();

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
                            ? 'Chỉnh sửa bài luyện đọc'
                            : 'Tạo bài luyện đọc',
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
                          ? 'Chỉnh lại nội dung bài đọc rồi bấm lưu để cập nhật ngay trong danh sách.'
                          : 'Tạo nội dung trước, kiểm tra lại rồi bấm lưu như màn thẻ nhớ.',
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
                          ? 'Bạn có thể đổi tiêu đề, mức độ, nội dung hoặc tạo lại bằng AI trước khi cập nhật bài đọc.'
                          : 'Không còn tự động lưu. Bạn có thể tạo nhanh bằng AI hoặc tự nhập tay toàn bộ nội dung bài đọc.',
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
                title: 'Tiêu đề bài đọc',
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
                    hintText: 'Ví dụ: Hội thoại ở quán cà phê',
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFF8A76F1),
                  ),
                ),
              ),
              const Gap(18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            items: const [
                              DropdownMenuItem(
                                value: 'Cơ bản',
                                child: Text('Cơ bản'),
                              ),
                              DropdownMenuItem(
                                value: 'Trung bình',
                                child: Text('Trung bình'),
                              ),
                              DropdownMenuItem(
                                value: 'Nâng cao',
                                child: Text('Nâng cao'),
                              ),
                            ],
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
                      ],
                    ),
                  ),
                ],
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
                      hintText:
                          'Ví dụ: gọi món ở nhà hàng, giới thiệu bản thân, hỏi đường...',
                      icon: Icons.psychology_alt_rounded,
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
                      backgroundColor: const Color(0xFF5B5FEF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: Icon(
                      _isGenerating
                          ? Icons.hourglass_top_rounded
                          : Icons.auto_awesome_rounded,
                      size: 18,
                    ),
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
                iconColor: const Color(0xFFE16A8A),
                iconBackground: const Color(0xFFFDEEF3),
                title: 'Nội dung bài đọc',
                subtitle: 'Bạn có thể sửa lại nội dung AI tạo trước khi lưu.',
              ),
              const Gap(10),
              _InputCard(
                child: TextFormField(
                  controller: _contentController,
                  maxLines: 12,
                  minLines: 8,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2B315A),
                  ),
                  decoration: _inputDecoration(
                    hintText: 'Nhập hoặc tạo nội dung bài đọc ở đây...',
                    icon: Icons.article_rounded,
                    iconColor: const Color(0xFFE16A8A),
                  ),
                ),
              ),
              const Gap(18),
              _SectionLabel(
                icon: Icons.visibility_rounded,
                iconColor: const Color(0xFF4F46E5),
                iconBackground: const Color(0xFFEFF3FF),
                title: 'Xem trước',
                subtitle: 'Kiểm tra lại trước khi bấm lưu.',
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
                      _titleController.text.trim().isEmpty
                          ? 'Chưa có tiêu đề'
                          : _titleController.text.trim(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF242A4A),
                      ),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(label: _selectedLevel),
                        _InfoChip(label: _useAi ? 'Tạo bằng AI' : 'Nhập tay'),
                      ],
                    ),
                    const Gap(14),
                    Text(
                      _contentController.text.trim().isEmpty
                          ? 'Nội dung xem trước sẽ hiện ở đây sau khi bạn nhập hoặc tạo bằng AI.'
                          : _contentController.text.trim(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.65,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF58607F),
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

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    required Color iconColor,
  }) {
    return InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 16, right: 10),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 20),
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFA0A5BF),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFE7E2F6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFF8A76F1), width: 1.4),
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

class _InputCard extends StatelessWidget {
  const _InputCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF3F0FF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  selected ? const Color(0xFF8A76F1) : const Color(0xFFE7EAF4),
              width: selected ? 1.3 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      selected
                          ? const Color(0xFFE4DEFF)
                          : const Color(0xFFF5F7FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color:
                      selected
                          ? const Color(0xFF5B5FEF)
                          : const Color(0xFF7A809E),
                ),
              ),
              const Gap(12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF242A4A),
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
        color: const Color(0xFFF3F5FB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF68708F),
        ),
      ),
    );
  }
}
