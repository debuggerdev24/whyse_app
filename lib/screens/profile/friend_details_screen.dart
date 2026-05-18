import 'package:redstreakapp/core/enums/user_gender.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/providers/family/family_provider.dart';
import 'package:redstreakapp/providers/friend/friend_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/screens/profile/friends_list_screen_params.dart';
import 'package:redstreakapp/screens/profile/widgets/add_family_member_bottom_sheet.dart';
import 'package:redstreakapp/screens/profile/widgets/friend_details_header.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_friend_avatar.dart';
import 'package:shimmer/shimmer.dart';

class FriendDetailsScreenParams {
  const FriendDetailsScreenParams({
    required this.friend,
    this.friendshipId,
    this.isFriend,
    this.gender,
    this.familyRole,
    this.isFamilyMember = false,
  });

  final FriendUser friend;
  final String? friendshipId;

  /// When set, overrides friendship detection from [friendshipId] / provider.
  final bool? isFriend;

  /// When set, overrides [friend.gender] for family relationship options.
  final UserGender? gender;

  /// e.g. Father, Sister — shown on family member profiles.
  final String? familyRole;

  /// When true, hides add-friend / add-to-family actions.
  final bool isFamilyMember;
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

  FriendDetailsScreenParams get params => widget.params;
  FriendUser get friend => params.friend;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<FriendProvider>().getFriends();
    });
  }

  bool _isFriend(FriendProvider friendProvider) {
    if (params.isFriend != null) return params.isFriend!;
    if (params.friendshipId != null && params.friendshipId!.isNotEmpty) {
      return true;
    }
    return friendProvider.friendsList.any((f) => f.friend.id == friend.id);
  }

  bool _isOwnProfile(ProfileProvider profileProvider) {
    final currentUserId = profileProvider.profileData?.userId;
    return currentUserId != null && currentUserId == friend.id;
  }

  bool _isFamilyMember(FamilyProvider familyProvider) {
    if (params.isFamilyMember) return true;
    return familyProvider.isFamilyMember(friend.id);
  }

  String? _familyRole(FamilyProvider familyProvider) {
    if (params.familyRole != null && params.familyRole!.isNotEmpty) {
      return params.familyRole;
    }
    return familyProvider.relationshipFor(friend.id);
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FriendDetailsHeader(friend: friend),
          Expanded(
            child: ColoredBox(
              color: AppColors.white,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _profileDetailsBlock(),
                    _relationshipActionsBlock(),
                    _friendsBlock(context),
                    _groupsBlock(context),
                    _overviewBlock(),
                    _interestsBlock(),
                    _yourBooksBlock(),
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

  Widget _profileDetailsBlock() {
    final displayName = friend.displayName ?? friend.username ?? '';
    final username = friend.username;

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
                text: '${_visibleFriends.length}',
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

  Widget _relationshipActionsBlock() {
    return Consumer3<FriendProvider, ProfileProvider, FamilyProvider>(
      builder: (context, friendProvider, profileProvider, familyProvider, _) {
        if (_isOwnProfile(profileProvider)) return const SizedBox.shrink();
        if (_isFamilyMember(familyProvider)) return const SizedBox.shrink();

        final isFriend = _isFriend(friendProvider);

        return Padding(
          padding: EdgeInsets.fromLTRB(27.w, 4.h, 27.w, 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isFriend)
                _buildAddToFamilyButton()
              else if (_requestSent)
                _buildRequestSentButton()
              else
                _buildAddToFriendButton(friendProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddToFriendButton(FriendProvider friendProvider) {
    final isLoading = _isSendingRequest || friendProvider.isSendingRequest;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : () => _sendFriendRequest(),
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

  void _showAddToFamilySheet() {
    final memberName = friend.displayName ?? friend.username ?? 'this user';
    showAddFamilyMemberBottomSheet(
      context,
      memberName: memberName,
      memberGender: params.gender ?? friend.gender,
      onConfirm: (relationship) {
        context.read<FamilyProvider>().addFamilyMember(
          member: friend,
          relationship: relationship,
        );
        AppToast.success(
          context,
          '${friend.displayName ?? memberName} added as $relationship',
        );
      },
    );
  }

  Widget _buildAddToFamilyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showAddToFamilySheet,
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

  void _sendFriendRequest() {
    final email = friend.email;
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
          'Friend request sent to ${friend.displayName ?? 'user'}',
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isSendingRequest = false);
        AppToast.error(context, error);
      },
    );
  }

  Widget _friendsBlock(BuildContext context) {
    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitleRow(
            title: 'Friends',
            showViewAll: _visibleFriends.isNotEmpty,
            onViewAll: () => context.pushNamed(
              AppRoutes.friendsListScreen.name,
              extra: FriendsListScreenParams(
                friends: _visibleFriends,
                title: _friendsListTitle,
                viewOnly: true,
              ),
            ),
          ),
          16.w.verticalSpace,
          if (_visibleFriends.isEmpty)
            _buildFriendsEmpty()
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < _visibleFriends.length; i++) ...[
                    if (i > 0) 16.w.horizontalSpace,
                    ProfileFriendAvatar(
                      friend: _visibleFriends[i],
                      onTap: () => _openFriendProfile(context, _visibleFriends[i]),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _groupsBlock(BuildContext context) {
    return _sectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitleRow(
            title: 'Groups',
            showViewAll: _demoGroups.isNotEmpty,
            onViewAll: () => context.pushNamed(AppRoutes.groupListScreen.name),
          ),
          16.w.verticalSpace,
          if (_demoGroups.isEmpty)
            _buildGroupsEmpty()
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < _demoGroups.length; i++) ...[
                    if (i > 0) 16.w.horizontalSpace,
                    _GroupAvatar(title: _demoGroups[i]),
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

  Widget _interestsBlock() {
    const interests = ['Adventure', 'Science', 'History', 'Fantasy'];

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

  Widget _mySeriesListBlock() {
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
              children: List.generate(3, (index) {
                return _ViewOnlySeriesCard(
                  title: _demoSeriesTitles[index],
                  readingsCount: 12 + index * 4,
                  imageSeed: 'friend-series-$index',
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  List<FriendUser> get _visibleFriends => _demoFriends
      .where((f) => f.id != friend.id)
      .toList(growable: false);

  String get _friendsListTitle {
    final name = friend.displayName ?? friend.username;
    if (name == null || name.isEmpty) return 'Friends';
    return "$name's Friends";
  }

  void _openFriendProfile(BuildContext context, FriendUser target) {
    if (target.id == friend.id) return;
    context.pushNamed(
      AppRoutes.friendDetailsScreen.name,
      extra: FriendDetailsScreenParams(friend: target),
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

  static final List<FriendUser> _demoFriends = [
    const FriendUser(
      id: 'demo-1',
      displayName: 'Alex Rivera',
      username: 'alex',
      gender: UserGender.male,
    ),
    const FriendUser(
      id: 'demo-2',
      displayName: 'Jamie Lee',
      username: 'jamie',
      gender: UserGender.female,
    ),
    const FriendUser(
      id: 'demo-3',
      displayName: 'Sam Patel',
      username: 'sam',
      gender: UserGender.male,
    ),
    const FriendUser(
      id: 'demo-4',
      displayName: 'Taylor Kim',
      username: 'taylor',
      gender: UserGender.female,
    ),
    const FriendUser(
      id: 'demo-5',
      displayName: 'Jordan Fox',
      username: 'jordan',
      gender: UserGender.male,
    ),
  ];

  static const List<String> _demoGroups = [
    'Book Club',
    'Reading Squad',
    'Story Time',
    'Weekend Readers',
  ];

  static const List<String> _demoSeriesTitles = [
    'Mystery of the Lost City',
    'Ocean Explorers',
    'Space Adventures',
  ];
}

class _GroupAvatar extends StatelessWidget {
  const _GroupAvatar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.black.setOpacity(0.1),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.group, size: 28.sp, color: AppColors.black),
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
  });

  final String title;
  final int readingsCount;
  final String imageSeed;

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
                imageUrl: 'https://picsum.photos/seed/$imageSeed/700/500',
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
              text: '$readingsCount Readings',
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
