import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/models/friend/friend_details_model.dart';
import 'package:redstreakapp/providers/family/family_provider.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/screens/group/widget/group_image_widget.dart';
import 'package:redstreakapp/services/profile/friend_api_service.dart';
import 'package:redstreakapp/screens/profile/friends_list_screen_params.dart';
import 'package:redstreakapp/screens/profile/widgets/add_family_member_bottom_sheet.dart';
import 'package:redstreakapp/screens/profile/widgets/friend_details_header.dart';
import 'package:redstreakapp/screens/profile/widgets/friend_preview_avatar.dart';
import 'package:shimmer/shimmer.dart';

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

  bool _isFriend(FriendDetailsData details) => details.profile.isFriend;

  bool _isOwnProfile(ProfileProvider profileProvider) {
    final currentUserId = profileProvider.profileData?.userId;
    return currentUserId != null && currentUserId == friendId;
  }

  bool _isFamilyMember(FamilyProvider familyProvider) =>
      familyProvider.isFamilyMember(friendId);

  String? _familyRole(FamilyProvider familyProvider) =>
      familyProvider.relationshipFor(friendId);

  @override
  Widget build(BuildContext context) {
    return AppLayout(
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
              FriendDetailsHeader(profile: profile),
              Expanded(
                child: ColoredBox(
                  color: AppColors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _profileDetailsBlock(details),
                        _relationshipActionsBlock(details, profile),
                        _friendsBlock(context, details),
                        _groupsBlock(context, details),
                        _overviewBlock(),
                        _interestsBlock(details),
                        _yourBooksBlock(),
                        _mySeriesListBlock(details),
                        SizedBox(height: 24.w),
                      ],
                    ),
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
    return ColoredBox(
      color: AppColors.white,
      child: SingleChildScrollView(
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
              Expanded(child: _shimmerBox(height: 88.h, radius: 12.r)),
              16.w.horizontalSpace,
              Expanded(child: _shimmerBox(height: 88.h, radius: 12.r)),
            ],
          ),
          16.h.verticalSpace,
          Row(
            children: [
              Expanded(child: _shimmerBox(height: 88.h, radius: 12.r)),
              16.w.horizontalSpace,
              Expanded(child: _shimmerBox(height: 88.h, radius: 12.r)),
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
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
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

  Widget _profileDetailsBlock(FriendDetailsData details) {
    final profile = details.profile;
    final displayName = profile.displayName ?? profile.username ?? '';
    final username = profile.username;
    final friendsCount = details.friendsPreview.totalCount;

    return Consumer<FamilyProvider>(
      builder: (context, familyProvider, _) {
        final familyRole = _familyRole(familyProvider);

        return Container(
          padding: EdgeInsets.fromLTRB(27.w, 20.h, 27.w, 20.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: displayName,
                      style: AppTextStyles.bold(
                        fontSize: 20,
                        color: AppColors.black,
                      ),
                    ),
                    if (username != null && username.isNotEmpty)
                      AppText(
                        text: '@$username',
                        style: AppTextStyles.bold(
                          fontSize: 14,
                          color: AppColors.black.withValues(alpha: 0.6),
                        ),
                      ),
                    if (familyRole != null) ...[
                      10.h.verticalSpace,
                      _FamilyRoleBadge(role: familyRole),
                    ],
                  ],
                ),
              ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: '$friendsCount',
                style: AppTextStyles.bold(fontSize: 20, color: AppColors.black),
              ),
              AppText(
                text: 'Friends',
                style: AppTextStyles.bold(
                  fontSize: 14,
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
            ],
          ),
        );
      },
    );
  }

  Widget _relationshipActionsBlock(
    FriendDetailsData details,
    FriendProfile profile,
  ) {
    return Consumer3<FriendProvider, ProfileProvider, FamilyProvider>(
      builder: (context, friendProvider, profileProvider, familyProvider, _) {
        if (_isOwnProfile(profileProvider)) return const SizedBox.shrink();
        if (_isFamilyMember(familyProvider)) return const SizedBox.shrink();

        final isFriend = _isFriend(details);

        return Padding(
          padding: EdgeInsets.fromLTRB(27.w, 4.h, 27.w, 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isFriend)
                _buildAddToFamilyButton(profile)
              else if (_requestSent)
                _buildRequestSentButton()
              else
                _buildAddToFriendButton(friendProvider, profile),
            ],
          ),
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
      child: OutlinedButton(
        onPressed: isLoading ? null : () => _sendFriendRequest(profile),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.black,
          backgroundColor: AppColors.white,
          side: BorderSide(color: AppColors.black.setOpacity(0.15)),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: const StadiumBorder(),
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
      child: OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.teal,
          backgroundColor: AppColors.extealighttealcolor,
          disabledForegroundColor: AppColors.teal,
          disabledBackgroundColor: AppColors.extealighttealcolor,
          side: BorderSide(color: AppColors.teal.setOpacity(0.25)),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: const StadiumBorder(),
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
      onConfirm: (relationship) {
        context.read<FamilyProvider>().addFamilyMemberFromProfile(
          profile: profile,
          relationship: relationship,
        );
        AppToast.success(
          context,
          '${profile.displayName ?? memberName} added as $relationship',
        );
      },
    );
  }

  Widget _buildAddToFamilyButton(FriendProfile profile) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showAddToFamilySheet(profile),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.family_restroom_rounded, size: 22.sp, color: AppColors.white),
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
      AppToast.error(context, 'This user does not have an email on their profile');
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
            showViewAll: visibleFriends.isNotEmpty,
            onViewAll: () => context.pushNamed(
              AppRoutes.friendsListScreen.name,
              extra: FriendsListScreenParams.fromPreviews(
                friendPreviews: visibleFriends,
                title: friendsListTitle,
                viewOnly: true,
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

    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitleRow(
            title: 'Groups',
            showViewAll: groups.isNotEmpty,
            onViewAll: () => context.pushNamed(AppRoutes.groupListScreen.name),
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

  Widget _overviewBlock() {
    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Overview',
            style: AppTextStyles.bold(fontSize: 18, color: AppColors.black),
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
                    value: '263',
                    label: 'Streaks',
                  ),
                ),
                16.w.horizontalSpace,
                Expanded(
                  child: _profileStatCard(
                    leading: SvgIcon(
                      AppAssets.document,
                      size: 24.w,
                      color: AppColors.black,
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
                    leading: SvgIcon(
                      AppAssets.dumbbell,
                      size: 24.w,
                      color: AppColors.black,
                    ),
                    value: '30',
                    label: 'Exercises',
                  ),
                ),
                16.w.horizontalSpace,
                Expanded(
                  child: _profileStatCard(
                    leading: SvgIcon(
                      AppAssets.clock,
                      size: 24.w,
                      color: AppColors.black,
                    ),
                    value: '60',
                    label: 'Hours',
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
            style: AppTextStyles.bold(fontSize: 18, color: AppColors.black),
          ),
          16.w.verticalSpace,
          Wrap(
            spacing: 8.r,
            runSpacing: 12.r,
            children: interests
                .map(
                  (interest) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.extealighttealcolor,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: AppText(
                      text: interest,
                      style: AppTextStyles.bold(
                        fontSize: 14,
                        color: AppColors.teal,
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

  Widget _yourBooksBlock() {
    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: 'Books Read',
                style: AppTextStyles.bold(fontSize: 18, color: AppColors.black),
              ),
              AppText(
                text: 'View all',
                style: AppTextStyles.semiBold(
                  fontSize: 14,
                  color: AppColors.teal,
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
                  margin: const EdgeInsets.only(bottom: 5, left: 1),
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
    );
  }

  Widget _mySeriesListBlock(FriendDetailsData details) {
    final topics = details.topicsPreview.items;
    if (topics.isEmpty) return const SizedBox.shrink();

    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'My Series List',
            style: AppTextStyles.bold(fontSize: 18, color: AppColors.black),
          ),
          12.verticalSpace,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
        ],
      ),
    );
  }

  String _friendsListTitle(FriendProfile profile) {
    final name = profile.displayName ?? profile.username;
    if (name == null || name.isEmpty) return 'Friends';
    return "$name's Friends";
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
  }) {
    return Row(
      children: [
        AppText(
          text: title,
          style: AppTextStyles.bold(fontSize: 18, color: AppColors.black),
        ),
        const Spacer(),
        if (showViewAll)
          GestureDetector(
            onTap: onViewAll,
            behavior: HitTestBehavior.opaque,
            child: AppText(
              text: 'View all',
              style: AppTextStyles.semibold(
                fontSize: 14,
                color: AppColors.teal,
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionContainer({required Widget child}) {
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
        child: child,
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
        padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 14.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(alignment: Alignment.topLeft, child: leading),
            10.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: value,
                    style: AppTextStyles.semiBold(
                      fontSize: 18,
                      color: AppColors.black,
                    ).copyWith(height: 1.2),
                  ),
                  4.w.verticalSpace,
                  AppText(
                    text: label,
                    style: AppTextStyles.semiBold(
                      fontSize: 14,
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
        ],
      ),
    );
  }

  Widget _buildGroupsEmpty() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 36.w,
            color: AppColors.black.setOpacity(0.2),
          ),
          8.h.verticalSpace,
          AppText(
            text: 'No groups yet',
            style: AppTextStyles.semibold(
              fontSize: 14,
              color: AppColors.black.setOpacity(0.45),
            ),
          ),
        ],
      ),
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
              child: GroupImageWidget(
                imageUrl: thumbnailUrl,
                size: 64.w,
              ),
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

    return Container(
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
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: SizedBox(
              height: 132.w,
              width: double.infinity,
              child: AppNetworkImage(
                imageUrl: imageUrl ?? 'https://picsum.photos/seed/$imageSeed/700/500',
                tag: 'FriendDetails.series',
                placeholder: (_) => _storyImageShimmer(),
                errorCompact: true,
                errorIconOnly: true,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 13.w, 14.w, 2.w),
            child: AppText(
              text: title,
              style: AppTextStyles.bold(fontSize: 16.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: AppText(
              text: subtitle?.trim().isNotEmpty == true
                  ? subtitle!
                  : '$readingsCount Readings',
              style: AppTextStyles.medium(
                fontSize: 12.sp,
                color: subtitleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.w, 14.w, 16.w),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.black.setOpacity(0.06),
                borderRadius: BorderRadius.circular(24.r),
              ),
              alignment: Alignment.center,
              child: AppText(
                text: 'Start Reading',
                style: AppTextStyles.semibold(
                  fontSize: 14.sp,
                  color: AppColors.black.setOpacity(0.35),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyRoleBadge extends StatelessWidget {
  const _FamilyRoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.extealighttealcolor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.teal.setOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.family_restroom_rounded,
            size: 16.sp,
            color: AppColors.teal,
          ),
          6.w.horizontalSpace,
          AppText(
            text: role,
            style: AppTextStyles.semibold(
              fontSize: 13,
              color: AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}

Shimmer _storyImageShimmer() {
  return Shimmer.fromColors(
    baseColor: AppColors.shimmerBaseColor,
    highlightColor: AppColors.shimmerHighlightColor,
    child: Container(
      width: double.infinity,
      height: 132.w,
      color: AppColors.shimmerBaseColor,
    ),
  );
}
