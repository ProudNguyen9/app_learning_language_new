class ReadingFeedback {
  const ReadingFeedback({
    required this.score,
    required this.shortComment,
    required this.overallMeaning,
    required this.wordMeanings,
  });

  final int score;
  final String shortComment;
  final String overallMeaning;
  final List<WordMeaning> wordMeanings;

  factory ReadingFeedback.empty() {
    return const ReadingFeedback(
      score: 0,
      shortComment: '',
      overallMeaning: '',
      wordMeanings: [],
    );
  }
}

class WordMeaning {
  const WordMeaning({required this.word, required this.meaning});

  final String word;
  final String meaning;
}
