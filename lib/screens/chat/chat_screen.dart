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
  bool _glassScrolling = false;

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

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is ScrollEndNotification) {
      if (_glassScrolling) setState(() => _glassScrolling = false);
    } else if (notification is OverscrollNotification) {
      if (!_glassScrolling) setState(() => _glassScrolling = true);
    } else if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta.abs() > 0.5 && !_glassScrolling) {
        setState(() => _glassScrolling = true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    // The tab pill's top edge sits 67px above the screen bottom
    // (5px inset + 62px bar). Keep the field just above that.
    final composerBottom = keyboard > 0
        ? keyboard + 8
        : MediaQuery.viewPaddingOf(context).bottom + 75;

    return Scaffold(
      backgroundColor: chatBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.paddingOf(context).top + 8,
              20,
              4,
            ),
            child: AppText(
              text: 'Chat',
              style: AppTextStyles.semibold(
                fontSize: 32,
                color: const Color(0xFF1A1A1A),
              ).copyWith(height: 1.1, letterSpacing: -0.6),
            ),
          ),
          Expanded(
            child: Consumer<ChatProvider>(
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
                final showSuggestions =
                    _showSuggestions &&
                    !chatProvider.isStreaming &&
                    messages.isNotEmpty;
                final overlayHeight =
                    ChatInputBar.height + (showSuggestions ? 138 : 0);
                // The field is translucent, so the list must clear its full
                // height or the last line sits underneath it.
                final listBottom = composerBottom + overlayHeight + 16;

                return NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: Stack(
                    children: [
                      if (messages.isEmpty && !chatProvider.isStreaming)
                        Positioned.fill(
                          child: Skeletonizer(
                            enabled: chatProvider.isChatHistoryLoading,
                            child: ChatEmptyState(
                              suggestions: _suggestions,
                              onSuggestionTap: _handleSend,
                              bottomReserve: listBottom,
                            ),
                          ),
                        )
                      else
                        Positioned.fill(
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: EdgeInsets.fromLTRB(16, 8, 16, listBottom),
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            itemCount: messages.length + (isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (isTyping && index == 0) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: _TypingIndicator(),
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
                                  !message.isUserMessage &&
                                  message.id == latestBotId;
                              final shouldAnimate =
                                  chatProvider.isStreaming && isStreamingTarget;
                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
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
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: composerBottom + overlayHeight - 8,
                        height: 72,
                        child: ChatScrollEdge(active: _glassScrolling),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: composerBottom,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showSuggestions) ...[
                              ChatSuggestionSection(
                                suggestions: _suggestions,
                                onSuggestionTap: _handleSend,
                              ),
                              const SizedBox(height: 10),
                            ],
                            ChatInputBar(
                              controller: _messageController,
                              focusNode: _focusNode,
                              scrolling: _glassScrolling,
                              onSend: () => _handleSend(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
    final textSegmentIndexes = <int>[];
    for (var i = 0; i < segments.length; i++) {
      if (segments[i].type == ChatMessageSegmentType.text &&
          segments[i].content.trim().isNotEmpty) {
        textSegmentIndexes.add(i);
      }
    }
    final lastTextSegmentIndex = textSegmentIndexes.isEmpty
        ? -1
        : textSegmentIndexes.last;

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
              animate: animateText,
              showCursor: isStreaming && isLastText,
            ),
          );
        case ChatMessageSegmentType.cards:
          if (segment.items.isEmpty) continue;
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
  const _ChatCardsSegment({required this.items, required this.onCardTap});

  final List<CardItem> items;
  final ValueChanged<CardItem> onCardTap;

  @override
  Widget build(BuildContext context) {
    final sparks = items
        .where((item) => item.kind == CardItemType.spark)
        .toList();
    final stories = items
        .where((item) => item.kind != CardItemType.spark)
        .toList();

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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: SizedBox(
          width: 36,
          height: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
