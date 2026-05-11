import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/list_flashcard.dart';

class LocalFlashcardStore {
  LocalFlashcardStore._();

  static final List<FlashcardList> _items = [
    FlashcardList(
      id: 'local_1',
      title: 'Từ vựng du lịch',
      description: 'Bộ mẫu offline để hiển thị giao diện',
      userId: 'local_user',
      flashcards: [
        Flashcard(id: 'f1', question: 'airport', answer: 'sân bay'),
        Flashcard(id: 'f2', question: 'passport', answer: 'hộ chiếu'),
        Flashcard(id: 'f3', question: 'ticket', answer: 'vé'),
      ],
    ),
  ];

  static List<FlashcardList> getAll() {
    return List<FlashcardList>.from(_items);
  }

  static void add(FlashcardList item) {
    _items.insert(0, item);
  }

  static void update(FlashcardList item) {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index == -1) return;
    _items[index] = item;
  }

  static void deleteById(String id) {
    _items.removeWhere((e) => e.id == id);
  }
}
