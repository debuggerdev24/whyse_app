import 'package:flutter_animate/flutter_animate.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/providers/curiosity_reading/curiosity_reading_provider.dart';
import 'package:redstreakapp/screens/curiosity_reading/widget/curiosity_reading_content.dart';
import 'package:redstreakapp/screens/curiosity_reading/widget/curiosity_reading_screen_shimmer.dart';

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

  Future<void> _exitToHome() async {
    final provider = context.read<CuriosityReadingProvider>();
    await provider.onLeaveReadingScreen();
    provider.markReadingScreenInactive();
    if (mounted) context.pop();
    provider.refreshFromHome();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _exitToHome();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Consumer<CuriosityReadingProvider>(
          builder: (context, provider, child) {
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
              child: Column(
                key: ValueKey(currentReading.id),
                children: [
                  _buildHeaderSection(
                    context,
                    title: currentReading.question,
                    imageUrl: currentReading.imgUrl,
                    onBackTap: _exitToHome,
                    onBookmarkTap: () {},
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(25.w, 20.h, 25.w, 0),
                      physics: const BouncingScrollPhysics(),
                      child: CuriosityReadingContent(reading: currentReading),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context, {
    required String title,
    required String imageUrl,
    required VoidCallback onBackTap,
    required VoidCallback onBookmarkTap,
  }) {
    return SizedBox(
      height: 340.h,
      width: double.maxFinite,
      child: Stack(
        children: [
          Positioned.fill(
            child: AppNetworkImage(
              imageUrl: imageUrl,
              tag: 'CuriosityReading.hero',
              placeholder: (_) => const AppSkeletonImagePlaceholder(),
            ).animate().fadeIn(delay: 200.ms),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.setOpacity(0.1),
                    Colors.black.setOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12.r,
                  left: 25.w,
                  right: 25.w,
                ),
                height: 40.h,
                width: double.maxFinite,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: onBackTap,
                        child: Container(
                          height: 40.h,
                          width: 40.h,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: .all(13.r),
                          child: SvgIcon(AppAssets.backButton),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: AppText(
                        text: 'Sparks',
                        style: AppTextStyles.semiBold(
                          fontSize: 20,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: onBookmarkTap,
                        child: Container(
                          height: 40.h,
                          width: 40.h,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: .all(10.r),
                          child: SvgIcon(AppAssets.bookmark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.w, 0, 25.w, 16.h),
                    child: AppText(
                      text: title,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semiBold(
                        fontSize: 18,
                        color: AppColors.white,
                      ).copyWith(height: 1.35, letterSpacing: 0.1),
                      textAlign: TextAlign.start,
                    ).animate().fadeInRight(curve: Curves.decelerate),
                  ),
                  Container(
                    height: 30.h,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
