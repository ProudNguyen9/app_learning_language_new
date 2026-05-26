import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';

class FlashcardModel extends Flashcard {
  FlashcardModel({
    required super.id,
    required super.question,
    required super.answer,
    super.questionImage,
    super.answerImage,
    super.questionLanguage,
    super.answerLanguage,
  });

  factory FlashcardModel.fromEntity(Flashcard flashcard) {
    return FlashcardModel(
      id: flashcard.id,
      question: flashcard.question,
      answer: flashcard.answer,
      questionImage: flashcard.questionImage,
      answerImage: flashcard.answerImage,
      questionLanguage: flashcard.questionLanguage,
      answerLanguage: flashcard.answerLanguage,
    );
  }

  factory FlashcardModel.fromMap(Map<String, dynamic> map) {
    return FlashcardModel(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      questionImage: map['questionImage'],
      answerImage: map['answerImage'],
      questionLanguage: map['questionLanguage'] ?? 'en-US',
      answerLanguage: map['answerLanguage'] ?? 'vi-VN',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'questionImage': questionImage,
      'answerImage': answerImage,
      'questionLanguage': questionLanguage,
      'answerLanguage': answerLanguage,
    };
  }

  Flashcard toEntity() {
    return Flashcard(
      id: id,
      question: question,
      answer: answer,
      questionImage: questionImage,
      answerImage: answerImage,
      questionLanguage: questionLanguage,
      answerLanguage: answerLanguage,
    );
  }
}
