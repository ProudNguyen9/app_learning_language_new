import 'package:apphoctienganh/features/learning/presentation/providers/speak_question_provider.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/speech_provider.dart';
import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SpeechQuizScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const SpeechQuizScreen({super.key, required this.flashcards});

  @override
  State<SpeechQuizScreen> createState() => _SpeechQuizScreenState();
}

class _SpeechQuizScreenState extends State<SpeechQuizScreen> {
  @override
  void initState() {
    super.initState();
    requestMicPermission();
    final provider = Provider.of<SpeechQuestionProvider>(
      context,
      listen: false,
    );
    provider.loadData(widget.flashcards); // Load flashcards mới từ widget
  }

  Future<void> requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpeechQuestionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Speech Quiz'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Câu hỏi:',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    provider.currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              if (provider.isListening)
                Text(
                  'Câu mình đã đọc: ${provider.spokenText}',
                  style: const TextStyle(fontSize: 18, color: Colors.black45),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),

              // Sử dụng Row để đặt icon loa và mic cạnh nhau và đồng bộ kiểu
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<SpeechProvider>().speakText(
                        context
                            .read<SpeechQuestionProvider>()
                            .currentQuestion
                            .question,
                        true,
                      );
                    },
                    icon: Icon(
                      Icons
                          .volume_up, // Hoặc thay đổi thành Icons.volume_up nếu muốn loa
                      size: 35, // Đặt kích thước cho icon
                    ),
                    label: Text(
                      '', // Hoặc thay đổi thành 'Dừng' khi muốn biểu thị trạng thái
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 186, 218, 191),
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10, // Khoảng cách giữa hai nút
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (provider.isListening) {
                        provider.stopListening();
                        final correct = provider.checkAnswer();
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text(
                                  correct ? ' Đúng rồi!' : ' Sai rồi!',
                                ),
                                content: Text(
                                  correct
                                      ? 'Bạn đã phát âm chính xác.'
                                      : 'Bạn cần luyện thêm. Câu đúng là:\n"${provider.currentQuestion.question}"',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      provider.nextQuestion();
                                    },
                                    child: Text(
                                      provider.isLastQuestion
                                          ? 'Hoàn tất'
                                          : 'Câu tiếp',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      } else {
                        provider.startListening();
                      }
                    },
                    icon: Icon(
                      provider.isListening ? Icons.stop : Icons.mic,
                      size: 30, // Đặt kích thước giống icon loa
                    ),
                    label: Text(
                      provider.isListening ? 'Dừng' : 'Thu âm',
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 186, 218, 191),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (provider.isLastQuestion)
                Center(
                  child: Text(
                    '🎉 Bạn đã hoàn thành tất cả các câu hỏi!',
                    style: const TextStyle(fontSize: 20, color: Colors.orange),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
