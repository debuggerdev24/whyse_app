class Story {
  final String id, title, content;
  final List<String> images;
  final String? image; // Single image from get all stories API
  final List<Quiz> quiz;
  final String? readingTopic, readingLevel, readingSkillFocus;
  final int? age;
  final String? language;
  final String? textType;
  final int? lessonDuration;
  final List<String>? tags;
  final String? createdAt; // Added for good measure
  final String? updatedAt; // Added for good measure

  Story({
    required this.id,
    required this.title,
    required this.content,
    required this.images,
    this.image,
    required this.quiz,
    this.readingTopic,
    this.readingLevel,
    this.readingSkillFocus,
    this.age,
    this.language,
    this.textType,
    this.lessonDuration,
    this.tags,
    this.createdAt,
    this.updatedAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      image: json['image'],
      quiz: json['quiz'] != null
          ? (json['quiz'] as List).map((i) => Quiz.fromJson(i)).toList()
          : [],
      readingTopic: json['readingTopic'],
      readingLevel: json['readingLevel'],
      readingSkillFocus: json['readingSkillFocus'],
      age: json['age'],
      language: json['language'],
      textType: json['textType'],
      lessonDuration: json['lessonDuration'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class Quiz {
  final String question;
  final List<String> options;
  final String answer;
  final int correctAnswer;
  final String questionType;

  Quiz({
    required this.question,
    required this.options,
    required this.answer,
    required this.correctAnswer,
    required this.questionType,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      question: json['question'] ?? '',
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : [],
      answer: json['answer'] ?? '',
      correctAnswer: json['correctAnswer'] ?? 0,
      questionType: json['questionType'] ?? '',
    );
  }
}
