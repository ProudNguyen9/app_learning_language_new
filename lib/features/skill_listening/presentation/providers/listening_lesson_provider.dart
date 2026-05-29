import 'package:apphoctienganh/features/skill_listening/data/models/listening_lesson_model.dart';
import 'package:apphoctienganh/features/skill_listening/domain/entities/listening_lesson.dart';
import 'package:apphoctienganh/features/skill_listening/domain/services/listening_lesson_business.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class ListeningLessonProvider extends ChangeNotifier {
  ListeningLessonProvider({ListeningLessonBusiness? business})
    : _business = business ?? const ListeningLessonBusiness();

  static const String _boxName = 'listening_lessons';

  final ListeningLessonBusiness _business;
  final List<ListeningLesson> _lessons = [];
  bool _isLoaded = false;
  bool _isSaving = false;

  List<ListeningLesson> get lessons => List.unmodifiable(_lessons);
  bool get isLoaded => _isLoaded;
  bool get isSaving => _isSaving;

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return Hive.openBox(_boxName);
  }

  Future<void> loadLessons() async {
    final box = await _openBox();
    final loadedLessons =
        box.values
            .whereType<Map>()
            .map((item) => ListeningLessonModel.fromMap(item).toEntity())
            .where(
              (lesson) =>
                  lesson.title.trim().isNotEmpty &&
                  lesson.content.trim().isNotEmpty,
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _lessons
      ..clear()
      ..addAll(loadedLessons);
    _isLoaded = true;
    notifyListeners();
  }

  Future<String> saveLesson({
    required String title,
    required String content,
    required String level,
    required String source,
  }) async {
    final normalizedTitle = title.trim();
    final normalizedContent = content.trim();
    final normalizedLevel = level.trim().isEmpty ? 'Cơ bản' : level.trim();

    if (normalizedTitle.isEmpty) {
      return 'Vui lòng nhập tiêu đề bài luyện nghe';
    }

    if (normalizedContent.isEmpty) {
      return 'Vui lòng nhập hoặc tạo nội dung bài luyện nghe';
    }

    _isSaving = true;
    notifyListeners();

    try {
      final lesson = ListeningLesson(
        id: const Uuid().v4(),
        title: normalizedTitle,
        content: normalizedContent,
        level: normalizedLevel,
        createdAt: DateTime.now(),
        source: source,
      );

      final box = await _openBox();
      await box.put(lesson.id, ListeningLessonModel.fromEntity(lesson).toMap());

      _lessons.insert(0, lesson);
      _isLoaded = true;
      return 'Lưu bài luyện nghe thành công';
    } catch (_) {
      return 'Không thể lưu bài luyện nghe';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String> updateLesson({
    required String id,
    required String title,
    required String content,
    required String level,
    required String source,
  }) async {
    final normalizedTitle = title.trim();
    final normalizedContent = content.trim();
    final normalizedLevel = level.trim().isEmpty ? 'Cơ bản' : level.trim();

    if (normalizedTitle.isEmpty) {
      return 'Vui lòng nhập tiêu đề bài luyện nghe';
    }

    if (normalizedContent.isEmpty) {
      return 'Vui lòng nhập hoặc tạo nội dung bài luyện nghe';
    }

    final lessonIndex = _lessons.indexWhere((lesson) => lesson.id == id);
    if (lessonIndex == -1) {
      return 'Không tìm thấy bài luyện nghe để cập nhật';
    }

    _isSaving = true;
    notifyListeners();

    try {
      final currentLesson = _lessons[lessonIndex];
      final updatedLesson = currentLesson.copyWith(
        title: normalizedTitle,
        content: normalizedContent,
        level: normalizedLevel,
        source: source,
      );

      final box = await _openBox();
      await box.put(
        updatedLesson.id,
        ListeningLessonModel.fromEntity(updatedLesson).toMap(),
      );

      _lessons[lessonIndex] = updatedLesson;
      _lessons.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoaded = true;
      return 'Cập nhật bài luyện nghe thành công';
    } catch (_) {
      return 'Không thể cập nhật bài luyện nghe';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String> deleteLesson(String id) async {
    final lessonIndex = _lessons.indexWhere((lesson) => lesson.id == id);
    if (lessonIndex == -1) {
      return 'Không tìm thấy bài luyện nghe để xóa';
    }

    try {
      final box = await _openBox();
      await box.delete(id);
      _lessons.removeAt(lessonIndex);
      notifyListeners();
      return 'Xóa bài luyện nghe thành công';
    } catch (_) {
      return 'Không thể xóa bài luyện nghe';
    }
  }

  List<ListeningLesson> filterLessons({
    required String query,
    required String filter,
  }) {
    return _business.filterLessons(
      lessons: _lessons,
      query: query,
      filter: filter,
    );
  }

  String buildAiPrompt({required String topic, required String level}) {
    return _business.buildAiPrompt(topic: topic, level: level);
  }
}
