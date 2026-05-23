import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/speech_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BigFlashcardScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  const BigFlashcardScreen({super.key, required this.flashcards});

  @override
  _BigFlashcardScreenState createState() => _BigFlashcardScreenState();
}

class _BigFlashcardScreenState extends State<BigFlashcardScreen> {
  int currentIndex = 0;
  bool showAnswer = false;

  void nextCard() {
    setState(() {
      if (currentIndex < widget.flashcards.length - 1) {
        currentIndex++;
        showAnswer = false;
      }
    });
  }

  void previousCard() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        showAnswer = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final flashcard = widget.flashcards[currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Flashcards'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showAnswer = !showAnswer;
                });
              },
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      showAnswer ? flashcard.answer : flashcard.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              context.read<SpeechProvider>().speakTextWithLanguage(
                showAnswer ? flashcard.answer : flashcard.question,
                showAnswer
                    ? flashcard.answerLanguage
                    : flashcard.questionLanguage,
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: previousCard,
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              Text('${currentIndex + 1}/${widget.flashcards.length}'),
              IconButton(
                onPressed: nextCard,
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
