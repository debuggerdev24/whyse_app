import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/chat/chat_history_model.dart';
import 'package:redstreakapp/models/explore/explore_models.dart';
import 'package:redstreakapp/models/home/browse_topic_model.dart';
import 'package:redstreakapp/providers/chat/chat_provider.dart';
import 'package:redstreakapp/providers/curiosity_reading/curiosity_reading_provider.dart';
import 'package:redstreakapp/providers/explore/explore_provider.dart';
import 'package:redstreakapp/screens/chat/widgets/chat_widgets.dart';
import 'package:redstreakapp/services/home/home_api_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _suggestions = [
    'Suggest me a book to read',
    'I want to read a Spark about nature',
    'Suggest me a story to read',
    'What should I learn today?',
    'Show me series about animals',
  ];

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _showSuggestions = true;
  bool _isOpeningCard = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreProvider>().ensureExploreReady();
      context.read<ChatProvider>().loadChatHistory();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSend([String? presetText]) async {
    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.isStreaming) return;

    final text = (presetText ?? _messageController.text).trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() => _showSuggestions = false);
    _focusNode.unfocus();
    _scrollToBottom();

    await chatProvider.sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _onCardTap(CardItem item) async {
    if (_isOpeningCard || item.id.isEmpty) return;
    setState(() => _isOpeningCard = true);

    try {
      if (item.kind == CardItemType.spark) {
        await _openSpark(item);
      } else {
        await _openSeries(item);
      }
    } finally {
      if (mounted) setState(() => _isOpeningCard = false);
    }
  }

  Future<void> _openSpark(CardItem item) async {
    final curiosity = context.read<CuriosityReadingProvider>();
    curiosity.beginExploreSession(
      items: [
        ExploreSparkItem(
          id: item.id,
          title: item.title,
          question: item.question,
          imageUrl: item.imageUrl,
          interestName: '',
          rawJson: {
            'id': item.id,
            'title': item.title,
            'question': item.question,
            'imgUrl': item.imageUrl,
          },
        ),
      ],
      startIndex: 0,
      pagination: const ExplorePagination(
        page: 1,
        limit: 1,
        total: 1,
        totalPages: 1,
        hasMore: false,
      ),
      loadMoreItems: () async => (
        items: <ExploreSparkItem>[],
        pagination: const ExplorePagination(
          page: 1,
          limit: 1,
          total: 1,
          totalPages: 1,
          hasMore: false,
        ),
      ),
    );

    if (!mounted) return;
    context.pushNamed(AppRoutes.curiosityReadingScreen.name);
  }

  Future<void> _openSeries(CardItem item) async {
    final response = await HomeApiService.instance.getTopicProgress(
      topicId: item.id,
    );
    if (!mounted) return;

    await response.fold(
      (error) async {
        AppToast.error(context, error.errorMsg);
      },
      (result) async {
        final data = result['data'] ?? result;
        final readings = data['readings'];
        final list = readings is List ? readings : <dynamic>[];
        if (list.isEmpty) {
          AppToast.info(context: context, message: 'No readings found');
          return;
        }

        final topic = BrowseTopicModel(
          id: item.id,
          topic: item.title,
          learningGoal: item.question,
          type: 'story',
          interests: const [],
          noOfStories: list.length,
          noOfStoriesGenerated: list.length,
          createdBy: '',
          isOwnTopic: false,
          isInMyList: false,
          createdOn: null,
          updatedAt: null,
          thumbnailUrl: item.imageUrl,
          thumbnailSource: '',
          thumbnailLicense: '',
          thumbnailAttribution: '',
          thumbnailSearchEntity: '',
        );

        context.pushNamed(
          AppRoutes.randomStorySeriesScreen.name,
          extra: {'progress': result, 'searchTopic': topic.toJson()},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: chatBackgroundColor,
      appBar: const ChatAppBar(),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final messages = chatProvider.messages
              .where(
                (m) =>
                    m.isUserMessage ||
                    m.segments.isNotEmpty ||
                    m.content.trim().isNotEmpty,
              )
              .toList();
          final isTyping = chatProvider.isBotTyping;

          // While history is loading (or truly empty), show the welcome
          // landing — not the mid-chat suggestion strip on a blank list.
          if (messages.isEmpty && !chatProvider.isStreaming) {
            return Column(
              children: [
                Expanded(
                  child: Skeletonizer(
                    enabled: chatProvider.isChatHistoryLoading,
                    child: ChatEmptyState(
                      suggestions: _suggestions,
                      onSuggestionTap: _handleSend,
                    ),
                  ),
                ),
                ChatInputBar(
                  controller: _messageController,
                  focusNode: _focusNode,
                  onSend: () => _handleSend(),
                ),
              ],
            );
          }

          final itemCount = messages.length + (isTyping ? 1 : 0);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                  physics: const BouncingScrollPhysics(),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (isTyping && index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(top: 16.h),
                        child: const _TypingIndicator(),
                      );
                    }

                    final messageIndex = isTyping ? index - 1 : index;
                    final message =
                        messages[messages.length - 1 - messageIndex];
                    final latestBotId = chatProvider.messages
                        .lastWhere(
                          (m) => !m.isUserMessage,
                          orElse: () => message,
                        )
                        .id;
                    final isStreamingTarget =
                        !message.isUserMessage && message.id == latestBotId;
                    // Animate while the stream is active; typewriter keeps
                    // catching up after the stream ends via its own state.
                    final shouldAnimate =
                        chatProvider.isStreaming && isStreamingTarget;
                    return Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: _ChatMessageTile(
                        message: message,
                        onCardTap: _onCardTap,
                        animateText: shouldAnimate,
                        isStreaming: shouldAnimate,
                      ),
                    );
                  },
                ),
              ),
              if (_showSuggestions &&
                  !chatProvider.isStreaming &&
                  messages.isNotEmpty)
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
          );
        },
      ),
    );
  }
}

