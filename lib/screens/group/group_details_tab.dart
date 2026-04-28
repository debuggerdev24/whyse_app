import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/shared_pref.dart';
import 'package:redstreakapp/core/widgets/loading_dialog.dart';
import 'package:redstreakapp/models/group/group_members_model.dart';
import 'package:redstreakapp/providers/group_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/screens/group/group_screen_params.dart';
import 'package:shimmer/shimmer.dart';

class _GroupDetailsTabVM {
  final DataState state;
  final List<GroupMember> members;
  final String? error;

  _GroupDetailsTabVM({
    required this.state,
    required this.members,
    required this.error,
  });

  bool get isLoading => state == DataState.loading;
  bool get isError => state == DataState.failed;

  factory _GroupDetailsTabVM.fromProvider(GroupProvider p) {
    return _GroupDetailsTabVM(
      state: p.getGroupMembersState,
      members: p.groupMembersList,
      error: p.getGroupMembersError,
    );
  }
}

/// Details tab: description card + members (reused from former group-only screen).
class GroupDetailsTabBody extends StatelessWidget {
  const GroupDetailsTabBody({super.key, required this.params});

  final GroupDetailsScreenParams params;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (params.description != null && params.description!.isNotEmpty)
            _DescriptionCard(description: params.description!),
          if (params.description != null && params.description!.isNotEmpty)
            14.h.verticalSpace,
          _MembersCard(params: params),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Description',
            style: AppTextStyles.semibold(
              fontSize: 17.sp,
              color: AppColors.black,
            ),
          ),
          10.h.verticalSpace,
          AppText(
            text: description,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.medium(
              fontSize: 14.sp,
              color: AppColors.black.withValues(alpha: 0.68),
            ).copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({required this.params});

  final GroupDetailsScreenParams params;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppOutlinedButton(
            onTap: () {
              context.pushNamed(
                AppRoutes.addMembersScreen.name,
                extra: params.id,
              );
            },
            margin: EdgeInsets.only(bottom: 14.h),
            borderColor: AppColors.black.withValues(alpha: 0.14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgIcon(
                  AppAssets.addMembers,
                  size: 22.sp,
                  color: AppColors.black,
                ),
                6.w.horizontalSpace,
                AppText(
                  text: 'Add Members',
                  style: AppTextStyles.semibold(
                    fontSize: 15.sp,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
          Selector<GroupProvider, _GroupDetailsTabVM>(
            selector: (_, p) => _GroupDetailsTabVM.fromProvider(p),
            builder: (context, value, _) {
              if (value.isLoading) {
                return Column(
                  children: List.generate(5, (index) {
                    return Column(
                      children: [
                        Shimmer.fromColors(
                          baseColor: AppColors.shimmerBaseColor,
                          highlightColor: AppColors.shimmerHighlightColor,
                          child: Container(
                            height: 30,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: AppColors.black.withValues(alpha: 0.10),
                              ),
                            ),
                          ),
                        ),
                        if (index != 4)
                          Divider(
                            height: 28.w,
                            color: AppColors.black.withValues(alpha: 0.08),
                          ),
                      ],
                    );
                  }),
                );
              }
              if (value.isError) {
                return Center(
                  child: Text(value.error ?? 'Something went wrong'),
                );
              }
              if (value.members.isEmpty) {
                return const SizedBox.shrink();
              }

              final myUserId = LocalStorageService.instance.getLoggedInUserId;
              final amIOwner = value.members.any(
                (m) => m.userId == myUserId && m.isOwner,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'Members',
                    style: AppTextStyles.semibold(
                      fontSize: 19.sp,
                      color: AppColors.black,
                    ),
                  ),
                  12.h.verticalSpace,
                  ...List.generate(value.members.length, (index) {
                    final member = value.members[index];
                    final isMe = member.userId == myUserId;

                    return Column(
                      children: [
                        GroupMemberRow(
                          item: member,
                          isMe: isMe,
                          amIOwner: amIOwner,
                          onLeave: () {
                            showLoadingDialog(context);
                            context.read<GroupProvider>().leaveGroup(
                              groupId: member.groupId,
                              onError: (error) {
                                context.pop();
                                AppToast.error(context, error);
                              },
                              onSuccess: () {
                                context.pop();
                                AppToast.success(context, 'Left Group');
                                context.read<ProfileProvider>().getGroupsList();
                                context.read<GroupProvider>().getGroupsList();
                                context.pop();
                              },
                            );
                          },
                          onRemove: () {
                            showLoadingDialog(context);
                            context.read<GroupProvider>().removeMemberFromGroup(
                              groupId: member.groupId,
                              userId: member.userId,
                              onError: (error) {
                                context.pop();
                                AppToast.error(context, error);
                              },
                              onSuccess: () {
                                context.pop();
                                AppToast.success(
                                  context,
                                  'Member removed successfully',
                                );
                              },
                            );
                          },
                        ),
                        if (index != value.members.length - 1)
                          Divider(
                            height: 28.w,
                            color: AppColors.black.withValues(alpha: 0.08),
                          ),
                      ],
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

enum _MemberTagType { leave, remove, owner, member }

class GroupMemberRow extends StatelessWidget {
  const GroupMemberRow({
    super.key,
    required this.item,
    required this.isMe,
    required this.amIOwner,
    required this.onLeave,
    required this.onRemove,
  });

  final GroupMember item;
  final bool isMe;
  final bool amIOwner;
  final VoidCallback onLeave;
  final VoidCallback onRemove;

  _MemberTagType get _tagType {
    if (isMe && amIOwner) return _MemberTagType.owner;
    if (isMe) return _MemberTagType.leave;
    if (item.isOwner) return _MemberTagType.owner;
    if (amIOwner) return _MemberTagType.remove;
    return _MemberTagType.member;
  }

  @override
  Widget build(BuildContext context) {
    final tag = _tagType;
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: const BoxDecoration(
            color: AppColors.extealighttealcolor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, size: 15.sp, color: AppColors.teal),
        ),
        12.w.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: item.displayName,
                style: AppTextStyles.semibold(
                  fontSize: 16.sp,
                  color: AppColors.black,
                ),
              ),
              if (isMe)
                AppText(
                  text: 'You',
                  style: AppTextStyles.medium(
                    fontSize: 12.sp,
                    color: AppColors.black.withValues(alpha: 0.45),
                  ),
                ),
            ],
          ),
        ),
        _MemberTag(
          type: tag,
          onTap: switch (tag) {
            _MemberTagType.leave => onLeave,
            _MemberTagType.remove => onRemove,
            _MemberTagType.owner => null,
            _MemberTagType.member => null,
          },
        ),
      ],
    );
  }
}

class _MemberTag extends StatelessWidget {
  const _MemberTag({required this.type, this.onTap});

  final _MemberTagType type;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (label, bgColor, textColor, borderColor) = switch (type) {
      _MemberTagType.leave => (
        'Leave',
        const Color(0xFFFFF5F5),
        AppColors.redColor,
        AppColors.redColor.withValues(alpha: 0.6),
      ),
      _MemberTagType.remove => (
        'Remove',
        const Color(0xFFFFF5F5),
        AppColors.redColor,
        AppColors.redColor.withValues(alpha: 0.4),
      ),
      _MemberTagType.owner => (
        'Owner',
        AppColors.extealighttealcolor,
        AppColors.teal,
        AppColors.teal.withValues(alpha: 0.4),
      ),
      _MemberTagType.member => (
        'Member',
        const Color(0xFFF3F3F3),
        AppColors.black.withValues(alpha: 0.6),
        Colors.transparent,
      ),
    };

    final child = Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: AppText(
        text: label,
        style: AppTextStyles.semibold(fontSize: 12.sp, color: textColor),
      ),
    );

    if (onTap == null) return child;

    return GestureDetector(onTap: onTap, child: child);
  }
}
