import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:redstreakapp/providers/curiosity_reading/curiosity_reading_provider.dart';
import 'package:redstreakapp/providers/explore/explore_provider.dart';
import 'package:redstreakapp/screens/chat/models/chat_message.dart';
import 'package:redstreakapp/screens/chat/widgets/chat_widgets.dart';
import 'package:redstreakapp/screens/dashboard.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _initialBotMessage =
      'What do you want to learn next?';

  static const _suggestions = [
    'Suggest me a book to read',
    'I want to read a spark post about nature',
    'Suggest me a story to read',
  ];

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _showSuggestions = true;
  bool _isBotTyping = false;
  int _messageCounter = 0;

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        id: _nextMessageId(),
        type: ChatMessageType.botText,
        text: _initialBotMessage,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreProvider>().ensureExploreReady();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _nextMessageId() => 'chat_${++_messageCounter}';

  void _closeChat() {
    tabIndex.value = 0;
    AppRouter.indexedStackNavigationShell?.goBranch(0);
  }

  Future<void> _handleSend([String? presetText]) async {
    final text = (presetText ?? _messageController.text).trim();
    if (text.isEmpty || _isBotTyping) return;

    setState(() {
      _showSuggestions = false;
      _messages.add(
        ChatMessage(
          id: _nextMessageId(),
          type: ChatMessageType.userText,
          text: text,
        ),
      );
      _isBotTyping = true;
    });
    _messageController.clear();
    _focusNode.unfocus();
    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    final response = _buildBotResponse(text);
    setState(() {
      _messages.addAll(response);
      _isBotTyping = false;
    });
    _scrollToBottom();
  }

  List<ChatMessage> _buildBotResponse(String userText) {
    final normalized = userText.toLowerCase();
    final kind = _resolveResponseKind(normalized);

    switch (kind) {
      case ChatResponseKind.sparkPosts:
        return [
          ChatMessage(
            id: _nextMessageId(),
            type: ChatMessageType.sparkCards,
            sparkItems: _sparkItems(),
          ),
        ];
      case ChatResponseKind.storyTopics:
        return [
          ChatMessage(
            id: _nextMessageId(),
            type: ChatMessageType.botText,
            text:
                'Sure. Here are some topics you can choose to read stories from.',
          ),
          ChatMessage(
            id: _nextMessageId(),
            type: ChatMessageType.topicCards,
            topicItems: _topicItems(),
          ),
        ];
      case ChatResponseKind.bookSuggestion:
        return [
          ChatMessage(
            id: _nextMessageId(),
            type: ChatMessageType.botText,
            text:
                'Great choice! Head to Explore to browse books and series tailored for you.',
          ),
        ];
      case ChatResponseKind.generic:
      case ChatResponseKind.none:
        return [
          ChatMessage(
            id: _nextMessageId(),
            type: ChatMessageType.botText,
            text:
                'I can help you find spark posts, stories, or books. Try one of the suggestions below.',
          ),
        ];
    }
  }

  ChatResponseKind _resolveResponseKind(String normalized) {
    if (normalized.contains('spark')) {
      return ChatResponseKind.sparkPosts;
    }
    if (normalized.contains('story') || normalized.contains('topic')) {
      return ChatResponseKind.storyTopics;
    }
    if (normalized.contains('book')) {
      return ChatResponseKind.bookSuggestion;
    }
    return ChatResponseKind.generic;
  }

  List<ChatSparkItem> _sparkItems() {
    final readings =
        context.read<CuriosityReadingProvider>().curiosityReading?.data.readings ??
            const [];

    if (readings.isNotEmpty) {
      return readings
          .take(5)
          .map(
            (reading) => ChatSparkItem(
              id: reading.id,
              title: reading.question,
              imageUrl: reading.imgUrl,
            ),
          )
          .toList();
    }

    return const [
      ChatSparkItem(
        id: 'spark_1',
        title: 'Why are there clouds in the sky?',
        imageUrl: 'assets/images/story1.png',
      ),
      ChatSparkItem(
        id: 'spark_2',
        title: 'How do trees grow in the rain?',
        imageUrl: 'assets/images/story2.png',
      ),
      ChatSparkItem(
        id: 'spark_3',
        title: 'What makes the ocean blue?',
        imageUrl: 'assets/images/story3.png',
      ),
    ];
  }

  List<ChatTopicItem> _topicItems() {
    final explore = context.read<ExploreProvider>();
    final topics = <BrowseTopicModel>[
      ...?explore.seriesState.forYou?.items,
      ...?explore.seriesState.popular?.items,
    ];

    final unique = <String, BrowseTopicModel>{};
    for (final topic in topics) {
      if (topic.id.isEmpty) continue;
      unique.putIfAbsent(topic.id, () => topic);
    }

    if (unique.isNotEmpty) {
      return unique.values
          .take(5)
          .map(
            (topic) => ChatTopicItem(
              id: topic.id,
              title: topic.topic,
              storyCount: topic.noOfStories,
              imageUrl: topic.thumbnailUrl,
              isInMyList: topic.isInMyList,
            ),
          )
          .toList();
    }

    return const [
      ChatTopicItem(
        id: 'topic_nature',
        title: 'Nature',
        storyCount: 50,
        imageUrl: 'assets/images/story1.png',
        isInMyList: false,
      ),
      ChatTopicItem(
        id: 'topic_space',
        title: 'Space',
        storyCount: 50,
        imageUrl: 'assets/images/space.png',
        isInMyList: false,
      ),
      ChatTopicItem(
        id: 'topic_adventure',
        title: 'Adventure',
        storyCount: 42,
        imageUrl: 'assets/images/story2.png',
        isInMyList: false,
      ),
    ];
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  void _openSparkReading(int index) {
    final provider = context.read<CuriosityReadingProvider>();
    provider.setCurrentIndex(index);
    context.pushNamed(AppRoutes.curiosityReadingScreen.name);
  }

  void _openTopic(BrowseTopicModel topic) {
    context.pushNamed(
      AppRoutes.randomStorySeriesScreen.name,
      extra: {
        'progress': <String, dynamic>{},
        'searchTopic': topic.toJson(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: chatBackgroundColor,
      appBar: ChatAppBar(onClose: _closeChat),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length + (_isBotTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isBotTyping && index == _messages.length) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                    child: const _TypingIndicator(),
                  );
                }

                final message = _messages[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _ChatMessageTile(
                    message: message,
                    onSparkRead: (item) {
                      final sparks = _sparkItems();
                      final sparkIndex = sparks.indexWhere((e) => e.id == item.id);
                      if (sparkIndex >= 0 &&
                          context
                                  .read<CuriosityReadingProvider>()
                                  .curiosityReading
                                  ?.data
                                  .readings
                                  .isNotEmpty ==
                              true) {
                        _openSparkReading(sparkIndex);
                        return;
                      }
                      AppToast.info(
                        context: context,
                        message: 'Opening spark post…',
                      );
                    },
                    onTopicTap: (item) {
                      final explore = context.read<ExploreProvider>();
                      final topics = <BrowseTopicModel>[
                        ...?explore.seriesState.forYou?.items,
                        ...?explore.seriesState.popular?.items,
                      ];
                      BrowseTopicModel? match;
                      for (final topic in topics) {
                        if (topic.id == item.id) {
                          match = topic;
                          break;
                        }
                      }
                      if (match != null) {
                        _openTopic(match);
                      } else {
                        AppToast.info(
                          context: context,
                          message: 'Opening ${item.title}…',
                        );
                      }
                    },
                    onAddToList: (_) {
                      AppToast.success(context, 'Added to your list');
                    },
                  ),
                );
              },
            ),
          ),
          if (_showSuggestions && !_isBotTyping)
            ChatSuggestionSection(
              suggestions: _suggestions,
              onSuggestionTap: _handleSend,
            ),
          ChatInputBar(
            controller: _messageController,
            focusNode: _focusNode,
            onSend: () => _handleSend(),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageTile extends StatelessWidget {
  const _ChatMessageTile({
    required this.message,
    this.onSparkRead,
    this.onTopicTap,
    this.onAddToList,
  });

  final ChatMessage message;
  final ValueChanged<ChatSparkItem>? onSparkRead;
  final ValueChanged<ChatTopicItem>? onTopicTap;
  final ValueChanged<ChatTopicItem>? onAddToList;

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case ChatMessageType.botText:
        return ChatBotTextBubble(text: message.text ?? '');
      case ChatMessageType.userText:
        return ChatUserTextBubble(text: message.text ?? '');
      case ChatMessageType.sparkCards:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChatSparkCardsRow(
              items: message.sparkItems,
              onReadTap: onSparkRead,
            ),
          ],
        );
      case ChatMessageType.topicCards:
        return ChatTopicCardsRow(
          items: message.topicItems,
          onCardTap: onTopicTap,
          onAddToListTap: onAddToList,
        );
    }
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ChatBotAvatar(),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: SizedBox(
              width: 36.w,
              height: 8.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (index) {
                  return Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
