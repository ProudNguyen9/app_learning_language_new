import 'package:apphoctienganh/core/theme/app_colors.dart';
import 'package:apphoctienganh/features/flashcard/flashcard.dart';
import 'package:apphoctienganh/features/learning/learning.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:apphoctienganh/features/home/presentation/providers/home_provider.dart';

class FlashcardScreen extends StatefulWidget {
  final FlashcardList flashcardList;
  const FlashcardScreen({
    super.key,
    required this.flashcardList,
    required List<Flashcard> flashcards,
  });

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final List<GlobalKey<FlipCardState>> flipCardKeys = [];

  @override
  void initState() {
    super.initState();
    // Lưu danh sách flashcards vào provider khi màn hình được tạo
    context.read<HomeProvider>().setFlashcards(widget.flashcardList.flashcards);

    // Tạo flip card keys cho từng flashcard
    for (var i = 0; i < widget.flashcardList.flashcards.length; i++) {
      flipCardKeys.add(GlobalKey<FlipCardState>());
    }
  }

  // giao diện của cái card
  Widget _buildCard(String text, String? pathImage, String languageCode) {
    return FlashcardFaceWidget(
      text: text,
      pathImage: pathImage,
      languageCode: languageCode,
      onSpeak: () {
        context.read<SpeechProvider>().speakTextWithLanguage(
          text,
          languageCode,
        );
      },
    );
  }

  // flipcard
  Widget _buildFlashcard() {
    final homeProvider = context.watch<HomeProvider>();
    final flashcard = homeProvider.flashcards[homeProvider.currentIndex];
    return FlipCard(
      key: flipCardKeys[context.watch<HomeProvider>().currentIndex],
      direction: FlipDirection.HORIZONTAL,
      front: _buildCard(
        flashcard.question,
        flashcard.questionImage,
        flashcard.questionLanguage,
      ),
      back: _buildCard(
        flashcard.answer,
        flashcard.answerImage,
        flashcard.answerLanguage,
      ),
    );
  }

  void _showStudyOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StudyOptionsBottomSheet(
          flashcards: widget.flashcardList.flashcards,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final cards = provider.flashcards;

    return Scaffold(
      backgroundColor: FlashcardScreenStyles.pageBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: FlashcardScreenStyles.pageBackground,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.flashcardList.title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: ColorSetting.colorprimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${widget.flashcardList.flashcards.length} thuật ngữ',
              style: GoogleFonts.lexend(
                fontSize: 12,
                color: FlashcardScreenStyles.mutedText,
              ),
            ),
          ],
        ),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: ColorSetting.colorprimary,
        ),
        actions: [
          // Nút Edit
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 30, 0),
            width: 30.0,
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(
                FontAwesomeIcons.penToSquare,
                color: ColorSetting.colorprimary,
                size: 20,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            EditFlashCard(flashcardList: widget.flashcardList),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: FlashcardScreenStyles.cardBackground,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: FlashcardScreenStyles.borderColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: FlashcardScreenStyles.accentSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Thẻ ${provider.currentIndex + 1}/${cards.length}',
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ColorSetting.colorprimary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Chạm để lật thẻ',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            color: FlashcardScreenStyles.mutedText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 320,
                      child: Center(child: _buildFlashcard()),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FlashcardNavButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: context.read<HomeProvider>().previousCard,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              cards.length > 5 ? 5 : cards.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 16,
                                ),
                                width: provider.currentIndex == index ? 22 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color:
                                      provider.currentIndex == index
                                          ? ColorSetting.colorprimary
                                          : const Color(0xFFD9D2EF),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                          FlashcardNavButton(
                            icon: Icons.arrow_forward_ios_rounded,
                            onTap: context.read<HomeProvider>().nextCard,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thuật ngữ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF241B4A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Xem nhanh toàn bộ nội dung trong bộ thẻ',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: FlashcardScreenStyles.mutedText,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      context.read<HomeProvider>().sortlist(value);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'default',
                            child: Center(child: Text('Theo thứ tự gốc')),
                          ),
                          const PopupMenuItem<String>(
                            value: 'A_Z',
                            child: Center(child: Text('Theo chữ cái A-Z')),
                          ),
                          const PopupMenuItem<String>(
                            value: 'Z_A',
                            child: Center(child: Text('Theo chữ cái Z-A')),
                          ),
                        ],
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: FlashcardScreenStyles.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: FlashcardScreenStyles.borderColor,
                        ),
                      ),
                      child: Icon(
                        Icons.sort_rounded,
                        color: ColorSetting.colorprimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final flashcard = cards[index];
                return FlashcardTermItem(
                  question: flashcard.question,
                  answer: flashcard.answer,
                  onSpeak: () {
                    context.read<SpeechProvider>().speakTextWithLanguage(
                      flashcard.question,
                      flashcard.questionLanguage,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 96),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: SizedBox(
          height: 56,
          width: MediaQuery.of(context).size.width - 32,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: ColorSetting.colorprimary,
              disabledBackgroundColor: ColorSetting.colorprimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            onPressed: _showStudyOptions,
            icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
            label: Text(
              'Bắt đầu học với chế độ khác',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
