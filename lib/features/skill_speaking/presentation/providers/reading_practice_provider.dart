import 'dart:async';
import 'dart:math' as math;

import 'package:apphoctienganh/features/skill_speaking/domain/entities/speaking_lesson.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ReadingPracticeProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();

  SpeakingLesson? _lesson;
  List<String> _segments = const [];
  List<String> _expectedWords = const [];
  String _recognizedText = '';
  bool _isReady = false;
  bool _isListening = false;
  bool _isStarted = false;
  bool _isCompleted = false;
  int _currentSegmentIndex = 0;
  int _karaokeWordIndex = 0;
  double _score = 0;
  Timer? _karaokeTimer;

  SpeakingLesson? get lesson => _lesson;
  List<String> get segments => _segments;
  String get recognizedText => _recognizedText;
  bool get isReady => _isReady;
  bool get isListening => _isListening;
  bool get isStarted => _isStarted;
  bool get isCompleted => _isCompleted;
  int get currentSegmentIndex => _currentSegmentIndex;
  double get score => _score;
  int get totalWords => _expectedWords.length;
  int get karaokeWordIndex => _karaokeWordIndex;

  String get currentSegment {
    if (_segments.isEmpty) return '';
    if (_currentSegmentIndex < 0 || _currentSegmentIndex >= _segments.length) {
      return _segments.first;
    }
    return _segments[_currentSegmentIndex];
  }

  int get recognizedWordCount {
    if (_recognizedText.trim().isEmpty) return 0;
    return _recognizedText
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => _normalize(word).isNotEmpty)
        .length;
  }

  double get progress {
    if (_expectedWords.isEmpty) return 0;
    return (_karaokeWordIndex / _expectedWords.length).clamp(0, 1);
  }

  Future<void> loadLesson(SpeakingLesson lesson) async {
    _lesson = lesson;
    _segments = _splitSegments(lesson.content);
    _expectedWords = _extractWords(lesson.content);
    _recognizedText = '';
    _currentSegmentIndex = 0;
    _karaokeWordIndex = 0;
    _score = 0;
    _isStarted = false;
    _isListening = false;
    _isCompleted = false;
    _karaokeTimer?.cancel();
    _isReady = await _speech.initialize();
    notifyListeners();
  }

  Future<void> startPractice() async {
    if (_lesson == null || _expectedWords.isEmpty) return;
    if (!_isReady) {
      _isReady = await _speech.initialize();
    }

    await _speech.stop();
    _karaokeTimer?.cancel();

    _recognizedText = '';
    _currentSegmentIndex = 0;
    _karaokeWordIndex = 0;
    _score = 0;
    _isStarted = true;
    _isCompleted = false;
    _isListening = true;
    notifyListeners();

    await _speech.listen(
      localeId: 'en_US',
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      pauseFor: const Duration(seconds: 5),
      listenFor: const Duration(minutes: 3),
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        notifyListeners();
      },
    );

    _startKaraokeTimer();
  }

  Future<void> startListening() async {
    return;
  }

  Future<void> stopListeningAndScore() async {
    await _completePractice(forceFinish: true);
  }

  Future<void> retryCurrentSegment() async {
    await resetAll();
    await startPractice();
  }

  Future<void> goNextSegment() async {
    await _completePractice(forceFinish: true);
  }

  int highlightedWordCountForSegment(int index) {
    if (index < 0 || index >= _segments.length) return 0;

    final segmentWordCount = _extractWords(_segments[index]).length;
    if (segmentWordCount == 0) return 0;

    final beforeCount = _wordCountBeforeSegment(index);
    final highlighted = _karaokeWordIndex - beforeCount;
    return highlighted.clamp(0, segmentWordCount);
  }

  Future<void> resetAll() async {
    _karaokeTimer?.cancel();
    _karaokeTimer = null;
    await _speech.stop();
    _recognizedText = '';
    _score = 0;
    _currentSegmentIndex = 0;
    _karaokeWordIndex = 0;
    _isListening = false;
    _isStarted = false;
    _isCompleted = false;
    notifyListeners();
  }

  void markResultHandled() {
    _isCompleted = false;
    notifyListeners();
  }

  void _startKaraokeTimer() {
    _karaokeTimer?.cancel();
    if (_expectedWords.isEmpty) return;

    final totalDurationMs = math.max(_expectedWords.length * 550, 6000);
    final perWordMs = math.max(
      220,
      (totalDurationMs / _expectedWords.length).round(),
    );

    _karaokeTimer = Timer.periodic(Duration(milliseconds: perWordMs), (timer) {
      if (!_isStarted) {
        timer.cancel();
        return;
      }

      if (_karaokeWordIndex >= _expectedWords.length) {
        timer.cancel();
        _karaokeTimer = null;
        _completePractice();
        return;
      }

      _karaokeWordIndex++;
      _currentSegmentIndex = _estimateCurrentSegmentIndexByWordIndex(
        _karaokeWordIndex,
      );
      notifyListeners();
    });
  }

  Future<void> _completePractice({bool forceFinish = false}) async {
    if (!_isStarted) return;

    _karaokeTimer?.cancel();
    _karaokeTimer = null;

    if (_isListening || forceFinish) {
      await _speech.stop();
    }

    _isListening = false;
    _karaokeWordIndex = _expectedWords.length;
    _currentSegmentIndex = _segments.isEmpty ? 0 : _segments.length - 1;

    final expected = _normalize(_lesson?.content ?? '');
    final spoken = _normalize(_recognizedText);
    _score = _calculateSimilarity(expected, spoken) * 100;
    _isCompleted = true;
    notifyListeners();
  }

  List<String> _splitSegments(String content) {
    return content
        .split(RegExp(r'(?<=[.!?])\s+|\n+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<String> _extractWords(String text) {
    return text
        .split(RegExp(r'\s+'))
        .map(_normalize)
        .where((word) => word.isNotEmpty)
        .toList();
  }

  int _wordCountBeforeSegment(int index) {
    var total = 0;
    for (var i = 0; i < index && i < _segments.length; i++) {
      total += _extractWords(_segments[i]).length;
    }
    return total;
  }

  int _estimateCurrentSegmentIndexByWordIndex(int highlightedWords) {
    if (_segments.isEmpty) return 0;
    if (highlightedWords <= 0) return 0;

    var cumulativeWords = 0;
    for (var i = 0; i < _segments.length; i++) {
      cumulativeWords += _extractWords(_segments[i]).length;
      if (highlightedWords <= cumulativeWords) {
        return i;
      }
    }

    return _segments.length - 1;
  }

  String _normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').trim();
  }

  double _calculateSimilarity(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    if (a == b) return 1;

    final distance = _levenshteinDistance(a, b);
    final maxLength = a.length > b.length ? a.length : b.length;
    return 1 - (distance / maxLength);
  }

  int _levenshteinDistance(String a, String b) {
    final rows = a.length + 1;
    final cols = b.length + 1;
    final matrix = List.generate(rows, (_) => List.filled(cols, 0));

    for (var i = 0; i < rows; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j < cols; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i < rows; i++) {
      for (var j = 1; j < cols; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((curr, next) => curr < next ? curr : next);
      }
    }

    return matrix[a.length][b.length];
  }
}
