import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/models/home/story_models/story_model.dart';

/// Full `data` object from `GET /story/ideas/:id/story` (success payload).
class GetStoryByIdeaData {
  GetStoryByIdeaData({
    required this.storyIdea,
    required this.prompt,
    required this.story,
    required this.continueReading,
  });

  final StoryIdeaPayload? storyIdea;
  final StoryPromptPayload? prompt;
  final ApiStoryPayload story;
  final ContinueReadingPayload? continueReading;

  bool get isStoryGenerated => storyIdea?.isGenerated == true;

  /// Hero / share image: prefer story thumbnail, then idea thumbnail.
  String get heroThumbnailUrl {
    final t = story.thumbnailUrl.trim();
    if (t.isNotEmpty) return story.thumbnailUrl;
    return storyIdea?.thumbnailUrl ?? '';
  }

  factory GetStoryByIdeaData.fromDataMap(Map<String, dynamic> data) {
    final storyRaw = data['story'];
    if (storyRaw is! Map) {
      throw const FormatException('getStoryByIdea: data.story missing or invalid');
    }
    return GetStoryByIdeaData(
      storyIdea: data['storyIdea'] is Map
          ? StoryIdeaPayload.fromJson(
              Map<String, dynamic>.from(data['storyIdea'] as Map),
            )
          : null,
      prompt: data['prompt'] is Map
          ? StoryPromptPayload.fromJson(
              Map<String, dynamic>.from(data['prompt'] as Map),
            )
          : null,
      story: ApiStoryPayload.fromJson(
        Map<String, dynamic>.from(storyRaw),
      ),
      continueReading: data['continueReading'] is Map
          ? ContinueReadingPayload.fromJson(
              Map<String, dynamic>.from(data['continueReading'] as Map),
            )
          : null,
    );
  }
}

class StoryIdeaPayload {
  StoryIdeaPayload({
    required this.id,
    required this.title,
    required this.description,
    required this.isGenerated,
    required this.thumbnailUrl,
    required this.priority,
    required this.sequenceIndex,
  });

  final String id;
  final String title;
  final String description;
  final bool isGenerated;
  final String thumbnailUrl;
  final int? priority;
  final int? sequenceIndex;

  factory StoryIdeaPayload.fromJson(Map<String, dynamic> json) {
    return StoryIdeaPayload(
      id: json['id']?.toString() ?? '',
      title: stripHtml(json['title']?.toString() ?? ''),
      description: stripHtml(json['description']?.toString() ?? ''),
      isGenerated: json['isGenerated'] == true,
      thumbnailUrl: resolveNetworkImageUrl(
        json['thumbnailUrl']?.toString() ?? '',
      ),
      priority: json['priority'] is int
          ? json['priority'] as int
          : int.tryParse(json['priority']?.toString() ?? ''),
      sequenceIndex: json['sequenceIndex'] is int
          ? json['sequenceIndex'] as int
          : int.tryParse(json['sequenceIndex']?.toString() ?? ''),
    );
  }
}

class StoryPromptPayload {
  StoryPromptPayload({
    required this.id,
    required this.promptType,
    required this.age,
    required this.grade,
    required this.language,
    required this.textType,
    required this.readingLevel,
    required this.readingSkill,
    required this.lessonDuration,
    required this.mustIncludeWords,
    required this.quizPerStory,
    required this.noOfStories,
  });

  final String? id;
  final String? promptType;
  final String? age;
  final String? grade;
  final String? language;
  final String? textType;
  final String? readingLevel;
  final String? readingSkill;
  final String? lessonDuration;
  final String? mustIncludeWords;
  final int? quizPerStory;
  final int? noOfStories;

  factory StoryPromptPayload.fromJson(Map<String, dynamic> json) {
    return StoryPromptPayload(
      id: json['id']?.toString(),
      promptType: json['promptType']?.toString(),
      age: json['age']?.toString(),
      grade: json['grade']?.toString(),
      language: json['language']?.toString(),
      textType: json['textType']?.toString(),
      readingLevel: json['readingLevel']?.toString(),
      readingSkill: json['readingSkill']?.toString(),
      lessonDuration: json['lessonDuration']?.toString(),
      mustIncludeWords: json['mustIncludeWords']?.toString(),
      quizPerStory: json['quizPerStory'] is int
          ? json['quizPerStory'] as int
          : int.tryParse(json['quizPerStory']?.toString() ?? ''),
      noOfStories: json['noOfStories'] is int
          ? json['noOfStories'] as int
          : int.tryParse(json['noOfStories']?.toString() ?? ''),
    );
  }
}

