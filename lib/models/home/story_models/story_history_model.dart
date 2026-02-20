class StoryHistoryModel {
    String id;
    String title;
    String content;
    List<String> pages;
    int pageCount;
    List<String> images;
    List<Quiz> quiz;
    Metadata metadata;
    DateTime createdAt;
    DateTime updatedAt;

    StoryHistoryModel({
        required this.id,
        required this.title,
        required this.content,
        required this.pages,
        required this.pageCount,
        required this.images,
        required this.quiz,
        required this.metadata,
        required this.createdAt,
        required this.updatedAt,
    });

    factory StoryHistoryModel.fromJson(Map<String, dynamic> json) => StoryHistoryModel(
        id: json["id"],
        title: json["title"],
        content: json["content"],
        pages: List<String>.from(json["pages"].map((x) => x)),
        pageCount: json["pageCount"],
        images: List<String>.from(json["images"].map((x) => x)),
        quiz: List<Quiz>.from(json["quiz"].map((x) => Quiz.fromJson(x))),
        metadata: Metadata.fromJson(json["metadata"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "pages": List<dynamic>.from(pages.map((x) => x)),
        "pageCount": pageCount,
        "images": List<dynamic>.from(images.map((x) => x)),
        "quiz": List<dynamic>.from(quiz.map((x) => x.toJson())),
        "metadata": metadata.toJson(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
    };
}

class Metadata {
    String readingTopic;
    String readingLevel;
    String readingSkillFocus;
    int age;
    String language;
    String textType;
    int lessonDuration;
    String lessonContentInstructions;
    List<String> tags;
    bool isPublic;

    Metadata({
        required this.readingTopic,
        required this.readingLevel,
        required this.readingSkillFocus,
        required this.age,
        required this.language,
        required this.textType,
        required this.lessonDuration,
        required this.lessonContentInstructions,
        required this.tags,
        required this.isPublic,
    });

    factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        readingTopic: json["readingTopic"],
        readingLevel: json["readingLevel"],
        readingSkillFocus: json["readingSkillFocus"],
        age: json["age"],
        language: json["language"],
        textType: json["textType"],
        lessonDuration: json["lessonDuration"],
        lessonContentInstructions: json["lessonContentInstructions"],
        tags: List<String>.from(json["tags"].map((x) => x)),
        isPublic: json["isPublic"],
    );

    Map<String, dynamic> toJson() => {
        "readingTopic": readingTopic,
        "readingLevel": readingLevel,
        "readingSkillFocus": readingSkillFocus,
        "age": age,
        "language": language,
        "textType": textType,
        "lessonDuration": lessonDuration,
        "lessonContentInstructions": lessonContentInstructions,
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "isPublic": isPublic,
    };
}

class Quiz {
    String answer;
    List<String> options;
    String question;
    String questionType;
    int correctAnswer;

    Quiz({
        required this.answer,
        required this.options,
        required this.question,
        required this.questionType,
        required this.correctAnswer,
    });

    factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        answer: json["answer"],
        options: List<String>.from(json["options"].map((x) => x)),
        question: json["question"],
        questionType: json["questionType"],
        correctAnswer: json["correctAnswer"],
    );

    Map<String, dynamic> toJson() => {
        "answer": answer,
        "options": List<dynamic>.from(options.map((x) => x)),
        "question": question,
        "questionType": questionType,
        "correctAnswer": correctAnswer,
    };
}
