import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/models/home/saved_series_model.dart';
import 'package:redstreakapp/providers/family/family_provider.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:redstreakapp/models/family/family_member_model.dart';
import 'package:redstreakapp/models/profile/profile_data_model.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_family_member_avatar.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/saved_series_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/screens/profile/friend_details_screen.dart';
import 'package:redstreakapp/screens/profile/widgets/group_block.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_friend_avatar.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_header_section.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_section_actions.dart';

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
      final gamification = context.read<GamificationProvider>();
      if (gamification.globalLeaderboard?.yourRank == null &&
          !gamification.isLoadingLeaderboard) {
        gamification.fetchLeaderboard(scope: 'global');
      }
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
                    _familyMembersBlock(context),
                    _friendsBlock(context),
                    GroupBlock(),
                    _overviewBlock(),
                    _interestsBlock(),
                    _subscriptionBlock(),
                    // _yourBooksBlock(context),
                    // _yourEBooksBlock(context),
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
                  text: 'Family',
                  style: AppTextStyles.bold(
                    fontSize: 22,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      context.pushNamed(AppRoutes.familyMembersListScreen.name),
                  child: AppText(
                    text: 'View all',
                    style: AppTextStyles.semibold(
                      fontSize: 16,
                      color: profileViewAllColor,
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
          12.w.horizontalSpace,
          ProfileDashedAddButton(
            onTap: () =>
                context.pushNamed(AppRoutes.addFamilyMemberScreen.name),
          ),
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
            AppSkeletonizer(
              child: SizedBox(
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
            text:
                provider.familyMembersError ?? 'Failed to load family members',
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
              style: AppTextStyles.semibold(
                fontSize: 14,
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMembersEmpty() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ProfileDashedAddButton(
        onTap: () => context.pushNamed(AppRoutes.addFamilyMemberScreen.name),
      ),
    );
  }

  Widget _addFamilyMemberButton(BuildContext context) {
    return ProfileMintButton(
      label: 'Add Family Members',
      onTap: () => context.pushNamed(AppRoutes.addFamilyMemberScreen.name),
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
                    fontSize: 22,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      context.pushNamed(AppRoutes.friendsListScreen.name),
                  child: AppText(
                    text: 'View all',
                    style: AppTextStyles.semibold(
                      fontSize: 16,
                      color: profileViewAllColor,
                    ),
                  ),
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
          12.w.horizontalSpace,
          ProfileDashedAddButton(
            onTap: () => context.pushNamed(AppRoutes.addFriendsScreen.name),
          ),
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
            AppSkeletonizer(
              child: SizedBox(
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
    return Align(
      alignment: Alignment.centerLeft,
      child: ProfileDashedAddButton(
        onTap: () => context.pushNamed(AppRoutes.addFriendsScreen.name),
      ),
    );
  }

  Widget _addFriendsButton(BuildContext context) {
    return ProfileMintButton(
      label: 'Add Friends',
      onTap: () => context.pushNamed(AppRoutes.addFriendsScreen.name),
    );
  }

  Widget _overviewBlock() {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final overview =
            provider.profileData?.overview ?? ProfileOverview.empty;
        final isLoading =
            provider.getProfileState == DataState.loading &&
            provider.profileData == null;

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
                  style: AppTextStyles.bold(
                    fontSize: 22,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
                14.w.verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: _profileStatCard(
                        leading: const Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFF5A623),
                          size: 26,
                        ),
                        value: isLoading ? '--' : '${overview.streak.current}',
                        label: 'Streaks',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _profileStatCard(
                        leading: const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF5B8DEF),
                          size: 24,
                        ),
                        value: isLoading
                            ? '--'
                            : '${overview.reading.completedCount}',
                        label: 'Pages Read',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _profileStatCard(
                        leading: const Icon(
                          Icons.schedule_rounded,
                          color: Color(0xFFB07CFF),
                          size: 24,
                        ),
                        value: isLoading
                            ? '--'
                            : '${_readingHours(overview.reading.totalDuration)}',
                        label: 'Hours',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _profileStatCard(
                        leading: _levelMark(
                          provider.profileData?.country ?? '',
                        ),
                        value: isLoading
                            ? '--'
                            : _levelLabel(
                                provider.profileData?.preferredLanguage ?? '',
                              ),
                        label: 'Level',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
                Row(
                  children: [
                    AppText(
                      text: 'Interests',
                      style: AppTextStyles.bold(
                        fontSize: 22,
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.pushNamed(
                        AppRoutes.editInterestsScreen.name,
                      ),
                      child: AppText(
                        text: 'Edit',
                        style: AppTextStyles.semibold(
                          fontSize: 16,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
                14.w.verticalSpace,
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F4),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: AppText(
                text: interest,
                style: AppTextStyles.medium(
                  fontSize: 14,
                  color: const Color(0xFF1C1C1E),
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
            child: AppSkeletonizer(
              child: Container(
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
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFFF5A623),
                      size: 26,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppText(
                                text: 'Free Plan (with ads)',
                                style: AppTextStyles.bold(
                                  fontSize: 16,
                                  color: const Color(0xFF1C1C1E),
                                ),
                              ),
                            ),
                            AppText(
                              text: '\$0/mo',
                              style: AppTextStyles.bold(
                                fontSize: 16,
                                color: const Color(0xFF1C1C1E),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        AppText(
                          text:
                              'Unlock a better reading experience with premium.',
                          style: AppTextStyles.regular(
                            fontSize: 13,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: AppText(
                    text: 'Upgrade',
                    style: AppTextStyles.semibold(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _yourBooksBlock(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: AppColors.white,
  //       border: Border(
  //         top: BorderSide(
  //           color: AppColors.black.withValues(alpha: 0.08),
  //           width: 1,
  //         ),
  //       ),
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               AppText(
  //                 text: 'Your Books',
  //                 style: AppTextStyles.bold(
  //                   fontSize: 20,
  //                   color: AppColors.black,
  //                 ),
  //               ),
  //               const Spacer(),
  //               GestureDetector(
  //                 behavior: HitTestBehavior.opaque,
  //                 onTap: () =>
  //                     context.pushNamed(AppRoutes.yourBooksScreen.name),
  //                 child: AppText(
  //                   text: 'See all',
  //                   style: AppTextStyles.semibold(
  //                     fontSize: 15,
  //                     color: AppColors.teal,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           12.verticalSpace,
  //           SizedBox(
  //             height: 125,
  //             width: double.maxFinite,
  //             child: ListView.separated(
  //               separatorBuilder: (context, index) => const SizedBox(width: 8),
  //               scrollDirection: Axis.horizontal,
  //               physics: const BouncingScrollPhysics(),
  //               itemCount: 10,
  //               itemBuilder: (context, index) {
  //                 return Container(
  //                   height: 120,
  //                   margin: EdgeInsets.only(bottom: 5, left: 1),
  //                   width: 80,
  //                   decoration: BoxDecoration(
  //                     color: AppColors.lightwhiteColor,
  //                     borderRadius: BorderRadius.circular(12.r),
  //                     image: DecorationImage(
  //                       image: AssetImage(AppAssets.demoBookImage),
  //                       fit: BoxFit.cover,
  //                     ),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: AppColors.black.withValues(alpha: 0.15),
  //                         spreadRadius: 2,
  //                         blurRadius: 2,
  //                         offset: const Offset(0, 2),
  //                       ),
  //                     ],
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _yourEBooksBlock(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: AppColors.white,
  //       border: Border(
  //         top: BorderSide(
  //           color: AppColors.black.withValues(alpha: 0.08),
  //           width: 1,
  //         ),
  //       ),
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               AppText(
  //                 text: 'Your eBooks',
  //                 style: AppTextStyles.bold(
  //                   fontSize: 20,
  //                   color: AppColors.black,
  //                 ),
  //               ),
  //               GestureDetector(
  //                 onTap: () =>
  //                     context.pushNamed(AppRoutes.yourBooksScreen.name),
  //                 child: AppText(
  //                   text: 'View all',
  //                   style: AppTextStyles.semibold(
  //                     fontSize: 15,
  //                     color: AppColors.teal,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           12.verticalSpace,
  //           SizedBox(
  //             height: 125,
  //             width: double.maxFinite,
  //             child: ListView.separated(
  //               separatorBuilder: (context, index) => const SizedBox(width: 8),
  //               scrollDirection: Axis.horizontal,
  //               physics: const BouncingScrollPhysics(),
  //               itemCount: 10,
  //               itemBuilder: (context, index) {
  //                 return Container(
  //                   height: 120,
  //                   margin: EdgeInsets.only(bottom: 5, left: 1),
  //                   width: 80,
  //                   decoration: BoxDecoration(
  //                     color: AppColors.lightwhiteColor,
  //                     borderRadius: BorderRadius.circular(12.r),
  //                     image: DecorationImage(
  //                       image: AssetImage(AppAssets.demoBookImage),
  //                       fit: BoxFit.cover,
  //                     ),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: AppColors.black.withValues(alpha: 0.15),
  //                         spreadRadius: 2,
  //                         blurRadius: 2,
  //                         offset: const Offset(0, 2),
  //                       ),
  //                     ],
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _mySeriesListBlock() {
    return Consumer<SavedSeriesProvider>(
      builder: (context, provider, _) {
        final list = provider.savedSeriesList;
        final isLoading = provider.isSavedSeriesLoading;
        final hasFailed = provider.savedSeriesFailed;

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
                        fontSize: 22,
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.pushNamed(
                        AppRoutes.mySavedSeriesScreen.name,
                      ),
                      child: AppText(
                        text: 'View all',
                        style: AppTextStyles.semibold(
                          fontSize: 16,
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
              child: AppSkeletonizer(
                child: Container(
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

    final cardWidth =
        (MediaQuery.sizeOf(context).width - 32.w - 12.w) / 2;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(list.length > 5 ? 5 : list.length, (index) {
          final item = list[index];
          return _SavedSeriesCard(
            item: item,
            width: cardWidth,
            onTap: () {
              final topicId = item.topic.id;
              final homeProvider = context.read<HomeProvider>();
              homeProvider.beginTopicStoryDetailsLoad(topicId: topicId);
              homeProvider.getTopicStoryDetails(topicId: topicId);
              context.pushNamed(
                AppRoutes.createdStorySummaryScreen.name,
                extra: topicId,
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
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 12.w, 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F8),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          SizedBox(height: 10.h),
          AppText(
            text: value,
            style: AppTextStyles.bold(
              fontSize: 22,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          AppText(
            text: label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.regular(
              fontSize: 13,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}

int _readingHours(ProfileReadingDuration duration) {
  final unit = duration.unit.toLowerCase();
  if (unit.startsWith('hour')) return duration.value;
  if (unit.startsWith('minute')) return duration.value ~/ 60;
  return duration.value;
}

String _levelLabel(String language) {
  final value = language.trim();
  return value.isEmpty ? '—' : value;
}

Widget _levelMark(String country) {
  final normalized = country.trim().toLowerCase();
  if (normalized == 'us' || normalized.contains('united states')) {
    return const Text('🇺🇸', style: TextStyle(fontSize: 22));
  }
  return const Icon(
    Icons.flag_rounded,
    color: Color(0xFFE24B4B),
    size: 24,
  );
}

class _SavedSeriesCard extends StatelessWidget {
  const _SavedSeriesCard({required this.item, required this.width, this.onTap});

  final SavedSeriesItem item;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final topic = item.topic;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 240,
        margin: EdgeInsets.only(right: 12.w),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(
              imageUrl: topic.thumbnailUrl,
              tag: 'Profile.savedTopic',
              placeholder: (_) => _storyImageShimmer(),
              errorCompact: true,
              errorIconOnly: true,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000000)],
                  stops: [0.35, 1],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
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
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: isToggling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.teal,
                              ),
                            )
                          : const Icon(
                              Icons.bookmark_rounded,
                              size: 18,
                              color: Color(0xFF1C1C1E),
                            ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: topic.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bold(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    text: '0 out of ${topic.storiesCount} Reading',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regular(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: AppText(
                        text: 'Start Reading',
                        style: AppTextStyles.semibold(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
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

Widget _storyImageShimmer() {
  return AppSkeletonizer(
    child: Container(
      width: double.infinity,
      height: 132.w,
      color: AppColors.shimmerBaseColor,
    ),
  );
}

