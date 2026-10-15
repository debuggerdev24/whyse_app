import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/providers/curiosity_reading/curiosity_reading_provider.dart';
import 'package:redstreakapp/providers/explore/explore_provider.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
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
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder: (context, value, child) => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Builder(
          builder: (context) {
            final media = MediaQuery.of(context);
            return Stack(
              children: [
                MediaQuery(
                  data: media.copyWith(
                    padding: media.padding.copyWith(
                      bottom: media.viewPadding.bottom + 96,
                    ),
                  ),
                  child: widget.navigationShell,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _GlassBottomBar(
                    currentIndex: value,
                    onTap: (index) {
                      tabIndex.value = index;
                      AppRouter.indexedStackNavigationShell?.goBranch(index);
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
    (AppAssets.community, 'Community'),
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
              child: _LiquidGlass(
                borderRadius: BorderRadius.circular(barHeight),
                child: Row(
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

class _LiquidGlass extends StatelessWidget {
  const _LiquidGlass({required this.borderRadius, required this.child});

  final BorderRadius borderRadius;
  final Widget child;

  static final ImageFilter _blur = ImageFilter.compose(
    outer: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
    inner: const ColorFilter.matrix(<double>[
      1.35, -0.15, -0.15, 0, 8,
      -0.15, 1.35, -0.15, 0, 8,
      -0.15, -0.15, 1.35, 0, 8,
      0, 0, 0, 1, 0,
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E6E73).withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: _blur,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: Colors.white.withValues(alpha: 0.28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.55),
                width: 1,
              ),
            ),
            child: child,
          ),
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
    final color = selected ? const Color(0xFF1C1C1E) : const Color(0xFF8E8E93);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: selected ? 64 : 0,
            height: selected ? 64 : 0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8E8E93).withValues(
                alpha: selected ? 0.30 : 0,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: AppTextStyles.medium(
                  fontSize: 11,
                  color: color,
                ).copyWith(height: 1.05, letterSpacing: -0.2),
              ),
            ],
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
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.profileScreen.name),
      child: SizedBox(
        width: size,
        height: size,
        child: _LiquidGlass(
          borderRadius: BorderRadius.circular(size),
          child: Center(
            child: SvgPicture.asset(
              AppAssets.profileIcon,
              width: 26,
              height: 26,
              colorFilter: const ColorFilter.mode(
                Color(0xFF1C1C1E),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
