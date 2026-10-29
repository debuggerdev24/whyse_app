import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/widgets/glass_icon_button.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/theme/theme_refresh.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/providers/curiosity_reading/curiosity_reading_provider.dart';
import 'package:redstreakapp/providers/explore/explore_provider.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/providers/home/home_provider.dart';
import 'package:redstreakapp/providers/home/saved_series_provider.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/providers/theme/app_theme_provider.dart';
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

  void callInitApis({required BuildContext context}) async {
    await Future.wait([
      homeProvider.getMyTopics(),
      curiosityReadingProvider.refreshFromHome(),
      context.read<GamificationProvider>().fetchStreakScore(),
      context.read<ProfileProvider>().getProfile(),
      context.read<SavedSeriesProvider>().getMySeriesList(),
      context.read<ExploreProvider>().prefetchExploreCache(),

      storyProvider.getStoryGoals(
        onFailed: (error) {
          AppToast.error(context, "Goal $error");
        },
      ),

      storyProvider.getStoryInterest(
        onFailed: (error) {
          AppToast.error(context, "Interest $error");
        },
      ),

      storyProvider.getStoryTopics(
        onFailed: (error) {
          AppToast.error(context, "Topic $error");
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final themeId = context.watch<AppThemeProvider>().palette.id;
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (context, value, child) => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Builder(
          builder: (context) {
            final media = MediaQuery.of(context);
            final hideBottomBar = value == 3;
            return Stack(
              children: [
                MediaQuery(
                  data: media.copyWith(
                    padding: media.padding.copyWith(
                      bottom: media.viewPadding.bottom +
                          (hideBottomBar ? 0 : 96),
                    ),
                  ),
                  child: ThemeRefresh(
                    themeId: themeId,
                    child: widget.navigationShell,
                  ),
                ),
                if (!hideBottomBar)
                  Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _GlassBottomBar(
                    currentIndex: value,
                    onTap: (index) {
                      final shell = AppRouter.indexedStackNavigationShell;
                      final alreadyOnTab = shell?.currentIndex == index;
                      tabIndex.value = index;
                      shell?.goBranch(
                        index,
                        initialLocation: alreadyOnTab,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GlassBottomBar extends StatelessWidget {
  const _GlassBottomBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <(String, String)>[
    (AppAssets.homeIcon, 'Home'),
    (AppAssets.explore, 'Explore'),
    (AppAssets.rewards, 'Rewards'),
    (AppAssets.aiChat, 'AI Chat'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    const barHeight = 62.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, bottom + 5),
      child: SizedBox(
        height: barHeight,
        child: Row(
          children: [
            Expanded(
              child: GlassSurface(
                borderRadius: BorderRadius.circular(barHeight),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final slot = constraints.maxWidth / _items.length;
                    const inset = 5.0;
                    return Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 480),
                          curve: Curves.easeOutBack,
                          left: currentIndex * slot + inset,
                          width: slot - inset * 2,
                          top: 5,
                          bottom: 5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < _items.length; i++)
                              Expanded(
                                child: _GlassNavItem(
                                  icon: _items[i].$1,
                                  label: _items[i].$2,
                                  selected: currentIndex == i,
                                  onTap: () => onTap(i),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            _NavProfileButton(size: barHeight),
          ],
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  const _GlassNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.onFill
        : (AppColors.isDark ? AppColors.muted : const Color(0xFF3C3C43));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: color),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SvgPicture.asset(
                icon,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  value ?? color,
                  BlendMode.srcIn,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            style: TextStyle(
              fontFamily: 'SFProText',
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 10,
              height: 1.05,
              letterSpacing: -0.08,
              color: color,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavProfileButton extends StatelessWidget {
  const _NavProfileButton({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return GlassIconButton(
      size: size,
      onTap: () => context.pushNamed(AppRoutes.profileScreen.name),
      child: SvgPicture.asset(
        AppAssets.profileIcon,
        width: 22,
        height: 22,
        colorFilter: ColorFilter.mode(
          AppColors.black,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
