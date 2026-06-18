import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/providers/curiosity_reading/curiosity_reading_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/saved_series_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/core/routes/app_router.dart';

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
  late CuriosityReadingProvider curiosityReadingProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      storyProvider = context.read<StoryProvider>();
      homeProvider = context.read<HomeProvider>();
      curiosityReadingProvider = context.read<CuriosityReadingProvider>();
      callInitApis(context: context);
    });
  }

  void callInitApis({required BuildContext context}) {
    context.read<ProfileProvider>().getProfile();
    homeProvider.getMyTopics();
    context.read<SavedSeriesProvider>().getMySeriesList();
    curiosityReadingProvider.refreshFromHome();

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
        backgroundColor: AppColors.backgroundColor,
        body: widget.navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: tabIndex.value,
          onTap: (index) {
            tabIndex.value = index;
            AppRouter.indexedStackNavigationShell?.goBranch(index);
          },
          items: [
            BottomNavItem(
              icon: AppAssets.homeIcon,
              isSelected: value == 0,
              index: 0,
            ),
            BottomNavItem(
              icon: AppAssets.explore,
              isSelected: value == 1,
              index: 1,
            ),
            BottomNavItem(
              icon: AppAssets.streak,
              isSelected: value == 2,
              index: 2,
            ),
            BottomNavItem(
              icon: AppAssets.chat,
              isSelected: value == 3,
              index: 3,
            ),
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
      padding: EdgeInsets.only(
        top: 18.r,
        bottom: MediaQuery.of(context).padding.bottom + 10.r,
      ),
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
    required this.index,
  });

  final String icon;
  final bool isSelected;
  final int index;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected
        ? AppColors.black
        : AppColors.darkGrey.withValues(alpha: 0.4);

    return Padding(
      padding: EdgeInsets.only(
        left: index == 0 ? 30.w : 0, 
        right: index == 3 ? 30.w : 0,
      ),
      child: SvgPicture.asset(
        icon,
        width: (index == 1) ? 40.w : 32.w,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        theme: SvgTheme(currentColor: color),
      ),
    );
  }
}
