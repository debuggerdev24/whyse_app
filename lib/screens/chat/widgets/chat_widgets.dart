import 'dart:async';

import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/chat/chat_history_model.dart';

const Color _chatBackground = Color(0xFFF9F6F3);

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: AppText(
        text: 'Chat',
        style: AppTextStyles.semiBold(fontSize: 20.sp, color: AppColors.black),
      ),
      // actions: [
      //   Padding(
      //     padding: EdgeInsets.only(right: 16.w),
      //     child: GestureDetector(
      //       onTap: onClose,
      //       child: Container(
      //         width: 36.w,
      //         height: 36.w,
      //         decoration: BoxDecoration(
      //           color: _closeButtonBg,
      //           shape: BoxShape.circle,
      //         ),
      //         child: Center(
      //           child: SvgIcon(
      //             AppAssets.close,no
      //             size: 14.w,
      //             color: AppColors.black,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ],
    );
  }
}

class ChatBotAvatar extends StatelessWidget {
  const ChatBotAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.robot,
      width: 28.w,
      height: 28.w,
      fit: BoxFit.contain,
    );
  }
}

class ChatBotTextBubble extends StatelessWidget {
  const ChatBotTextBubble({
    super.key,
    required this.text,
    this.showAvatar = true,
    this.animate = false,
    this.showCursor = false,
  });

  final String text;
  final bool showAvatar;
  final bool animate;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    final regularStyle = AppTextStyles.regular(
      fontSize: 16.sp,
      color: AppColors.black,
    ).copyWith(height: 1.35);
    final boldStyle = AppTextStyles.bold(
      fontSize: 16.sp,
      color: AppColors.black,
    ).copyWith(height: 1.35);

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 0.82.sw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAvatar) ...[const ChatBotAvatar(), SizedBox(height: 8.h)],
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: ChatTypewriterText(
                text: text,
                style: regularStyle,
                boldStyle: boldStyle,
                animate: animate,
                showCursor: showCursor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reveals assistant text gradually (ChatGPT / Cursor style) with a blink cursor.
class ChatTypewriterText extends StatefulWidget {
  const ChatTypewriterText({
    super.key,
    required this.text,
    required this.style,
    required this.boldStyle,
    this.animate = false,
    this.showCursor = false,
    this.charsPerTick = 3,
    this.tickDuration = const Duration(milliseconds: 16),
  });

  final String text;
  final TextStyle style;
  final TextStyle boldStyle;
  final bool animate;
  final bool showCursor;
  final int charsPerTick;
  final Duration tickDuration;

  @override
  State<ChatTypewriterText> createState() => _ChatTypewriterTextState();
}

class _ChatTypewriterTextState extends State<ChatTypewriterText> {
  Timer? _timer;
  Timer? _cursorTimer;
  int _visibleLength = 0;
  String _target = '';
  bool _cursorOn = true;
  bool _hasStartedAnimation = false;

  bool get _isTyping => _visibleLength < _target.length;
  bool get _shouldShowCursor => widget.showCursor || _isTyping;

  @override
  void initState() {
    super.initState();
    _target = widget.text;
    if (widget.animate) {
      _hasStartedAnimation = true;
      _visibleLength = 0;
      _startTyping();
    } else {
      _visibleLength = widget.text.length;
    }
    _startCursorBlink();
  }

  @override
  void didUpdateWidget(covariant ChatTypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final next = widget.text;

    // Keep revealing until catching up, even after stream ends.
    if (!widget.animate && !_hasStartedAnimation) {
      _timer?.cancel();
      _target = next;
      _visibleLength = next.length;
      return;
    }

    if (widget.animate && !_hasStartedAnimation) {
      _hasStartedAnimation = true;
    }

    if (next == _target) {
      if (_isTyping) _startTyping();
      return;
    }

    if (next.startsWith(_target) || next.startsWith(_visibleText)) {
      _target = next;
      _startTyping();
      return;
    }

    // New segment text replaced the previous one.
    _target = next;
    _visibleLength = 0;
    _hasStartedAnimation = true;
    _startTyping();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  String get _visibleText {
    if (_visibleLength <= 0) return '';
    if (_visibleLength >= _target.length) return _target;
    return _target.substring(0, _visibleLength);
  }

  void _startCursorBlink() {
    _cursorTimer?.cancel();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 530), (_) {
      if (!mounted || !_shouldShowCursor) return;
      setState(() => _cursorOn = !_cursorOn);
    });
  }

  void _startTyping() {
    _timer?.cancel();
    if (_visibleLength >= _target.length) {
      if (mounted) setState(() {});
      return;
    }

    _timer = Timer.periodic(widget.tickDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_visibleLength >= _target.length) {
        timer.cancel();
        setState(() {});
        return;
      }
      setState(() {
        _visibleLength =
            (_visibleLength + widget.charsPerTick).clamp(0, _target.length);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final useTypewriter = _hasStartedAnimation || widget.animate;
    final visible = useTypewriter ? _visibleText : widget.text;
    final showCursor = _shouldShowCursor && _cursorOn;

    return Text.rich(
      TextSpan(
        children: [
          ..._buildBoldSpans(visible, widget.style, widget.boldStyle),
          if (showCursor)
            TextSpan(
              text: '|',
              style: widget.style.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

List<InlineSpan> _buildBoldSpans(
  String text,
  TextStyle style,
  TextStyle boldStyle,
) {
  if (text.isEmpty) return const [];
  final parts = text.split('**');
  if (parts.length == 1) {
    return [TextSpan(text: text, style: style)];
  }
  return [
    for (var i = 0; i < parts.length; i++)
      TextSpan(text: parts[i], style: i.isOdd ? boldStyle : style),
  ];
}

class ChatUserTextBubble extends StatelessWidget {
  const ChatUserTextBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 0.82.sw),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: AppText(
            text: text,
            style: AppTextStyles.regular(
              fontSize: 16.sp,
              color: AppColors.white,
            ).copyWith(height: 1.35),
          ),
        ),
      ),
    );
  }
}

class ChatSparkCardsRow extends StatelessWidget {
  const ChatSparkCardsRow({super.key, required this.items, this.onCardTap});

  final List<CardItem> items;
  final ValueChanged<CardItem>? onCardTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 4.w, right: 4.w),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final item = items[index];
          return _ChatSparkCard(item: item, onTap: () => onCardTap?.call(item));
        },
      ),
    );
  }
}

