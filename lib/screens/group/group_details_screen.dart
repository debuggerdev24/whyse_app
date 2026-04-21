import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/group/group_members_model.dart';
import 'package:redstreakapp/providers/group_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/screens/group/widget/group_image_widget.dart';
import 'package:shimmer/shimmer.dart';

class GroupDetailsScreenParams {
  String id;
  String groupName;
  String? thumbnail;
  String? description;

  GroupDetailsScreenParams({
    required this.id,
    required this.groupName,
    this.thumbnail,
    this.description,
  });
}

class _GroupDetailsScreenVM {
  final DataState state;
  final List<GroupMember> members;
  final String? error;

  _GroupDetailsScreenVM({
    required this.state,
    required this.members,
    required this.error,
  });

  bool get isLoading => state == DataState.loading;
  bool get isError => state == DataState.failed;

  factory _GroupDetailsScreenVM.fromProvider(GroupProvider p) {
    return _GroupDetailsScreenVM(
      state: p.getGroupMembersState,
      members: p.groupMembersList,
      error: p.getGroupMembersError,
    );
  }
}

class GroupDetailsScreen extends StatefulWidget {
  final GroupDetailsScreenParams params;
  const GroupDetailsScreen({super.key, required this.params});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<GroupProvider>().getGroupMembers(groupId: widget.params.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: AppText(text: 'Group Details'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "Edit",
              style: AppTextStyles.bold(fontSize: 14.sp, color: AppColors.teal),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            20.w.verticalSpace,
            GroupImageWidget(imageUrl: widget.params.thumbnail, size: 120.w),
            8.w.verticalSpace,
            AppText(
              text: widget.params.groupName,
              style: AppTextStyles.bold(
                fontSize: 24.sp,
                color: AppColors.black,
              ),
            ),

            Selector<GroupProvider, _GroupDetailsScreenVM>(
              selector: (p0, p1) => _GroupDetailsScreenVM.fromProvider(p1),
              builder: (context, provider, _) {
                if (provider.isLoading) return const SizedBox();
                if (provider.isError) {
                  return Center(
                    child: Text(provider.error ?? "Something went wrong"),
                  );
                }
                return AppText(
                  text: '${provider.members.length} Members',
                  style: AppTextStyles.semibold(
                    fontSize: 14.sp,
                    color: AppColors.orangeColor,
                  ),
                );
              },
            ),
            22.w.verticalSpace,
            Divider(height: 1, color: AppColors.black.withValues(alpha: 0.1)),
            20.w.verticalSpace,
            //* Description
            Container(
              width: double.maxFinite,
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              padding: EdgeInsets.fromLTRB(24.w, 20.w, 24.w, 16.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
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
                      fontSize: 16.sp,
                      color: AppColors.black,
                    ),
                  ),
                  8.w.verticalSpace,
                  AppText(
                    text: widget.params.description ?? "-",
                    style: AppTextStyles.medium(
                      fontSize: 14.sp,
                      color: AppColors.black.withValues(alpha: 0.68),
                    ).copyWith(height: 1.35),
                  ),
                ],
              ),
            ),

            //* Updates
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(24.w, 20.w, 24.w, 16.h),
              child: Row(
                children: [
                  AppText(
                    text: "Updates",
                    style: AppTextStyles.semibold(
                      fontSize: 16.sp,
                      color: AppColors.black,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12.sp,
                    color: AppColors.black.withValues(alpha: 0.68),
                  ),
                ],
              ),
            ),
            //*Streaks Section
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRoutes.streakRankingScreen.name);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: EdgeInsets.fromLTRB(24.w, 0.w, 24.w, 16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(20.w, 20.w, 24.w, 16.h),
                child: Row(
                  children: [
                    SvgIcon(
                      AppAssets.thunder,
                      size: 24.sp,
                      color: AppColors.orangeColor,
                    ),
                    8.w.horizontalSpace,
                    AppText(
                      text: "Streaks Ranking",
                      style: AppTextStyles.semibold(
                        fontSize: 16.sp,
                        color: AppColors.black,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12.sp,
                      color: AppColors.black.withValues(alpha: 0.68),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(24.w, 0.w, 24.w, 16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(20.w, 20.w, 24.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //* Add Members Button
                  AppOutlinedButton(
                    onTap: () {},
                    margin: EdgeInsets.only(bottom: 16.w),

                    borderColor: AppColors.black.withValues(alpha: 0.14),
                    child: Row(
                      spacing: 6.w,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgIcon(
                          AppAssets.addMembers,
                          size: 22.sp,
                          color: AppColors.black,
                        ),
                        AppText(
                          text: " Add Members",
                          style: AppTextStyles.semibold(
                            fontSize: 15.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //* Members Title
                  Selector<GroupProvider, _GroupDetailsScreenVM>(
                    builder: (context, value, child) {
                      if (value.isLoading) {
                        return Column(
                          children: [
                            ...List.generate(5, (index) {
                              return Column(
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: AppColors.shimmerBaseColor,
                                    highlightColor:
                                        AppColors.shimmerHighlightColor,
                                    child: Container(
                                      height: 30,
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        border: Border.all(
                                          color: AppColors.black.withValues(
                                            alpha: 0.10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (index != value.members.length - 1)
                                    Divider(
                                      height: 28.w,
                                      color: AppColors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                    ),
                                ],
                              );
                            }),
                          ],
                        );
                      }
                      if (value.isError) {
                        return Center(
                          child: Text(value.error ?? "Something went wrong"),
                        );
                      }
                      if (value.members.isEmpty) {
                        return const SizedBox();
                      }
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
                          12.w.verticalSpace,
                          ...List.generate(value.members.length, (index) {
                            final member = value.members[index];
                            return Column(
                              children: [
                                _MemberRow(
                                  item: member,
                                  onTap: (isLeave, groupId) {
                                    if (isLeave) {
                                      context.read<GroupProvider>().leaveGroup(
                                        groupId: groupId,
                                        onError: (error) =>
                                            AppToast.error(context, error),
                                        onSuccess: () {
                                          AppToast.success(
                                            context,
                                            'Left Group',
                                          );
                                          context
                                              .read<ProfileProvider>()
                                              .getGroupsList();
                                          context.pop();
                                          context.pop();
                                        },
                                      );
                                    }
                                  },
                                ),
                                if (index != value.members.length - 1)
                                  Divider(
                                    height: 28.w,
                                    color: AppColors.black.withValues(
                                      alpha: 0.08,
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ],
                      );
                    },
                    selector: (p0, p1) =>
                        _GroupDetailsScreenVM.fromProvider(p1),
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

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.item, required this.onTap});

  final GroupMember item;
  final Function(bool isLeave, String groupId) onTap;

  @override
  Widget build(BuildContext context) {
    final isLeave = item.isOwner;
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: AppColors.extealighttealcolor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, size: 15.sp, color: AppColors.teal),
        ),
        12.w.horizontalSpace,
        Expanded(
          child: AppText(
            text: item.displayName,
            style: AppTextStyles.semibold(
              fontSize: 16.sp,
              color: AppColors.black,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onTap.call(isLeave, item.groupId);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: isLeave
                  ? const Color(0xFFFFF5F5)
                  : const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isLeave
                    ? AppColors.redColor.withValues(alpha: 0.6)
                    : Colors.transparent,
              ),
            ),
            child: AppText(
              text: isLeave ? 'Leave' : 'Remove',
              style: AppTextStyles.semibold(
                fontSize: 12.sp,
                color: isLeave
                    ? AppColors.redColor
                    : AppColors.black.withValues(alpha: 0.82),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
