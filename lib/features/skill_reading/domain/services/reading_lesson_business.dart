import 'dart:convert';

import 'package:apphoctienganh/features/skill_reading/domain/entities/reading_lesson.dart';

class ReadingLessonBusiness {
  const ReadingLessonBusiness();

  List<ReadingLesson> filterLessons({
    required List<ReadingLesson> lessons,
    required String query,
    required String filter,
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    Iterable<ReadingLesson> result = lessons;

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
      'task': 'reading_comprehension_lesson',
      'instruction':
          'Tạo một bài đọc hiểu ngắn theo đúng ngôn ngữ mà người dùng yêu cầu trong topic. '
          'Nếu topic yêu cầu tiếng Việt, tiếng Nhật, tiếng Hàn hay bất kỳ ngôn ngữ nào khác thì content phải dùng đúng ngôn ngữ đó, tuyệt đối không tự động đổi sang tiếng Anh. '
          'Chỉ khi topic không nêu rõ ngôn ngữ thì mới mặc định dùng tiếng Anh. '
          'Nội dung phải tự nhiên, dễ hiểu và phù hợp để người học đọc hiểu. '
          'Trả về JSON thuần, không markdown, không giải thích thêm.',
      'requirements': {
        'title':
            'Tiêu đề ngắn gọn, ưu tiên cùng ngôn ngữ với content trừ khi người dùng yêu cầu khác',
        'content':
            'Một đoạn văn dài khoảng 70 đến 130 từ hoặc độ dài tương đương, 1 đến 2 đoạn ngắn, dùng đúng ngôn ngữ người dùng yêu cầu trong topic',
        'level': normalizedLevel,
        'topic':
            normalizedTopic.isEmpty
                ? 'đời sống hằng ngày, mặc định tạo bằng tiếng Anh nếu không có yêu cầu ngôn ngữ riêng'
                : normalizedTopic,
      },
      'format': {'title': 'string', 'content': 'string', 'level': 'string'},
    };

    return jsonEncode(payload);
  }

  String buildGradingPrompt({
    required String lessonTitle,
    required String originalText,
    required String userMeaning,
    required String translationMode,
  }) {
    final modeInstruction = switch (translationMode) {
      'sentence' =>
        'Người học dịch theo từng câu. Hãy ưu tiên độ đúng nghĩa của từng câu và tính liên kết giữa các câu.',
      'word' =>
        'Người học dịch theo từng chữ hoặc cụm ngắn. Hãy ưu tiên độ đúng nghĩa từ vựng, cụm từ và mức độ bao phủ ý chính.',
      'paragraph' =>
        'Người học dịch theo từng đoạn. Hãy ưu tiên độ đúng nghĩa của từng đoạn và cách diễn đạt tự nhiên.',
      _ =>
        'Người học dịch toàn bộ đoạn văn. Hãy ưu tiên độ đúng nghĩa tổng thể, sự trôi chảy và đầy đủ ý.',
    };

    final payload = {
      'task': 'grade_reading_comprehension',
      'instruction':
          'Bạn là giám khảo chấm bài đọc hiểu tiếng Anh sang tiếng Việt. '
          'Hãy chấm dựa trên mức độ đúng nghĩa tổng thể, dùng từ tự nhiên và đủ ý. '
          '$modeInstruction '
          'Luôn trả về JSON thuần, không markdown, không giải thích ngoài JSON.',
      'input': {
        'lesson_title': lessonTitle,
        'original_text': originalText,
        'user_meaning': userMeaning,
        'translation_mode': translationMode,
      },
      'requirements': {
        'score': 'Số nguyên từ 0 đến 100',
        'short_comment': 'Nhận xét ngắn gọn bằng tiếng Việt, tối đa 2 câu',
        'overall_meaning':
            'Ghép lại nghĩa cuối cùng của toàn đoạn bằng tiếng Việt, tự nhiên, rõ ý',
        'word_meanings':
            'Danh sách 8 đến 16 từ/cụm từ quan trọng trong đoạn, mỗi phần tử có word và meaning bằng tiếng Việt',
      },
      'format': {
        'score': 'number',
        'short_comment': 'string',
        'overall_meaning': 'string',
        'word_meanings': [
          {'word': 'string', 'meaning': 'string'},
        ],
      },
    };

    return jsonEncode(payload);
  }
}
