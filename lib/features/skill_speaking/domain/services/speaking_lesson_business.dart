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
          'Tạo một bài luyện đọc ngắn theo đúng ngôn ngữ mà người dùng yêu cầu trong topic. '
          'Nếu topic yêu cầu tiếng Việt, tiếng Nhật, tiếng Hàn hay bất kỳ ngôn ngữ nào khác thì content phải dùng đúng ngôn ngữ đó, tuyệt đối không tự động đổi sang tiếng Anh. '
          'Chỉ khi topic không nêu rõ ngôn ngữ thì mới mặc định dùng tiếng Anh. '
          'Nội dung phải dễ đọc thành tiếng, tự nhiên, rõ ý và phù hợp luyện phát âm. '
          'Trả về JSON thuần, không markdown, không giải thích thêm.',
      'requirements': {
        'title':
            'Tiêu đề ngắn gọn, ưu tiên cùng ngôn ngữ với content trừ khi người dùng yêu cầu khác',
        'content':
            'Một đoạn văn dài khoảng 80 đến 140 từ hoặc độ dài tương đương, chia câu rõ ràng, dùng đúng ngôn ngữ người dùng yêu cầu trong topic',
        'level': normalizedLevel,
        'topic':
            normalizedTopic.isEmpty
                ? 'chủ đề giao tiếp hằng ngày, mặc định tạo bằng tiếng Anh nếu không có yêu cầu ngôn ngữ riêng'
                : normalizedTopic,
      },
      'format': {'title': 'string', 'content': 'string', 'level': 'string'},
    };

    return jsonEncode(payload);
  }
}
