
class StoryModel {
  final String id, title, content;
  final List<StoryQuiz> quiz;
  final List<StoryPages> pages;
  final String? readingTopic,
      readingLevel,
      readingSkillFocus,
      language,
      textType,
      image,
      createdAt,
      updatedAt;
  final int? lessonDuration, age;
  final List<String>? tags;

  StoryModel({
    required this.id,
    required this.title,
    required this.content,
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
    this.updatedAt, required this.pages,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      image: json['image'],
      quiz: json['quiz'] != null
          ? (json['quiz'] as List).map((i) => StoryQuiz.fromJson(i)).toList()
          : [],
      readingTopic: json['readingTopic'],
      readingLevel: json['readingLevel'],
      readingSkillFocus: json['readingSkillFocus'],
      age: json['age'],
      language: json['language'],
      textType: json['textType'],
      lessonDuration: int.parse(json['lessonDuration']),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      pages: json['pages'] != null ? (json['pages'] as List).map((i) => StoryPages.fromJson(i)).toList() : [],
    );
  }
}

class StoryQuiz {
  final String question;
  final List<String> options;
  final String answer;
  final int correctAnswer;
  final String questionType;

  StoryQuiz({
    required this.question,
    required this.options,
    required this.answer,
    required this.correctAnswer,
    required this.questionType,
  });

  factory StoryQuiz.fromJson(Map<String, dynamic> json) {
    return StoryQuiz(
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


class StoryPages {
    int pageIndex;
    String text;
    String primaryEntity;
    String imageUrl;
    String imageSource;
    String license;
    String attribution;
    String sourcePageUrl;
    bool needsReview;

    StoryPages({
        required this.pageIndex,
        required this.text,
        required this.primaryEntity,
        required this.imageUrl,
        required this.imageSource,
        required this.license,
        required this.attribution,
        required this.sourcePageUrl,
        required this.needsReview,
    });

    factory StoryPages.fromJson(Map<String, dynamic> json) => StoryPages(
        pageIndex: json["pageIndex"] ?? 0,
        text: json["text"] ?? '',
        primaryEntity: json["primaryEntity"] ?? '',
        imageUrl: json["imageUrl"] ?? '',
        imageSource: json["imageSource"] ?? '',
        license: json["license"] ?? '',
        attribution: json["attribution"] ?? '',
        sourcePageUrl: json["sourcePageUrl"] ?? '',
        needsReview: json["needsReview"] ?? false,
    );

}
