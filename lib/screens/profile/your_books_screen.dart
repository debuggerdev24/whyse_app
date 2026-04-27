import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/profile/your_books_provider.dart';

class YourEBooksScreen extends StatelessWidget {
  const YourEBooksScreen({super.key});

  static const List<_BookItemData> _books = [
    _BookItemData(
      imagePath: AppAssets.demoBookImage,
      author: 'Jeff Kinney',
      title: 'Diary of a Wimpy Kid (Book 1)',
      description:
          'For the adult readers of this book, it will make them feel nostalgic about their good old childhood days and help them...',
      pagesLeft: 130,
      progress: 0.50,
    ),
    _BookItemData(
      imagePath: AppAssets.demoBookImage,
      author: 'Jeff Kinney',
      title: 'Diary of a Wimpy Kid 5 : The Ugly Truth',
      description:
          'For the adult readers of this book, it will make them feel nostalgic about their good old childhood days and help them...',
      pagesLeft: 130,
      progress: 0.50,
    ),
    _BookItemData(
      imagePath: AppAssets.demoBookImage,
      author: 'Jeff Kinney',
      title: 'Diary of a Wimpy Kid # 9 : The Long Haul',
      description:
          'For the adult readers of this book, it will make them feel nostalgic about their good old childhood days and help them...',
      pagesLeft: 130,
      progress: 0.50,
    ),
    _BookItemData(
      imagePath: AppAssets.demoBookImage,
      author: 'Jeff Kinney',
      title: 'Diary of a Wimpy Kid 2 : Rodrick Rules',
      description:
          'Diary of a Wimpy Kid: Rodrick Rules is a sequel to the colossal hit Diary of a Wimpy Kid. The story rotates around...',
      pagesLeft: 130,
      progress: 0.50,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<YourBooksProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            leading: provider.optionMode.isNone
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 25.r),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.pop(),
                        child: SvgIcon(AppAssets.backButton, size: 13.sp),
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(left: 18.r),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => provider.setOptionMode(OptionMode.none),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AppText(
                          text: 'Cancel',
                          style: AppTextStyles.bold(
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
            centerTitle: true,
            title: provider.optionMode.isNone
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgIcon(
                        AppAssets.bookOpen,
                        size: 24.sp,
                        color: AppColors.black,
                      ),
                      5.horizontalSpace,
                      AppText(
                        text: 'Your Books',
                        style: AppTextStyles.bold(fontSize: 20),
                      ),
                    ],
                  )
                : AppText(
                    text: 'Select books',
                    style: AppTextStyles.bold(fontSize: 20),
                  ),
            actions: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (provider.optionMode.isNone) {
                    _showOptionsBottomSheet(context);
                    return;
                  }
                  if (!provider.hasSelection) return;
                  if (provider.optionMode.isShare) {
                    _showShareWithBottomSheet(context);
                    return;
                  }
                  if (provider.optionMode.isRemove) {
                    provider.clearBookSelection();
                    provider.setOptionMode(OptionMode.none);
                    AppToast.success(context, 'Selected books removed');
                  }
                },
                child: !provider.optionMode.isNone
                    ? Padding(
                        padding: EdgeInsets.only(right: 25.r),
                        child: AppText(
                          text: provider.optionMode.isShare
                              ? 'Share with'
                              : 'Remove',
                          style: AppTextStyles.bold(
                            fontSize: 14,
                            color: provider.hasSelection
                                ? AppColors.teal
                                : AppColors.teal.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : Container(
                        width: 28.w,
                        height: 28.w,
                        margin: EdgeInsets.only(right: 25.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          border: Border.all(
                            color: AppColors.black.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Icon(
                          Icons.more_vert_rounded,
                          size: 17.sp,
                          color: AppColors.black,
                        ),
                      ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.h),
              child: Container(
                color: AppColors.black.withValues(alpha: 0.1),
                height: 1,
              ),
            ),
          ),
          body: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
            itemBuilder: (context, index) =>
                _BookItemTile(data: _books[index], index: index),
            separatorBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Divider(
                color: AppColors.black.withValues(alpha: 0.08),
                height: 1,
              ),
            ),
            itemCount: _books.length,
          ),
        );
      },
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    _showBottomSheetContainer(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          30.verticalSpace,
          AppText(text: 'Options', style: AppTextStyles.bold(fontSize: 20)),
          30.verticalSpace,
          Row(
            children: [
              _SheetActionButton(
                label: 'Share',
                icon: Icons.ios_share_rounded,
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<YourBooksProvider>().setOptionMode(
                    OptionMode.share,
                  );
                },
              ),
              16.horizontalSpace,
              _SheetActionButton(
                label: 'Remove',
                icon: Icons.close_rounded,
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<YourBooksProvider>().setOptionMode(
                    OptionMode.remove,
                  );
                },
              ),
            ],
          ),
          (MediaQuery.paddingOf(context).bottom + 15).verticalSpace,
        ],
      ),
    );
  }

  void _showShareWithBottomSheet(BuildContext context) {
    _showBottomSheetContainer(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(),
          30.verticalSpace,
          AppText(
            text: 'Share with',
            style: AppTextStyles.semibold(fontSize: 20),
          ),
          30.verticalSpace,
          Row(
            children: [
              _SheetActionButton(
                label: 'Group',
                icon: Icons.groups_2_rounded,
                onTap: () {
                  final rootContext =
                      AppRouter.rootNavigatorKey.currentContext ?? context;
                  Navigator.of(context).pop();
                  _showRecipientsBottomSheet(rootContext, isGroup: true);
                },
              ),
              16.horizontalSpace,
              _SheetActionButton(
                label: 'Friends',
                icon: Icons.person_outline_rounded,
                onTap: () {
                  final rootContext =
                      AppRouter.rootNavigatorKey.currentContext ?? context;
                  Navigator.of(context).pop();
                  _showRecipientsBottomSheet(rootContext, isGroup: false);
                },
              ),
            ],
          ),
          (MediaQuery.paddingOf(context).bottom + 15).verticalSpace,
        ],
      ),
    );
  }

  void _showRecipientsBottomSheet(
    BuildContext context, {
    required bool isGroup,
  }) {
    final recipients = isGroup ? _groups : _friends;
    int selectedIndex = 0;

    _showBottomSheetContainer(
      context: context,
      child: StatefulBuilder(
        builder: (context, setLocalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHandle(),
              30.verticalSpace,
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          final rootContext =
                              AppRouter.rootNavigatorKey.currentContext ??
                              context;
                          Navigator.of(context).pop();
                          _showShareWithBottomSheet(rootContext);
                        },
                        child: Container(
                          width: 50.w,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 25.sp,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: AppText(
                      text: isGroup ? 'Share with Group' : 'Share with Friends',
                      style: AppTextStyles.semibold(fontSize: 20),
                    ),
                  ),
                ],
              ),
              30.verticalSpace,
              Container(
                height: 1,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(
                height: 300.h,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = recipients[index];
                    final isSelected = selectedIndex == index;
                    return _RecipientTile(
                      data: item,
                      selected: isSelected,
                      onTap: () {
                        setLocalState(() {
                          selectedIndex = index;
                        });
                      },
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppColors.black.withValues(alpha: 0.08),
                  ),
                  itemCount: recipients.length,
                ),
              ),
              14.verticalSpace,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: AppText(
                    text: 'Send',
                    style: AppTextStyles.semibold(
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              2.verticalSpace,
            ],
          );
        },
      ),
    );
  }

  void _showBottomSheetContainer({
    required BuildContext context,
    required Widget child,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 10.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
          ),
          child: child,
        );
      },
    );
  }
}

