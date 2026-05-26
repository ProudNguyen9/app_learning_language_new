import 'dart:async';
import 'dart:convert';

import 'package:apphoctienganh/features/ai/data/datasources/ai_chat_local_data_source.dart';
import 'package:apphoctienganh/features/ai/domain/ai_chat_message.dart';
import 'package:apphoctienganh/features/ai/domain/ai_persona.dart';
import 'package:apphoctienganh/features/ai/domain/ai_prompt_builder.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class AiVoiceChatResult {
  final String reply;
  final String emotion;
  final String language;
  final bool shouldListenAgain;

  const AiVoiceChatResult({
    required this.reply,
    required this.emotion,
    required this.language,
    required this.shouldListenAgain,
  });

  factory AiVoiceChatResult.fromMap(Map<String, dynamic> json) {
    return AiVoiceChatResult(
      reply: (json['reply'] ?? '').toString(),
      emotion: (json['emotion'] ?? 'calm').toString(),
      language: (json['language'] ?? 'en-US').toString(),
      shouldListenAgain: json['shouldListenAgain'] == true,
    );
  }
}

class AiVoiceChatService {
  AiVoiceChatService({
    AiChatLocalDataSource? chatLocalDataSource,
    http.Client? httpClient,
    FlutterTts? flutterTts,
    Uuid? uuid,
  }) : _chatLocalDataSource = chatLocalDataSource ?? AiChatLocalDataSource(),
       _httpClient = httpClient ?? http.Client(),
       _flutterTts = flutterTts ?? FlutterTts(),
       _uuid = uuid ?? const Uuid() {
    _flutterTts.awaitSpeakCompletion(true);
  }

  final AiChatLocalDataSource _chatLocalDataSource;
  final http.Client _httpClient;
  final FlutterTts _flutterTts;
  final Uuid _uuid;

  static const String _chatPath = '/chat/completions';

  Future<AiVoiceChatResult> sendMessage({
    required String baseUrl,
    required String apiKey,
    required String model,
    required AiPersonal persona,
    required String friendDescription,
    required String conversationId,
    required String userMessage,
  }) async {
    final trimmedMessage = userMessage.trim();
    if (trimmedMessage.isEmpty) {
      throw Exception('Nội dung người dùng đang rỗng.');
    }

    final history = _chatLocalDataSource.getMessagesByConversation(
      conversationId,
    );

    final requestBody = AiPromptBuilder.buildChatRequest(
      persona: persona,
      friendDescription: friendDescription,
      history: history,
      userMessage: trimmedMessage,
      model: model,
    );

    final uri = Uri.parse('${baseUrl.replaceAll(RegExp(r'/$'), '')}$_chatPath');
    http.Response response;
    try {
      response = await _httpClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (apiKey.trim().isNotEmpty) 'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 60));
    } on TimeoutException {
      throw Exception(
        'AI phản hồi quá lâu nên đã bị timeout. Hãy thử lại hoặc kiểm tra server AI.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'AI request failed: ${response.statusCode} ${utf8.decode(response.bodyBytes)}',
      );
    }

    final responseText = utf8.decode(response.bodyBytes);
    final decoded = jsonDecode(responseText) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('AI không trả về choices hợp lệ.');
    }

    final message = choices.first['message'] as Map<String, dynamic>?;
    final rawContent = (message?['content'] ?? '').toString();
    if (rawContent.trim().isEmpty) {
      throw Exception('AI không trả về content hợp lệ.');
    }

    final parsed = AiPromptBuilder.parseResponse(rawContent);
    final result = AiVoiceChatResult.fromMap(parsed);

    return AiVoiceChatResult(
      reply: _sanitizeReplyText(result.reply),
      emotion: result.emotion,
      language: result.language,
      shouldListenAgain: result.shouldListenAgain,
    );
  }

  Future<void> saveConversationTurn({
    required String conversationId,
    required AiPersonal persona,
    required String userMessage,
    required String assistantReply,
  }) async {
    final trimmedUserMessage = userMessage.trim();
    final trimmedAssistantReply = assistantReply.trim();

    if (trimmedUserMessage.isEmpty || trimmedAssistantReply.isEmpty) {
      return;
    }

    final now = DateTime.now();
    await _chatLocalDataSource.saveMessages([
      AiChatMessage(
        id: _uuid.v4(),
        conversationId: conversationId,
        personaId: persona.id,
        role: 'user',
        content: trimmedUserMessage,
        createdAt: now,
      ),
      AiChatMessage(
        id: _uuid.v4(),
        conversationId: conversationId,
        personaId: persona.id,
        role: 'assistant',
        content: trimmedAssistantReply,
        createdAt: now.add(const Duration(milliseconds: 1)),
      ),
    ]);
  }

  Future<void> speak({
    required String text,
    required String language,
    required String emotion,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      return;
    }

    final normalizedLanguage = language.trim().isEmpty ? 'en-US' : language;

    await _flutterTts.stop();
    await _flutterTts.setLanguage(_ttsLanguageFor(normalizedLanguage));
    await _flutterTts.setSpeechRate(_speechRateFor(normalizedLanguage));
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.speak(trimmedText);
  }

  Future<void> speakAndWait({
    required String text,
    required String language,
    required String emotion,
  }) async {
    try {
      await speak(text: text, language: language, emotion: emotion);
    } catch (_) {
      return;
    }
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  String _ttsLanguageFor(String language) {
    final normalized = language.replaceAll('_', '-').toLowerCase();

    if (normalized.startsWith('vi')) return 'vi-VN';
    if (normalized.startsWith('en-gb')) return 'en-GB';
    if (normalized.startsWith('en')) return 'en-US';
    if (normalized.startsWith('ja')) return 'ja-JP';
    if (normalized.startsWith('ko')) return 'ko-KR';
    if (normalized.startsWith('zh')) return 'zh-CN';
    if (normalized.startsWith('fr')) return 'fr-FR';
    if (normalized.startsWith('de')) return 'de-DE';
    if (normalized.startsWith('es')) return 'es-ES';
    return 'en-US';
  }

  double _speechRateFor(String language) {
    final normalized = language.replaceAll('_', '-').toLowerCase();

    if (normalized.startsWith('vi')) return 0.45;
    if (normalized.startsWith('en')) return 0.42;
    return 0.45;
  }

  String _sanitizeReplyText(String text) {
    return text
        .replaceAll(
          RegExp(
            r'[😀-🙏🌀-🗿🚀-🛿🇠-🇿☀-⛿✀-➿⭐❤♡♥♪•◆◉○●■□▶◀▷◁➤➜➥➔🙂-🫿]',
            unicode: true,
          ),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> dispose() async {
    await _flutterTts.stop();
    _httpClient.close();
  }
}
