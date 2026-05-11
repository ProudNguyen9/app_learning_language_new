import 'package:apphoctienganh/features/flashcard/domain/entities/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/popup_provider.dart';
import 'dart:async';

import 'package:rflutter_alert/rflutter_alert.dart';

class Popupscreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  const Popupscreen({super.key, required this.flashcards});

  @override
  State<Popupscreen> createState() => _PopupscreenState();
}

class _PopupscreenState extends State<Popupscreen> {
  Timer? _timer;
  double _seconds = 0.0;

  @override
  void initState() {
    super.initState();

    // Gọi hàm load dữ liệu từ provider
    context.read<Popupprovider>().loadInitialFlashcards(widget.flashcards);
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _seconds += 0.1;
      });

      final flashcardProvider = context.read<Popupprovider>();
      final flashcards = flashcardProvider.flashcards;

      if (flashcardProvider.matchedIndexes.length == flashcards.length) {
        timer.cancel();
        Alert(
          context: context,
          type:
              AlertType
                  .success, // Có thể là info / warning / error tùy tình huống
          title: "Hoàn thành!",
          desc: "Bạn đã hoàn thành trong ${_seconds.toStringAsFixed(1)} giây.",
          buttons: [
            DialogButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(context).pop(); // Quay lại màn hình trước
              },
              width: 120,
              color: Colors.green,
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ), // Tùy chỉnh màu nút nếu muốn
            ),
          ],
        ).show();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashcards = context.watch<Popupprovider>().flashcards;
    final flashcardProvider = context.read<Popupprovider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ghép hình'),
            SizedBox(width: 8),
            Row(
              children: [
                Icon(FontAwesomeIcons.clock, size: 20),
                SizedBox(width: 8),
                Text(
                  "${_seconds.toStringAsFixed(1)} s",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: flashcards.length,
          itemBuilder: (_, index) {
            final flashcard = flashcards[index];
            final isSelected = flashcardProvider.selectedIndexes.contains(
              index,
            );
            final isIncorrect = flashcardProvider.incorrectIndexes.contains(
              index,
            );
            final isMatched = flashcardProvider.matchedIndexes.contains(index);
            final isQuestion = flashcard.id.endsWith(
              '_q',
            ); // 👈 phân biệt là câu hỏi hay đáp án
            final text = isQuestion ? flashcard.question : flashcard.answer;

            return GestureDetector(
              onTap: () {
                flashcardProvider.selectCard(index);
              },
              child: FlashcardTile(
                text: text,
                isSelected: isSelected,
                isIncorrect: isIncorrect,
                isMatched: isMatched,
              ),
            );
          },
        ),
      ),
    );
  }
}

class FlashcardTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isIncorrect;
  final bool isMatched;

  const FlashcardTile({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isIncorrect,
    required this.isMatched,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isSelected ? 0.4 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color:
              isMatched
                  ? Colors.green.withOpacity(0.6)
                  : isIncorrect
                  ? Colors.red.withOpacity(0.6)
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(8),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
