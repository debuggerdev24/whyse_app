class QuizModel {
  final String storyId;
  final String storyTitle;
  final List<Question> questions;
  final int totalQuestions;

  QuizModel({
    required this.storyId,
    required this.storyTitle,
    required this.questions,
    required this.totalQuestions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      storyId: json["storyId"],
      storyTitle: json["storyTitle"],
      questions: json["questions"],
      totalQuestions: json["totalQuestions"],
    );
  }
}

class Question {
  final int index;
  final String answer;
  final List<String> options;
  final String question;
  final String questionType;
  final int correctAnswer;

  Question({
    required this.index,
    required this.answer,
    required this.options,
    required this.question,
    required this.questionType,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      index: json["index"],
      answer: json["answer"],
      options: json["options"],
      question: json["question"],
      questionType: json["questionType"],
      correctAnswer: json["correctAnswer"],
    );
  }
  /*
   {
                "index": 0,
                "answer": "Love for humanity",
                "options": [
                    "Love for humanity",
                    "Wealth accumulation",
                    "Fame and recognition",
                    "Power and authority"
                ],
                "question": "What did Sai Sudarshan emphasize in his teachings?",
                "questionType": "literal",
                "correctAnswer": 0
            },
  */
}
