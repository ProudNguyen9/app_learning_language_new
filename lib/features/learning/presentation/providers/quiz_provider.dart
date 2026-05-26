import 'package:flutter/material.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';

class QuizProvider with ChangeNotifier {
  final List<Flashcard> _flashcard = [];
  final Map<int, List<String>> _optionsByIndex = {};

  void load(List<Flashcard> flashcards) {
    _flashcard.clear();
    _flashcard.addAll(flashcards);
    _optionsByIndex.clear();
    _currentIndex = 0;
    _incorrectAnswers = 0;
    _buildOptions();
    notifyListeners();
  }

  int _currentIndex = 0;
  int _incorrectAnswers = 0;

  int get currentIndex => _currentIndex;
  int get incorrectAnswers => _incorrectAnswers;

  Flashcard get currentflashcard => _flashcard[_currentIndex];

  List<Flashcard> get allflashcard => _flashcard;
  List<String> get currentOptions => _optionsByIndex[_currentIndex] ?? [];
  bool get isLastQuestion => _currentIndex >= _flashcard.length - 1;

  bool isCorrect(String selectedAnswer) {
    final isRight = selectedAnswer == currentflashcard.answer;
    if (!isRight) {
      _incorrectAnswers++;
    }
    return isRight;
  }

  void nextQuestion() {
    if (!isLastQuestion) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void resetQuiz() {
    _currentIndex = 0;
    _incorrectAnswers = 0;
    notifyListeners();
  }

  void _buildOptions() {
    for (var i = 0; i < _flashcard.length; i++) {
      final current = _flashcard[i];
      final answerPool =
          _flashcard
              .where(
                (card) =>
                    card.id != current.id &&
                    card.answer.trim().isNotEmpty &&
                    card.answer.trim().toLowerCase() !=
                        current.answer.trim().toLowerCase(),
              )
              .map((card) => card.answer.trim())
              .toSet()
              .toList();

      answerPool.shuffle();

      final totalCards = _flashcard.length;
      final targetOptionCount =
          totalCards <= 2
              ? 2
              : totalCards == 3
              ? 3
              : 4;

      final options = <String>[
        current.answer.trim(),
        ...answerPool.take(targetOptionCount - 1),
      ];

      options.shuffle();
      _optionsByIndex[i] = options;
    }
  }
}
