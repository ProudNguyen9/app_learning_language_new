import 'dart:io';

import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:apphoctienganh/features/flashcard/domain/services/flashcard_business.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlashcardProvider with ChangeNotifier {
  FlashcardProvider({FlashcardBusiness? business})
    : _business = business ?? const FlashcardBusiness(),
      _flashcards =
          (business ?? const FlashcardBusiness()).buildInitialFlashcards();

  final FlashcardBusiness _business;
  List<Flashcard> _flashcards;

  List<Flashcard> get flashcardList => _flashcards;
  set flashcardListset(List<Flashcard> newList) {
    _flashcards = newList;
  }

  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucketName = 'img_flashcard';

  List<Flashcard> _buildInitialFlashcards() {
    return _business.buildInitialFlashcards();
  }

  void addFlashcard() {
    _flashcards = [..._flashcards, _business.createEmptyFlashcard()];
    notifyListeners();
  }

  void importFlashcards(List<Flashcard> flashcards, {required bool replace}) {
    _flashcards = _business.importFlashcards(
      _flashcards,
      flashcards,
      replace: replace,
    );
    notifyListeners();
  }

  void deleteFlashcardById(String id) {
    _flashcards = _business.deleteFlashcardById(_flashcards, id);
    notifyListeners();
  }

  void duplicateFlashcardById(String id) {
    _flashcards = _business.duplicateFlashcardById(_flashcards, id);
    notifyListeners();
  }

  Future<String> _uploadImageToSupabase({
    required String flashcardId,
    required XFile pickedFile,
  }) async {
    final file = File(pickedFile.path);
    final storagePath = pickedFile.name;

    await _supabase.storage
        .from(_bucketName)
        .upload(
          storagePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from(_bucketName).getPublicUrl(storagePath);
  }

  Future<void> _deleteImageFromSupabase(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;

    final marker = '/$_bucketName/';
    final markerIndex = imageUrl.indexOf(marker);
    if (markerIndex == -1) return;

    final storagePath = imageUrl.substring(markerIndex + marker.length);
    if (storagePath.isEmpty) return;

    try {
      await _supabase.storage.from(_bucketName).remove([storagePath]);
    } catch (_) {}
  }

  Future<void> pickImage(String id, {required bool isQuestion}) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        final index = _flashcards.indexWhere((fc) => fc.id == id);
        if (index != -1) {
          final oldImageUrl =
              isQuestion
                  ? _flashcards[index].questionImage
                  : _flashcards[index].answerImage;
          final url = await _uploadImageToSupabase(
            flashcardId: id,
            pickedFile: pickedFile,
          );

          if (isQuestion) {
            _flashcards[index].questionImage = url;
          } else {
            _flashcards[index].answerImage = url;
          }

          await _deleteImageFromSupabase(oldImageUrl);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Lỗi tải ảnh lên Supabase: $e');
      }
    }
  }

  Future<void> removeQuestionImage(String id) async {
    final index = _flashcards.indexWhere((fc) => fc.id == id);
    if (index != -1) {
      await _deleteImageFromSupabase(_flashcards[index].questionImage);
      _flashcards[index].questionImage = null;
      notifyListeners();
    }
  }

  Future<void> removeAnswerImage(String id) async {
    final index = _flashcards.indexWhere((fc) => fc.id == id);
    if (index != -1) {
      await _deleteImageFromSupabase(_flashcards[index].answerImage);
      _flashcards[index].answerImage = null;
      notifyListeners();
    }
  }

  void updateFlashcardContent({
    required String id,
    String? question,
    String? answer,
    String? questionLanguage,
    String? answerLanguage,
  }) {
    final index = _flashcards.indexWhere((fc) => fc.id == id);
    if (index != -1) {
      if (question != null) {
        _flashcards[index].question = question;
      } else if (answer != null) {
        _flashcards[index].answer = answer;
      }
      if (questionLanguage != null) {
        _flashcards[index].questionLanguage = questionLanguage;
      }
      if (answerLanguage != null) {
        _flashcards[index].answerLanguage = answerLanguage;
      }
      notifyListeners();
    }
  }

  Future<String> save_list_flashcard_async({
    required String title,
    String? description,
  }) async {
    try {
      final validation = _business.validateFlashcardList(
        flashcards: _flashcards,
        title: title,
      );
      if (validation != null) {
        return validation;
      }

      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 'Người dùng chưa đăng nhập';
      }
      final vocabularyRows =
          _flashcards.map((flashcard) {
            return {
              'user_id': user.id,
              'word': flashcard.question.trim(),
              'meaning': flashcard.answer.trim(),
              'example': '',
              'level': 1,
              'question_language': flashcard.questionLanguage,
              'answer_language': flashcard.answerLanguage,
              'media': {
                'questionImage': flashcard.questionImage,
                'answerImage': flashcard.answerImage,
              },
            };
          }).toList();

      final insertedVocabulary =
          await _supabase.from('vocabulary').insert(vocabularyRows).select();

      final vocabIds =
          insertedVocabulary
              .map<int>((item) => item['vocab_id'] as int)
              .toList();

      await _supabase.from('lessons').insert({
        'skill_id': 1,
        'user_id': user.id,
        'title': title.trim(),
        'type': 'flashcard',
        'content': {
          'description': description?.trim() ?? '',
          'vocab_ids': vocabIds,
        },
        'duration_minutes': 0,
        'level_required': 1,
      });

      _flashcards = _buildInitialFlashcards();
      notifyListeners();
      return 'Lưu flashcard thành công!';
    } catch (e) {
      return 'Đã xảy ra lỗi: $e';
    }
  }

  void loadData(List<Flashcard> flashcards) {
    flashcardListset = flashcards;
  }

  Future<String> saveForEditFlashcardListAsync({
    required String id,
    required String title,
    String? description,
  }) async {
    try {
      final validation = _business.validateFlashcardList(
        flashcards: _flashcards,
        title: title,
      );
      if (validation != null) {
        return validation;
      }

      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 'Người dùng chưa đăng nhập';
      }

      final vocabIds = <int>[];

      for (final flashcard in _flashcards) {
        final existingVocabId = int.tryParse(flashcard.id);
        final vocabularyData = {
          'user_id': user.id,
          'word': flashcard.question.trim(),
          'meaning': flashcard.answer.trim(),
          'example': '',
          'level': 1,
          'question_language': flashcard.questionLanguage,
          'answer_language': flashcard.answerLanguage,
          'media': {
            'questionImage': flashcard.questionImage,
            'answerImage': flashcard.answerImage,
          },
        };

        if (existingVocabId != null) {
          await _supabase
              .from('vocabulary')
              .update(vocabularyData)
              .eq('vocab_id', existingVocabId)
              .eq('user_id', user.id);
          vocabIds.add(existingVocabId);
        } else {
          final insertedVocabulary =
              await _supabase
                  .from('vocabulary')
                  .insert(vocabularyData)
                  .select('vocab_id')
                  .single();

          vocabIds.add(insertedVocabulary['vocab_id'] as int);
        }
      }

      final lessonId = int.tryParse(id);
      if (lessonId == null) {
        return 'Không tìm thấy mã bộ flashcard hợp lệ!';
      }

      await _supabase
          .from('lessons')
          .update({
            'title': title.trim(),
            'content': {
              'description': description?.trim() ?? '',
              'vocab_ids': vocabIds,
            },
          })
          .eq('lesson_id', lessonId)
          .eq('user_id', user.id);

      _flashcards = _buildInitialFlashcards();
      notifyListeners();

      return 'Cập nhật flashcard thành công!';
    } catch (e) {
      print('Error: $e');
      return 'Đã xảy ra lỗi: $e';
    }
  }
}
