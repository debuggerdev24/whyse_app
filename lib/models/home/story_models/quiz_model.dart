class QuizModel {
  final String storyId;
  final String storyTitle;
  final List<Question> questions;
  final int totalQuestions;
  final int? totalMcqQuestions;
  final bool? replacedExisting;

  QuizModel({
    required this.storyId,
    required this.storyTitle,
    required this.questions,
    required this.totalQuestions,
    this.totalMcqQuestions,
    this.replacedExisting,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      storyId: json["storyId"]?.toString() ?? "",
      storyTitle: json["storyTitle"]?.toString() ?? "",
      questions: (json["questions"] is List)
          ? (json["questions"] as List)
              .map((e) => Question.fromJson(
                    Map<String, dynamic>.from(e as Map? ?? {}),
                  ))
              .toList()
          : <Question>[],
      totalQuestions: json["totalQuestions"] is int
          ? json["totalQuestions"] as int
          : int.tryParse(json["totalQuestions"]?.toString() ?? "") ?? 0,
      totalMcqQuestions: json["totalMcqQuestions"] is int
          ? json["totalMcqQuestions"] as int
          : int.tryParse(json["totalMcqQuestions"]?.toString() ?? ""),
      replacedExisting: json["replacedExisting"] == true,
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
      index: json["index"] is int
          ? json["index"] as int
          : int.tryParse(json["index"]?.toString() ?? "") ?? 0,
      answer: json["answer"]?.toString() ?? "",
      options: (json["options"] is List)
          ? List<String>.from(
              (json["options"] as List).map((e) => e?.toString() ?? ""),
            )
          : <String>[],
      question: json["question"]?.toString() ?? "",
      questionType: json["questionType"]?.toString() ?? "",
      correctAnswer: json["correctAnswer"] is int
          ? json["correctAnswer"] as int
          : int.tryParse(json["correctAnswer"]?.toString() ?? "") ?? 0,
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
