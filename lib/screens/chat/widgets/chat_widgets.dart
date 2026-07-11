import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/screens/chat/models/chat_message.dart';

const Color _chatBackground = Color(0xFFF9F6F3);
const Color _closeButtonBg = Color(0xFFF0F0F0);

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key, required this.onClose});

  final VoidCallback onClose;

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
      //             AppAssets.close,
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
  const ChatBotTextBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 0.82.sw),
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
              child: AppText(
                text: text,
                style: AppTextStyles.regular(
                  fontSize: 16.sp,
                  color: AppColors.black,
                ).copyWith(height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
  const ChatSparkCardsRow({super.key, required this.items, this.onReadTap});

  final List<ChatSparkItem> items;
  final ValueChanged<ChatSparkItem>? onReadTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 4.w, right: 20.w),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final item = items[index];
          return _ChatSparkCard(
            item: item,
            onReadTap: () => onReadTap?.call(item),
          );
        },
      ),
    );
  }
}

class _ChatSparkCard extends StatelessWidget {
  const _ChatSparkCard({required this.item, this.onReadTap});

  final ChatSparkItem item;
  final VoidCallback? onReadTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  Positioned(
                    left: 10.w,
                    right: 10.w,
                    bottom: 10.h,
                    child: AppText(
                      text: item.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bold(
                        fontSize: 14.sp,
                        color: AppColors.white,
                        height: 1.25,
                      ),
                    ),
                  ),
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
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              GestureDetector(
                onTap: onReadTap,
                child: AppText(
                  text: 'Read',
                  style: AppTextStyles.semiBold(
                    fontSize: 15.sp,
                    color: AppColors.teal,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.thumb_up_outlined,
                size: 20.w,
                color: AppColors.black.withValues(alpha: 0.45),
              ),
              SizedBox(width: 12.w),
              Icon(
                Icons.thumb_down_outlined,
                size: 20.w,
                color: AppColors.black.withValues(alpha: 0.45),
              ),
            ],
          ),
        ],
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
  const ChatTopicCardsRow({
    super.key,
    required this.items,
    this.onCardTap,
    this.onAddToListTap,
  });

  final List<ChatTopicItem> items;
  final ValueChanged<ChatTopicItem>? onCardTap;
  final ValueChanged<ChatTopicItem>? onAddToListTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 248.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 4.w, right: 20.w),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final item = items[index];
          return _ChatTopicCard(
            item: item,
            onTap: () => onCardTap?.call(item),
            onAddToListTap: () => onAddToListTap?.call(item),
          );
        },
      ),
    );
  }
}

class _ChatTopicCard extends StatelessWidget {
  const _ChatTopicCard({required this.item, this.onTap, this.onAddToListTap});

  final ChatTopicItem item;
  final VoidCallback? onTap;
  final VoidCallback? onAddToListTap;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = AppColors.black.withValues(alpha: 0.45);

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
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 0),
              child: AppText(
                text: '${item.storyCount} Stories',
                style: AppTextStyles.medium(
                  fontSize: 13.sp,
                  color: subtitleColor,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: GestureDetector(
                onTap: onAddToListTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    SvgIcon(
                      AppAssets.bookmark,
                      size: 16.w,
                      color: AppColors.black.withValues(alpha: 0.45),
                    ),
                    SizedBox(width: 6.w),
                    AppText(
                      text: 'Add to List',
                      style: AppTextStyles.semiBold(
                        fontSize: 14.sp,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
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
