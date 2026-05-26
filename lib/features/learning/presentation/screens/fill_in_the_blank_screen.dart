import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:flutter/material.dart';

class QuizWithChoicesPage extends StatelessWidget {
  final List<Flashcard> flashcards;
  const QuizWithChoicesPage({super.key, required this.flashcards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Điền vào chỗ trống')),
      body: const Center(child: Text('Màn hình điền vào chỗ trống')),
    );
  }
}
