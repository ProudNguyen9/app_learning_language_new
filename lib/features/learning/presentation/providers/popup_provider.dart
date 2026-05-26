import 'package:flutter/material.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';

class Popupprovider extends ChangeNotifier {
  List<Flashcard> _flashcards = [];
  List<Flashcard> get flashcards => _flashcards;

  // Đảm bảo rằng biến vẫn là Set<int>
  final Set<int> _matchedIndexes = {};
  final Set<int> _selectedIndexes = {};
  final Set<int> _incorrectIndexes = {};

  // Và các getter không thay đổi:
  Set<int> get matchedIndexes => _matchedIndexes;
  Set<int> get selectedIndexes => _selectedIndexes;
  Set<int> get incorrectIndexes => _incorrectIndexes;

  void loadInitialFlashcards(List<Flashcard> flashcard) {
    // Lưu tạm flashcards gốc từ list đầu tiên
    final original = flashcard;

    // Gọi lại như trong hàm loadData nhưng từ firstList
    _flashcards = [];
    for (var card in original) {
      _flashcards.add(
        Flashcard(
          id: '${card.id}_q',
          question: card.question,
          answer: card.answer,
          questionImage: card.questionImage,
          answerImage: card.answerImage,
        ),
      );
      _flashcards.add(
        Flashcard(
          id: '${card.id}_a',
          question: card.question,
          answer: card.answer,
          questionImage: card.questionImage,
          answerImage: card.answerImage,
        ),
      );
    }

    _flashcards.shuffle();
    _matchedIndexes.clear();
    _selectedIndexes.clear();
    _incorrectIndexes.clear();
    notifyListeners();
  }

  void selectCard(int index) {
    if (_selectedIndexes.contains(index) || _matchedIndexes.contains(index)) {
      return;
    }

    _selectedIndexes.add(index);
    notifyListeners(); // cập nhật UI khi chọn

    if (_selectedIndexes.length == 2) {
      Future.delayed(Duration(milliseconds: 500), () {
        final selected = _selectedIndexes.toList();
        final firstIndex = selected[0];
        final secondIndex = selected[1];

        final firstCard = _flashcards[firstIndex];
        final secondCard = _flashcards[secondIndex];

        // Tách ID gốc ra để so sánh
        String normalizeId(String id) =>
            id.replaceAll('_q', '').replaceAll('_a', '');

        if (normalizeId(firstCard.id) == normalizeId(secondCard.id) &&
            firstCard.id != secondCard.id) {
          _matchedIndexes.addAll([firstIndex, secondIndex]);
          notifyListeners();

          Future.delayed(const Duration(milliseconds: 800), () {
            _selectedIndexes.clear();
            notifyListeners();
          });
        } else {
          _incorrectIndexes.addAll([firstIndex, secondIndex]);
          notifyListeners();

          Future.delayed(Duration(milliseconds: 800), () {
            _selectedIndexes.clear();
            _incorrectIndexes.clear();
            notifyListeners();
          });
        }
      });
    }
  }
}
