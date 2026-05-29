import 'package:apphoctienganh/features/skill_listening/domain/entities/listening_lesson.dart';

class ListeningLessonModel extends ListeningLesson {
  ListeningLessonModel({
    required super.id,
    required super.title,
    required super.content,
    required super.level,
    required super.createdAt,
    super.source,
  });

  factory ListeningLessonModel.fromEntity(ListeningLesson lesson) {
    return ListeningLessonModel(
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

  factory ListeningLessonModel.fromMap(Map<dynamic, dynamic> map) {
    return ListeningLessonModel(
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

  ListeningLesson toEntity() {
    return ListeningLesson(
      id: id,
      title: title,
      content: content,
      level: level,
      createdAt: createdAt,
      source: source,
    );
  }
}
