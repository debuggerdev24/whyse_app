enum ChatMessageType { botText, userText, sparkCards, topicCards }

enum ChatResponseKind { none, sparkPosts, storyTopics, bookSuggestion, generic }

class ChatSparkItem {
  const ChatSparkItem({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String imageUrl;
}

class ChatTopicItem {
  const ChatTopicItem({
    required this.id,
    required this.title,
    required this.storyCount,
    required this.imageUrl,
    required this.isInMyList,
  });

  final String id;
  final String title;
  final int storyCount;
  final String imageUrl;
  final bool isInMyList;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.type,
    this.text,
    this.sparkItems = const [],
    this.topicItems = const [],
  });

  final String id;
  final ChatMessageType type;
  final String? text;
  final List<ChatSparkItem> sparkItems;
  final List<ChatTopicItem> topicItems;
}
