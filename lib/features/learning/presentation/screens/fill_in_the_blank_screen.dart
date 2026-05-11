import 'package:apphoctienganh/features/learning/presentation/providers/fill_in_the_blank_provider.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class QuizWithChoicesPage extends StatefulWidget {
  final List<Flashcard> flashcards;
  const QuizWithChoicesPage({super.key, required this.flashcards});

  @override
  State<QuizWithChoicesPage> createState() => _QuizWithChoicesPageState();
}

class _QuizWithChoicesPageState extends State<QuizWithChoicesPage> {
  late List<String> shuffledOptions;
  String? selectedAnswer;
  late Future<String> sentenceFuture;

  @override
  void initState() {
    super.initState();
    final provider = context.read<FillInTheBlankProvider>();
    provider.loadData(widget.flashcards);
    sentenceFuture = generateClozeSentence();
    shuffledOptions = _generateOptions();
  }

  Future<String> generateClozeSentence() async {
    final word = context.read<FillInTheBlankProvider>().currentQuestion.word;
    final response = await Gemini.instance.prompt(
      parts: [
        Part.text('''
Tạo một câu tiếng Anh có nghĩa, trong đó từ "$word" được thay bằng dấu ___.
Chỉ trả về câu đó, không cần giải thích. Ví dụ: "He opened the ___ and took out a book."
'''),
      ],
    );

    return response?.output?.trim().replaceAll('"', '') ?? '___';
  }

  List<String> _generateOptions() {
    final provider = context.read<FillInTheBlankProvider>();
    final correctWord = provider.currentQuestion.word;
    final allWords = provider.allQuestions.map((q) => q.word).toList();

    // Lấy ra 2 đáp án sai ngẫu nhiên (không trùng đáp án đúng)
    final wrongOptions =
        allWords.where((word) => word != correctWord).toList()..shuffle();

    final choices = [correctWord, ...wrongOptions.take(2)];
    choices.shuffle(); // trộn lại để random vị trí đúng
    return choices;
  }

  void _submitAnswer() {
    final provider = context.read<FillInTheBlankProvider>();
    final correct =
        selectedAnswer?.toLowerCase().trim() ==
        provider.currentQuestion.word.toLowerCase();

    showModalBottomSheet(
      backgroundColor: Colors.transparent, // nền của bottom sheet trong suốt
      context: context,
      builder:
          (context) => AwesomeSnackbarContent(
            title: correct ? ' Chính xác!' : ' Sai rồi!',
            message:
                correct
                    ? 'Bạn chọn đúng đáp án!'
                    : 'Từ đúng là: "${provider.currentQuestion.word}"',
            contentType: correct ? ContentType.success : ContentType.failure,
          ),
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (provider.isLastQuestion) {
        Alert(
          context: context,
          type: AlertType.success,
          title: "Hoàn thành!",
          desc:
              "Bạn đã hoàn thành tất cả câu hỏi.\nSố câu sai: ${provider.incorrectAnswers}",
          buttons: [
            DialogButton(
              onPressed: () {
                provider.resetQuiz();
                setState(() {
                  sentenceFuture = generateClozeSentence();
                  shuffledOptions = _generateOptions();
                  selectedAnswer = null;
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Chơi lại",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ).show();
      } else {
        provider.nextQuestion();
        setState(() {
          sentenceFuture = generateClozeSentence();
          shuffledOptions = _generateOptions();
          selectedAnswer = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FillInTheBlankProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Điền vào chỗ trống")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (provider.currentIndex + 1) / provider.allQuestions.length,
              color: Colors.teal,
              minHeight: 8,
            ),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: sentenceFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.data!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...shuffledOptions.map((option) {
                      return RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        groupValue: selectedAnswer,
                        onChanged: (value) {
                          setState(() {
                            selectedAnswer = value;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: selectedAnswer != null ? _submitAnswer : null,
                      child: const Text("Xác nhận"),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
