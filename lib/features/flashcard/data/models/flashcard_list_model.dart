import 'package:apphoctienganh/features/flashcard/data/models/flashcard_model.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/list_flashcard.dart';

class FlashcardListModel extends FlashcardList {
  FlashcardListModel({
    required super.id,
    required super.title,
    required super.description,
    required super.flashcards,
    required super.userId,
  });

  factory FlashcardListModel.fromEntity(FlashcardList flashcardList) {
    return FlashcardListModel(
      id: flashcardList.id,
      title: flashcardList.title,
      description: flashcardList.description,
      flashcards: flashcardList.flashcards,
      userId: flashcardList.userId,
    );
  }

  factory FlashcardListModel.fromMap(Map<String, dynamic> map) {
    return FlashcardListModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      flashcards:
          ((map['flashcards'] as List?) ?? const [])
              .whereType<Map<String, dynamic>>()
              .map((item) => FlashcardModel.fromMap(item).toEntity())
              .toList(),
      userId: map['userId'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'flashcards':
          flashcards
              .map((flashcard) => FlashcardModel.fromEntity(flashcard).toMap())
              .toList(),
      'userId': userId,
    };
  }

  FlashcardList toEntity() {
    return FlashcardList(
      id: id,
      title: title,
      description: description,
      flashcards: List<Flashcard>.from(flashcards),
      userId: userId,
    );
  }
}
