import 'package:apphoctienganh/features/skill_reading/domain/entities/reading_lesson.dart';

class ReadingLessonModel extends ReadingLesson {
  ReadingLessonModel({
    required super.id,
    required super.title,
    required super.content,
    required super.level,
    required super.createdAt,
    super.source,
    super.translationMode,
  });

  factory ReadingLessonModel.fromEntity(ReadingLesson lesson) {
    return ReadingLessonModel(
      id: lesson.id,
      title: lesson.title,
      content: lesson.content,
      level: lesson.level,
      createdAt: lesson.createdAt,
      source: lesson.source,
      translationMode: lesson.translationMode,
    );
  }

  factory ReadingLessonModel.fromMap(Map<dynamic, dynamic> map) {
    return ReadingLessonModel(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      level: (map['level'] ?? 'Cơ bản').toString(),
      createdAt:
          DateTime.tryParse((map['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      source: (map['source'] ?? 'manual').toString(),
      translationMode: (map['translationMode'] ?? 'full_passage').toString(),
    );
  }

  ReadingLesson toEntity() {
    return ReadingLesson(
      id: id,
      title: title,
      content: content,
      level: level,
      createdAt: createdAt,
      source: source,
      translationMode: translationMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'level': level,
      'createdAt': createdAt.toIso8601String(),
      'source': source,
      'translationMode': translationMode,
    };
  }
}
