import 'package:apphoctienganh/core/network/api_client.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';

abstract interface class FlashcardRemoteDataSource {
  Future<List<Flashcard>> getFlashcards();
}

final class FlashcardRemoteDataSourceImpl implements FlashcardRemoteDataSource {
  const FlashcardRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Flashcard>> getFlashcards() async {
    final response = await _apiClient.get<List<Flashcard>>(
      '/flashcards',
      decoder: (json) {
        if (json is! List) return const [];

        return json
            .whereType<Map<String, dynamic>>()
            .map(_flashcardFromJson)
            .toList(growable: false);
      },
    );

    return response.data;
  }

  Flashcard _flashcardFromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      questionImage: json['questionImage']?.toString(),
      answerImage: json['answerImage']?.toString(),
    );
  }
}