class _ChatMessageTile extends StatelessWidget {
  const _ChatMessageTile({
    required this.message,
    required this.onCardTap,
    this.animateText = false,
    this.isStreaming = false,
  });

  final ChatMessage message;
  final ValueChanged<CardItem> onCardTap;
  final bool animateText;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    if (message.isUserMessage) {
      final text = _primaryText(message);
      if (text.isEmpty) return const SizedBox.shrink();
      return ChatUserTextBubble(text: text);
    }

    final segments = message.segments;
    if (segments.isEmpty) {
      final fallback = message.content.trim();
      // Placeholder assistant row while SSE is still connecting / typing.
      if (fallback.isEmpty) return const SizedBox.shrink();
      return ChatBotTextBubble(
        text: fallback,
        animate: animateText,
        showCursor: isStreaming,
      );
    }

    final children = <Widget>[];
    var avatarShown = false;
    final textSegmentIndexes = <int>[];
    for (var i = 0; i < segments.length; i++) {
      if (segments[i].type == ChatMessageSegmentType.text &&
          segments[i].content.trim().isNotEmpty) {
        textSegmentIndexes.add(i);
      }
    }
    final lastTextSegmentIndex =
        textSegmentIndexes.isEmpty ? -1 : textSegmentIndexes.last;

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      switch (segment.type) {
        case ChatMessageSegmentType.text:
          final text = segment.content.trim();
          if (text.isEmpty) continue;
          final isLastText = i == lastTextSegmentIndex;
          children.add(
            ChatBotTextBubble(
              key: ValueKey('${message.id}-text-$i'),
              text: text,
              showAvatar: !avatarShown,
              animate: animateText,
              showCursor: isStreaming && isLastText,
            ),
          );
          avatarShown = true;
        case ChatMessageSegmentType.cards:
          if (segment.items.isEmpty) continue;
          if (!avatarShown) {
            children.add(const ChatBotAvatar());
            children.add(SizedBox(height: 8.h));
            avatarShown = true;
          }
          children.add(
            _ChatCardsSegment(items: segment.items, onCardTap: onCardTap),
          );
      }
    }

    if (children.isEmpty) {
      final fallback = message.content.trim();
      if (fallback.isEmpty) return const SizedBox.shrink();
      return ChatBotTextBubble(
        text: fallback,
        animate: animateText,
        showCursor: isStreaming,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: 10.h),
          children[i],
        ],
      ],
    );
  }

  String _primaryText(ChatMessage message) {
    for (final segment in message.segments) {
      if (segment.type == ChatMessageSegmentType.text &&
          segment.content.trim().isNotEmpty) {
        return segment.content.trim();
      }
    }
    return message.content.trim();
  }
}

class _ChatCardsSegment extends StatelessWidget {
  const _ChatCardsSegment({
    required this.items,
    required this.onCardTap,
  });

  final List<CardItem> items;
  final ValueChanged<CardItem> onCardTap;

  @override
  Widget build(BuildContext context) {
    final sparks =
        items.where((item) => item.kind == CardItemType.spark).toList();
    final stories =
        items.where((item) => item.kind != CardItemType.spark).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sparks.isNotEmpty)
          ChatSparkCardsRow(items: sparks, onCardTap: onCardTap),
        if (sparks.isNotEmpty && stories.isNotEmpty) SizedBox(height: 10.h),
        if (stories.isNotEmpty)
          ChatTopicCardsRow(items: stories, onCardTap: onCardTap),
      ],
    );
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
