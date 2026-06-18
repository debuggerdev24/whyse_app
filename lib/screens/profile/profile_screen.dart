import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/models/home/saved_series_model.dart';
import 'package:redstreakapp/providers/family/family_provider.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:redstreakapp/models/family/family_member_model.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_family_member_avatar.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/saved_series_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/screens/profile/friend_details_screen.dart';
import 'package:redstreakapp/screens/profile/widgets/group_block.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_friend_avatar.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_header_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FriendProvider>().getFriends();
      context.read<FamilyProvider>().getFamilyMembersPreview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProfileHeaderSection(),
          Expanded(
            child: ColoredBox(
              color: AppColors.white,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _profileDetailsBlock(context),
                    _familyMembersBlock(context),
                    _friendsBlock(context),
                    GroupBlock(),
                    _overviewBlock(),
                    _interestsBlock(),
                    _subscriptionBlock(),
                    _yourBooksBlock(context),
                    _yourEBooksBlock(context),
                    _mySeriesListBlock(),
                    SizedBox(height: 24.w),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileDetailsBlock(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        if (provider.getProfileState == DataState.loading) {
          return const _ProfileDetailsBlockShimmer();
        }

        if (provider.profileData == null ||
            provider.getProfileState == DataState.failed) {
          return Center(child: Text('Failed to load profile data'));
        }

        return Container(
          padding: EdgeInsets.fromLTRB(27.w, 20.h, 27.w, 20.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: provider.profileData!.displayName,
                    style: AppTextStyles.bold(
                      fontSize: 20,
                      color: AppColors.black,
                    ),
                  ),
                  Row(
                    children: [
                      AppText(
                        text: '@${provider.profileData!.username}',
                        style: AppTextStyles.bold(
                          fontSize: 14,
                          color: AppColors.black.withValues(alpha: 0.6),
                        ),
                      ),
                      AppText(
                        text: ' • Joined -',
                        style: AppTextStyles.semibold(
                          fontSize: 14,
                          color: AppColors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Consumer<FriendProvider>(
                builder: (context, provider, _) {
                  final count = provider.getFriendsState == DataState.success
                      ? provider.friendsList.length
                      : 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: '$count',
                        style: AppTextStyles.bold(
                          fontSize: 20,
                          color: AppColors.black,
                        ),
                      ),
                      AppText(
                        text: 'Friends',
                        style: AppTextStyles.bold(
                          fontSize: 14,
                          color: AppColors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _familyMembersBlock(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.black.setOpacity(0.08), width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppText(
                  text: 'Family Members',
                  style: AppTextStyles.bold(
                    fontSize: 20,
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.pushNamed(
                    AppRoutes.familyMembersListScreen.name,
                  ),
                  child: AppText(
                    text: 'View all',
                    style: AppTextStyles.semibold(
                      fontSize: 15,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),
            16.w.verticalSpace,
            Consumer<FamilyProvider>(
              builder: (context, provider, _) {
                return _buildFamilyMembersContent(context, provider);
              },
            ),
            16.w.verticalSpace,
            _addFamilyMemberButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMembersContent(
    BuildContext context,
    FamilyProvider provider,
  ) {
    switch (provider.familyMembersState) {
      case DataState.loading:
        return _buildFamilyMembersShimmer();
      case DataState.failed:
        return _buildFamilyMembersError(context, provider);
      case DataState.success:
        final members = provider.profileFamilyMembers;
        if (members.isEmpty) {
          return _buildFamilyMembersEmpty();
        }
        return _buildFamilyMembersList(context, members);
    }
  }

  Widget _buildFamilyMembersList(
    BuildContext context,
    List<FamilyMember> members,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < members.length; i++) ...[
            if (i > 0) 16.w.horizontalSpace,
            ProfileFamilyMemberAvatar(
              familyMember: members[i],
              onTap: () => context.pushNamed(
                AppRoutes.friendDetailsScreen.name,
                extra: FriendDetailsScreenParams(
                  friendId: members[i].member.id,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFamilyMembersShimmer() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) 16.w.horizontalSpace,
            AppSkeletonizer(child: SizedBox(
                width: 72.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    8.h.verticalSpace,
                    Container(
                      width: 52.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    4.h.verticalSpace,
                    Container(
                      width: 40.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFamilyMembersError(
    BuildContext context,
    FamilyProvider provider,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          AppText(
            text: provider.familyMembersError ?? 'Failed to load family members',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium(
              fontSize: 13,
              color: AppColors.black.setOpacity(0.5),
            ),
          ),
          8.h.verticalSpace,
          GestureDetector(
            onTap: () => provider.getFamilyMembersPreview(forceRefresh: true),
            child: AppText(
              text: 'Retry',
              style: AppTextStyles.semibold(fontSize: 14, color: AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMembersEmpty() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          Icon(
            Icons.family_restroom_outlined,
            size: 36.w,
            color: AppColors.black.setOpacity(0.2),
          ),
          8.h.verticalSpace,
          AppText(
            text: 'No family members yet',
            style: AppTextStyles.semibold(
              fontSize: 14,
              color: AppColors.black.setOpacity(0.45),
            ),
          ),
          4.h.verticalSpace,
          AppText(
            text: 'Add family from a friend\'s profile',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium(
              fontSize: 12,
              color: AppColors.black.setOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addFamilyMemberButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () =>
            context.pushNamed(AppRoutes.addFamilyMemberScreen.name),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          backgroundColor: AppColors.white,
          side: BorderSide(color: AppColors.black.setOpacity(0.15)),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.family_restroom_outlined,
              size: 22.sp,
              color: AppColors.black,
            ),
            16.w.horizontalSpace,
            AppText(
              text: 'Add Family Member',
              style: AppTextStyles.semibold(
                fontSize: 16,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _friendsBlock(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.black.setOpacity(0.08), width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppText(
                  text: 'Friends',
                  style: AppTextStyles.bold(
                    fontSize: 20,
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                Consumer<FriendProvider>(
                  builder: (context, provider, _) {
                    if (provider.getFriendsState == DataState.success &&
                        provider.friendsList.isNotEmpty) {
                      return GestureDetector(
                        onTap: () =>
                            context.pushNamed(AppRoutes.friendsListScreen.name),
                        child: AppText(
                          text: 'View all',
                          style: AppTextStyles.semibold(
                            fontSize: 15,
                            color: AppColors.teal,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            16.w.verticalSpace,
            Consumer<FriendProvider>(
              builder: (context, provider, _) {
                return _buildFriendsContent(context, provider);
              },
            ),
            16.w.verticalSpace,
            _addFriendsButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsContent(BuildContext context, FriendProvider provider) {
    switch (provider.getFriendsState) {
      case DataState.loading:
        return _buildFriendsShimmer();
      case DataState.failed:
        return _buildFriendsError(context, provider);
      case DataState.success:
        if (provider.friendsList.isEmpty) {
          return _buildFriendsEmpty();
        }
        return _buildFriendsList(provider.friendsList);
    }
  }

  Widget _buildFriendsList(List<FriendResponse> friends) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < friends.length; i++) ...[
            if (i > 0) 16.w.horizontalSpace,
            GestureDetector(
              onTap: () => context.pushNamed(
                AppRoutes.friendDetailsScreen.name,
                extra: FriendDetailsScreenParams(
                  friendId: friends[i].friend.id,
                ),
              ),
              child: ProfileFriendAvatar(friend: friends[i].friend),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFriendsShimmer() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) 16.w.horizontalSpace,
            AppSkeletonizer(child: SizedBox(
                width: 72.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    8.h.verticalSpace,
                    Container(
                      width: 52.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFriendsError(BuildContext context, FriendProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 32.w,
            color: AppColors.black.setOpacity(0.25),
          ),
          8.h.verticalSpace,
          AppText(
            text: provider.getFriendsError ?? 'Failed to load friends',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium(
              fontSize: 13,
              color: AppColors.black.setOpacity(0.5),
            ),
          ),
          12.h.verticalSpace,
          GestureDetector(
            onTap: () => context.read<FriendProvider>().getFriends(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.teal.setOpacity(0.4)),
              ),
              child: AppText(
                text: 'Retry',
                style: AppTextStyles.semibold(
                  fontSize: 13,
                  color: AppColors.teal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsEmpty() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 36.w,
            color: AppColors.black.setOpacity(0.2),
          ),
          8.h.verticalSpace,
          AppText(
            text: 'No friends yet',
            style: AppTextStyles.semibold(
              fontSize: 14,
              color: AppColors.black.setOpacity(0.45),
            ),
          ),
          4.h.verticalSpace,
          AppText(
            text: 'Add friends to start reading together',
            style: AppTextStyles.medium(
              fontSize: 12,
              color: AppColors.black.setOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addFriendsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => context.pushNamed(AppRoutes.addFriendsScreen.name),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          backgroundColor: AppColors.white,
          side: BorderSide(color: AppColors.black.setOpacity(0.15)),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              size: 22.sp,
              color: AppColors.black,
            ),
            16.w.horizontalSpace,
            AppText(
              text: 'Add Friends',
              style: AppTextStyles.semibold(
                fontSize: 16,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overviewBlock() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.black.setOpacity(0.08), width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'Overview',
              style: AppTextStyles.bold(fontSize: 20, color: AppColors.black),
            ),
            16.w.verticalSpace,
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _profileStatCard(
                      leading: SvgIcon(
                        AppAssets.thunder,
                        size: 28.w,
                        color: AppColors.orangeColor,
                      ),
                      value: '263',
                      label: 'Streaks',
                    ),
                  ),
                  16.w.horizontalSpace,
                  Expanded(
                    child: _profileStatCard(
                      leading: Icon(
                        Icons.description_outlined,
                        size: 28.sp,
                        color: AppColors.black.setOpacity(0.55),
                      ),
                      value: '450',
                      label: 'Pages Read',
                    ),
                  ),
                ],
              ),
            ),
            16.w.verticalSpace,
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _profileStatCard(
                      leading: Icon(
                        Icons.schedule_outlined,
                        size: 28.sp,
                        color: AppColors.black.setOpacity(0.55),
                      ),
                      value: '60',
                      label: 'Hours',
                    ),
                  ),
                  16.w.horizontalSpace,
                  Expanded(
                    child: _profileStatCard(
                      leading: Text('🇺🇸', style: TextStyle(fontSize: 26.sp)),
                      value: 'A1',
                      label: 'Level',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _interestsBlock() {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.black.setOpacity(0.08),
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Interests',
                  style: AppTextStyles.bold(
                    fontSize: 20,
                    color: AppColors.black,
                  ),
                ),
                16.w.verticalSpace,
                _buildInterestsContent(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInterestsContent(
    BuildContext context,
    ProfileProvider provider,
  ) {
    if (provider.getProfileState == DataState.loading) {
      return _buildInterestsShimmer();
    }

    if (provider.getProfileState == DataState.failed) {
      return _buildInterestsError(context, provider);
    }

    final interests = provider.profileData?.interests ?? [];
    if (interests.isEmpty) {
      return _buildInterestsEmpty();
    }

    return Wrap(
      spacing: 8.r,
      runSpacing: 12.r,
      children: interests
          .map(
            (interest) => Container(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.extealighttealcolor,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: AppText(
                text: interest,
                style: AppTextStyles.semibold(
                  fontSize: 13,
                  color: AppColors.teal,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildInterestsShimmer() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: List.generate(4, (i) {
          final widths = [72.0, 88.0, 64.0, 80.0];
          return Padding(
            padding: EdgeInsets.only(right: i < 3 ? 12.w : 0),
            child: AppSkeletonizer(child: Container(
                width: widths[i].w,
                height: 38.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInterestsError(BuildContext context, ProfileProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 30.w,
            color: AppColors.black.setOpacity(0.25),
          ),
          8.h.verticalSpace,
          AppText(
            text: provider.getProfileError ?? 'Failed to load interests',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium(
              fontSize: 13,
              color: AppColors.black.setOpacity(0.5),
            ),
          ),
          12.h.verticalSpace,
          GestureDetector(
            onTap: () => context.read<ProfileProvider>().getProfile(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.teal.setOpacity(0.4)),
              ),
              child: AppText(
                text: 'Retry',
                style: AppTextStyles.semibold(
                  fontSize: 13,
                  color: AppColors.teal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsEmpty() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          Icon(
            Icons.interests_outlined,
            size: 34.w,
            color: AppColors.black.setOpacity(0.2),
          ),
          8.h.verticalSpace,
          AppText(
            text: 'No interests added yet',
            style: AppTextStyles.semibold(
              fontSize: 14,
              color: AppColors.black.setOpacity(0.45),
            ),
          ),
          4.h.verticalSpace,
          AppText(
            text: 'Add interests to personalise your experience',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium(
              fontSize: 12,
              color: AppColors.black.setOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subscriptionBlock() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'Subscription',
              style: AppTextStyles.bold(fontSize: 20, color: AppColors.black),
            ),
            11.verticalSpace,
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightwhiteColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.black.withValues(alpha: 0.08),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: AppText(
                        text: 'Free Plan (with ads)',
                        style: AppTextStyles.bold(
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    AppText(
                      text: '\$0/mo',
                      style: AppTextStyles.bold(
                        fontSize: 16,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            16.verticalSpace,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: const StadiumBorder(),
                ),
                child: AppText(
                  text: 'Upgrade',
                  style: AppTextStyles.semibold(
                    fontSize: 15,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _yourBooksBlock(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppText(
                  text: 'Your Books',
                  style: AppTextStyles.bold(
                    fontSize: 20,
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      context.pushNamed(AppRoutes.yourBooksScreen.name),
                  child: AppText(
                    text: 'See all',
                    style: AppTextStyles.semibold(
                      fontSize: 15,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),
            12.verticalSpace,
            SizedBox(
              height: 125,
              width: double.maxFinite,
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    height: 120,
                    margin: EdgeInsets.only(bottom: 5, left: 1),
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.lightwhiteColor,
                      borderRadius: BorderRadius.circular(12.r),
                      image: DecorationImage(
                        image: AssetImage(AppAssets.demoBookImage),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.15),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _yourEBooksBlock(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.black.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: 'Your eBooks',
                  style: AppTextStyles.bold(
                    fontSize: 20,
                    color: AppColors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      context.pushNamed(AppRoutes.yourBooksScreen.name),
                  child: AppText(
                    text: 'View all',
                    style: AppTextStyles.semibold(
                      fontSize: 15,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),
            12.verticalSpace,
            SizedBox(
              height: 125,
              width: double.maxFinite,
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    height: 120,
                    margin: EdgeInsets.only(bottom: 5, left: 1),
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.lightwhiteColor,
                      borderRadius: BorderRadius.circular(12.r),
                      image: DecorationImage(
                        image: AssetImage(AppAssets.demoBookImage),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.15),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mySeriesListBlock() {
    return Consumer<SavedSeriesProvider>(
      builder: (context, provider, _) {
        final list = provider.savedSeriesList;
        final isLoading = provider.isSavedSeriesLoading;
        final hasFailed = provider.savedSeriesFailed;
        final hasItems = list != null && list.isNotEmpty;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.black.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppText(
                      text: 'My Series List',
                      style: AppTextStyles.bold(
                        fontSize: 20,
                        color: AppColors.black,
                      ),
                    ),
                    const Spacer(),
                    if (hasItems)
                      GestureDetector(
                        onTap: () => context.pushNamed(
                          AppRoutes.mySavedSeriesScreen.name,
                        ),
                        child: AppText(
                          text: 'See all',
                          style: AppTextStyles.semibold(
                            fontSize: 15,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                  ],
                ),
                12.verticalSpace,
                _buildSeriesContent(
                  context,
                  provider,
                  list,
                  isLoading,
                  hasFailed,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeriesContent(
    BuildContext context,
    SavedSeriesProvider provider,
    List<SavedSeriesItem>? list,
    bool isLoading,
    bool hasFailed,
  ) {
    if (isLoading && list == null) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: List.generate(
            3,
            (i) => Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: AppSkeletonizer(child: Container(
                  width: 210.w,
                  height: 240.w,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerBaseColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (hasFailed) {
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 32.w,
                color: AppColors.black.setOpacity(0.25),
              ),
              8.h.verticalSpace,
              AppText(
                text:
                    provider.savedSeriesError ?? 'Failed to load saved series',
                textAlign: TextAlign.center,
                style: AppTextStyles.medium(
                  fontSize: 13,
                  color: AppColors.black.setOpacity(0.5),
                ),
              ),
              12.h.verticalSpace,
              GestureDetector(
                onTap: () =>
                    context.read<SavedSeriesProvider>().getMySeriesList(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.teal.setOpacity(0.4)),
                  ),
                  child: AppText(
                    text: 'Retry',
                    style: AppTextStyles.semibold(
                      fontSize: 13,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (list == null || list.isEmpty) {
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            children: [
              Icon(
                Icons.bookmark_border_rounded,
                size: 36.w,
                color: AppColors.black.setOpacity(0.2),
              ),
              8.h.verticalSpace,
              AppText(
                text: 'No saved series yet',
                style: AppTextStyles.semibold(
                  fontSize: 14,
                  color: AppColors.black.setOpacity(0.45),
                ),
              ),
              4.h.verticalSpace,
              AppText(
                text: 'Series you save will appear here',
                style: AppTextStyles.medium(
                  fontSize: 12,
                  color: AppColors.black.setOpacity(0.35),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(list.length > 5 ? 5 : list.length, (index) {
          final item = list[index];
          return _SavedSeriesCard(
            item: item,
            onTap: () {
              context.read<HomeProvider>().getTopicStoryDetails(
                topicId: item.topic.id,
              );
              context.pushNamed(
                AppRoutes.createdStorySummaryScreen.name,
                extra: item.topic.id,
              );
            },
          );
        }),
      ),
    );
  }

  Widget _profileStatCard({
    required Widget leading,
    required String value,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightwhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.black.setOpacity(0.08)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 36.w,
              child: Center(child: leading),
            ),
            10.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: value,
                    style: AppTextStyles.bold(
                      fontSize: 20,
                      color: AppColors.black,
                    ),
                  ),
                  4.w.verticalSpace,
                  AppText(
                    text: label,
                    style: AppTextStyles.medium(
                      fontSize: 12,
                      color: AppColors.black.setOpacity(0.48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedSeriesCard extends StatelessWidget {
  const _SavedSeriesCard({required this.item, this.onTap});

  final SavedSeriesItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final topic = item.topic;
    final subtitleColor = AppColors.black.setOpacity(0.45);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210.w,
        margin: EdgeInsets.only(right: 10.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.setOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child: SizedBox(
                    height: 132.w,
                    width: double.infinity,
                    child: AppNetworkImage(
                      imageUrl: topic.thumbnailUrl,
                      tag: 'Profile.savedTopic',
                      placeholder: (_) => _storyImageShimmer(),
                      errorCompact: true,
                      errorIconOnly: true,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Builder(
                    builder: (context) {
                      final ssp = context.watch<SavedSeriesProvider>();
                      final isToggling = ssp.isTopicListToggling(topic.id);
                      return GestureDetector(
                        onTap: isToggling
                            ? null
                            : () async {
                                final result = await ssp.toggleTopic(
                                  topicId: topic.id,
                                  onFailed: (err) {
                                    if (context.mounted) {
                                      AppToast.error(context, err);
                                    }
                                  },
                                );
                                if (result != null && context.mounted) {
                                  AppToast.success(
                                    context,
                                    result.isInMyList
                                        ? 'Added to your list'
                                        : 'Removed from your list',
                                  );
                                }
                              },
                        child: Container(
                          width: 32.h,
                          height: 32.h,
                          margin: EdgeInsets.only(top: 10.w, right: 10.w),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: isToggling
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.teal,
                                  ),
                                )
                              : Icon(
                                  Icons.bookmark_rounded,
                                  size: 20.sp,
                                  color: AppColors.teal,
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 13.w, 14.w, 2.w),
              child: AppText(
                text: topic.title,
                style: AppTextStyles.bold(fontSize: 16.sp),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: AppText(
                text: '${topic.storiesCount} Readings',
                style: AppTextStyles.medium(
                  fontSize: 12.sp,
                  color: subtitleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppButton(
              margin: EdgeInsets.fromLTRB(14.w, 12.w, 14.w, 16.w),
              onTap: () => onTap?.call(),
              text: "Start Reading",
            ),
          ],
        ),
      ),
    );
  }
}

Widget _storyImageShimmer() {
  return AppSkeletonizer(
    child: Container(
      width: double.infinity,
      height: 132.w,
      color: AppColors.shimmerBaseColor,
    ),
  );
}

class _ProfileDetailsBlockShimmer extends StatelessWidget {
  const _ProfileDetailsBlockShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(27, 20, 27, 20),
      child: AppSkeletonizer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// LEFT SIDE (Name + Username)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 140, height: 20),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _box(width: 100, height: 14),
                    const SizedBox(width: 6),
                    _box(width: 90, height: 14),
                  ],
                ),
              ],
            ),

            /// RIGHT SIDE (Friends count)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(width: 40, height: 20),
                const SizedBox(height: 6),
                _box(width: 60, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _box({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
