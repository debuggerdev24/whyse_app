import 'package:flutter/material.dart';
import '../../models/home/story_models/story_model.dart';

class QuizProvider extends ChangeNotifier {
  int? selectedOptionIndex;
  bool isChecked = false;
  int currentQuestionIndex = 0;
  int score = 0;

  List<Map<String, dynamic>> questions = [];

  void initQuiz(List<Quiz> quizzes) {
    questions = quizzes
        .map(
          (q) => {
        "question": q.question,
        "options": q.options,
        "correctIndex": q.correctAnswer,
      },
    )
        .toList();

    selectedOptionIndex = null;
    isChecked = false;
    currentQuestionIndex = 0;
    score = 0;
    notifyListeners();
  }

  void selectOption(int index) {
    if (!isChecked) {
      selectedOptionIndex = index;
      notifyListeners();
    }
  }

  void checkAnswer() {
    isChecked = true;
    if (selectedOptionIndex ==
        questions[currentQuestionIndex]['correctIndex']) {
      score++;
    }
    notifyListeners();
  }

  void continueQuiz() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      selectedOptionIndex = null;
      isChecked = false;
      notifyListeners();
    }
  }
}
