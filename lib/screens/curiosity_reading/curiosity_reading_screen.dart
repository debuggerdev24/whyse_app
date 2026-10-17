import 'dart:async';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/providers/curiosity_reading/curiosity_reading_provider.dart';
import 'package:redstreakapp/providers/gamification/gamification_provider.dart';
import 'package:redstreakapp/screens/curiosity_reading/widget/curiosity_reading_content.dart';
import 'package:redstreakapp/screens/curiosity_reading/widget/curiosity_reading_screen_shimmer.dart';
import 'package:redstreakapp/screens/curiosity_reading/widgets/spark_session_summary_sheet.dart';
import 'package:redstreakapp/screens/dashboard.dart';

class CuriosityReadingScreen extends StatefulWidget {
  const CuriosityReadingScreen({super.key});

  @override
  State<CuriosityReadingScreen> createState() => _CuriosityReadingScreenState();
}

class _CuriosityReadingScreenState extends State<CuriosityReadingScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _lastTrackedReadingId;
  CuriosityReadingProvider? _provider;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = context.read<CuriosityReadingProvider>();
      _provider!.markReadingScreenActive();
      context.read<GamificationProvider>().startSparkSession();
      _provider!.onSparkAwarded = (award) {
        if (!mounted) return;
        context.read<GamificationProvider>().recordSparkCompletion(award);
      };
      _provider!.onSparkRewardsFromApi = (award) {
        if (!mounted) return;
        context.read<GamificationProvider>().applySparkInteractionRewards(award);
      };
      if (_provider!.openedFromExplore && _provider!.isLoadingReadingBody) {
        _provider!.loadExploreSessionBody();
      }
    });
  }

  @override
  void dispose() {
    _provider?.markReadingScreenInactive();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) {
      context.read<CuriosityReadingProvider>().updateScrollDepth(100);
      return;
    }

    final depth = ((_scrollController.offset / maxScroll) * 100).round().clamp(
      0,
      100,
    );
    context.read<CuriosityReadingProvider>().updateScrollDepth(depth);
  }

  void _trackReadingIfNeeded(CuriosityReadingProvider provider) {
    final reading = provider.currentReading;
    if (reading == null || reading.id == _lastTrackedReadingId) return;

    _lastTrackedReadingId = reading.id;
    _scrollController.jumpTo(0);
    provider.onReadingDisplayed(reading.id);
  }

  void _exitReading() {
    final provider = context.read<CuriosityReadingProvider>();
    final gamification = context.read<GamificationProvider>();

    provider.onLeaveReadingScreen();
    provider.markReadingScreenInactive();

    final fromExplore = provider.openedFromExplore;

    if (!mounted) return;
    context.pop();

    unawaited(() async {
      await provider.awaitPendingInteractions();
      provider.onSparkAwarded = null;
      provider.onSparkRewardsFromApi = null;

      final summary = gamification.consumeSparkSessionSummary();
      if (summary != null && !summary.isEmpty) {
        final rootContext = AppRouter.rootNavigatorKey.currentContext;
        SparkSummaryAction? action;
        if (rootContext != null && rootContext.mounted) {
          action = await showSparkSessionSummarySheet(rootContext, summary);
        }
        await gamification.fetchStreakScore(force: true);
        final tab = action == SparkSummaryAction.home ? 0 : 1;
        tabIndex.value = tab;
        AppRouter.indexedStackNavigationShell?.goBranch(tab);
      }

      if (fromExplore) {
        await provider.exitExploreSessionAndRestoreHome();
      } else {
        await provider.refreshFromHome();
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _exitReading();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          body: Consumer<CuriosityReadingProvider>(
          builder: (context, provider, child) {
            if (provider.isGettingCuriosityReading ||
                provider.isLoadingReadingBody) {
              return const CuriosityReadingScreenShimmer();
            }

            if (provider.curiosityReading == null) {
              if (!provider.isGettingCuriosityReading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  provider.getCuriosityReading();
                });
              }
              return const CuriosityReadingScreenShimmer();
            }

            final readings = provider.curiosityReading!.data.readings;
            if (readings.isEmpty) {
              return const Center(child: Text('No readings available'));
            }

            final currentIndex = provider.currentIndex;
            final isWaitingForMore =
                currentIndex >= readings.length &&
                provider.isLoadingMoreReading;

            if (isWaitingForMore) {
              return const CuriosityReadingScreenShimmer();
            }

            if (currentIndex < 0 || currentIndex >= readings.length) {
              return const Center(child: Text('No readings available'));
            }

            final currentReading = readings[currentIndex];

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _trackReadingIfNeeded(provider);
            });

            return GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity;
                if (velocity == null) return;
                if (velocity < 0) {
                  provider.nextReading();
                } else if (velocity > 0) {
                  provider.previousReading();
                }
              },
              child: SingleChildScrollView(
                key: ValueKey(currentReading.id),
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 24.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderSection(
                      context,
                      title: currentReading.question,
                      category: currentReading.interestName,
                      imageUrl: currentReading.imgUrl,
                      onBackTap: _exitReading,
                      onBookmarkTap: () {},
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                      child: CuriosityReadingContent(reading: currentReading),
                    ),
                  ],
                ),
              ),
            );
          },
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context, {
    required String title,
    required String category,
    required String imageUrl,
    required VoidCallback onBackTap,
    required VoidCallback onBookmarkTap,
  }) {
    final topInset = MediaQuery.paddingOf(context).top;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      child: SizedBox(
        height: topInset + 348.h,
        width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(
                imageUrl: imageUrl,
                tag: 'CuriosityReading.hero',
                placeholder: (_) => const AppSkeletonImagePlaceholder(),
              ).animate().fadeIn(delay: 200.ms),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0xB3000000),
                    ],
                    stops: [0, 0.52, 1],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, topInset + 10, 14.w, 22.h),
                child: Column(
                  children: [
                    SizedBox(
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GlassIconButton(
                              onTap: onBackTap,
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: Color(0xFF1C1C1E),
                                size: 28,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 56),
                            child: AppText(
                              text: 'Curiosity Reading',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bold(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GlassIconButton(
                              onTap: onBookmarkTap,
                              child: SvgIcon(
                                AppAssets.bookmark,
                                size: 20,
                                color: const Color(0xFF1C1C1E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (category.trim().isNotEmpty)
                            AppText(
                              text: category.trim().toUpperCase(),
                              style: AppTextStyles.semibold(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.92),
                              ).copyWith(letterSpacing: 1.1),
                            ),
                          8.h.verticalSpace,
                          AppText(
                            text: title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bold(
                              fontSize: 26,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                        ],
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