/// `data.story` — generated reading document.
class ApiStoryPayload {
  ApiStoryPayload({
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
    required this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String content;
  final List<StoryPages> pages;
  final int pageCount;
  final List<String> images;
  final List<StoryQuiz> quiz;
  final StoryContentMetadata metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String thumbnailUrl;

  int? get lessonDuration => metadata.lessonDuration;

  factory ApiStoryPayload.fromJson(Map<String, dynamic> json) {
    final pagesJson = json['pages'];
    final pages = pagesJson is List
        ? pagesJson
            .map((e) => StoryPages.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <StoryPages>[];

    final imagesJson = json['images'];
    final images = imagesJson is List
        ? List<String>.from(imagesJson.map((x) => x.toString()))
        : <String>[];

    final quizJson = json['quiz'];
    final quiz = quizJson is List
        ? quizJson
            .map((x) => StoryQuiz.fromJson(Map<String, dynamic>.from(x as Map)))
            .toList()
        : <StoryQuiz>[];

    final metaRaw = json['metadata'];
    final metadata = metaRaw is Map<String, dynamic>
        ? StoryContentMetadata.fromJson(metaRaw)
        : StoryContentMetadata.empty();

    final pageCountRaw = json['pageCount'];
    final pageCount = pageCountRaw is int
        ? pageCountRaw
        : int.tryParse(pageCountRaw?.toString() ?? '') ?? pages.length;

    return ApiStoryPayload(
      id: json['id']?.toString() ?? '',
      title: stripHtml(json['title']?.toString() ?? ''),
      content: stripHtml(json['content']?.toString() ?? ''),
      pages: pages,
      pageCount: pageCount,
      images: images,
      quiz: quiz,
      metadata: metadata,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      thumbnailUrl: resolveNetworkImageUrl(
        json['thumbnailUrl']?.toString() ?? '',
      ),
    );
  }
}

class StoryContentMetadata {
  StoryContentMetadata({
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

  final String readingTopic;
  final String readingLevel;
  final String readingSkillFocus;
  final int age;
  final String language;
  final String textType;
  final int lessonDuration;
  final String lessonContentInstructions;
  final List<String> tags;
  final bool isPublic;

  factory StoryContentMetadata.empty() => StoryContentMetadata(
        readingTopic: '',
        readingLevel: '',
        readingSkillFocus: '',
        age: 0,
        language: '',
        textType: '',
        lessonDuration: 0,
        lessonContentInstructions: '',
        tags: const [],
        isPublic: false,
      );

  factory StoryContentMetadata.fromJson(Map<String, dynamic> json) {
    final ageRaw = json['age'];
    final age = ageRaw is int
        ? ageRaw
        : int.tryParse(ageRaw?.toString() ?? '0') ?? 0;
    final lessonRaw = json['lessonDuration'];
    final lesson = lessonRaw is int
        ? lessonRaw
        : int.tryParse(lessonRaw?.toString() ?? '0') ?? 0;
    final tagsJson = json['tags'];
    final tags = tagsJson is List
        ? List<String>.from(tagsJson.map((x) => x.toString()))
        : <String>[];
    return StoryContentMetadata(
      readingTopic: json['readingTopic']?.toString() ?? '',
      readingLevel: json['readingLevel']?.toString() ?? '',
      readingSkillFocus: json['readingSkillFocus']?.toString() ?? '',
      age: age,
      language: json['language']?.toString() ?? '',
      textType: json['textType']?.toString() ?? '',
      lessonDuration: lesson,
      lessonContentInstructions:
          json['lessonContentInstructions']?.toString() ?? '',
      tags: tags,
      isPublic: json['isPublic'] == true,
    );
  }
}

class ContinueReadingPayload {
  ContinueReadingPayload({
    required this.pageCount,
    required this.readPages,
    required this.remainingPages,
    required this.lastPageIndex,
    required this.continueFromPageIndex,
    required this.percentComplete,
    required this.lastReadAt,
    required this.completedAt,
    required this.isCompleted,
  });

  final int pageCount;
  final int readPages;
  final int remainingPages;
  final int lastPageIndex;
  final int continueFromPageIndex;
  final int percentComplete;
  final String? lastReadAt;
  final String? completedAt;
  final bool isCompleted;

  factory ContinueReadingPayload.fromJson(Map<String, dynamic> json) {
    int readInt(Object? v, [int fallback = 0]) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? fallback;
    }

    return ContinueReadingPayload(
      pageCount: readInt(json['pageCount']),
      readPages: readInt(json['readPages']),
      remainingPages: readInt(json['remainingPages']),
      lastPageIndex: readInt(json['lastPageIndex']),
      continueFromPageIndex: readInt(json['continueFromPageIndex']),
      percentComplete: readInt(json['percentComplete']),
      lastReadAt: json['lastReadAt']?.toString(),
      completedAt: json['completedAt']?.toString(),
      isCompleted: json['isCompleted'] == true,
    );
  }
}
