import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';

class FlashcardList {
  String id;

  String title;

  String description;

  List<Flashcard> flashcards;

  String userId;

  int studiedCards;

  double progressPercent;

  bool isCompleted;

  DateTime? lastStudiedAt;

  // Chuyển từ Firebase -> FlashcardList
  factory FlashcardList.fromMap(Map<String, dynamic> map) {
    return FlashcardList(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      flashcards:
          ((map['flashcards'] as List?) ?? const [])
              .whereType<Map<String, dynamic>>()
              .map((item) => Flashcard.fromMap(item))
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

  // Chuyển từ FlashcardList -> Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'flashcards': flashcards.map((f) => f.toMap()).toList(),
      'userId': userId,
      'studiedCards': studiedCards,
      'progressPercent': progressPercent,
      'isCompleted': isCompleted,
      'lastStudiedAt': lastStudiedAt?.toIso8601String(),
    };
  }

  FlashcardList({
    required this.id,
    required this.title,
    required this.description,
    required this.flashcards,
    required this.userId,
    this.studiedCards = 0,
    this.progressPercent = 0,
    this.isCompleted = false,
    this.lastStudiedAt,
  });
}
