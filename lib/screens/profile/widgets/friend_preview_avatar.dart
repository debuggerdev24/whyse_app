import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/friend/friend_details_model.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_friend_avatar.dart';

class FriendPreviewAvatar extends StatelessWidget {
  const FriendPreviewAvatar({super.key, required this.friend, this.onTap});

  final FriendPreviewItem friend;
  final VoidCallback? onTap;

  Color get _color {
    final hash = friend.id.codeUnits.fold<int>(0, (prev, c) => prev + c);
    return ProfileFriendAvatar.avatarColors[hash %
        ProfileFriendAvatar.avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final name = friend.displayLabel;
    final avatarUrl = resolveNullableNetworkImageUrl(friend.avatarUrl);

    final avatar = Container(
      width: 64.w,
      height: 64.w,
      decoration: BoxDecoration(shape: BoxShape.circle, color: _color),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: avatarUrl != null
          ? AppNetworkImage(
              imageUrl: avatarUrl,
              tag: 'FriendPreviewAvatar',
              width: 64.w,
              height: 64.w,
              fit: BoxFit.cover,
              placeholder: (_) => _initials(),
              errorCompact: true,
              errorIconOnly: true,
              errorBuilder: (_, __, ___) => _initials(),
            )
          : _initials(),
    );

    final child = SizedBox(
      width: 72.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          avatar,
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

  Widget _initials() {
    return Center(
      child: AppText(
        text: friend.initials,
        style: AppTextStyles.bold(
          fontSize: 22.sp,
          color: AppColors.white.setOpacity(0.92),
        ),
      ),
    );
  }
}
