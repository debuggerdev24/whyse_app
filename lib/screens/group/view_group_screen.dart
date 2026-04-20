import 'package:redstreakapp/core/utils/app_imports.dart';

class ViewGroupScreen extends StatelessWidget {
  const ViewGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: appBar(context),
      body: Column(
        children: [
          Divider(color: AppColors.black.withValues(alpha: 0.1), height: 1),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 24.h),
              itemCount: _kGroupAssignments.length,
              separatorBuilder: (_, _) => 22.h.verticalSpace,
              itemBuilder: (context, index) {
                final item = _kGroupAssignments[index];
                return _GroupAssignmentRow(item: item);
              },
            ),
          ),
          AppFilledButton(
            backgroundColor: AppColors.black,
            text: " Share Series",
            icon: SvgIcon(
              AppAssets.shareIcon,
              size: 20.sp,
              color: AppColors.white,
            ),
            margin: EdgeInsets.only(bottom: 15.w),
            onTap: () {},

          ),
        ],
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 50.w,
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lighttealcolor,
            ),
            child: Icon(
              Icons.people_alt_rounded,
              size: 20.sp,
              color: AppColors.teal,
            ),
          ),
          15.w.horizontalSpace,
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: "Grp1e",
                style: AppTextStyles.semibold(
                  fontSize: 16.sp,
                  color: AppColors.black,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.pushNamed(AppRoutes.groupDetailsScreen.name),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      text: "Details",
                      style: AppTextStyles.medium(
                        fontSize: 12.sp,
                        color: AppColors.black.withValues(alpha: 0.8),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16.sp,
                      color: AppColors.black.withValues(alpha: 0.65),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.chevron_left_rounded),
      ),
      actions: [
        SvgIcon(AppAssets.searchIcon, size: 28.sp, color: AppColors.black),

        10.w.horizontalSpace,
      ],
    );
  }
}

class _GroupAssignmentRow extends StatelessWidget {
  const _GroupAssignmentRow({required this.item});

  final _GroupAssignmentItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lighttealcolor,
          ),
          child: Icon(Icons.person, size: 18.sp, color: AppColors.teal),
        ),
        10.w.horizontalSpace,
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 12.w),

              margin: EdgeInsets.only(right: 60.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.asset(
                      item.imagePath,
                      width: double.infinity,
                      height: 94.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  8.w.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: item.title,
                          style: AppTextStyles.bold(
                            fontSize: 17.sp,
                            color: AppColors.black,
                          ),
                        ),
                        2.w.verticalSpace,
                        AppText(
                          text: item.progress,
                          style: AppTextStyles.medium(
                            fontSize: 13.sp,
                            color: AppColors.black.withValues(alpha: 0.78),
                          ),
                        ),
                        8.w.verticalSpace,
                        Row(
                          children: [
                            AppText(
                              text: 'Add to List',
                              style: AppTextStyles.semibold(
                                fontSize: 14.sp,
                                color: AppColors.teal,
                              ),
                            ),
                            const Spacer(),
                            AppText(
                              text: item.time,
                              style: AppTextStyles.medium(
                                fontSize: 11.sp,
                                color: AppColors.black.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupAssignmentItem {
  const _GroupAssignmentItem({
    required this.title,
    required this.progress,
    required this.time,
    required this.imagePath,
  });

  final String title;
  final String progress;
  final String time;
  final String imagePath;
}

const List<_GroupAssignmentItem> _kGroupAssignments = [
  _GroupAssignmentItem(
    title: 'Nature',
    progress: '0 out of 50 Readings',
    time: '6:17 PM',
    imagePath: AppAssets.story1,
  ),
  _GroupAssignmentItem(
    title: 'Space',
    progress: '0 out of 50 Readings',
    time: '8:24 PM',
    imagePath: AppAssets.story2,
  ),
];
