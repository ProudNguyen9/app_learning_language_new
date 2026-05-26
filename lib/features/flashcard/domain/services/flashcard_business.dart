import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:uuid/uuid.dart';

class FlashcardBusiness {
  const FlashcardBusiness();

  List<Flashcard> buildInitialFlashcards() {
    return [createEmptyFlashcard(), createEmptyFlashcard()];
  }

  Flashcard createEmptyFlashcard() {
    return Flashcard(
      id: const Uuid().v4(),
      question: '',
      answer: '',
      questionImage: null,
      answerImage: null,
    );
  }

  List<Flashcard> importFlashcards(
    List<Flashcard> currentFlashcards,
    List<Flashcard> flashcards, {
    required bool replace,
  }) {
    final uuid = const Uuid();
    final importedFlashcards = <Flashcard>[];

    for (final flashcard in flashcards) {
      final question = flashcard.question.trim();
      final answer = flashcard.answer.trim();

      if (question.isEmpty && answer.isEmpty) continue;

      importedFlashcards.add(
        Flashcard(
          id: uuid.v4(),
          question: question,
          answer: answer,
          questionImage: null,
          answerImage: null,
          questionLanguage: flashcard.questionLanguage,
          answerLanguage: flashcard.answerLanguage,
        ),
      );
    }

    if (importedFlashcards.isEmpty) {
      return currentFlashcards;
    }

    if (replace) {
      return importedFlashcards;
    }

    return [...currentFlashcards, ...importedFlashcards];
  }

  List<Flashcard> deleteFlashcardById(List<Flashcard> flashcards, String id) {
    if (flashcards.length <= 2) return flashcards;
    return flashcards.where((flashcard) => flashcard.id != id).toList();
  }

  List<Flashcard> duplicateFlashcardById(
    List<Flashcard> flashcards,
    String id,
  ) {
    final index = flashcards.indexWhere((fc) => fc.id == id);
    if (index == -1) return flashcards;

    final current = flashcards[index];
    final duplicated = Flashcard(
      id: const Uuid().v4(),
      question: current.question,
      answer: current.answer,
      questionImage: current.questionImage,
      answerImage: current.answerImage,
      questionLanguage: current.questionLanguage,
      answerLanguage: current.answerLanguage,
    );

    final updated = List<Flashcard>.from(flashcards);
    updated.insert(index + 1, duplicated);
    return updated;
  }

  String? validateFlashcardList({
    required List<Flashcard> flashcards,
    required String title,
  }) {
    if (flashcards.isEmpty) {
      return 'Danh sách flashcard không được trống!';
    }

    if (flashcards.length < 2) {
      return 'Cần ít nhất 2 flashcard!';
    }

    if (title.trim().isEmpty) {
      return 'Tiêu đề không thể trống!';
    }

    for (final flashcard in flashcards) {
      if (flashcard.question.isEmpty || flashcard.answer.isEmpty) {
        return 'Mỗi flashcard phải có cả câu hỏi và câu trả lời!';
      }
    }

    return null;
  }
}
