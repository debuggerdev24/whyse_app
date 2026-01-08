class GenerateStoryRequest {
  final String textType;
  final String language;
  final String readingTopic;
  final String lessonDuration;
  final String readingSkillFocus;
  final String readingLevel;
  final int age;
  final String lessonContentInstructions;

  GenerateStoryRequest({
    required this.textType,
    required this.language,
    required this.readingTopic,
    required this.lessonDuration,
    required this.readingSkillFocus,
    required this.readingLevel,
    required this.age,
    required this.lessonContentInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      "TextType": textType,
      "Language": language,
      "ReadingTopic": readingTopic,
      "LessonDuration": lessonDuration,
      "ReadingSkillFocus": readingSkillFocus,
      "ReadingLevel": readingLevel,
      "Age": age,
      "LessonContentInstructions": lessonContentInstructions,
    };
  }
}
