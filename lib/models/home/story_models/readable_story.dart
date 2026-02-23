import 'package:redstreakapp/models/home/story_models/story_model.dart';

/// Common interface implemented by both [StoryModel] and [StoryHistoryModel].
/// Typing [ReadingScreen.story] against this gives full IDE suggestions
/// everywhere in the screen without needing dynamic casts.
abstract class IReadableStory {
  String get id;
  String get title;
  List<StoryPages> get pages;
  List<StoryQuiz> get quiz;
  int? get lessonDuration;
}
