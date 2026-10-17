import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/models/friend/friend_details_model.dart';
import 'package:redstreakapp/models/profile/profile_data_model.dart';
import 'package:redstreakapp/providers/family/family_provider.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/screens/group/widget/group_image_widget.dart';
import 'package:redstreakapp/services/profile/friend_api_service.dart';
import 'package:redstreakapp/screens/profile/friends_list_screen_params.dart';
import 'package:redstreakapp/screens/profile/user_profile_groups_list_screen_params.dart';
import 'package:redstreakapp/screens/profile/user_profile_topics_list_screen_params.dart';
import 'package:redstreakapp/screens/profile/widgets/add_family_member_bottom_sheet.dart';
import 'package:redstreakapp/screens/profile/widgets/friend_details_header.dart';
import 'package:redstreakapp/screens/profile/widgets/friend_preview_avatar.dart';

class FriendDetailsScreenParams {
  const FriendDetailsScreenParams({required this.friendId});

  final String friendId;
}

class FriendDetailsScreen extends StatefulWidget {
  const FriendDetailsScreen({super.key, required this.params});

  final FriendDetailsScreenParams params;

  @override
  State<FriendDetailsScreen> createState() => _FriendDetailsScreenState();
}

class _FriendDetailsScreenState extends State<FriendDetailsScreen> {
  bool _requestSent = false;
  bool _isSendingRequest = false;
  late Future<FriendDetailsData> _detailsFuture;

