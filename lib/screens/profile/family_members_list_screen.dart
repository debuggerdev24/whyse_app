import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/family/family_member_model.dart';
import 'package:redstreakapp/providers/family/family_provider.dart';
import 'package:redstreakapp/screens/profile/friend_details_screen.dart';

class FamilyMembersListScreen extends StatelessWidget {
  const FamilyMembersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        title: const AppText(text: 'Family Members'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
      ),
      body: Column(
        children: [
          Divider(color: AppColors.black.setOpacity(0.1), height: 1),
          Expanded(
            child: Consumer<FamilyProvider>(
              builder: (context, provider, _) {
                final members = provider.familyMembers;
                if (members.isEmpty) return const _EmptyState();

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 20.h),
                  physics: const BouncingScrollPhysics(),
                  itemCount: members.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 24.w,
                    thickness: 1,
                    color: AppColors.black.setOpacity(0.08),
                  ),
                  itemBuilder: (context, index) {
                    return _FamilyMemberTile(member: members[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberTile extends StatelessWidget {
  const _FamilyMemberTile({required this.member});

  final FamilyMember member;

  static const List<Color> _avatarColors = [
    Color(0xFF53C3BF),
    Color(0xFFD7B086),
    Color(0xFF66C99D),
    Color(0xFF7B9FD4),
    Color(0xFFD48B8B),
    Color(0xFFA68BD4),
  ];

  Color get _avatarColor {
    final hash =
        member.member.id.codeUnits.fold<int>(0, (prev, c) => prev + c);
    return _avatarColors[hash % _avatarColors.length];
  }

  void _openProfile(BuildContext context) {
    context.pushNamed(
      AppRoutes.friendDetailsScreen.name,
      extra: FriendDetailsScreenParams(friendId: member.member.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = member.member;
    return GestureDetector(
      onTap: () => _openProfile(context),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: _avatarColor,
            child: AppText(
              text: user.initials,
              style: AppTextStyles.bold(
                fontSize: 14.sp,
                color: AppColors.white,
              ),
            ),
          ),
          16.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: user.displayName ?? user.username ?? '',
                  style: AppTextStyles.semibold(
                    fontSize: 16.sp,
                    color: AppColors.black,
                  ),
                ),
                6.h.verticalSpace,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.extealighttealcolor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: AppText(
                    text: member.relationship,
                    style: AppTextStyles.semibold(
                      fontSize: 12.sp,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 24.sp,
            color: AppColors.black.setOpacity(0.35),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.family_restroom_outlined,
            size: 48.w,
            color: AppColors.black.setOpacity(0.3),
          ),
          12.verticalSpace,
          AppText(
            text: 'No family members yet',
            style: AppTextStyles.medium(fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
}
