import 'dart:math';

import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/list_flashcard.dart';
import 'package:apphoctienganh/core/data/local_flashcard_store.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeProvider extends ChangeNotifier {
  List<FlashcardList> _flashcardLists = [];
  List<FlashcardList> get flashcardLists => _flashcardLists;
  List<FlashcardList> get recentFlashcardLists {
    final items =
        _flashcardLists.where((item) => item.lastStudiedAt != null).toList()
          ..sort((a, b) => b.lastStudiedAt!.compareTo(a.lastStudiedAt!));
    return items;
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  List<Flashcard> _originalFlashcards =
      []; // bản gốc trả về khi sắp xếp ở next stepcarrd

  Future<void> loadDataforsetstateinhomepage() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _flashcardLists = [];
        notifyListeners();
        return;
      }

      final lessons = await _supabase
          .from('lessons')
          .select()
          .eq('user_id', user.id)
          .eq('type', 'flashcard')
          .order('created_at', ascending: false);

      final vocabularies = await _supabase
          .from('vocabulary')
          .select()
          .eq('user_id', user.id);

      final progressRows = await _supabase
          .from('user_progress')
          .select('lesson_id, score, completed, completed_at')
          .eq('user_id', user.id)
          .order('completed_at', ascending: false);

      final vocabularyMap = {
        for (final item in vocabularies) item['vocab_id'] as int: item,
      };
      final progressByLesson = <int, Map<String, dynamic>>{};
      for (final row in progressRows) {
        final lessonId = (row['lesson_id'] as num?)?.toInt();
        if (lessonId == null || progressByLesson.containsKey(lessonId)) {
          continue;
        }
        progressByLesson[lessonId] = Map<String, dynamic>.from(row);
      }

      _flashcardLists =
          lessons.map<FlashcardList>((lesson) {
            final content =
                (lesson['content'] as Map<String, dynamic>?) ??
                <String, dynamic>{};
            final vocabIds =
                (content['vocab_ids'] as List?)?.whereType<int>().toList() ??
                <int>[];

            final flashcards =
                vocabIds
                    .map<Flashcard>((vocabId) {
                      final vocab = vocabularyMap[vocabId];
                      if (vocab == null) {
                        return Flashcard(
                          id: vocabId.toString(),
                          question: '',
                          answer: '',
                        );
                      }

                      final media =
                          (vocab['media'] as Map<String, dynamic>?) ??
                          <String, dynamic>{};

                      return Flashcard(
                        id: (vocab['vocab_id'] ?? '').toString(),
                        question: (vocab['word'] ?? '').toString(),
                        answer: (vocab['meaning'] ?? '').toString(),
                        questionImage: media['questionImage']?.toString(),
                        answerImage: media['answerImage']?.toString(),
                        questionLanguage:
                            (vocab['question_language'] ?? 'en-US').toString(),
                        answerLanguage:
                            (vocab['answer_language'] ?? 'vi-VN').toString(),
                      );
                    })
                    .where(
                      (card) =>
                          card.question.isNotEmpty || card.answer.isNotEmpty,
                    )
                    .toList();

            final lessonId = (lesson['lesson_id'] as num?)?.toInt();
            final progress =
                lessonId == null ? null : progressByLesson[lessonId];
            final progressPercent = _normalizeProgressPercent(progress);
            final isCompleted =
                progress?['completed'] == true || progressPercent >= 1;

            return FlashcardList(
              id: (lesson['lesson_id'] ?? '').toString(),
              title: (lesson['title'] ?? '').toString(),
              description: (content['description'] ?? '').toString(),
              flashcards: flashcards,
              userId: (lesson['user_id'] ?? '').toString(),
              studiedCards: _resolveStudiedCards(
                totalCards: flashcards.length,
                progressPercent: progressPercent,
                isCompleted: isCompleted,
              ),
              progressPercent: progressPercent,
              isCompleted: isCompleted,
              lastStudiedAt: _parseDateTime(progress?['completed_at']),
            );
          }).toList();
    } catch (e) {
      debugPrint('Lỗi tải lessons flashcard: $e');
      _flashcardLists = LocalFlashcardStore.getAll();
    }

    notifyListeners();
  }

  // xóa bộ flashcard
  Future<String> deleteFlashcardListById(String id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 'Người dùng chưa đăng nhập';
      }

      final lessonId = int.tryParse(id);
      if (lessonId == null) {
        LocalFlashcardStore.deleteById(id);
        _flashcardLists.removeWhere((list) => list.id == id);
        notifyListeners();
        return 'Đã xóa bộ flashcard trên máy!';
      }

      final lesson =
          await _supabase
              .from('lessons')
              .select('content')
              .eq('lesson_id', lessonId)
              .eq('user_id', user.id)
              .eq('type', 'flashcard')
              .maybeSingle();

      if (lesson == null) {
        return 'Không tìm thấy bộ flashcard cần xóa!';
      }

      final content =
          (lesson['content'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final vocabIds =
          (content['vocab_ids'] as List?)
              ?.map((id) => int.tryParse(id.toString()))
              .whereType<int>()
              .toList() ??
          <int>[];

      await _supabase
          .from('user_progress')
          .delete()
          .eq('lesson_id', lessonId)
          .eq('user_id', user.id);

      await _supabase
          .from('lessons')
          .delete()
          .eq('lesson_id', lessonId)
          .eq('user_id', user.id);

      if (vocabIds.isNotEmpty) {
        await _supabase
            .from('vocabulary')
            .delete()
            .eq('user_id', user.id)
            .inFilter('vocab_id', vocabIds);
      }

      LocalFlashcardStore.deleteById(id);
      _flashcardLists.removeWhere((list) => list.id == id);
      _flashcards = [];
      _originalFlashcards = [];
      _currentIndex = 0;
      notifyListeners();
      return 'Xóa bộ flashcard thành công!';
    } catch (e) {
      debugPrint('Lỗi khi xóa flashcard list: $e');
      return 'Đã xảy ra lỗi khi xóa: $e';
    }
  }

  // viết cho  screen netstepcard

  List<Flashcard> _flashcards = [];
  int _currentIndex = 0;

  // Lấy danh sách flashcards
  List<Flashcard> get flashcards => _flashcards;

  // Lấy chỉ số thẻ flashcard hiện tại
  int get currentIndex => _currentIndex;

  // Cập nhật danh sách flashcards
  void setFlashcards(List<Flashcard> flashcards) {
    _flashcards = [...flashcards];
    _originalFlashcards = [...flashcards];
    _currentIndex = 0;
  }

  // Di chuyển đến thẻ kế tiếp
  void nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      _currentIndex++;
      notifyListeners();
    } else {
      _currentIndex = 0;
      notifyListeners();
    }
  }

  // Di chuyển về thẻ trước
  void previousCard() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  // sắp xếp
  void sortlist(String type) {
    switch (type) {
      case 'A_Z':
        _flashcards.sort(
          (a, b) =>
              a.question.toLowerCase().compareTo(b.question.toLowerCase()),
        );
        break;
      case 'Z_A':
        _flashcards.sort(
          (a, b) =>
              b.question.toLowerCase().compareTo(a.question.toLowerCase()),
        );
        break;
      case 'default':
        _flashcards = [..._originalFlashcards];
        break;
    }
    notifyListeners();
  }

  Future<void> trackFlashcardStudySession({
    required FlashcardList flashcardList,
    required int studiedCards,
  }) async {
    final user = _supabase.auth.currentUser;
    final lessonId = int.tryParse(flashcardList.id);
    if (user == null || lessonId == null) {
      return;
    }

    final totalCards = flashcardList.flashcards.length;
    if (totalCards == 0) {
      return;
    }

    final safeStudiedCards = studiedCards.clamp(0, totalCards);
    final progressPercent = safeStudiedCards / totalCards;
    final completedAt = DateTime.now();

    try {
      await _supabase.from('user_progress').insert({
        'user_id': user.id,
        'lesson_id': lessonId,
        'score': (progressPercent * 100).round(),
        'completed': progressPercent >= 1,
        'completed_at': completedAt.toIso8601String(),
      });

      _flashcardLists =
          _flashcardLists.map((item) {
            if (item.id != flashcardList.id) {
              return item;
            }
            return FlashcardList(
              id: item.id,
              title: item.title,
              description: item.description,
              flashcards: item.flashcards,
              userId: item.userId,
              studiedCards: safeStudiedCards,
              progressPercent: progressPercent,
              isCompleted: progressPercent >= 1,
              lastStudiedAt: completedAt,
            );
          }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi lưu tiến độ flashcard: $e');
    }
  }

  double _normalizeProgressPercent(Map<String, dynamic>? progress) {
    if (progress == null) {
      return 0;
    }

    final rawScore = (progress['score'] as num?)?.toDouble();
    if (rawScore == null) {
      return progress['completed'] == true ? 1 : 0;
    }

    if (rawScore <= 1) {
      return rawScore.clamp(0, 1).toDouble();
    }

    return (rawScore / 100).clamp(0, 1).toDouble();
  }

  int _resolveStudiedCards({
    required int totalCards,
    required double progressPercent,
    required bool isCompleted,
  }) {
    if (totalCards <= 0) {
      return 0;
    }
    if (isCompleted) {
      return totalCards;
    }

    return min(totalCards, (progressPercent * totalCards).round());
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

// viết cho  screen netstepcard
