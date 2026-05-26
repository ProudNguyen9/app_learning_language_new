import 'dart:convert';

import 'package:apphoctienganh/features/skill_speaking/domain/entities/speaking_lesson.dart';

class SpeakingLessonBusiness {
  const SpeakingLessonBusiness();

  List<SpeakingLesson> filterLessons({
    required List<SpeakingLesson> lessons,
    required String query,
    required String filter,
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    Iterable<SpeakingLesson> result = lessons;

    if (normalizedQuery.isNotEmpty) {
      result = result.where((lesson) {
        return lesson.title.toLowerCase().contains(normalizedQuery) ||
            lesson.content.toLowerCase().contains(normalizedQuery) ||
            lesson.level.toLowerCase().contains(normalizedQuery);
      });
    }

    switch (filter) {
      case 'Mới đây':
        result =
            result.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Mức độ bình thường':
        result = result.where((lesson) => lesson.level == 'Trung bình');
        break;
      case 'Mức độ khó':
        result = result.where((lesson) => lesson.level == 'Nâng cao');
        break;
      default:
        result =
            result.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return result.toList();
  }

  String buildAiPrompt({required String topic, required String level}) {
    final normalizedTopic = topic.trim();
    final normalizedLevel = level.trim().isEmpty ? 'Cơ bản' : level.trim();

    final payload = {
      'task': 'speaking_reading_lesson',
      'instruction':
          'Tạo một bài luyện đọc ngắn bằng tiếng Anh cho người học ngoại ngữ. '
          'Nội dung phải dễ đọc thành tiếng, tự nhiên, rõ ý và phù hợp luyện phát âm. '
          'Trả về JSON thuần, không markdown, không giải thích thêm.',
      'requirements': {
        'title': 'Tiêu đề bài đọc ngắn gọn bằng tiếng Việt',
        'content':
            'Một đoạn văn tiếng Anh dài khoảng 80 đến 140 từ, chia câu rõ ràng để luyện đọc',
        'level': normalizedLevel,
        'topic':
            normalizedTopic.isEmpty
                ? 'chủ đề giao tiếp hằng ngày'
                : normalizedTopic,
      },
      'format': {'title': 'string', 'content': 'string', 'level': 'string'},
    };

    return jsonEncode(payload);
  }
}
