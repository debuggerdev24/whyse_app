enum AccountSetupStep {
  country,
  language,
  readingGoal,
  interests,
  topics,
  goals,
  finished,
}

enum OnboardingChatItemType {
  botMessage,
  userMessage,
  countryPicker,
  languagePicker,
  readingGoalPicker,
  interestPicker,
  topicPicker,
  goalPicker,
}

class OnboardingChatItem {
  const OnboardingChatItem({
    required this.id,
    required this.type,
    this.botText,
    this.userText,
    this.isActive = false,
  });

  final String id;
  final OnboardingChatItemType type;
  final String? botText;
  final String? userText;
  final bool isActive;

  OnboardingChatItem copyWith({
    String? id,
    OnboardingChatItemType? type,
    String? botText,
    String? userText,
    bool? isActive,
  }) {
    return OnboardingChatItem(
      id: id ?? this.id,
      type: type ?? this.type,
      botText: botText ?? this.botText,
      userText: userText ?? this.userText,
      isActive: isActive ?? this.isActive,
    );
  }
}
