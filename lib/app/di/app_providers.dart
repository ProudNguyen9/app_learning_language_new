import 'package:apphoctienganh/features/auth/presentation/providers/auth_provider.dart';
import 'package:apphoctienganh/features/flashcard/presentation/providers/flashcard_provider.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/big_flashcard_provider.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/fill_in_the_blank_provider.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/word_scramble_provider.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/popup_provider.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/question_answer_provider.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/quiz_provider.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/speak_question_provider.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/word_guessing_provider.dart';
import 'package:apphoctienganh/features/home/presentation/providers/home_provider.dart';
import 'package:apphoctienganh/features/learning/presentation/providers/speech_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

export 'package:apphoctienganh/features/auth/presentation/providers/auth_provider.dart';
export 'package:apphoctienganh/features/flashcard/presentation/providers/flashcard_provider.dart';
export 'package:apphoctienganh/features/learning/presentation/providers/big_flashcard_provider.dart';
export 'package:apphoctienganh/features/learning/presentation/providers/fill_in_the_blank_provider.dart';
export 'package:apphoctienganh/features/learning/presentation/providers/word_scramble_provider.dart';
export 'package:apphoctienganh/features/learning/presentation/providers/popup_provider.dart';
export 'package:apphoctienganh/features/learning/presentation/providers/question_answer_provider.dart';
export 'package:apphoctienganh/features/learning/presentation/providers/quiz_provider.dart';
export 'package:apphoctienganh/features/learning/presentation/providers/speak_question_provider.dart';
export 'package:apphoctienganh/features/learning/presentation/providers/word_guessing_provider.dart';
export 'package:apphoctienganh/features/home/presentation/providers/home_provider.dart';
export 'package:apphoctienganh/features/learning/presentation/providers/speech_provider.dart';

final List<SingleChildWidget> appProviders = [
  ChangeNotifierProvider(create: (_) => AuthProvider()),
  ChangeNotifierProvider(create: (_) => FlashcardProvider()),
  ChangeNotifierProvider(create: (_) => HomeProvider()),
  ChangeNotifierProvider(create: (_) => SpeechProvider()),
  ChangeNotifierProvider(create: (_) => QuestionAnswerProvider()),
  ChangeNotifierProvider(create: (_) => BigFlashcardProvider()),
  ChangeNotifierProvider(create: (_) => Popupprovider()),
  ChangeNotifierProvider(create: (_) => QuizProvider()),
  ChangeNotifierProvider(create: (_) => WordGuessProvider()),
  ChangeNotifierProvider(create: (_) => WordScrambleProvider()),
  ChangeNotifierProvider(create: (_) => FillInTheBlankProvider()),
  ChangeNotifierProvider(create: (_) => SpeechQuestionProvider()),
];
