import 'package:apphoctienganh/features/skill_listening/domain/entities/listening_lesson.dart';
import 'package:apphoctienganh/features/skill_listening/domain/services/listening_lesson_business.dart';
import 'package:flutter/foundation.dart';

class ListeningPracticeProvider extends ChangeNotifier {
  ListeningPracticeProvider({ListeningLessonBusiness? business})
    : _business = business ?? const ListeningLessonBusiness();

  final ListeningLessonBusiness _business;

  ListeningLesson? _lesson;
  List<String> _segments = const [];
  List<String> _answers = const [];
  int _currentSegmentIndex = 0;
  int _correctCount = 0;
  bool _showHint = false;
  bool _isCompleted = false;
  String _lastSubmittedText = '';
  String _feedbackMessage = '';

  ListeningLesson? get lesson => _lesson;
  List<String> get segments => _segments;
  List<String> get answers => _answers;
  int get currentSegmentIndex => _currentSegmentIndex;
  int get correctCount => _correctCount;
  bool get showHint => _showHint;
  bool get isCompleted => _isCompleted;
  String get lastSubmittedText => _lastSubmittedText;
  String get feedbackMessage => _feedbackMessage;

  String get currentSegment {
    if (_segments.isEmpty) return '';
    return _segments[_currentSegmentIndex.clamp(0, _segments.length - 1)];
  }

  String get currentHint => _business.buildHint(currentSegment);

  double get progress => _business.calculateProgress(
    currentIndex: _isCompleted ? _segments.length : _currentSegmentIndex,
    total: _segments.length,
  );

  Future<void> loadLesson(ListeningLesson lesson) async {
    _lesson = lesson;
    _segments = lesson.segments;
    _answers = List.filled(_segments.length, '');
    _currentSegmentIndex = 0;
    _correctCount = 0;
    _showHint = false;
    _isCompleted = false;
    _lastSubmittedText = '';
    _feedbackMessage = '';
    notifyListeners();
  }

  void toggleHint() {
    _showHint = !_showHint;
    notifyListeners();
  }

  void replayCurrentSentenceReady() {
    notifyListeners();
  }

  bool submitAnswer(String value) {
    if (_segments.isEmpty || _isCompleted) return false;

    final trimmed = value.trim();
    _lastSubmittedText = trimmed;
    _answers[_currentSegmentIndex] = trimmed;

    final isCorrect = _business.isSentenceCorrect(
      expected: currentSegment,
      actual: trimmed,
    );

    if (isCorrect) {
      _correctCount++;
      _feedbackMessage = 'Chính xác rồi, sang câu tiếp theo nhé.';
      _showHint = false;

      if (_currentSegmentIndex >= _segments.length - 1) {
        _isCompleted = true;
      } else {
        _currentSegmentIndex++;
      }
    } else {
      _feedbackMessage =
          'Chưa đúng hoàn toàn, bạn nghe lại hoặc bật gợi ý để thử tiếp.';
    }

    notifyListeners();
    return isCorrect;
  }

  void skipToNext() {
    if (_segments.isEmpty || _isCompleted) return;

    if (_currentSegmentIndex >= _segments.length - 1) {
      _isCompleted = true;
    } else {
      _currentSegmentIndex++;
    }
    _showHint = false;
    _feedbackMessage = 'Đã chuyển sang câu tiếp theo.';
    notifyListeners();
  }

  Future<void> resetPractice() async {
    if (_lesson == null) return;
    await loadLesson(_lesson!);
  }
}
