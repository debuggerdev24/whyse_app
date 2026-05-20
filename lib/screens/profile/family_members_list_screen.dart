import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/family/family_member_model.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/providers/family/family_provider.dart';
import 'package:redstreakapp/screens/profile/friend_details_screen.dart';
import 'package:redstreakapp/screens/profile/widgets/edit_family_member_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

class FamilyMembersListScreen extends StatefulWidget {
  const FamilyMembersListScreen({super.key});

  @override
  State<FamilyMembersListScreen> createState() =>
      _FamilyMembersListScreenState();
}

class _FamilyMembersListScreenState extends State<FamilyMembersListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FamilyProvider>().getFamilyMembers();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    context.read<FamilyProvider>().loadMoreFamilyMembers();
  }

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
                switch (provider.familyMembersState) {
                  case DataState.loading:
                    return const _LoadingList();
                  case DataState.failed:
                    return _ErrorState(
                      message: userFacingMessage(provider.familyMembersError),
                      onRetry: () =>
                          provider.getFamilyMembers(forceRefresh: true),
                    );
                  case DataState.success:
                    if (provider.familyMembers.isEmpty) {
                      return const _EmptyState();
                    }
                    final itemCount =
                        provider.familyMembers.length +
                        (provider.hasMoreFamilyMembers ? 1 : 0);

                    return RefreshIndicator(
                      color: AppColors.teal,
                      onRefresh: () =>
                          provider.getFamilyMembers(forceRefresh: true),
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 20.h),
                        itemCount: itemCount,
                        separatorBuilder: (_, __) => Divider(
                          height: 24.w,
                          thickness: 1,
                          color: AppColors.black.setOpacity(0.08),
                        ),
                        itemBuilder: (context, index) {
                          if (index == provider.familyMembers.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Center(
                                child: SizedBox(
                                  width: 24.sp,
                                  height: 24.sp,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.teal,
                                  ),
                                ),
                              ),
                            );
                          }
                          return _FamilyMemberTile(
                            key: ValueKey(provider.familyMembers[index].id),
                            member: provider.familyMembers[index],
                          );
                        },
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyMemberTile extends StatefulWidget {
  const _FamilyMemberTile({super.key, required this.member});

  final FamilyMember member;

  @override
  State<_FamilyMemberTile> createState() => _FamilyMemberTileState();
}

class _FamilyMemberTileState extends State<_FamilyMemberTile> {
  bool _isRemoving = false;

  static const List<Color> _avatarColors = [
    Color(0xFF53C3BF),
    Color(0xFFD7B086),
    Color(0xFF66C99D),
    Color(0xFF7B9FD4),
    Color(0xFFD48B8B),
    Color(0xFFA68BD4),
  ];

  FamilyMember get member => widget.member;

  Color get _avatarColor {
    final hash = member.member.id.codeUnits.fold<int>(0, (prev, c) => prev + c);
    return _avatarColors[hash % _avatarColors.length];
  }

  void _openProfile() {
    context.pushNamed(
      AppRoutes.friendDetailsScreen.name,
      extra: FriendDetailsScreenParams(friendId: member.member.id),
    );
  }

  void _showEditSheet() {
    showEditFamilyMemberBottomSheet(context, member: member);
  }

  void _showRemoveDialog() {
    if (_isRemoving) return;
    final name =
        member.member.displayName ?? member.member.username ?? 'this member';
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 28.w, 24.w, 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Colors.red.setOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.family_restroom_outlined,
                  size: 28.sp,
                  color: Colors.red,
                ),
              ),
              16.h.verticalSpace,
              AppText(
                text: 'Remove Family Member',
                style: AppTextStyles.bold(fontSize: 18.sp),
              ),
              8.h.verticalSpace,
              AppText(
                text: 'Are you sure you want to remove $name from your family?',
                textAlign: TextAlign.center,
                style: AppTextStyles.medium(
                  fontSize: 14.sp,
                  color: AppColors.black.setOpacity(0.6),
                ),
              ),
              24.h.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(
                            color: AppColors.black.setOpacity(0.15),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          text: 'Cancel',
                          style: AppTextStyles.semibold(
                            fontSize: 15.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        _removeMember();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          text: 'Remove',
                          style: AppTextStyles.semibold(
                            fontSize: 15.sp,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeMember() {
    setState(() => _isRemoving = true);
    context.read<FamilyProvider>().removeFamilyMember(
      familyMemberId: member.id,
      onSuccess: () {
        if (!mounted) return;
        setState(() => _isRemoving = false);
        AppToast.success(
          context,
          '${member.member.displayName ?? "Member"} removed from family',
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isRemoving = false);
        AppToast.error(context, userFacingMessage(error));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = member.member;
    final avatarUrl = resolveNullableNetworkImageUrl(user.avatarUrl);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _openProfile,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _avatarColor,
                  ),
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.center,
                  child: avatarUrl != null
                      ? AppNetworkImage(
                          imageUrl: avatarUrl,
                          tag: 'FamilyMembersList.avatar',
                          width: 48.w,
                          height: 48.w,
                          fit: BoxFit.cover,
                          errorCompact: true,
                          errorIconOnly: true,
                          errorBuilder: (_, __, ___) =>
                              Center(child: _initials(user)),
                        )
                      : _initials(user),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
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
              ],
            ),
          ),
        ),
        8.w.horizontalSpace,
        _ActionChip(
          label: 'Edit',
          foregroundColor: AppColors.teal,
          backgroundColor: AppColors.extealighttealcolor,
          borderColor: AppColors.teal.setOpacity(0.25),
          onTap: _showEditSheet,
        ),
        8.w.horizontalSpace,
        _ActionChip(
          label: 'Remove',
          foregroundColor: Colors.red,
          backgroundColor: Colors.red.setOpacity(0.08),
          borderColor: Colors.red.setOpacity(0.2),
          isLoading: _isRemoving,
          onTap: _isRemoving ? null : _showRemoveDialog,
        ),
      ],
    );
  }

  Widget _initials(FriendUser user) {
    return Center(child: AppText(
        text: user.initials,
        style: AppTextStyles.bold(fontSize: 14.sp, color: AppColors.white),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
    this.onTap,
    this.isLoading = false,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor),
        ),
        child: isLoading
            ? SizedBox(
                width: 14.sp,
                height: 14.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : AppText(
                text: label,
                style: AppTextStyles.semibold(
                  fontSize: 12.sp,
                  color: foregroundColor,
                ),
              ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 20.h),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      separatorBuilder: (_, __) => Divider(
        height: 24.w,
        thickness: 1,
        color: AppColors.black.setOpacity(0.08),
      ),
      itemBuilder: (_, __) => const _ShimmerTile(),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          16.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                8.h.verticalSpace,
                Container(
                  width: 72.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ],
            ),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: AppColors.black.setOpacity(0.3),
            ),
            12.h.verticalSpace,
            AppText(
              text: message ?? 'Failed to load family members',
              textAlign: TextAlign.center,
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: AppColors.black.setOpacity(0.55),
              ),
            ),
            16.h.verticalSpace,
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.teal.setOpacity(0.4)),
                ),
                child: AppText(
                  text: 'Retry',
                  style: AppTextStyles.semibold(
                    fontSize: 14.sp,
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
}
