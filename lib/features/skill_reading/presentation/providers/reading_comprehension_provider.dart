import 'package:apphoctienganh/features/skill_reading/domain/entities/reading_feedback.dart';
import 'package:apphoctienganh/features/skill_reading/domain/entities/reading_lesson.dart';
import 'package:flutter/foundation.dart';

class ReadingComprehensionProvider extends ChangeNotifier {
  ReadingLesson? _lesson;
  String _userMeaning = '';
  bool _isSubmitting = false;
  ReadingFeedback _feedback = ReadingFeedback.empty();
  bool _hasResult = false;

  ReadingLesson? get lesson => _lesson;
  String get userMeaning => _userMeaning;
  bool get isSubmitting => _isSubmitting;
  ReadingFeedback get feedback => _feedback;
  bool get hasResult => _hasResult;

  Future<void> loadLesson(ReadingLesson lesson) async {
    _lesson = lesson;
    _userMeaning = '';
    _isSubmitting = false;
    _feedback = ReadingFeedback.empty();
    _hasResult = false;
    notifyListeners();
  }

  void updateMeaning(String value) {
    _userMeaning = value;
    notifyListeners();
  }

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void applyFeedback(ReadingFeedback feedback) {
    _feedback = feedback;
    _hasResult = true;
    _isSubmitting = false;
    notifyListeners();
  }

  void reset() {
    _userMeaning = '';
    _isSubmitting = false;
    _feedback = ReadingFeedback.empty();
    _hasResult = false;
    notifyListeners();
  }
}
