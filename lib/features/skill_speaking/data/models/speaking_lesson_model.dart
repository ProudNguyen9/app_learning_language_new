import 'package:apphoctienganh/features/skill_speaking/domain/entities/speaking_lesson.dart';

class SpeakingLessonModel extends SpeakingLesson {
  SpeakingLessonModel({
    required super.id,
    required super.title,
    required super.content,
    required super.level,
    required super.createdAt,
    super.source,
  });

  factory SpeakingLessonModel.fromEntity(SpeakingLesson lesson) {
    return SpeakingLessonModel(
      id: lesson.id,
      title: lesson.title,
      content: lesson.content,
      level: lesson.level,
      createdAt: lesson.createdAt,
      source: lesson.source,
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
    };
  }

  factory SpeakingLessonModel.fromMap(Map<dynamic, dynamic> map) {
    return SpeakingLessonModel(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      level: (map['level'] ?? 'Cơ bản').toString(),
      createdAt:
          DateTime.tryParse((map['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      source: (map['source'] ?? 'manual').toString(),
    );
  }

  SpeakingLesson toEntity() {
    return SpeakingLesson(
      id: id,
      title: title,
      content: content,
      level: level,
      createdAt: createdAt,
      source: source,
    );
  }
}
