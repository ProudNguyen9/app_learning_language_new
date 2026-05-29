import 'package:apphoctienganh/features/skill_reading/data/models/reading_lesson_model.dart';
import 'package:apphoctienganh/features/skill_reading/domain/entities/reading_lesson.dart';
import 'package:apphoctienganh/features/skill_reading/domain/services/reading_lesson_business.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class ReadingLessonProvider extends ChangeNotifier {
  ReadingLessonProvider({ReadingLessonBusiness? business})
    : _business = business ?? const ReadingLessonBusiness();

  static const String _boxName = 'reading_lessons';

  final ReadingLessonBusiness _business;
  final List<ReadingLesson> _lessons = [];
  bool _isLoaded = false;
  bool _isSaving = false;

  List<ReadingLesson> get lessons => List.unmodifiable(_lessons);
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
            .map((item) => ReadingLessonModel.fromMap(item).toEntity())
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
    required String translationMode,
  }) async {
    final normalizedTitle = title.trim();
    final normalizedContent = content.trim();
    final normalizedLevel = level.trim().isEmpty ? 'Cơ bản' : level.trim();

    if (normalizedTitle.isEmpty) {
      return 'Vui lòng nhập tiêu đề bài đọc hiểu';
    }

    if (normalizedContent.isEmpty) {
      return 'Vui lòng nhập hoặc tạo nội dung bài đọc hiểu';
    }

    _isSaving = true;
    notifyListeners();

    try {
      final lesson = ReadingLesson(
        id: const Uuid().v4(),
        title: normalizedTitle,
        content: normalizedContent,
        level: normalizedLevel,
        createdAt: DateTime.now(),
        source: source,
        translationMode: translationMode,
      );

      final box = await _openBox();
      await box.put(lesson.id, ReadingLessonModel.fromEntity(lesson).toMap());

      _lessons.insert(0, lesson);
      _isLoaded = true;
      return 'Lưu bài đọc hiểu thành công';
    } catch (_) {
      return 'Không thể lưu bài đọc hiểu';
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
    required String translationMode,
  }) async {
    final normalizedTitle = title.trim();
    final normalizedContent = content.trim();
    final normalizedLevel = level.trim().isEmpty ? 'Cơ bản' : level.trim();

    if (normalizedTitle.isEmpty) {
      return 'Vui lòng nhập tiêu đề bài đọc hiểu';
    }

    if (normalizedContent.isEmpty) {
      return 'Vui lòng nhập hoặc tạo nội dung bài đọc hiểu';
    }

    final lessonIndex = _lessons.indexWhere((lesson) => lesson.id == id);
    if (lessonIndex == -1) {
      return 'Không tìm thấy bài đọc hiểu để cập nhật';
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
        translationMode: translationMode,
      );

      final box = await _openBox();
      await box.put(
        updatedLesson.id,
        ReadingLessonModel.fromEntity(updatedLesson).toMap(),
      );

      _lessons[lessonIndex] = updatedLesson;
      _lessons.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _isLoaded = true;
      return 'Cập nhật bài đọc hiểu thành công';
    } catch (_) {
      return 'Không thể cập nhật bài đọc hiểu';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String> deleteLesson(String id) async {
    final lessonIndex = _lessons.indexWhere((lesson) => lesson.id == id);
    if (lessonIndex == -1) {
      return 'Không tìm thấy bài đọc hiểu để xóa';
    }

    try {
      final box = await _openBox();
      await box.delete(id);
      _lessons.removeAt(lessonIndex);
      notifyListeners();
      return 'Xóa bài đọc hiểu thành công';
    } catch (_) {
      return 'Không thể xóa bài đọc hiểu';
    }
  }

  List<ReadingLesson> filterLessons({
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

  String buildGradingPrompt({
    required String lessonTitle,
    required String originalText,
    required String userMeaning,
    required String translationMode,
  }) {
    return _business.buildGradingPrompt(
      lessonTitle: lessonTitle,
      originalText: originalText,
      userMeaning: userMeaning,
      translationMode: translationMode,
    );
  }
}
