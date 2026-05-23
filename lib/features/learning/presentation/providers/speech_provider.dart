import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';

class SpeechProvider with ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  SpeechProvider() {
    _flutterTts.setPitch(0.9);
    _flutterTts.setSpeechRate(0.4);
    _flutterTts.setCompletionHandler(() {
      print("Đã đọc xong!");
    });
  }

  Future<void> speakText(String text, bool isEnglish) async {
    final lang = isEnglish ? 'en-US' : 'vi-VN';
    await speakTextWithLanguage(text, lang);
  }

  Future<void> speakTextWithLanguage(String text, String languageCode) async {
    final lang = languageCode.trim().isEmpty ? 'en-US' : languageCode.trim();
    await _flutterTts.setLanguage(lang);
    await _flutterTts.speak(text);
  }
}
