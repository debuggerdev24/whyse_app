import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/family/family_member_model.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/providers/family/family_provider.dart';
import 'package:redstreakapp/screens/profile/friend_details_screen.dart';
import 'package:redstreakapp/screens/profile/widgets/edit_family_member_bottom_sheet.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';

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
    return SettingsScaffold(
      title: 'Family',
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        child: Consumer<FamilyProvider>(
          builder: (context, provider, _) {
            switch (provider.familyMembersState) {
              case DataState.loading:
                return const _LoadingList();
              case DataState.failed:
                return _ErrorState(
                  message: userFacingMessage(provider.familyMembersError),
                  onRetry: () => provider.getFamilyMembers(forceRefresh: true),
                );
              case DataState.success:
                if (provider.familyMembers.isEmpty) {
                  return const _EmptyState();
                }
                final itemCount = provider.familyMembers.length +
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
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.paddingOf(context).bottom + 16,
                    ),
                    itemCount: itemCount,
                    separatorBuilder: (_, _) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      if (index == provider.familyMembers.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
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
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE8E6),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.family_restroom_outlined,
                  size: 28,
                  color: Color(0xFFFF5C4D),
                ),
              ),
              16.h.verticalSpace,
              AppText(
                text: 'Remove Family Member',
                style: AppTextStyles.bold(fontSize: 18, color: settingsInk),
              ),
              8.h.verticalSpace,
              AppText(
                text: 'Are you sure you want to remove $name from your family?',
                textAlign: TextAlign.center,
                style: AppTextStyles.regular(fontSize: 14, color: settingsMuted),
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
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFE4E4E4)),
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          text: 'Cancel',
                          style: AppTextStyles.semibold(
                            fontSize: 15,
                            color: settingsInk,
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
                          color: const Color(0xFFFF5C4D),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: AppText(
                          text: 'Remove',
                          style: AppTextStyles.semibold(
                            fontSize: 15,
                            color: Colors.white,
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

    return Opacity(
      opacity: _isRemoving ? 0.5 : 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _isRemoving ? null : _openProfile,
              behavior: HitTestBehavior.opaque,
              child: ClipOval(
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: avatarUrl != null
                      ? AppNetworkImage(
                          imageUrl: avatarUrl,
                          tag: 'FamilyMembersList.avatar',
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorCompact: true,
                          errorIconOnly: true,
                          errorBuilder: (_, _, _) => _initials(user),
                        )
                      : _initials(user),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap: _isRemoving ? null : _openProfile,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: user.displayName ?? user.username ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semibold(
                        fontSize: 16,
                        color: settingsInk,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.extealighttealcolor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AppText(
                        text: member.relationship,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semibold(
                          fontSize: 12,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            _ActionChip(
              label: 'Edit',
              foregroundColor: AppColors.teal,
              backgroundColor: AppColors.extealighttealcolor,
              onTap: _showEditSheet,
            ),
            SizedBox(width: 8.w),
            _ActionChip(
              label: 'Remove',
              foregroundColor: const Color(0xFFFF5C4D),
              backgroundColor: const Color(0xFFFFE8E6),
              isLoading: _isRemoving,
              onTap: _isRemoving ? null : _showRemoveDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _initials(FriendUser user) {
    return ColoredBox(
      color: _avatarColor,
      child: Center(
        child: AppText(
          text: user.initials,
          style: AppTextStyles.bold(fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    this.onTap,
    this.isLoading = false,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: isLoading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : AppText(
                text: label,
                style: AppTextStyles.semibold(
                  fontSize: 12,
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
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (_, _) => const _ShimmerTile(),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppText(
        text: 'No family members yet',
        style: AppTextStyles.regular(fontSize: 14, color: settingsMuted),
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
            AppText(
              text: message ?? 'Failed to load family members',
              textAlign: TextAlign.center,
              style: AppTextStyles.regular(fontSize: 14, color: settingsMuted),
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: settingsInk,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: AppText(
                  text: 'Retry',
                  style: AppTextStyles.semibold(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
