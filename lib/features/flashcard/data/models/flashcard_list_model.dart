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
    super.studiedCards,
    super.progressPercent,
    super.isCompleted,
    super.lastStudiedAt,
  });

  factory FlashcardListModel.fromEntity(FlashcardList flashcardList) {
    return FlashcardListModel(
      id: flashcardList.id,
      title: flashcardList.title,
      description: flashcardList.description,
      flashcards: flashcardList.flashcards,
      userId: flashcardList.userId,
      studiedCards: flashcardList.studiedCards,
      progressPercent: flashcardList.progressPercent,
      isCompleted: flashcardList.isCompleted,
      lastStudiedAt: flashcardList.lastStudiedAt,
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
      studiedCards: (map['studiedCards'] as num?)?.toInt() ?? 0,
      progressPercent: (map['progressPercent'] as num?)?.toDouble() ?? 0,
      isCompleted: map['isCompleted'] == true,
      lastStudiedAt:
          map['lastStudiedAt'] is String
              ? DateTime.tryParse(map['lastStudiedAt'] as String)
              : null,
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
      'studiedCards': studiedCards,
      'progressPercent': progressPercent,
      'isCompleted': isCompleted,
      'lastStudiedAt': lastStudiedAt?.toIso8601String(),
    };
  }

  FlashcardList toEntity() {
    return FlashcardList(
      id: id,
      title: title,
      description: description,
      flashcards: List<Flashcard>.from(flashcards),
      userId: userId,
      studiedCards: studiedCards,
      progressPercent: progressPercent,
      isCompleted: isCompleted,
      lastStudiedAt: lastStudiedAt,
    );
  }
}
