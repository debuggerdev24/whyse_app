import 'package:cached_network_image/cached_network_image.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:shimmer/shimmer.dart';

class ProfileFriendAvatar extends StatelessWidget {
  const ProfileFriendAvatar({super.key, required this.friend, this.onTap});

  final FriendUser friend;
  final VoidCallback? onTap;

  static const List<Color> avatarColors = [
    Color(0xFF167C80),
    Color(0xFFE8D9C4),
    Color(0xFFFFB37A),
    Color(0xFFFFA8C5),
    Color(0xFF6B8E9B),
    Color(0xFF53C3BF),
    Color(0xFFD7B086),
    Color(0xFF66C99D),
  ];

  Color get _color {
    final hash = friend.id.codeUnits.fold<int>(0, (prev, c) => prev + c);
    return avatarColors[hash % avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final name = friend.displayName ?? friend.username ?? '';
    final child = SizedBox(
      width: 72.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _color),
              // alignment: Alignment.center,
              child: friend.avatarUrl != null
                  ? CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: friend.avatarUrl!,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.shimmerBaseColor,
                        highlightColor: AppColors.shimmerHighlightColor,
                        child: Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _color,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 64.w,
                        height: 64.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _color,
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          text: friend.initials,
                          style: AppTextStyles.bold(
                            fontSize: 22.sp,
                            color: AppColors.white.setOpacity(0.92),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: AppText(
                        text: friend.initials,
                        style: AppTextStyles.bold(
                          fontSize: 22.sp,
                          color: AppColors.white.setOpacity(0.92),
                        ),
                      ),
                    ),
            ),
          ),
          8.h.verticalSpace,
          AppText(
            text: name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.medium(fontSize: 12, color: AppColors.black),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}