class _ChatSparkCard extends StatelessWidget {
  const _ChatSparkCard({required this.item, this.onTap});

  final CardItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cta = item.ctaLabel.trim().isEmpty ? 'Read' : item.ctaLabel;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _SparkCardImage(imageUrl: item.imageUrl),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.55),
                            ],
                            stops: const [0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10.w,
                      right: 10.w,
                      bottom: 10.h,
                      child: AppText(
                        text: item.title.isNotEmpty
                            ? item.title
                            : item.question,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bold(
                          fontSize: 14.sp,
                          color: AppColors.white,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            AppText(
              text: cta,
              style: AppTextStyles.semiBold(
                fontSize: 15.sp,
                color: AppColors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkCardImage extends StatelessWidget {
  const _SparkCardImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Image.asset(AppAssets.story1, fit: BoxFit.cover);
    }
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }
    return AppNetworkImage(
      imageUrl: imageUrl,
      tag: 'Chat.sparkCard',
      fit: BoxFit.cover,
      placeholder: (_) => Container(color: AppColors.lighttealcolor),
      errorBuilder: (_, _, _) =>
          Image.asset(AppAssets.story1, fit: BoxFit.cover),
    );
  }
}

class ChatTopicCardsRow extends StatelessWidget {
  const ChatTopicCardsRow({super.key, required this.items, this.onCardTap});

  final List<CardItem> items;
  final ValueChanged<CardItem>? onCardTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 248.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 4.w, right: 4.w),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final item = items[index];
          return _ChatTopicCard(item: item, onTap: () => onCardTap?.call(item));
        },
      ),
    );
  }
}

class _ChatTopicCard extends StatelessWidget {
  const _ChatTopicCard({required this.item, this.onTap});

  final CardItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = AppColors.black.withValues(alpha: 0.45);
    final cta = item.ctaLabel.trim().isEmpty ? 'Open Series' : item.ctaLabel;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 120.h,
              child: _SparkCardImage(imageUrl: item.imageUrl),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
              child: AppText(
                text: item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bold(fontSize: 17.sp),
              ),
            ),
            if (item.question.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 0),
                child: AppText(
                  text: item.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.medium(
                    fontSize: 13.sp,
                    color: subtitleColor,
                  ),
                ),
              ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: AppText(
                text: cta,
                style: AppTextStyles.semiBold(
                  fontSize: 14.sp,
                  color: AppColors.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatSuggestionSection extends StatelessWidget {
  const ChatSuggestionSection({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
          child: AppText(
            text: 'Not sure where to start?',
            style: AppTextStyles.medium(
              fontSize: 14.sp,
              color: AppColors.black.withValues(alpha: 0.45),
            ),
          ),
        ),
        SizedBox(
          height: 92.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            physics: const BouncingScrollPhysics(),
            itemCount: suggestions.length,
            separatorBuilder: (_, _) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return GestureDetector(
                onTap: () => onSuggestionTap(suggestion),
                child: Container(
                  width: 168.w,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppText(
                      text: suggestion,
                      style: AppTextStyles.medium(
                        fontSize: 15.sp,
                        color: AppColors.black,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Empty chat landing — welcome copy + prompt suggestions.
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
      child: Column(
        children: [
          SizedBox(height: 28.h),
          Image.asset(
            AppAssets.robot,
            width: 72.w,
            height: 72.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 18.h),
          AppText(
            text: 'What do you want to learn next?',
            textAlign: TextAlign.center,
            style: AppTextStyles.semiBold(
              fontSize: 22.sp,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 10.h),
          AppText(
            text:
                'Ask me for stories, Sparks, books, or anything you’re curious about.',
            textAlign: TextAlign.center,
            style: AppTextStyles.regular(
              fontSize: 15.sp,
              color: AppColors.black.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 28.h),
          Align(
            alignment: Alignment.centerLeft,
            child: AppText(
              text: 'Try asking',
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: AppColors.black.withValues(alpha: 0.45),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          ...suggestions.map(
            (suggestion) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: GestureDetector(
                onTap: () => onSuggestionTap(suggestion),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: suggestion,
                          style: AppTextStyles.medium(
                            fontSize: 15.sp,
                            color: AppColors.black,
                            height: 1.35,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18.w,
                        color: AppColors.teal,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _chatBackground,
      padding: EdgeInsets.fromLTRB(
        20.w,
        8.h,
        20.w,
        MediaQuery.of(context).padding.bottom + 12.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: AppTextStyles.regular(
                  fontSize: 16.sp,
                  color: AppColors.black,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Type here',
                  hintStyle: AppTextStyles.regular(
                    fontSize: 16.sp,
                    color: AppColors.black.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: AppColors.white,
                size: 22.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color get chatBackgroundColor => _chatBackground;
