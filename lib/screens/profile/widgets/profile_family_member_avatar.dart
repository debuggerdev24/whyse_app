import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/family/family_member_model.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_friend_avatar.dart';

class ProfileFamilyMemberAvatar extends StatelessWidget {
  const ProfileFamilyMemberAvatar({
    super.key,
    required this.familyMember,
    this.onTap,
  });

  final FamilyMember familyMember;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final member = familyMember.member;
    final name = member.displayName ?? member.username ?? '';
    final hash = member.id.codeUnits.fold<int>(0, (prev, c) => prev + c);
    final color = ProfileFriendAvatar.avatarColors[
        hash % ProfileFriendAvatar.avatarColors.length];

    final child = SizedBox(
      width: 72.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            alignment: Alignment.center,
            child: AppText(
              text: member.initials,
              style: AppTextStyles.bold(
                fontSize: 22.sp,
                color: AppColors.white.setOpacity(0.92),
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
          2.h.verticalSpace,
          AppText(
            text: familyMember.relationship,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.semibold(
              fontSize: 11,
              color: AppColors.teal,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;
    return GestureDetector(onTap: onTap, child: child);
  }
}
