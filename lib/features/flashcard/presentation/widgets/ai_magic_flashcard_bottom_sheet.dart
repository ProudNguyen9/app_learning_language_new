import 'dart:convert';
import 'dart:math';

import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:apphoctienganh/features/flashcard/presentation/providers/flashcard_provider.dart';
import 'package:apphoctienganh/features/flashcard/presentation/widgets/import_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AiMagicFlashcardBottomSheet extends StatefulWidget {
  const AiMagicFlashcardBottomSheet({super.key});

  @override
  State<AiMagicFlashcardBottomSheet> createState() =>
      _AiMagicFlashcardBottomSheetState();
}

class _AiMagicFlashcardBottomSheetState
    extends State<AiMagicFlashcardBottomSheet> {
  String get _baseUrl => _getEnvValue(
    key: 'AI_OPENAI_BASE_URL',
    fallback: 'http://10.0.2.2:8317/v1',
  );
  String get _apiKey => _getEnvValue(key: 'AI_OPENAI_API_KEY', fallback: '');
  String get _model =>
      _getEnvValue(key: 'AI_OPENAI_MODEL', fallback: 'gpt-5.4');

  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_AiChatMessage> _messages = [
    _AiChatMessage(
      isUser: false,
      text:
          'Xin chào! Mình là trợ lý học ngoại ngữ. Bạn có thể hỏi về từ vựng, ngữ pháp, dịch câu, luyện hội thoại hoặc yêu cầu mình tạo flashcard.',
    ),
  ];

  bool _isLoading = false;

  String _getEnvValue({required String key, required String fallback}) {
    try {
      return dotenv.env[key] ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final prompt = _chatController.text.trim();
    if (prompt.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_AiChatMessage(isUser: true, text: prompt));
      _isLoading = true;
      _chatController.clear();
    });
    _scrollToBottom();

    try {
      final aiResponse = await _sendAiRequest(prompt);

      if (!mounted) return;
      setState(() {
        _messages.add(
          _AiChatMessage(
            isUser: false,
            text: aiResponse.message,
            flashcards: aiResponse.flashcards,
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _AiChatMessage(isUser: false, text: 'Không thể tạo flashcard: $e'),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  Future<_AiResponse> _sendAiRequest(String prompt) async {
    final requestedCount = _extractRequestedFlashcardCount(prompt);
    final apiMessages = _buildApiMessages();
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': apiMessages,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API lỗi ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final content = decoded['choices']?[0]?['message']?['content']?.toString();

    if (content == null || content.trim().isEmpty) {
      return const _AiResponse(message: 'Mình chưa nhận được phản hồi từ AI.');
    }

    return _parseAiResponse(content, requestedCount: requestedCount);
  }

  List<Map<String, String>> _buildApiMessages() {
    final apiMessages = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'Bạn là trợ lý học ngoại ngữ trong app flashcard. '
            'Bạn có trí nhớ hội thoại trong các tin nhắn được gửi kèm, hãy dùng ngữ cảnh câu trước để trả lời câu sau. '
            'Chỉ được trả lời các nội dung liên quan học ngoại ngữ: từ vựng, ngữ pháp, dịch câu, ví dụ câu, luyện hội thoại, phát âm, và tạo flashcard. '
            'Nếu người dùng hỏi ngoài phạm vi học ngoại ngữ, hãy từ chối nhẹ nhàng và hướng họ quay lại học ngoại ngữ. '
            'Chỉ tạo flashcard khi người dùng yêu cầu rõ ràng như: tạo thẻ, tạo flashcard, tạo từ vựng, gen thẻ, danh sách từ vựng. '
            'Nếu người dùng chỉ chào hỏi hoặc hỏi bình thường, hãy chat bình thường, không tạo flashcard. '
            'Nếu người dùng yêu cầu số lượng cụ thể, phải tạo đúng số lượng đó, không tạo dư. '
            'Luôn trả về JSON thuần, không markdown, không ```.'
            'Nếu là chat thường: {"type":"chat","message":"nội dung trả lời"}. '
            'Nếu là tạo flashcard: {"type":"flashcards","message":"Mình đã tạo ... thẻ cho bạn:","flashcards":[{"question":"từ/câu ngôn ngữ đang học","answer":"nghĩa tiếng Việt","question_language":"mã TTS của ngôn ngữ đang học","answer_language":"vi-VN"}]}. '
            'Mã TTS hợp lệ ví dụ: en-US, en-GB, vi-VN, ja-JP, ko-KR, zh-CN, fr-FR, de-DE, es-ES, it-IT, pt-BR, ru-RU, th-TH, id-ID, hi-IN, ar-SA. '
            'Nếu người dùng yêu cầu tạo theo nước/ngôn ngữ nào thì question_language phải đúng ngôn ngữ đó. Ví dụ tiếng Nhật là ja-JP, tiếng Hàn là ko-KR, tiếng Trung là zh-CN, tiếng Pháp là fr-FR, tiếng Đức là de-DE, tiếng Tây Ban Nha là es-ES.',
      },
    ];

    final memoryMessages = _messages.skip(1).toList();
    final recentMessages =
        memoryMessages.length > 10
            ? memoryMessages.sublist(memoryMessages.length - 10)
            : memoryMessages;

    for (final message in recentMessages) {
      apiMessages.add({
        'role': message.isUser ? 'user' : 'assistant',
        'content': message.toApiContent(),
      });
    }

    return apiMessages;
  }

  int? _extractRequestedFlashcardCount(String prompt) {
    final match = RegExp(r'\d+').firstMatch(prompt);
    if (match == null) return null;

    final count = int.tryParse(match.group(0) ?? '');
    if (count == null || count <= 0) return null;

    return min(count, 100);
  }

  _AiResponse _parseAiResponse(String content, {int? requestedCount}) {
    final jsonText = _extractJsonObject(content);
    final decoded = jsonDecode(jsonText);

    if (decoded is! Map) {
      return _AiResponse(message: content.trim());
    }

    final type = decoded['type']?.toString();
    final message =
        decoded['message']?.toString().trim().isNotEmpty == true
            ? decoded['message'].toString().trim()
            : 'Mình đã xử lý yêu cầu của bạn.';

    if (type != 'flashcards') {
      return _AiResponse(message: message);
    }

    final rawFlashcards = decoded['flashcards'];
    final flashcards = _parseFlashcardsFromDynamic(rawFlashcards);
    final limitedFlashcards =
        requestedCount == null
            ? flashcards
            : flashcards.take(requestedCount).toList();

    return _AiResponse(message: message, flashcards: limitedFlashcards);
  }

  List<Flashcard> _parseFlashcardsFromDynamic(dynamic value) {
    if (value is! List) return [];

    return value
        .asMap()
        .entries
        .map((entry) {
          final item = entry.value;
          if (item is! Map) {
            return Flashcard(
              id: const Uuid().v4(),
              question: '',
              answer: '',
              questionLanguage: 'en-US',
              answerLanguage: 'vi-VN',
            );
          }

          final question =
              (item['question'] ?? item['term'] ?? item['word'] ?? '')
                  .toString();
          final answer =
              (item['answer'] ?? item['definition'] ?? item['meaning'] ?? '')
                  .toString();
          final questionLanguage =
              (item['question_language'] ??
                      item['questionLanguage'] ??
                      item['language'] ??
                      'en-US')
                  .toString();
          final answerLanguage =
              (item['answer_language'] ?? item['answerLanguage'] ?? 'vi-VN')
                  .toString();

          return Flashcard(
            id: const Uuid().v4(),
            question: question.trim(),
            answer: answer.trim(),
            questionLanguage:
                questionLanguage.trim().isEmpty
                    ? 'en-US'
                    : questionLanguage.trim(),
            answerLanguage:
                answerLanguage.trim().isEmpty ? 'vi-VN' : answerLanguage.trim(),
          );
        })
        .where((flashcard) {
          return flashcard.question.isNotEmpty || flashcard.answer.isNotEmpty;
        })
        .toList();
  }

  String _extractJsonObject(String content) {
    final cleaned =
        content.replaceAll('```json', '').replaceAll('```', '').trim();
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');

    if (start == -1 || end == -1 || end <= start) {
      throw Exception('AI không trả về JSON hợp lệ');
    }

    return cleaned.substring(start, end + 1);
  }

  Future<void> _showImportOptionDialog(List<Flashcard> flashcards) async {
    final flashcardProvider = context.read<FlashcardProvider>();
    final bottomSheetNavigator = Navigator.of(context);

    final shouldReplace = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF2D9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFB56A00),
                  size: 22,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  'Thêm thẻ AI',
                  style: GoogleFonts.lexend(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2F2A5A),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Bạn muốn thêm ${flashcards.length} thẻ AI vào danh sách hiện tại bằng cách nào?',
            style: GoogleFonts.lexend(
              fontSize: 14,
              height: 1.45,
              color: const Color(0xFF5A5781),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF5A5781),
                textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w700),
              ),
              child: const Text('Nối tiếp'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorSetting.colorprimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: GoogleFonts.lexend(fontWeight: FontWeight.w700),
              ),
              child: const Text('Ghi đè'),
            ),
          ],
        );
      },
    );

    if (shouldReplace == null || !mounted) return;

    flashcardProvider.importFlashcards(flashcards, replace: shouldReplace);

    if (bottomSheetNavigator.canPop()) {
      bottomSheetNavigator.pop();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
                Expanded(
                  child: Text(
                    'AI Magic Flashcard',
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2F2A5A),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(8),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoading && index == _messages.length) {
                    return const _AiTypingBubble();
                  }

                  final message = _messages[index];
                  return _AiMessageBubble(
                    message: message,
                    onAddFlashcards:
                        message.flashcards.isEmpty
                            ? null
                            : () => _showImportOptionDialog(message.flashcards),
                  );
                },
              ),
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: Tạo 10 từ vựng chủ đề gia đình',
                      filled: true,
                      fillColor: const Color(0xFFF6F2FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const Gap(8),
                IconButton.filled(
                  onPressed: _isLoading ? null : _sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: ColorSetting.colorprimary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AiChatMessage {
  final bool isUser;
  final String text;
  final List<Flashcard> flashcards;

  const _AiChatMessage({
    required this.isUser,
    required this.text,
    this.flashcards = const [],
  });

  String toApiContent() {
    if (isUser) return text;

    if (flashcards.isEmpty) {
      return jsonEncode({'type': 'chat', 'message': text});
    }

    return jsonEncode({
      'type': 'flashcards',
      'message': text,
      'flashcards':
          flashcards
              .map(
                (flashcard) => {
                  'question': flashcard.question,
                  'answer': flashcard.answer,
                },
              )
              .toList(),
    });
  }
}

class _AiResponse {
  final String message;
  final List<Flashcard> flashcards;

  const _AiResponse({required this.message, this.flashcards = const []});
}

class _AiMessageBubble extends StatelessWidget {
  final _AiChatMessage message;
  final VoidCallback? onAddFlashcards;

  const _AiMessageBubble({required this.message, this.onAddFlashcards});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: message.flashcards.isEmpty ? null : double.infinity,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              message.isUser
                  ? ColorSetting.colorprimary
                  : const Color(0xFFF3EEFF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: message.isUser ? Colors.white : const Color(0xFF2F2A5A),
              ),
            ),
            if (message.flashcards.isNotEmpty) ...[
              const Gap(12),
              for (int i = 0; i < message.flashcards.length; i++)
                FlashcardPreviewItem(
                  index: i,
                  term: message.flashcards[i].question,
                  definition: message.flashcards[i].answer,
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAddFlashcards,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorSetting.colorprimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm thẻ học'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AiTypingBubble extends StatelessWidget {
  const _AiTypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EEFF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            Gap(8),
            Text('AI đang trả lời...'),
          ],
        ),
      ),
    );
  }
}
