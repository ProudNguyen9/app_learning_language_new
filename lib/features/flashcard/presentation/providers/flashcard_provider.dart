import 'dart:io';
import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class FlashcardProvider with ChangeNotifier {
  List<Flashcard> _flashcards = [
    Flashcard(
      id: const Uuid().v4(),
      question: "",
      answer: "",
      questionImage: null,
      answerImage: null,
    ),
    Flashcard(
      id: const Uuid().v4(),
      question: "",
      answer: "",
      questionImage: null,
      answerImage: null,
    ),
  ];
  List<Flashcard> get flashcardList => _flashcards;
  set flashcardListset(List<Flashcard> newList) {
    _flashcards = newList;
  }

  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucketName = 'img_flashcard';

  List<Flashcard> _buildInitialFlashcards() {
    return [
      Flashcard(
        id: const Uuid().v4(),
        question: "",
        answer: "",
        questionImage: null,
        answerImage: null,
      ),
      Flashcard(
        id: const Uuid().v4(),
        question: "",
        answer: "",
        questionImage: null,
        answerImage: null,
      ),
    ];
  }

  // add new flashcard
  void addFlashcard() {
    _flashcards.add(
      Flashcard(
        id: const Uuid().v4(),
        question: "",
        answer: "",
        questionImage: null,
        answerImage: null,
      ),
    );
    notifyListeners();
  }

  void importFlashcards(List<Flashcard> flashcards, {required bool replace}) {
    final uuid = const Uuid();
    final importedFlashcards = <Flashcard>[];

    for (final flashcard in flashcards) {
      final question = flashcard.question.trim();
      final answer = flashcard.answer.trim();

      if (question.isEmpty && answer.isEmpty) continue;

      importedFlashcards.add(
        Flashcard(
          id: uuid.v4(),
          question: question,
          answer: answer,
          questionImage: null,
          answerImage: null,
          questionLanguage: flashcard.questionLanguage,
          answerLanguage: flashcard.answerLanguage,
        ),
      );
    }

    if (importedFlashcards.isEmpty) return;

    if (replace) {
      _flashcards = importedFlashcards;
    } else {
      _flashcards.addAll(importedFlashcards);
    }

    notifyListeners();
  }

  void deleteFlashcardById(String id) {
    if (_flashcards.length <= 2) return;
    _flashcards.removeWhere((flashcard) => flashcard.id == id);
    notifyListeners();
  }

  void duplicateFlashcardById(String id) {
    final index = _flashcards.indexWhere((fc) => fc.id == id);
    if (index == -1) return;

    final current = _flashcards[index];
    final duplicated = Flashcard(
      id: const Uuid().v4(),
      question: current.question,
      answer: current.answer,
      questionImage: current.questionImage,
      answerImage: current.answerImage,
      questionLanguage: current.questionLanguage,
      answerLanguage: current.answerLanguage,
    );

    _flashcards.insert(index + 1, duplicated);
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

  // Hàm chọn ảnh và tải lên Supabase Storage
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

  // Xóa ảnh câu hỏi
  Future<void> removeQuestionImage(String id) async {
    final index = _flashcards.indexWhere((fc) => fc.id == id);
    if (index != -1) {
      await _deleteImageFromSupabase(_flashcards[index].questionImage);
      _flashcards[index].questionImage = null;
      notifyListeners();
    }
  }

  // Xóa ảnh câu trả lời
  Future<void> removeAnswerImage(String id) async {
    final index = _flashcards.indexWhere((fc) => fc.id == id);
    if (index != -1) {
      await _deleteImageFromSupabase(_flashcards[index].answerImage);
      _flashcards[index].answerImage = null;
      notifyListeners();
    }
  }

  //  save  onchange thuật ngữ và bản dịch
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

  // save  supabase

  Future<String> save_list_flashcard_async({
    required String title,
    String? description,
  }) async {
    try {
      // Kiểm tra xem _flashcards có dữ liệu hay không
      if (_flashcards.isEmpty) {
        return 'Danh sách flashcard không được trống!';
      }

      // Kiểm tra số lượng flashcard
      if (_flashcards.length < 2) {
        return 'Cần ít nhất 2 flashcard!';
      }

      // Kiểm tra xem title có hợp lệ không
      if (title.isEmpty) {
        return 'Tiêu đề không thể trống!';
      }

      // Duyệt qua từng flashcard và kiểm tra question và answer
      for (var flashcard in _flashcards) {
        if (flashcard.question.isEmpty || flashcard.answer.isEmpty) {
          return 'Mỗi flashcard phải có cả câu hỏi và câu trả lời!';
        }
      }
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return "Người dùng chưa đăng nhập";
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

  // cho edit
  void loadData(List<Flashcard> flashcards) {
    flashcardListset = flashcards;
  }

  Future<String> saveForEditFlashcardListAsync({
    required String id,
    required String title,
    String? description,
  }) async {
    try {
      // Kiểm tra danh sách flashcard có rỗng không
      if (_flashcards.isEmpty) {
        return 'Danh sách flashcard không được trống!';
      }

      // Kiểm tra số lượng flashcard
      if (_flashcards.length < 2) {
        return 'Cần ít nhất 2 flashcard!';
      }

      // Kiểm tra tiêu đề
      if (title.isEmpty) {
        return 'Tiêu đề không thể trống!';
      }

      // Kiểm tra từng flashcard có đầy đủ câu hỏi và câu trả lời không
      for (var flashcard in _flashcards) {
        if (flashcard.question.isEmpty || flashcard.answer.isEmpty) {
          return 'Mỗi flashcard phải có cả câu hỏi và câu trả lời!';
        }
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
