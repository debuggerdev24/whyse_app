import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';

ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

class UserDashBoard extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const UserDashBoard({super.key, required this.navigationShell});

  @override
  State<StatefulWidget> createState() => _UserDashBoardState();
}

class _UserDashBoardState extends State<UserDashBoard> {
  late StoryProvider storyProvider;
  late HomeProvider homeProvider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      storyProvider = context.read<StoryProvider>();
      homeProvider = context.read<HomeProvider>();
      callInitApis(context: context);
    });
  }

  void callInitApis({required BuildContext context}) {
    homeProvider.getHomeScreenTopics();
    // storyProvider.getAllStories();

    storyProvider.getStoryGoals(
      onFailed: (error) {
        AppToast.error(context, "Goal $error");
      },
    );

    storyProvider.getStoryInterest(
      onFailed: (error) {
        AppToast.error(context, "Interest $error");
      },
    );

    storyProvider.getStoryTopics(
      onFailed: (error) {
        AppToast.error(context, "Topic $error");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (context, value, child) => Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: value,
          onTap: (index) {
            tabIndex.value = index;
            // todo widget.navigationShell.goBranch(index);
          },
          items: [
            BottomNavItem(icon: AppAssets.note, isSelected: value == 0),
            BottomNavItem(icon: AppAssets.book, isSelected: value == 1),
            BottomNavItem(icon: AppAssets.dumble, isSelected: value == 2),
            BottomNavItem(icon: AppAssets.star, isSelected: value == 3),
          ],
        ),
      ),
    );
  }
}

class BottomNavigationBar extends StatelessWidget {
  const BottomNavigationBar({
    super.key,
    required this.items,
    required this.onTap,
    this.currentIndex = 0,
  });

  final List<BottomNavItem> items;
  final ValueChanged<int> onTap;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 18,
            spreadRadius: -3,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      height: 80.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          items.length,
          (index) => GestureDetector(
            onTap: () => onTap.call(index),
            child: items[index],
          ),
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    super.key,
    required this.icon,
    required this.isSelected,
  });

  final String icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected
        ? AppColors.black
        : AppColors.darkGrey.withValues(alpha: 0.3);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
      child: Column(
        children: [
          SvgPicture.asset(
            icon,
            width: 32.w,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
