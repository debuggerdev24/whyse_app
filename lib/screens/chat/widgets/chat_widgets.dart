import 'dart:async';
import 'dart:ui';

import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/chat/chat_history_model.dart';

const Color _chatInk = Color(0xFF1A1A1A);

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
    this.animate = false,
    this.showCursor = false,
  });

  final String text;
  final bool animate;
  final bool showCursor;

  @override
  Widget build(BuildContext context) {
    final regularStyle = AppTextStyles.regular(
      fontSize: 15,
      color: _chatInk,
    ).copyWith(height: 1.35);
    final boldStyle = AppTextStyles.bold(
      fontSize: 15,
      color: _chatInk,
    ).copyWith(height: 1.35);

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: ChatTypewriterText(
            text: text,
            style: regularStyle,
            boldStyle: boldStyle,
            animate: animate,
            showCursor: showCursor,
          ),
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
        _visibleLength = (_visibleLength + widget.charsPerTick).clamp(
          0,
          _target.length,
        );
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
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(22),
          ),
          child: AppText(
            text: text,
            style: AppTextStyles.regular(
              fontSize: 15,
              color: Colors.white,
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
          padding: const EdgeInsets.only(bottom: 10),
          child: AppText(
            text: 'Not sure where to start?',
            style: AppTextStyles.medium(
              fontSize: 13,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: suggestions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return GestureDetector(
                onTap: () => onSuggestionTap(suggestion),
                child: Container(
                  width: 168,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppText(
                      text: suggestion,
                      style: AppTextStyles.medium(
                        fontSize: 14,
                        color: _chatInk,
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
    this.bottomReserve = 80,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;
  final double bottomReserve;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomReserve + 16),
      child: Column(
        children: [
          const SizedBox(height: 28),
          Image.asset(
            AppAssets.robot,
            width: 72,
            height: 72,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 18),
          AppText(
            text: 'What do you want to learn next?',
            textAlign: TextAlign.center,
            style: AppTextStyles.semibold(fontSize: 22, color: _chatInk),
          ),
          const SizedBox(height: 10),
          AppText(
            text:
                'Ask me for stories, Sparks, books, or anything you’re curious about.',
            textAlign: TextAlign.center,
            style: AppTextStyles.regular(
              fontSize: 14,
              color: const Color(0xFF8E8E93),
            ).copyWith(height: 1.35),
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: AppText(
              text: 'Try asking',
              style: AppTextStyles.medium(
                fontSize: 13,
                color: const Color(0xFF8E8E93),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...suggestions.map(
            (suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onSuggestionTap(suggestion),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: suggestion,
                          style: AppTextStyles.medium(
                            fontSize: 14,
                            color: _chatInk,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
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
    this.scrolling = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool scrolling;

  static const double height = 54;

  @override
  Widget build(BuildContext context) {
    final outerRadius = BorderRadius.circular(height);
    final innerRadius = BorderRadius.circular(height - 1.4);

    return TweenAnimationBuilder<double>(
      tween: Tween(end: scrolling ? 1 : 0),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        final sigma = 8 + (4 * t);
        return Container(
          height: height,
          padding: const EdgeInsets.all(1.4),
          decoration: BoxDecoration(
            borderRadius: outerRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.95),
                Colors.white.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0.78),
              ],
              stops: const [0.0, 0.46, 1.0],
            ),
          ),
          child: ClipRRect(
            borderRadius: innerRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0x2EFFFFFF),
                          Color(0x1AFFFFFF),
                          Color(0x12FFFFFF),
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 0,
                  left: 18,
                  right: 18,
                  height: 1,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0x00FFFFFF),
                            Color(0xF5FFFFFF),
                            Color(0x00FFFFFF),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-1.15 + (1.5 * t), -1),
                        end: Alignment(0.35 + t, 1.1),
                        colors: [
                          const Color(0x00FFFFFF),
                          Colors.white.withValues(alpha: 0.08 * t),
                          const Color(0x00FFFFFF),
                        ],
                      ),
                    ),
                  ),
                ),
                child!,
              ],
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                cursorColor: AppColors.teal,
                style: AppTextStyles.regular(fontSize: 15, color: _chatInk),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Type here',
                  hintStyle: AppTextStyles.regular(
                    fontSize: 15,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Softens messages as they pass the composer while the list is moving.
class ChatScrollEdge extends StatelessWidget {
  const ChatScrollEdge({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: active ? 1 : 0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: ClipRect(
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: _fadeShader,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const ColoredBox(color: Color(0x33F2F2F7)),
            ),
          ),
        ),
      ),
    );
  }
}

Shader _fadeShader(Rect bounds) {
  return const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00000000), Color(0xFFFFFFFF)],
    stops: [0.0, 0.72],
  ).createShader(bounds);
}

Color get chatBackgroundColor => AppColors.backgroundColor;
