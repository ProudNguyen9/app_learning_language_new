class Flashcard {
  String id;

  String question;

  String answer;

  String? questionImage;

  String? answerImage;

  String questionLanguage;

  String answerLanguage;

  //  Chuyển từ Map Firebase sang Flashcard
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      questionImage: map['questionImage'],
      answerImage: map['answerImage'],
      questionLanguage: map['questionLanguage'] ?? 'en-US',
      answerLanguage: map['answerLanguage'] ?? 'vi-VN',
    );
  }

  //  Chuyển từ Flashcard sang Map để đẩy lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'questionImage': questionImage,
      'answerImage': answerImage,
      'questionLanguage': questionLanguage,
      'answerLanguage': answerLanguage,
    };
  }

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.questionImage,
    this.answerImage,
    this.questionLanguage = 'en-US',
    this.answerLanguage = 'vi-VN',
  });
}
