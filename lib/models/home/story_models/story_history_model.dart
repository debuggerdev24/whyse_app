import 'package:redstreakapp/core/utils/text_utils.dart';
import 'package:redstreakapp/models/home/story_models/readable_story.dart';
import 'package:redstreakapp/models/home/story_models/story_model.dart';

class StoryHistoryModel implements IReadableStory {
    String id;
    String title;
    String content;
    List<StoryPages> pages;
    int pageCount;
    List<String> images;
    List<StoryQuiz> quiz;
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

    /// Satisfies [IReadableStory] — delegates to [metadata.lessonDuration].
    @override
    int? get lessonDuration => metadata.lessonDuration;

    factory StoryHistoryModel.fromJson(Map<String, dynamic> json) => StoryHistoryModel(
        id: json["id"],
        title: stripHtml(json["title"]?.toString() ?? ''),
        content: stripHtml(json["content"]?.toString() ?? ''),
        pages: (json["pages"] as List).map((e) => StoryPages.fromJson(e),).toList(),

        pageCount: json["pageCount"],
        images: List<String>.from(json["images"].map((x) => x)),
        quiz: List<StoryQuiz>.from(json["quiz"].map((x) => StoryQuiz.fromJson(x))),
        metadata: Metadata.fromJson(json["metadata"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
    );

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
}

