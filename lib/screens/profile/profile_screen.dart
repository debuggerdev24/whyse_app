import 'package:cached_network_image/cached_network_image.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/global_widgets.dart';
import 'package:redstreakapp/models/home/story_models/story_topics.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_header_section.dart';
import 'package:shimmer/shimmer.dart';

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
                    _profileDetailsBlock(),
                    _friendsBlock(),  
                    _groupsBlock(),
                    _overviewBlock(),
                    _interestsBlock(),
                    _subscriptionBlock(),
                    _yourBooksBlock(),
                    _yourEBooksBlock(context),
                    _mySeriesesListBlock(),
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

  Widget _profileDetailsBlock() {
    return Container(
      padding: EdgeInsets.fromLTRB(27.w, 20.h, 27.w, 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: 'Stacey Abrams',
                style: AppTextStyles.bold(fontSize: 20, color: AppColors.black),
              ),
              Row(
                children: [
                  AppText(
                    text: '@StaceyAbs21',
                    style: AppTextStyles.bold(
                      fontSize: 14,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  AppText(
                    text: ' • Joined 2025',
                    style: AppTextStyles.semibold(
                      fontSize: 14,
                      color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: '15',
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

  Widget _subscriptionBlock() {
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
              text: 'Subscription',
              style: AppTextStyles.bold(fontSize: 20, color: AppColors.black),
            ),
            11.verticalSpace,
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightwhiteColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.black.withValues(alpha: 0.08),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: AppText(
                        text: 'Free Plan (with ads)',
                        style: AppTextStyles.bold(
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    AppText(
                      text: '\$0/mo',
                      style: AppTextStyles.bold(
                        fontSize: 16,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            16.verticalSpace,
            SizedBox(
              width: double.infinity,
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
                  text: 'Upgrade',
                  style: AppTextStyles.semibold(
                    fontSize: 15,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _yourBooksBlock() {
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
            Row(
              children: [
                AppText(
                  text: 'Your Books',
                  style: AppTextStyles.bold(
                    fontSize: 20,
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                // GestureDetector(
                //   behavior: HitTestBehavior.opaque,
                //   onTap: () {},
                //   child: AppText(
                //     text: 'See all',
                //     style: AppTextStyles.semibold(
                //       fontSize: 15,
                //       color: AppColors.teal,
                //     ),
                //   ),
                // ),
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
                    margin: EdgeInsets.only(bottom: 5, left: 1),
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
      ),
    );
  }

  Widget _yourEBooksBlock(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: 'Your eBooks',
                  style: AppTextStyles.bold(
                    fontSize: 20,
                    color: AppColors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      context.pushNamed(AppRoutes.yourEBooksScreen.name),
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
                    margin: EdgeInsets.only(bottom: 5, left: 1),
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
      ),
    );
  }

  Widget _mySeriesesListBlock() {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: 'My Series List',
                  style: AppTextStyles.bold(
                    fontSize: 20,
                    color: AppColors.black,
                  ),
                ),
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
            12.verticalSpace,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  5,
                  (index) => _StoryCard(
                    story: [
                      CreatedStoryTopicsModel(
                        id: '1',
                        topic: 'Story 1',
                        learningGoal: 'Learning Goal 1',
                        type: 'Story',
                        interests: [],
                        noOfStories: 3,
                        noOfStoriesGenerated: 2,
                        createdBy: '',
                        isOwnTopic: false,
                        createdOn: DateTime.now().toIso8601String(),
                        updatedAt: DateTime.now().toIso8601String(),
                        thumbnailUrl: AppAssets.demoBookImage,
                      ),
                      CreatedStoryTopicsModel(
                        id: '1',
                        topic: 'Story 2',
                        learningGoal: 'Learning Goal 2',
                        type: 'Story',
                        interests: [],
                        noOfStories: 3,
                        noOfStoriesGenerated: 2,
                        createdBy: '',
                        isOwnTopic: false,
                        createdOn: DateTime.now().toIso8601String(),
                        updatedAt: DateTime.now().toIso8601String(),
                        thumbnailUrl: AppAssets.demoBookImage,
                      ),
                      CreatedStoryTopicsModel(
                        id: '1',
                        topic: 'Story 3',
                        learningGoal: 'Learning Goal 3',
                        type: 'Story',
                        interests: [],
                        noOfStories: 3,
                        noOfStoriesGenerated: 2,
                        createdBy: '',
                        isOwnTopic: false,
                        createdOn: DateTime.now().toIso8601String(),
                        updatedAt: DateTime.now().toIso8601String(),
                        thumbnailUrl: AppAssets.demoBookImage,
                      ),
                      CreatedStoryTopicsModel(
                        id: '1',
                        topic: 'Story 4',
                        learningGoal: 'Learning Goal 4',
                        type: 'Story',
                        interests: [],
                        noOfStories: 3,
                        noOfStoriesGenerated: 2,
                        createdBy: '',
                        isOwnTopic: false,
                        createdOn: DateTime.now().toIso8601String(),
                        updatedAt: DateTime.now().toIso8601String(),
                        thumbnailUrl: AppAssets.demoBookImage,
                      ),
                      CreatedStoryTopicsModel(
                        id: '1',
                        topic: 'Story 5',
                        learningGoal: 'Learning Goal 5',
                        type: 'Story',
                        interests: [],
                        noOfStories: 3,
                        noOfStoriesGenerated: 2,
                        createdBy: '',
                        isOwnTopic: false,
                        createdOn: DateTime.now().toIso8601String(),
                        updatedAt: DateTime.now().toIso8601String(),
                        thumbnailUrl: AppAssets.demoBookImage,
                      ),
                    ][index],
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ],
        ),
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
        border: Border.all(color: AppColors.black.withValues(alpha: 0.08)),
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
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story, this.onTap});

  final CreatedStoryTopicsModel story;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = AppColors.black.withValues(alpha: 0.45);
    final readCount = story.noOfStories;
    final totalCount = story.noOfStoriesGenerated > 0
        ? story.noOfStoriesGenerated
        : readCount;

    return Container(
      width: 210.w,
      alignment: Alignment.center,
      margin: EdgeInsets.only(right: 10.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: SizedBox(
                  height: 132.w,
                  width: double.infinity,
                  child: story.thumbnailUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: story.thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _storyImageShimmer(),
                          errorWidget: (_, __, ___) =>
                              const NoImageFound(compact: true, iconOnly: true),
                        )
                      : _storyImageShimmer(),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 32.h,
                  height: 32.h,
                  margin: EdgeInsets.only(top: 10.w, right: 10.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.bookmark_rounded,
                    size: 20.sp,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 13.w, 14.w, 2.w),
            child: AppText(
              text: story.topic,
              style: AppTextStyles.bold(fontSize: 16.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: AppText(
              text: '$readCount out of $totalCount Readings',
              style: AppTextStyles.medium(
                fontSize: 12.sp,
                color: subtitleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppButton(
            margin: EdgeInsets.fromLTRB(14.w, 12.w, 14.w, 16.w),
            onTap: () {
              onTap?.call();
            },
            text: "Start Reading",
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
