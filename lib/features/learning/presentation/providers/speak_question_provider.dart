import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechQuestion {
  final String id;
  final String question;
  final String questionLanguage;

  SpeechQuestion({
    required this.id,
    required this.question,
    this.questionLanguage = 'en-US',
  });
}

class SpeechQuestionProvider with ChangeNotifier {
  final List<SpeechQuestion> _questions = []; // KHÔNG FIX CỨNG NỮA!

  int _currentIndex = 0;
  int _incorrectAnswers = 0;
  String _spokenText = '';
  bool _isListening = false;

  final stt.SpeechToText _speech = stt.SpeechToText();

  int get currentIndex => _currentIndex;
  int get incorrectAnswers => _incorrectAnswers;
  String get spokenText => _spokenText;
  bool get isListening => _isListening;

  List<SpeechQuestion> get allQuestions => _questions;
  SpeechQuestion get currentQuestion => _questions[_currentIndex];

  bool get isLastQuestion => _currentIndex >= _questions.length - 1;

  Future<void> startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      _isListening = true;
      _speech.listen(
        onResult: (result) {
          _spokenText = result.recognizedWords;
          notifyListeners();
        },
      );
    } else {
      _isListening = false;
      _speech.stop();
    }
    notifyListeners();
  }

  void loadData(List<Flashcard> flashcards) {
    _questions.clear();
    _questions.addAll(
      flashcards.map(
        (flashcard) => SpeechQuestion(
          id: flashcard.id,
          question:
              flashcard
                  .question, // Hoặc flashcard.answer nếu ông chủ muốn điền đáp án
          questionLanguage: flashcard.questionLanguage,
        ),
      ),
    );
    _currentIndex = 0;
    _spokenText = '';
    _incorrectAnswers = 0;
    notifyListeners();
  }

  void stopListening() {
    _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  bool checkAnswer() {
    final expected = _removePunctuation(
      currentQuestion.question.toLowerCase().trim(),
    );
    final spoken = _removePunctuation(_spokenText.toLowerCase().trim());
    final similarity = _calculateSimilarity(expected, spoken);
    bool isCorrect = similarity >= 0.6;
    if (!isCorrect) _incorrectAnswers++;
    return isCorrect;
  }

  String _removePunctuation(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]'), '').trim();
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

  void nextQuestion() {
    if (!isLastQuestion) {
      _currentIndex++;
      _spokenText = '';
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _spokenText = '';
      _isListening = false;
      _speech.stop();
      notifyListeners();
    }
  }

  void resetQuiz() {
    _currentIndex = 0;
    _incorrectAnswers = 0;
    _spokenText = '';
    notifyListeners();
  }
}
