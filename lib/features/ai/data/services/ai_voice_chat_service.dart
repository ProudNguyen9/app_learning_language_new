import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:apphoctienganh/features/ai/data/datasources/ai_chat_local_data_source.dart';
import 'package:apphoctienganh/features/ai/domain/ai_chat_message.dart';
import 'package:apphoctienganh/features/ai/domain/ai_persona.dart';
import 'package:apphoctienganh/features/ai/domain/ai_prompt_builder.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:edge_tts/edge_tts.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
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
    AudioPlayer? audioPlayer,
    Uuid? uuid,
  }) : _chatLocalDataSource = chatLocalDataSource ?? AiChatLocalDataSource(),
       _httpClient = httpClient ?? http.Client(),
       _audioPlayer = audioPlayer ?? AudioPlayer(),
       _uuid = uuid ?? const Uuid();

  final AiChatLocalDataSource _chatLocalDataSource;
  final http.Client _httpClient;
  final AudioPlayer _audioPlayer;
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
    final response = await _httpClient
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (apiKey.trim().isNotEmpty) 'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 25));

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

    final settings = _voiceSettingsFor(language: language, emotion: emotion);

    final directory = await getTemporaryDirectory();
    final filePath = path.join(
      directory.path,
      'ai_voice_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );
    final audioFile = File(filePath);

    final communicate = Communicate(
      text: trimmedText,
      voice: settings.voice,
      rate: settings.rate,
      pitch: settings.pitch,
      volume: settings.volume,
    );

    await communicate.save(filePath);

    if (!await audioFile.exists()) {
      throw Exception('Không tạo được file âm thanh TTS.');
    }

    final audioBytes = await audioFile.readAsBytes();
    if (audioBytes.isEmpty) {
      throw Exception('File âm thanh TTS rỗng.');
    }

    await _audioPlayer.stop();
    await _audioPlayer.setSourceBytes(audioBytes);
    await _audioPlayer.resume();
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

    try {
      await _audioPlayer.onPlayerComplete.first.timeout(
        const Duration(seconds: 45),
      );
    } on TimeoutException {
      return;
    }
  }

  Future<void> stopSpeaking() async {
    await _audioPlayer.stop();
  }

  _VoiceSettings _voiceSettingsFor({
    required String language,
    required String emotion,
  }) {
    final normalizedLanguage = language.trim().isEmpty ? 'en-US' : language;
    final voice = _voiceForLanguage(normalizedLanguage);

    return switch (emotion) {
      'happy' => _VoiceSettings(
        voice: voice,
        rate: '+8%',
        pitch: '+8Hz',
        volume: '+0%',
      ),
      'encourage' => _VoiceSettings(
        voice: voice,
        rate: '+5%',
        pitch: '+6Hz',
        volume: '+0%',
      ),
      'strict' => _VoiceSettings(
        voice: voice,
        rate: '-6%',
        pitch: '-6Hz',
        volume: '+0%',
      ),
      'sad' => _VoiceSettings(
        voice: voice,
        rate: '-10%',
        pitch: '-10Hz',
        volume: '-5%',
      ),
      'excited' => _VoiceSettings(
        voice: voice,
        rate: '+12%',
        pitch: '+12Hz',
        volume: '+5%',
      ),
      _ => _VoiceSettings(
        voice: voice,
        rate: '+0%',
        pitch: '+0Hz',
        volume: '+0%',
      ),
    };
  }

  String _voiceForLanguage(String language) {
    final normalized = language.replaceAll('_', '-').toLowerCase();

    if (normalized.startsWith('vi')) return 'vi-VN-HoaiMyNeural';
    if (normalized.startsWith('en-gb')) return 'en-GB-SoniaNeural';
    if (normalized.startsWith('en')) return 'en-US-JennyNeural';
    if (normalized.startsWith('ja')) return 'ja-JP-NanamiNeural';
    if (normalized.startsWith('ko')) return 'ko-KR-SunHiNeural';
    if (normalized.startsWith('zh')) return 'zh-CN-XiaoxiaoNeural';
    if (normalized.startsWith('fr')) return 'fr-FR-DeniseNeural';
    if (normalized.startsWith('de')) return 'de-DE-KatjaNeural';
    if (normalized.startsWith('es')) return 'es-ES-ElviraNeural';
    return 'en-US-JennyNeural';
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
    await _audioPlayer.dispose();
    _httpClient.close();
  }
}

class _VoiceSettings {
  final String voice;
  final String rate;
  final String pitch;
  final String volume;

  const _VoiceSettings({
    required this.voice,
    required this.rate,
    required this.pitch,
    required this.volume,
  });
}