  FriendDetailsScreenParams get params => widget.params;
  String get friendId => params.friendId;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _fetchFriendDetails();
  }

  Future<FriendDetailsData> _fetchFriendDetails() async {
    final result = await FriendApiService.instance.getFriendsDetails(
      friendId: friendId,
    );
    return result.fold((failure) => throw failure, (response) => response.data);
  }             

  void _reloadDetails() {
    setState(() {
      _detailsFuture = _fetchFriendDetails();
    });
  }

  bool _hasPendingFriendRequest(FriendProfile profile) =>
      profile.friendRequestSent || _requestSent;

  bool _isOwnProfile(ProfileProvider profileProvider, FriendProfile profile) {
    final currentUserId = profileProvider.profileData?.userId;
    if (currentUserId == null || currentUserId.isEmpty) return false;
    return currentUserId == profile.userId;
  }

  bool _isFamilyMember(FamilyProvider familyProvider, String userId) =>
      familyProvider.isFamilyMember(userId);

  String? _familyRole(FamilyProvider familyProvider, String userId) =>
      familyProvider.relationshipFor(userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: FutureBuilder<FriendDetailsData>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FriendDetailsHeaderShimmer(),
                Expanded(child: _buildShimmerBody()),
              ],
            );
          }

          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? userFacingMessage((snapshot.error! as ApiException).errorMsg)
                : userFacingMessage(snapshot.error.toString());
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FriendDetailsHeaderShimmer(),
                Expanded(child: _buildErrorBody(message)),
              ],
            );
          }

          final details = snapshot.data!;
          final profile = details.profile;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<FamilyProvider>(
                builder: (context, familyProvider, _) {
                  return FriendDetailsHeader(
                    profile: profile,
                    friendsCount: details.friendsPreview.totalCount,
                    familyRole: _familyRole(familyProvider, profile.userId),
                  );
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _relationshipActionsBlock(details, profile),
                        _friendsBlock(context, details),
                        _groupsBlock(context, details),
                        _overviewBlock(details),
                        _interestsBlock(details),
                        // _yourBooksBlock(),
                        _mySeriesListBlock(details),
                        SizedBox(height: 24.w),
                      ],
                    ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerBody() {
    return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _shimmerProfileDetailsBlock(),
            _shimmerActionButton(),
            _shimmerHorizontalSection(avatarCount: 4),
            _shimmerHorizontalSection(avatarCount: 3, circleSize: 64),
            _shimmerOverviewBlock(),
            _shimmerInterestsBlock(),
            SizedBox(height: 24.w),
          ],
        ),
    );
  }

  Widget _shimmerProfileDetailsBlock() {
    return Container(
      padding: EdgeInsets.fromLTRB(27.w, 20.h, 27.w, 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 180.w, height: 22.h, radius: 6.r),
                10.h.verticalSpace,
                _shimmerBox(width: 120.w, height: 16.h, radius: 6.r),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _shimmerBox(width: 36.w, height: 22.h, radius: 6.r),
              6.h.verticalSpace,
              _shimmerBox(width: 52.w, height: 14.h, radius: 6.r),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerActionButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(27.w, 4.h, 27.w, 8.h),
      child: _shimmerBox(height: 48.h, radius: 24.r),
    );
  }

  Widget _shimmerHorizontalSection({
    required int avatarCount,
    double circleSize = 64,
  }) {
    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(width: 90.w, height: 20.h, radius: 6.r),
          16.h.verticalSpace,
          Row(
            children: [
              for (var i = 0; i < avatarCount; i++) ...[
                if (i > 0) 16.w.horizontalSpace,
                Column(
                  children: [
                    _shimmerBox(
                      width: circleSize.w,
                      height: circleSize.w,
                      radius: circleSize.w / 2,
                    ),
                    8.h.verticalSpace,
                    _shimmerBox(width: circleSize.w, height: 12.h, radius: 4.r),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerOverviewBlock() {
    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(width: 100.w, height: 20.h, radius: 6.r),
          16.h.verticalSpace,
          Row(
            children: [
              Expanded(
                child: _shimmerBox(height: 88.h, radius: 12.r),
              ),
              16.w.horizontalSpace,
              Expanded(
                child: _shimmerBox(height: 88.h, radius: 12.r),
              ),
            ],
          ),
          16.h.verticalSpace,
          Row(
            children: [
              Expanded(
                child: _shimmerBox(height: 88.h, radius: 12.r),
              ),
              16.w.horizontalSpace,
              Expanded(
                child: _shimmerBox(height: 88.h, radius: 12.r),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shimmerInterestsBlock() {
    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(width: 90.w, height: 20.h, radius: 6.r),
          16.h.verticalSpace,
          Wrap(
            spacing: 8.w,
            runSpacing: 12.h,
            children: List.generate(
              4,
              (_) => _shimmerBox(width: 100.w, height: 36.h, radius: 24.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    double? width,
    required double height,
    double radius = 8,
  }) {
    return AppSkeletonizer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBaseColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildErrorBody(String message) {
    return ColoredBox(
      color: AppColors.white,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48.w,
                color: AppColors.black.setOpacity(0.25),
              ),
              16.h.verticalSpace,
              AppText(
                text: message,
                textAlign: TextAlign.center,
                style: AppTextStyles.semibold(
                  fontSize: 15,
                  color: AppColors.black.setOpacity(0.6),
                ),
              ),
              20.h.verticalSpace,
              TextButton(
                onPressed: _reloadDetails,
                child: AppText(
                  text: 'Try again',
                  style: AppTextStyles.semibold(
                    fontSize: 16,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _relationshipActionsBlock(
    FriendDetailsData details,
    FriendProfile profile,
  ) {
    return Consumer3<FriendProvider, ProfileProvider, FamilyProvider>(
      builder: (context, friendProvider, profileProvider, familyProvider, _) {
        if (_isOwnProfile(profileProvider, profile)) {
          return const SizedBox.shrink();
        }

        final Widget actionButton;
        if (profile.isFriend) {
          if (_isFamilyMember(familyProvider, profile.userId)) {
            return const SizedBox.shrink();
          }
          actionButton = _buildAddToFamilyButton(profile);
        } else if (_hasPendingFriendRequest(profile)) {
          actionButton = _buildRequestSentButton();
        } else {
          actionButton = _buildAddToFriendButton(friendProvider, profile);
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
          child: actionButton,
        );
      },
    );
  }

  Widget _buildAddToFriendButton(
    FriendProvider friendProvider,
    FriendProfile profile,
  ) {
    final isLoading = _isSendingRequest || friendProvider.isSendingRequest;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : () => _sendFriendRequest(profile),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1C1C1E),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE4E4E4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.sp,
                height: 22.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.teal,
                ),
              )
            : Row(
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
                    text: 'Add to Friend',
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

  Widget _buildRequestSentButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.teal,
          backgroundColor: const Color(0xFFDDF4F1),
          disabledForegroundColor: AppColors.teal,
          disabledBackgroundColor: const Color(0xFFDDF4F1),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: AppText(
          text: 'Request Sent',
          style: AppTextStyles.semibold(fontSize: 16, color: AppColors.teal),
        ),
      ),
    );
  }

  void _showAddToFamilySheet(FriendProfile profile) {
    final memberName = profile.displayLabel.isNotEmpty
        ? profile.displayLabel
        : 'this user';
    showAddFamilyMemberBottomSheet(
      context,
      memberName: memberName,
      onConfirm: (role) async {
        final error = await context
            .read<FamilyProvider>()
            .addFamilyMemberFromProfile(profile: profile, role: role);
        if (!mounted) return error;
        if (error == null) {
          AppToast.success(
            context,
            '${profile.displayName ?? memberName} added as ${role.label}',
          );
          setState(() {});
        }
        return error;
      },
    );
  }

  Widget _buildAddToFamilyButton(FriendProfile profile) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => _showAddToFamilySheet(profile),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF1C1C1E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.family_restroom_rounded,
              size: 22.sp,
              color: AppColors.white,
            ),
            16.w.horizontalSpace,
            AppText(
              text: 'Add to Family',
              style: AppTextStyles.semibold(
                fontSize: 16,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendFriendRequest(FriendProfile profile) {
    final email = profile.email;
    if (email == null || email.isEmpty) {
      AppToast.error(
        context,
        'This user does not have an email on their profile',
      );
      return;
    }

    setState(() => _isSendingRequest = true);

    context.read<FriendProvider>().sendFriendRequest(
      email: email,
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          _isSendingRequest = false;
          _requestSent = true;
        });
        AppToast.success(
          context,
          'Friend request sent to ${profile.displayName ?? 'user'}',
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isSendingRequest = false);
        AppToast.error(context, error);
      },
    );
  }

  Widget _friendsBlock(BuildContext context, FriendDetailsData details) {
    final visibleFriends = details.friendsPreview.items
        .where((item) => item.id != details.profile.userId)
        .toList(growable: false);
    final friendsListTitle = _friendsListTitle(details.profile);

    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitleRow(
            title: 'Friends',
            showViewAll: details.friendsPreview.totalCount > 0,
            onViewAll: () => context.pushNamed(
              AppRoutes.friendsListScreen.name,
              extra: FriendsListScreenParams.forUserProfile(
                userId: details.profile.userId,
                title: friendsListTitle,
              ),
            ),
          ),
          16.w.verticalSpace,
          if (visibleFriends.isEmpty)
            _buildFriendsEmpty()
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < visibleFriends.length; i++) ...[
                    if (i > 0) 16.w.horizontalSpace,
                    FriendPreviewAvatar(
                      friend: visibleFriends[i],
                      onTap: () =>
                          _openFriendProfile(context, visibleFriends[i].id),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _groupsBlock(BuildContext context, FriendDetailsData details) {
    final groups = details.groupsPreview.items;
    final groupsListTitle = _groupsListTitle(details.profile);

    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitleRow(
            title: 'Groups',
            showViewAll: details.groupsPreview.totalCount > 0,
            onViewAll: () => context.pushNamed(
              AppRoutes.userProfileGroupsListScreen.name,
              extra: UserProfileGroupsListScreenParams(
                userId: details.profile.userId,
                title: groupsListTitle,
              ),
            ),
          ),
          16.w.verticalSpace,
          if (groups.isEmpty)
            _buildGroupsEmpty()
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < groups.length; i++) ...[
                    if (i > 0) 16.w.horizontalSpace,
                    _GroupAvatar(
                      title: groups[i].title ?? 'Group',
                      thumbnailUrl: groups[i].thumbnailUrl,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _overviewBlock(FriendDetailsData details) {
    final overview = details.overview ?? ProfileOverview.empty;

    return _sectionContainer(
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
          16.w.verticalSpace,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _profileStatCard(
                    leading: SvgIcon(
                      AppAssets.thunder,
                      size: 24.w,
                      color: AppColors.orangeColor,
                    ),
                    value: '${overview.streak.current}',
                    label: 'Streak',
                  ),
                ),
                16.w.horizontalSpace,
                Expanded(
                  child: _profileStatCard(
                    leading: SvgIcon(
                      AppAssets.star,
                      size: 24.w,
                      color: AppColors.orangeColor,
                    ),
                    value: '${overview.score}',
                    label: 'Points',
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
                    leading: SvgIcon(
                      AppAssets.document,
                      size: 24.w,
                      color: AppColors.black,
                    ),
                    value: '${overview.reading.completedCount}',
                    label: 'Readings',
                  ),
                ),
                16.w.horizontalSpace,
                Expanded(
                  child: _profileStatCard(
                    leading: Icon(
                      Icons.emoji_events_outlined,
                      size: 24.sp,
                      color: AppColors.teal,
                    ),
                    value: '${overview.achievementsUnlocked}',
                    label: 'Achievements',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _interestsBlock(FriendDetailsData details) {
    final interests = details.profile.interests;

    if (interests.isEmpty) return const SizedBox.shrink();

    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Interests',
            style: AppTextStyles.bold(
              fontSize: 22,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          16.w.verticalSpace,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests
                .map(
                  (interest) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F4),
                      borderRadius: BorderRadius.circular(20),
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
          ),
        ],
      ),
    );
  }

  // Widget _yourBooksBlock() {
  //   return _sectionContainer(
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             AppText(
  //               text: 'Books Read',
  //               style: AppTextStyles.bold(fontSize: 18, color: AppColors.black),
  //             ),
  //             AppText(
  //               text: 'View all',
  //               style: AppTextStyles.semiBold(
  //                 fontSize: 14,
  //                 color: AppColors.teal,
  //               ),
  //             ),
  //           ],
  //         ),
  //         12.verticalSpace,
  //         SizedBox(
  //           height: 125,
  //           width: double.maxFinite,
  //           child: ListView.separated(
  //             separatorBuilder: (context, index) => const SizedBox(width: 8),
  //             scrollDirection: Axis.horizontal,
  //             physics: const BouncingScrollPhysics(),
  //             itemCount: 10,
  //             itemBuilder: (context, index) {
  //               return Container(
  //                 height: 120,
  //                 margin: const EdgeInsets.only(bottom: 5, left: 1),
  //                 width: 80,
  //                 decoration: BoxDecoration(
  //                   color: AppColors.lightwhiteColor,
  //                   borderRadius: BorderRadius.circular(12.r),
  //                   image: DecorationImage(
  //                     image: AssetImage(AppAssets.demoBookImage),
  //                     fit: BoxFit.cover,
  //                   ),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: AppColors.black.withValues(alpha: 0.15),
  //                       spreadRadius: 2,
  //                       blurRadius: 2,
  //                       offset: const Offset(0, 2),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _mySeriesListBlock(FriendDetailsData details) {
    final topics = details.topicsPreview.items;
    final topicsListTitle = _topicsListTitle(details.profile);

    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitleRow(
            title: 'Series Followed',
            viewAllColor: AppColors.teal,
            showViewAll: details.topicsPreview.totalCount > 0,
            onViewAll: () => context.pushNamed(
              AppRoutes.userProfileTopicsListScreen.name,
              extra: UserProfileTopicsListScreenParams(
                userId: details.profile.userId,
                title: topicsListTitle,
              ),
            ),
          ),
          16.w.verticalSpace,
          if (topics.isEmpty)
            _buildTopicsEmpty()
          else
            SizedBox(
              height: 228.h,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < topics.length; i++)
                      _ViewOnlySeriesCard(
                        title: topics[i].title ?? 'Untitled',
                        readingsCount: topics[i].noOfReadings,
                        subtitle: topics[i].subtitle,
                        imageUrl: resolveNullableNetworkImageUrl(
                          topics[i].topicImage,
                        ),
                        imageSeed: 'friend-series-${topics[i].id}',
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _friendsListTitle(FriendProfile profile) {
    final name = profile.displayName ?? profile.username;
    if (name == null || name.isEmpty) return 'Friends';
    return "$name's Friends";
  }

  String _groupsListTitle(FriendProfile profile) {
    final name = profile.displayName ?? profile.username;
    if (name == null || name.isEmpty) return 'Groups';
    return "$name's Groups";
  }

  String _topicsListTitle(FriendProfile profile) {
    final name = profile.displayName ?? profile.username;
    if (name == null || name.isEmpty) return 'Series Followed';
    return "$name's Series";
  }

  void _openFriendProfile(BuildContext context, String targetId) {
    if (targetId == friendId) return;
    context.pushNamed(
      AppRoutes.friendDetailsScreen.name,
      extra: FriendDetailsScreenParams(friendId: targetId),
    );
  }

  Widget _sectionTitleRow({
    required String title,
    required bool showViewAll,
    required VoidCallback onViewAll,
    Color viewAllColor = const Color(0xFFF6A01A),
  }) {
    return Row(
      children: [
        AppText(
          text: title,
          style: AppTextStyles.bold(
            fontSize: 22,
            color: const Color(0xFF1C1C1E),
          ),
        ),
        const Spacer(),
        if (showViewAll)
          GestureDetector(
            onTap: onViewAll,
            behavior: HitTestBehavior.opaque,
            child: AppText(
              text: 'View all',
              style: AppTextStyles.semibold(fontSize: 14, color: viewAllColor),
            ),
          ),
      ],
    );
  }

  Widget _sectionContainer({required Widget child}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 4.h),
      child: child,
    );
  }

  Widget _profileStatCard({
    required Widget leading,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F8),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          SizedBox(height: 12.h),
          AppText(
            text: value,
            style: AppTextStyles.bold(
              fontSize: 22,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          SizedBox(height: 2.h),
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

  Widget _buildFriendsEmpty() {
    return AppText(
      text: 'No friends yet',
      style: AppTextStyles.regular(fontSize: 14, color: const Color(0xFF8E8E93)),
    );
  }

  Widget _buildGroupsEmpty() {
    return AppText(
      text: 'No groups yet',
      style: AppTextStyles.regular(fontSize: 14, color: const Color(0xFF8E8E93)),
    );
  }

  Widget _buildTopicsEmpty() {
    return AppText(
      text: 'No series yet',
      style: AppTextStyles.regular(fontSize: 14, color: const Color(0xFF8E8E93)),
    );
  }
}

class _GroupAvatar extends StatelessWidget {
  const _GroupAvatar({required this.title, this.thumbnailUrl});

  final String title;
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: SizedBox(
              width: 64.w,
              height: 64.w,
              child: GroupImageWidget(imageUrl: thumbnailUrl, size: 64.w),
            ),
          ),
          8.h.verticalSpace,
          AppText(
            text: title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.medium(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ViewOnlySeriesCard extends StatelessWidget {
  const _ViewOnlySeriesCard({
    required this.title,
    required this.readingsCount,
    required this.imageSeed,
    this.subtitle,
    this.imageUrl,
  });

  final String title;
  final int readingsCount;
  final String imageSeed;
  final String? subtitle;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = AppColors.black.setOpacity(0.45);
    final subtitleText = subtitle?.trim().isNotEmpty == true
        ? subtitle!
        : '$readingsCount Readings';

    return Container(
      width: 210.w,
      height: 228.h,
      margin: EdgeInsets.only(right: 10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AppNetworkImage(
              imageUrl:
                  imageUrl ?? 'https://picsum.photos/seed/$imageSeed/700/500',
              tag: 'FriendDetails.series',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_) => _storyImageShimmer(),
              errorCompact: true,
              errorIconOnly: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  style: AppTextStyles.bold(fontSize: 16.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                4.h.verticalSpace,
                AppText(
                  text: subtitleText,
                  style: AppTextStyles.medium(
                    fontSize: 12.sp,
                    color: subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _storyImageShimmer() {
  return AppSkeletonizer(
    child: Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.shimmerBaseColor,
    ),
  );
}
