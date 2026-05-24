import 'dart:math' as math;

import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/ai/data/datasources/ai_chat_local_data_source.dart';
import 'package:apphoctienganh/features/ai/data/datasources/ai_persona_local_data_source.dart';
import 'package:apphoctienganh/features/ai/data/services/ai_voice_chat_service.dart';
import 'package:apphoctienganh/features/ai/domain/ai_persona.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

IconData _iconFromKey(String iconKey) {
  switch (iconKey) {
    case 'faceSmile':
      return FontAwesomeIcons.faceSmile;
    case 'faceMeh':
      return FontAwesomeIcons.faceMeh;
    case 'heart':
      return FontAwesomeIcons.heart;
    default:
      return FontAwesomeIcons.robot;
  }
}

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
  String get _baseUrl => _getEnvValue(
    key: 'AI_OPENAI_BASE_URL',
    fallback: 'http://10.0.2.2:8317/v1',
  );
  String get _apiKey => _getEnvValue(key: 'AI_OPENAI_API_KEY', fallback: '');
  String get _model =>
      _getEnvValue(key: 'AI_OPENAI_MODEL', fallback: 'gpt-5.4');
  String _getEnvValue({required String key, required String fallback}) {
    try {
      return dotenv.env[key] ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  late final AnimationController _animationController;
  final AiPersonaLocalDataSource _localDataSource = AiPersonaLocalDataSource();
  final AiChatLocalDataSource _chatLocalDataSource = AiChatLocalDataSource();
  final AiVoiceChatService _voiceChatService = AiVoiceChatService();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  String _conversationId = const Uuid().v4();
  bool _isProcessing = false;
  String _statusText = 'Nhấn Bắt đầu để AI lắng nghe bạn';
  String _lastTranscript = '';
  String _lastReply = '';
  bool _isSubmittingSpeech = false;
  bool _isStartingListening = false;
  String? _speechLocaleId;
  String? _systemSpeechLocaleId;
  String? _pendingUserMessage;
  String? _pendingAssistantReply;
  bool _hasUnsavedTurn = false;

  final List<AiPersonal> _personalities = const [
    AiPersonal(
      id: 'vui_ve',
      title: 'Vui vẻ',
      modeTitle: 'Chế độ Vui vẻ',
      description:
          'Nói chuyện tươi sáng, thân thiện và nhiều năng lượng. Phù hợp khi bạn muốn học theo kiểu vui vẻ, đỡ áp lực và được cổ vũ liên tục.',
      systemPrompt:
          'Bạn là người bạn đồng hành vui vẻ, hoạt bát và tích cực. Hãy phản hồi ngắn, ấm áp, dễ gần, thường xuyên cổ vũ người học và giữ không khí thoải mái.',
      iconKey: 'faceSmile',
      colorValue: 0xFF3D5CFF,
    ),
    AiPersonal(
      id: 'cuc_suc',
      title: 'Cục súc',
      modeTitle: 'Chế độ Cục súc',
      description:
          'Phản hồi sắc gọn, thẳng ý và ưu tiên sửa sai nhanh. Hợp khi bạn muốn bị thúc học nghiêm túc, ít vòng vo và tập trung vào kết quả.',
      systemPrompt:
          'Bạn là người hướng dẫn thẳng tính, kỷ luật và trực diện. Hãy trả lời cực gọn, ưu tiên chỉ ra lỗi chính, sửa câu nhanh và thúc người học tập trung tiến bộ.',
      iconKey: 'faceMeh',
      colorValue: 0xFFFF8A3D,
    ),
    AiPersonal(
      id: 'chan_thanh',
      title: 'Chân thành',
      modeTitle: 'Chế độ Chân thành',
      description:
          'Trò chuyện dịu dàng, lắng nghe và kiên nhẫn giải thích. Phù hợp khi bạn muốn được đồng hành chậm rãi, rõ ràng và có cảm giác được thấu hiểu.',
      systemPrompt:
          'Bạn là người bạn chân thành, điềm tĩnh và biết lắng nghe. Hãy giải thích dễ hiểu, sửa lỗi nhẹ nhàng, tạo cảm giác an toàn và động viên người học từng bước.',
      iconKey: 'heart',
      colorValue: 0xFF7B61FF,
    ),
  ];

  int _selectedPersonalityIndex = 0;
  bool _isListening = false;
  String _friendDescription =
      'Một người bạn luyện tiếng Anh vui vẻ, kiên nhẫn, hay động viên và giải thích dễ hiểu.';

  AiPersonal get _selectedPersonality =>
      _personalities[_selectedPersonalityIndex];

  Future<void> _seedDefaultPersonas() async {
    if (_localDataSource.getPersonas().isEmpty) {
      await _localDataSource.savePersonas(_personalities);
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _seedDefaultPersonas();
    _initializeSpeechDefaults();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _friendDescriptionController.dispose();
    _speechToText.stop();
    _voiceChatService.dispose();
    super.dispose();
  }

  void _startPulse() {
    _animationController.repeat();
  }

  void _stopPulse() {
    _animationController
      ..stop()
      ..reset();
  }

  Future<void> _toggleListening() async {
    if (_isListening || _isProcessing) {
      await _stopInteraction();
      return;
    }

    await _startListening();
  }

  bool _isVietnameseLocale(String? localeId) {
    if (localeId == null) {
      return false;
    }

    final normalized = localeId.toLowerCase().replaceAll('_', '-');
    return normalized.startsWith('vi');
  }

  String? _pickPreferredSpeechLocale(List<stt.LocaleName> locales) {
    for (final locale in locales) {
      if (_isVietnameseLocale(locale.localeId)) {
        return locale.localeId;
      }
    }

    return locales.isNotEmpty ? locales.first.localeId : null;
  }

  Future<void> _initializeSpeechDefaults() async {
    final isAvailable = await _speechToText.initialize();
    if (!isAvailable) {
      return;
    }

    final systemLocale = await _speechToText.systemLocale();
    final locales = await _speechToText.locales();
    final preferredLocale =
        _pickPreferredSpeechLocale(locales) ?? systemLocale?.localeId;

    if (!mounted) return;
    setState(() {
      _systemSpeechLocaleId = systemLocale?.localeId;
      _speechLocaleId = preferredLocale;
    });
  }

  Future<void> _startListening() async {
    await _speechToText.stop();
    await _speechToText.cancel();
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final isAvailable = await _speechToText.initialize(
      onStatus: _handleSpeechStatus,
      onError: (error) {
        _stopPulse();
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _isProcessing = false;
          _isSubmittingSpeech = false;
          _isStartingListening = false;
          _statusText = 'Không thể nhận giọng nói: ${error.errorMsg}';
        });
      },
    );

    if (!isAvailable) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _isProcessing = false;
        _isSubmittingSpeech = false;
        _isStartingListening = false;
        _statusText = 'Thiết bị không hỗ trợ nhận giọng nói.';
      });
      return;
    }

    final locales = await _speechToText.locales();
    _speechLocaleId =
        _pickPreferredSpeechLocale(locales) ??
        _speechLocaleId ??
        _systemSpeechLocaleId;

    _startPulse();
    if (!mounted) return;
    setState(() {
      _isListening = true;
      _isProcessing = false;
      _isSubmittingSpeech = false;
      _isStartingListening = true;
      _statusText = 'Đang lắng nghe...';
      _lastTranscript = '';
    });

    await _speechToText.listen(
      onResult: (result) async {
        final words = result.recognizedWords.trim();

        if (!mounted) return;
        setState(() {
          _lastTranscript = words;
        });

        if (result.finalResult &&
            words.isNotEmpty &&
            !_isSubmittingSpeech &&
            !_isProcessing) {
          _isSubmittingSpeech = true;
          await _handleRecognizedSpeech(words);
        }
      },
      partialResults: true,
      cancelOnError: true,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: _speechLocaleId,
    );
  }

  void _handleSpeechStatus(String status) {
    if (!mounted) return;

    if (status == 'listening') {
      setState(() {
        _isStartingListening = false;
        _statusText = 'Đang lắng nghe...';
      });
      return;
    }

    if ((status == 'done' || status == 'notListening') &&
        _isListening &&
        !_isSubmittingSpeech &&
        !_isProcessing &&
        !_isStartingListening &&
        _lastTranscript.trim().isEmpty) {
      _stopPulse();
      setState(() {
        _isListening = false;
        _statusText =
            _isVietnameseLocale(_speechLocaleId)
                ? 'Không nghe rõ tiếng Việt, hãy thử nói chậm và rõ hơn.'
                : 'Không nghe rõ, hãy thử nói lại.';
      });
    }
  }

  String? _inferSpeechLocaleId(String text) {
    final value = text.trim();
    if (value.isEmpty) {
      return _speechLocaleId ?? _systemSpeechLocaleId;
    }

    if (RegExp(
      r'[ăâđêôơưĂÂĐÊÔƠƯáàảãạắằẳẵặấầẩẫậéèẻẽẹếềểễệóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵ]',
    ).hasMatch(value)) {
      return _speechLocaleId != null && _isVietnameseLocale(_speechLocaleId)
          ? _speechLocaleId
          : 'vi_VN';
    }

    if (RegExp(r'[ぁ-ゟ゠-ヿ一-龯]').hasMatch(value)) {
      return 'ja_JP';
    }

    if (RegExp(r'[가-힣]').hasMatch(value)) {
      return 'ko_KR';
    }

    if (RegExp(r'[\u4E00-\u9FFF]').hasMatch(value)) {
      return 'zh_CN';
    }

    if (RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'en_US';
    }

    return _speechLocaleId ?? _systemSpeechLocaleId;
  }

  Future<void> _handleRecognizedSpeech(String text) async {
    _stopPulse();
    await _speechToText.stop();

    final inferredSpeechLocaleId = _inferSpeechLocaleId(text);

    if (!mounted) return;
    setState(() {
      _isListening = false;
      _isProcessing = true;
      _isStartingListening = false;
      if (_isVietnameseLocale(inferredSpeechLocaleId)) {
        _speechLocaleId = inferredSpeechLocaleId;
      }
      _statusText = 'AI đang suy nghĩ...';
    });

    try {
      final result = await _voiceChatService.sendMessage(
        baseUrl: _baseUrl,
        apiKey: _apiKey,
        model: _model,
        persona: _selectedPersonality,
        friendDescription: _friendDescription,
        conversationId: _conversationId,
        userMessage: text,
      );

      if (!mounted) return;
      setState(() {
        _lastReply = result.reply;
        _pendingUserMessage = text;
        _pendingAssistantReply = result.reply;
        _hasUnsavedTurn = true;
        _statusText = 'AI đang phản hồi bằng giọng nói...';
      });

      await _voiceChatService.speakAndWait(
        text: result.reply,
        language: result.language,
        emotion: result.emotion,
      );

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _isSubmittingSpeech = false;
        _isStartingListening = false;
        _statusText =
            result.shouldListenAgain
                ? 'Đang chuẩn bị lắng nghe lại...'
                : 'Nhấn Bắt đầu để tiếp tục trò chuyện';
      });

      if (result.shouldListenAgain) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        await _startListening();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _isSubmittingSpeech = false;
        _isStartingListening = false;
        _statusText = 'Có lỗi xảy ra: $error';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi AI voice chat: $error')));
    }
  }

  Future<void> _stopInteraction() async {
    await _speechToText.stop();
    await _speechToText.cancel();
    await _voiceChatService.stopSpeaking();
    _stopPulse();

    final shouldSaveTurn =
        _hasUnsavedTurn &&
        (_pendingUserMessage?.trim().isNotEmpty ?? false) &&
        (_pendingAssistantReply?.trim().isNotEmpty ?? false);

    if (shouldSaveTurn) {
      await _voiceChatService.saveConversationTurn(
        conversationId: _conversationId,
        persona: _selectedPersonality,
        userMessage: _pendingUserMessage!,
        assistantReply: _pendingAssistantReply!,
      );
    }

    if (!mounted) return;
    setState(() {
      _isListening = false;
      _isProcessing = false;
      _isSubmittingSpeech = false;
      _isStartingListening = false;
      _pendingUserMessage = null;
      _pendingAssistantReply = null;
      _hasUnsavedTurn = false;
      _statusText = 'Đã dừng. Nhấn Bắt đầu để trò chuyện tiếp';
    });
  }

  Future<void> _clearAiMemory() async {
    await _chatLocalDataSource.clearAllMessages();
    _conversationId = const Uuid().v4();

    if (!mounted) return;

    setState(() {
      _lastTranscript = '';
      _lastReply = '';
      _pendingUserMessage = null;
      _pendingAssistantReply = null;
      _hasUnsavedTurn = false;
      _statusText = 'Đã xóa bộ nhớ AI. Cuộc trò chuyện mới đã được tạo.';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa toàn bộ lịch sử trò chuyện của AI.'),
      ),
    );
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
                            onPressed: () async {
                              await _clearAiMemory();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[300],
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Xóa bộ nhớ AI của bạn',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const Gap(18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              final value = descriptionController.text.trim();
                              final selectedPersona =
                                  _personalities[temporaryIndex];
                              setState(() {
                                _selectedPersonalityIndex = temporaryIndex;
                                _friendDescription =
                                    value.isEmpty
                                        ? 'Một người bạn luyện tiếng Anh thân thiện, dễ nói chuyện và luôn hỗ trợ bạn.'
                                        : value;
                                _friendDescriptionController.text =
                                    _friendDescription;
                              });
                              await _localDataSource.saveSelectedPersona(
                                selectedPersona,
                              );
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
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
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
                              color:
                                  _isListening
                                      ? ColorSetting.colorprimary
                                      : _isProcessing
                                      ? const Color(0xFFFF8A3D)
                                      : const Color(0xFF7B61FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Gap(8),
                          Flexible(
                            child: Text(
                              _statusText,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF5F5A93),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                                  Color(personality.colorValue),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                    personality.colorValue,
                                  ).withOpacity(0.34),
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
                      isProcessing: _isProcessing,
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
                  const Gap(16),
                  if (_lastTranscript.isNotEmpty)
                    _ConversationPreviewCard(
                      title: 'Bạn vừa nói',
                      icon: Icons.mic_rounded,
                      color: const Color(0xFF3D5CFF),
                      content: _lastTranscript,
                    ),
                  if (_lastTranscript.isNotEmpty) const Gap(12),
                  if (_lastReply.isNotEmpty)
                    _ConversationPreviewCard(
                      title: 'AI trả lời',
                      color: Color(personality.colorValue),
                      content: _lastReply,
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

class _PersonalityOptionCard extends StatelessWidget {
  const _PersonalityOptionCard({
    required this.personality,
    required this.isSelected,
    required this.onTap,
  });

  final AiPersonal personality;
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
              _iconFromKey(personality.iconKey),
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

  final AiPersonal personality;
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

class _ConversationPreviewCard extends StatelessWidget {
  const _ConversationPreviewCard({
    required this.title,
    this.icon,
    required this.color,
    required this.content,
  });

  final String title;
  final IconData? icon;
  final Color color;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5DDF8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Gap(12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D2755),
                  ),
                ),
                const Gap(6),
                Text(
                  content,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    height: 1.5,
                    color: const Color(0xFF5D5779),
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
  const _AiListeningButton({
    required this.isListening,
    required this.isProcessing,
    required this.onTap,
  });

  final bool isListening;
  final bool isProcessing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isListening
            ? const Color(0xFFC94B4B)
            : isProcessing
            ? const Color(0xFF7B61FF)
            : ColorSetting.colorprimary;

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
              isListening
                  ? Icons.stop_rounded
                  : isProcessing
                  ? Icons.graphic_eq_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 22,
            ),
            const Gap(8),
            Text(
              isListening
                  ? 'Dừng'
                  : isProcessing
                  ? 'AI đang trả lời'
                  : 'Bắt đầu',
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
