import 'dart:convert';

import 'package:apphoctienganh/features/skill_listening/domain/entities/listening_lesson.dart';

class ListeningLessonBusiness {
  const ListeningLessonBusiness();

  List<ListeningLesson> filterLessons({
    required List<ListeningLesson> lessons,
    required String query,
    required String filter,
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    Iterable<ListeningLesson> result = lessons;

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
      'task': 'listening_lesson',
      'instruction':
          'Tạo một bài luyện nghe ngắn theo đúng ngôn ngữ mà người dùng yêu cầu trong topic. '
          'Nếu topic yêu cầu tiếng Việt, tiếng Nhật, tiếng Hàn hay bất kỳ ngôn ngữ nào khác thì content phải dùng đúng ngôn ngữ đó, tuyệt đối không tự động đổi sang tiếng Anh. '
          'Chỉ khi topic không nêu rõ ngôn ngữ thì mới mặc định dùng tiếng Anh. '
          'Nội dung phải tự nhiên, dễ nghe, chia câu rõ để người học nghe từng câu và gõ lại. '
          'Trả về JSON thuần, không markdown, không giải thích thêm.',
      'requirements': {
        'title':
            'Tiêu đề ngắn gọn, ưu tiên cùng ngôn ngữ với content trừ khi người dùng yêu cầu khác',
        'content':
            'Một đoạn văn khoảng 4 đến 7 câu hoặc độ dài tương đương, câu rõ ràng, dùng đúng ngôn ngữ người dùng yêu cầu trong topic',
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

  String buildHint(String sentence) {
    final words =
        sentence.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (words.isEmpty) return '';

    return words.map(_maskWord).join(' ');
  }

  String normalizeText(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').trim();
  }

  bool isSentenceCorrect({required String expected, required String actual}) {
    return normalizeText(expected) == normalizeText(actual);
  }

  double calculateProgress({required int currentIndex, required int total}) {
    if (total <= 0) return 0;
    return (currentIndex / total).clamp(0, 1);
  }

  String _maskWord(String word) {
    final normalized = word.trim();
    if (normalized.length <= 2) return normalized;
    if (normalized.length <= 4) {
      return '${normalized.substring(0, 1)}${'_' * (normalized.length - 1)}';
    }
    return '${normalized.substring(0, 1)}${'_' * (normalized.length - 2)}${normalized.substring(normalized.length - 1)}';
  }
}
