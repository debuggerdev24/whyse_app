import 'package:redstreakapp/core/utils/app_imports.dart';

class GroupDetailsScreen extends StatelessWidget {
  const GroupDetailsScreen({super.key});

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
            _GroupAvatar(),
            8.w.verticalSpace,
            AppText(
              text: 'Grp1e',
              style: AppTextStyles.bold(
                fontSize: 24.sp,

                color: AppColors.black,
              ),
            ),

            AppText(
              text: '5 Members',
              style: AppTextStyles.semibold(
                fontSize: 14.sp,
                color: AppColors.orangeColor,
              ),
            ),
            22.w.verticalSpace,
            Divider(height: 1, color: AppColors.black.withValues(alpha: 0.1)),
            20.w.verticalSpace,
            //* Description
            Container(
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
                    text:
                        'This group is created for sharing weekly reading tasks and tracking progress together.',
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
                  AppText(
                    text: 'Members',
                    style: AppTextStyles.semibold(
                      fontSize: 19.sp,
                      color: AppColors.black,
                    ),
                  ),
                  12.w.verticalSpace,
                  ...List.generate(_kMembers.length, (index) {
                    final member = _kMembers[index];
                    return Column(
                      children: [
                        _MemberRow(item: member),
                        if (index != _kMembers.length - 1)
                          Divider(
                            height: 28.w,
                            color: AppColors.black.withValues(alpha: 0.08),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112.w,
      height: 112.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.extealighttealcolor,
      ),
      child: Icon(Icons.groups_rounded, size: 60.sp, color: AppColors.teal),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.item});

  final _MemberItem item;

  @override
  Widget build(BuildContext context) {
    final isLeave = item.action == 'Leave';
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
            text: item.name,
            style: AppTextStyles.semibold(
              fontSize: 16.sp,
              color: AppColors.black,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: isLeave ? const Color(0xFFFFF5F5) : const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isLeave
                  ? AppColors.redColor.withValues(alpha: 0.6)
                  : Colors.transparent,
            ),
          ),
          child: AppText(
            text: item.action,
            style: AppTextStyles.semibold(
              fontSize: 12.sp,
              color: isLeave
                  ? AppColors.redColor
                  : AppColors.black.withValues(alpha: 0.82),
            ),
          ),
        ),
      ],
    );
  }
}

class _MemberItem {
  const _MemberItem({required this.name, required this.action});
  final String name;
  final String action;
}

const List<_MemberItem> _kMembers = [
  _MemberItem(name: 'Emma Rodriguez', action: 'Remove'),
  _MemberItem(name: 'Liam Kumar', action: 'Remove'),
  _MemberItem(name: 'Sofia Mendes', action: 'Remove'),
  _MemberItem(name: 'You', action: 'Leave'),
];
