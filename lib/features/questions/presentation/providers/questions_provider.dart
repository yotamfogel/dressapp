import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/question_model.dart';
import '../../../../core/providers/app_providers.dart';

class QuestionsState {
  final List<QuestionModel> questions;
  final int currentQuestionIndex;
  final bool isLoading;
  final String? error;

  const QuestionsState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.isLoading = false,
    this.error,
  });

  QuestionsState copyWith({
    List<QuestionModel>? questions,
    int? currentQuestionIndex,
    bool? isLoading,
    String? error,
  }) {
    return QuestionsState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isLastQuestion => currentQuestionIndex >= questions.length - 1;
  bool get isFirstQuestion => currentQuestionIndex == 0;
  QuestionModel? get currentQuestion => 
      questions.isNotEmpty && currentQuestionIndex < questions.length 
          ? questions[currentQuestionIndex] 
          : null;
  bool get isCompleted => 
      questions.isNotEmpty && 
      questions.every((q) => q.userAnswer != null);
}

class QuestionsNotifier extends StateNotifier<QuestionsState> {
  final SharedPreferences _prefs;
  static const String _questionsKey = 'user_questions';
  static const String _answersKey = 'user_answers';

  QuestionsNotifier(this._prefs) : super(const QuestionsState()) {
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load questions from storage or create default ones
      final questionsJson = _prefs.getString(_questionsKey);
      List<QuestionModel> questions;

      if (questionsJson != null) {
        final List<dynamic> questionsList = jsonDecode(questionsJson);
        questions = questionsList
            .map((json) => QuestionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Create default questions - you can replace these later
        questions = [
          const QuestionModel(
            id: '1',
            question: 'What is your preferred style?',
            options: ['Casual', 'Formal', 'Streetwear', 'Vintage', 'Minimalist'],
          ),
          const QuestionModel(
            id: '2',
            question: 'What colors do you prefer?',
            options: ['Neutral tones', 'Bright colors', 'Dark colors', 'Pastels', 'Mixed'],
          ),
          const QuestionModel(
            id: '3',
            question: 'How often do you shop for clothes?',
            options: ['Weekly', 'Monthly', 'Seasonally', 'Rarely', 'Only when needed'],
          ),
          const QuestionModel(
            id: '4',
            question: 'What is your budget range?',
            options: ['Budget-friendly', 'Mid-range', 'Premium', 'Luxury', 'No specific budget'],
          ),
          const QuestionModel(
            id: '5',
            question: 'What occasions do you dress for most?',
            options: ['Work/Office', 'Casual outings', 'Special events', 'Athletic activities', 'Mix of all'],
          ),
        ];
        await _saveQuestions(questions);
      }

      // Load user answers
      final answersJson = _prefs.getString(_answersKey);
      if (answersJson != null) {
        final Map<String, dynamic> answers = jsonDecode(answersJson);
        questions = questions.map((question) {
          final answer = answers[question.id];
          if (answer != null) {
            return question.copyWith(
              userAnswer: answer['answer'] as String,
              answeredAt: DateTime.parse(answer['timestamp'] as String),
            );
          }
          return question;
        }).toList();
      }

      state = state.copyWith(
        questions: questions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _saveQuestions(List<QuestionModel> questions) async {
    final questionsJson = jsonEncode(
      questions.map((q) => q.toJson()).toList(),
    );
    await _prefs.setString(_questionsKey, questionsJson);
  }

  Future<void> _saveAnswer(String questionId, String answer) async {
    final answersJson = _prefs.getString(_answersKey);
    Map<String, dynamic> answers = {};
    
    if (answersJson != null) {
      answers = Map<String, dynamic>.from(jsonDecode(answersJson));
    }

    answers[questionId] = {
      'answer': answer,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _prefs.setString(_answersKey, jsonEncode(answers));
  }

  void nextQuestion() {
    if (!state.isLastQuestion) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  void previousQuestion() {
    if (!state.isFirstQuestion) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      state = state.copyWith(currentQuestionIndex: index);
    }
  }

  Future<void> answerQuestion(String answer) async {
    if (state.currentQuestion == null) return;

    try {
      // Update the question with the answer
      final updatedQuestions = state.questions.map((question) {
        if (question.id == state.currentQuestion!.id) {
          return question.copyWith(
            userAnswer: answer,
            answeredAt: DateTime.now(),
          );
        }
        return question;
      }).toList();

      // Save to database
      await _saveAnswer(state.currentQuestion!.id, answer);

      // Update state
      state = state.copyWith(questions: updatedQuestions);

      // Auto-advance to next question if not the last one
      if (!state.isLastQuestion) {
        nextQuestion();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final questionsProvider = StateNotifierProvider<QuestionsNotifier, QuestionsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return QuestionsNotifier(prefs);
});

final currentQuestionProvider = Provider<QuestionModel?>((ref) {
  return ref.watch(questionsProvider).currentQuestion;
});

final questionsProgressProvider = Provider<double>((ref) {
  final state = ref.watch(questionsProvider);
  if (state.questions.isEmpty) return 0.0;
  return (state.currentQuestionIndex + 1) / state.questions.length;
}); 