class _BookItemTile extends StatelessWidget {
  const _BookItemTile({required this.data, required this.index});

  final _BookItemData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    final progressPercent = '${(data.progress * 100).round()}%';
    return Consumer<YourBooksProvider>(
      builder: (context, provider, child) {
        final isSelectMode =
            provider.optionMode.isShare || provider.optionMode.isRemove;
        final isSelected = provider.isBookSelected(index);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isSelectMode
              ? () => provider.toggleBookSelection(index)
              : null,
          child: SizedBox(
            height: 135.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 95.h,
                  height: 135.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    image: DecorationImage(
                      image: AssetImage(data.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: data.author,
                        style: AppTextStyles.semibold(
                          fontSize: 13,
                          color: AppColors.black.withValues(alpha: 0.8),
                        ),
                      ),
                      2.verticalSpace,
                      AppText(
                        text: data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bold(fontSize: 16),
                      ),
                      4.verticalSpace,
                      AppText(
                        text: data.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.medium(
                          fontSize: 12,
                          color: AppColors.black.withValues(alpha: 0.80),
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppText(
                                        text: '${data.pagesLeft} Pages left',
                                        style: AppTextStyles.semibold(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    AppText(
                                      text: progressPercent,
                                      style: AppTextStyles.bold(
                                        fontSize: 10,
                                        color: AppColors.black.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                    10.horizontalSpace,
                                  ],
                                ),
                                6.verticalSpace,
                                LinearProgressIndicator(
                                  value: data.progress,
                                  minHeight: 3.h,
                                  color: AppColors.orangeColor,
                                  backgroundColor: AppColors.black.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelectMode)
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 50.h),
                    child: Container(
                      height: 30.h,
                      width: 30.h,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.teal : AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.teal
                              : AppColors.black.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: AppColors.white,
                              size: 18.sp,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookItemData {
  const _BookItemData({
    required this.imagePath,
    required this.author,
    required this.title,
    required this.description,
    required this.pagesLeft,
    required this.progress,
  });

  final String imagePath;
  final String author;
  final String title;
  final String description;
  final int pagesLeft;
  final double progress;
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 4.h,
      margin: EdgeInsets.only(top: 15.h),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  const _SheetActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65.w,
            height: 65.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.black.withValues(alpha: 0.06),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 32.sp, color: AppColors.black),
          ),
          6.verticalSpace,
          AppText(
            text: label,
            style: AppTextStyles.semibold(fontSize: 14, color: AppColors.black),
          ),
        ],
      ),
    );
  }
}

class _RecipientTile extends StatelessWidget {
  const _RecipientTile({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _RecipientData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.r, horizontal: 15.r),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25.r,
              backgroundColor: data.avatarBg,
              child: Icon(data.avatarIcon, color: AppColors.white, size: 18.sp),
            ),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: data.name,
                    style: AppTextStyles.semibold(fontSize: 16),
                  ),
                  5.verticalSpace,
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.r,
                          vertical: 5.r,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.black.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            SvgIcon(
                              AppAssets.thunder,
                              size: 14.sp,
                              color: AppColors.orangeColor,
                            ),
                            5.horizontalSpace,
                            AppText(
                              text: data.subLabel,
                              style: AppTextStyles.semibold(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 20.h,
              width: 20.h,
              decoration: BoxDecoration(
                color: selected ? AppColors.teal : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.teal
                      : AppColors.black.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: selected
                  ? Icon(Icons.check, color: AppColors.white, size: 16.sp)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipientData {
  const _RecipientData({
    required this.name,
    required this.subLabel,
    required this.avatarBg,
    required this.avatarIcon,
  });

  final String name;
  final String subLabel;
  final Color avatarBg;
  final IconData avatarIcon;
}

const List<_RecipientData> _friends = [
  _RecipientData(
    name: 'Emma Rodriguez',
    subLabel: '23',
    avatarBg: Color(0xFF4BAA89),
    avatarIcon: Icons.person_rounded,
  ),
  _RecipientData(
    name: 'Liam Kumar',
    subLabel: '23',
    avatarBg: Color(0xFFB57355),
    avatarIcon: Icons.person_rounded,
  ),
  _RecipientData(
    name: 'Sofia Mendes',
    subLabel: '23',
    avatarBg: Color(0xFFCB8E5F),
    avatarIcon: Icons.person_rounded,
  ),
  _RecipientData(
    name: 'Noah Patel',
    subLabel: '23',
    avatarBg: Color(0xFFD48658),
    avatarIcon: Icons.person_rounded,
  ),
  _RecipientData(
    name: 'Ava Thompson',
    subLabel: '23',
    avatarBg: Color(0xFF4BAA89),
    avatarIcon: Icons.person_rounded,
  ),
];

const List<_RecipientData> _groups = [
  _RecipientData(
    name: 'Grp1e',
    subLabel: '3 Members',
    avatarBg: Color(0xFFB45C68),
    avatarIcon: Icons.groups_2_rounded,
  ),
  _RecipientData(
    name: 'Grp354',
    subLabel: '4 Members',
    avatarBg: Color(0xFFC77D45),
    avatarIcon: Icons.groups_2_rounded,
  ),
  _RecipientData(
    name: 'Grp356',
    subLabel: '9 Members',
    avatarBg: Color(0xFFCA8944),
    avatarIcon: Icons.groups_2_rounded,
  ),
  _RecipientData(
    name: 'Gp879',
    subLabel: '5 Members',
    avatarBg: Color(0xFFCA9A6C),
    avatarIcon: Icons.groups_2_rounded,
  ),
  _RecipientData(
    name: 'Gp152',
    subLabel: '7 Members',
    avatarBg: Color(0xFFBFA176),
    avatarIcon: Icons.groups_2_rounded,
  ),
];
