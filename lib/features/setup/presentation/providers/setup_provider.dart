import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/setup_question_model.dart';
import '../../data/models/setup_db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupState {
  final List<SetupQuestionModel> questions;
  final int currentQuestionIndex;
  final bool isLoading;
  final bool isCompleted;
  final String? error;

  const SetupState({
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.isLoading = false,
    this.isCompleted = false,
    this.error,
  });

  SetupState copyWith({
    List<SetupQuestionModel>? questions,
    int? currentQuestionIndex,
    bool? isLoading,
    bool? isCompleted,
    String? error,
  }) {
    return SetupState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }
}

class SetupNotifier extends StateNotifier<SetupState> {
  final SetupDbHelper _dbHelper = SetupDbHelper();

  SetupNotifier() : super(const SetupState()) {
    _initializeQuestions();
  }

  void _initializeQuestions() {
    final questions = [
      SetupQuestionModel(
        id: 1,
        question: 'What\'s your style preference?',
        description: 'Choose the style that best describes your fashion taste',
        options: ['Casual', 'Formal', 'Streetwear', 'Vintage', 'Minimalist'],
      ),
      SetupQuestionModel(
        id: 2,
        question: 'What colors do you prefer?',
        description: 'Select your favorite color palette',
        options: ['Neutral tones', 'Bright colors', 'Pastels', 'Dark colors', 'Mixed'],
      ),
      SetupQuestionModel(
        id: 3,
        question: 'How often do you dress up?',
        description: 'Tell us about your dressing habits',
        options: ['Daily', 'Weekly', 'Special occasions', 'Rarely', 'Depends on mood'],
      ),
      SetupQuestionModel(
        id: 4,
        question: 'What\'s your budget range?',
        description: 'Help us suggest items within your budget',
        options: ['Budget-friendly', 'Mid-range', 'Premium', 'Luxury', 'No preference'],
      ),
      SetupQuestionModel(
        id: 5,
        question: 'What occasions do you dress for most?',
        description: 'Select the occasions you dress up for most frequently',
        options: ['Work/Office', 'Social events', 'Casual outings', 'Formal events', 'All occasions'],
      ),
    ];

    state = state.copyWith(questions: questions);
  }

  void selectOption(int questionId, String option) {
    final updatedQuestions = state.questions.map((question) {
      if (question.id == questionId) {
        return question.copyWith(selectedOption: option);
      }
      return question;
    }).toList();

    state = state.copyWith(questions: updatedQuestions);
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
    }
  }

  void setCurrentQuestionIndex(int index) {
    state = state.copyWith(currentQuestionIndex: index);
  }

  bool get canProceed {
    final currentQuestion = state.questions[state.currentQuestionIndex];
    return currentQuestion.selectedOption != null;
  }

  bool get isFirstQuestion => state.currentQuestionIndex == 0;
  bool get isLastQuestion => state.currentQuestionIndex == state.questions.length - 1;

  Future<void> saveResponses(WidgetRef ref) async {
    state = state.copyWith(isLoading: true);
    try {
      // Save to local database
      for (final question in state.questions) {
        if (question.selectedOption != null) {
          await _dbHelper.saveResponse(
            question.id,
            question.question,
            question.selectedOption!,
          );
        }
      }
      // Set setup_completed flag in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('setup_completed', true);
      state = state.copyWith(isCompleted: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final setupProvider = StateNotifierProvider<SetupNotifier, SetupState>((ref) {
  return SetupNotifier();
}); 