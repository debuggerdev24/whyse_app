import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_header_section.dart';

const List<({String name, Color bg})> _kProfileFriends = [
  (name: 'emma_rose', bg: Color(0xFF167C80)),
  (name: 'liam_12_official', bg: Color(0xFFE8D9C4)),
  (name: 'sofia_reads', bg: Color(0xFFFFB37A)),
  (name: 'noah_story', bg: Color(0xFFFFA8C5)),
  (name: 'ava_the_reader', bg: Color(0xFF167C80)),
];

const List<({String name, Color bg})> _kProfileGroups = [
  (name: 'Grp1e', bg: Color(0xFFC5D4F0)),
  (name: 'Grp354', bg: Color(0xFFE5D4C5)),
  (name: 'Grp356', bg: Color(0xFFD4E5C8)),
  (name: 'Gp879', bg: Color(0xFFE8D0E8)),
  (name: 'Gp152', bg: Color(0xFFD0E8E8)),
];

const List<String> _kProfileInterests = ['Nature', 'Mystery', 'Adventure'];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                    _friendsBlock(),
                    _groupsBlock(),
                    _overviewBlock(),
                    _interestsBlock(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _friendsBlock() {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppText(
                  text: 'Friends',
                  style: AppTextStyles.bold(
                    fontSize: 20,
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: AppText(
                    text: 'View all',
                    style: AppTextStyles.semibold(
                      fontSize: 15,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),
            16.w.verticalSpace,
            SizedBox(
              height: 92.h,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (var i = 0; i < _kProfileFriends.length; i++) ...[
                      if (i > 0) 16.w.horizontalSpace,
                      SizedBox(
                        width: 72.w,
                        child: Column(
                          children: [
                            Container(
                              width: 64.w,
                              height: 64.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _kProfileFriends[i].bg,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.person_rounded,
                                size: 34.sp,
                                color: AppColors.white.withValues(alpha: 0.92),
                              ),
                            ),
                            8.w.verticalSpace,
                            AppText(
                              text: _kProfileFriends[i].name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.medium(
                                fontSize: 12,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            20.w.verticalSpace,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.black,
                  backgroundColor: AppColors.white,
                  side: BorderSide(
                    color: AppColors.black.withValues(alpha: 0.15),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: const StadiumBorder(),
                ),
                child: Row(
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
                      text: 'Add Friends',
                      style: AppTextStyles.semibold(
                        fontSize: 16,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _groupsBlock() {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppText(
                  text: 'Groups',
                  style: AppTextStyles.bold(
                    fontSize: 20,
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: AppText(
                    text: 'View all',
                    style: AppTextStyles.semibold(
                      fontSize: 15,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),
            16.w.verticalSpace,
            SizedBox(
              height: 92.h,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (var i = 0; i < _kProfileGroups.length; i++) ...[
                      if (i > 0) 16.w.horizontalSpace,
                      SizedBox(
                        width: 72.w,
                        child: Column(
                          children: [
                            Container(
                              width: 64.w,
                              height: 64.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _kProfileGroups[i].bg,
                                border: i == 0
                                    ? Border.all(
                                        color: const Color(0xFF4A8FD4),
                                        width: 2,
                                      )
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.groups_2_rounded,
                                size: 30.sp,
                                color: AppColors.black.withValues(alpha: 0.45),
                              ),
                            ),
                            8.w.verticalSpace,
                            AppText(
                              text: _kProfileGroups[i].name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.medium(
                                fontSize: 12,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            20.w.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.black,
                      backgroundColor: AppColors.white,
                      side: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.15),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: const StadiumBorder(),
                    ),
                    child: AppText(
                      text: 'Create Group',
                      style: AppTextStyles.semibold(
                        fontSize: 15,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
                16.w.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: const StadiumBorder(),
                    ),
                    child: AppText(
                      text: 'Join Group',
                      style: AppTextStyles.semibold(
                        fontSize: 15,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _overviewBlock() {
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
            AppText(
              text: 'Overview',
              style: AppTextStyles.bold(fontSize: 20, color: AppColors.black),
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
                        size: 28.w,
                        color: AppColors.primaryColor,
                      ),
                      value: '263',
                      label: 'Streaks',
                    ),
                  ),
                  16.w.horizontalSpace,
                  Expanded(
                    child: _profileStatCard(
                      leading: Icon(
                        Icons.description_outlined,
                        size: 28.sp,
                        color: AppColors.black.withValues(alpha: 0.55),
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
                      leading: Icon(
                        Icons.schedule_outlined,
                        size: 28.sp,
                        color: AppColors.black.withValues(alpha: 0.55),
                      ),
                      value: '60',
                      label: 'Hours',
                    ),
                  ),
                  16.w.horizontalSpace,
                  Expanded(
                    child: _profileStatCard(
                      leading: Text('🇺🇸', style: TextStyle(fontSize: 26.sp)),
                      value: 'A1',
                      label: 'Level',
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

  Widget _interestsBlock() {
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
            AppText(
              text: 'Interests',
              style: AppTextStyles.bold(fontSize: 20, color: AppColors.black),
            ),
            16.w.verticalSpace,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (var i = 0; i < _kProfileInterests.length; i++) ...[
                    if (i > 0) 16.w.horizontalSpace,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.extealighttealcolor,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: AppText(
                        text: _kProfileInterests[i],
                        style: AppTextStyles.semibold(
                          fontSize: 14,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
      border: Border.all(
        color: AppColors.black.withValues(alpha: 0.08),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 36.w,
            child: Center(child: leading),
          ),
          10.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: value,
                  style: AppTextStyles.bold(
                    fontSize: 20,
                    color: AppColors.black,
                  ),
                ),
                4.w.verticalSpace,
                AppText(
                  text: label,
                  style: AppTextStyles.medium(
                    fontSize: 12,
                    color: AppColors.black.withValues(alpha: 0.48),
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
