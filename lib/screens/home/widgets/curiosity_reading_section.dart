import 'dart:ui';

import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/curiosity_reading/curiosity_reading_model.dart';
import 'package:redstreakapp/providers/curiosity_reading/curiosity_reading_provider.dart';

class CuriosityReadingSection extends StatelessWidget {
  const CuriosityReadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: AppText(
            text: "Today's Sparks",
            style: AppTextStyles.bold(fontSize: 22.sp, color: AppColors.black),
          ),
        ),
        // 6.w.verticalSpace,
        Consumer<CuriosityReadingProvider>(
          builder: (context, provider, child) {
            if (provider.isGettingCuriosityReading) {
              return const _CuriosityReadingLoadingUI();
            }

            if (provider.currentReadingError != null) {
              return _CuriosityReadingErrorUI(
                message: provider.currentReadingError!,
                onRetry: provider.retryLoadCuriosityReading,
              );
            }

            final readings = provider.curiosityReading?.data.readings;
            if (readings == null) {
              return const _CuriosityReadingLoadingUI();
            }
            if (readings.isEmpty) {
              return Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                child: AppText(
                  text: 'No sparks for today yet',
                  style: AppTextStyles.medium(
                    fontSize: 14.sp,
                    color: AppColors.darkGrey,
                  ),
                ),
              );
            }

            return _SparkDeck(
              readings: readings,
              hasMore:
                  provider.curiosityReading?.data.meta.pagination.hasMore ??
                  false,
              isLoadingMore: provider.isLoadingMoreReading,
              onLoadMore: provider.loadMoreReading,
              onOpen: (index) {
                provider.setCurrentIndex(index);
                context.pushNamed(AppRoutes.curiosityReadingScreen.name);
              },
            );
          },
        ),
      ],
    );
  }
}

class _SparkDeck extends StatefulWidget {
  const _SparkDeck({
    required this.readings,
    required this.onOpen,
    required this.onLoadMore,
    required this.hasMore,
    required this.isLoadingMore,
  });

  final List<Reading> readings;
  final ValueChanged<int> onOpen;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  @override
  State<_SparkDeck> createState() => _SparkDeckState();
}

class _SparkDeckState extends State<_SparkDeck>
    with SingleTickerProviderStateMixin {
  static const _visibleBehind = 2;

  late final AnimationController _settle;
  int _index = 0;
  double _drag = 0;
  double _from = 0;
  double _to = 0;
  int _indexDelta = 0;
  bool _settling = false;
  bool _dragMoved = false;
  String? _firstId;
  int _requestedMoreAtLength = -1;

  @override
  void initState() {
    super.initState();
    _firstId = widget.readings.first.id;
    _settle =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 320),
        )..addListener(() {
          if (mounted) setState(() {});
        });
    _settle.addStatusListener((status) {
      if (status != AnimationStatus.completed || !_settling) return;
      _settling = false;
      _settle.value = 0;
      if (!mounted) return;
      setState(() {
        if (_indexDelta != 0) {
          final last = widget.readings.length - 1;
          _index = (_index + _indexDelta).clamp(0, last < 0 ? 0 : last);
          _indexDelta = 0;
          _requestNextPage(_index);
        }
        _drag = 0;
      });
    });
  }

  @override
  void didUpdateWidget(covariant _SparkDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    final firstId = widget.readings.isEmpty ? null : widget.readings.first.id;
    if (firstId != _firstId) {
      _firstId = firstId;
      _index = 0;
      _drag = 0;
      _indexDelta = 0;
      _settling = false;
      _requestedMoreAtLength = -1;
      _settle.value = 0;
    }
    if (widget.readings.isEmpty) return;
    if (_index >= widget.readings.length) {
      _index = widget.readings.length - 1;
    }
  }

  double get _displayDrag {
    if (!_settling) return _drag;
    final t = Curves.easeOutCubic.transform(_settle.value);
    return _from + (_to - _from) * t;
  }

  void _requestNextPage(int index) {
    if (!widget.hasMore || widget.isLoadingMore) return;
    if (index < widget.readings.length - 2) return;
    if (_requestedMoreAtLength == widget.readings.length) return;
    _requestedMoreAtLength = widget.readings.length;
    widget.onLoadMore();
  }

  void _animateTo(double target, {int indexDelta = 0}) {
    _from = _displayDrag;
    _to = target;
    _indexDelta = indexDelta;
    _settling = true;
    _drag = target;
    _settle.forward(from: 0);
  }

  void _onDragUpdate(DragUpdateDetails details, double width) {
    if (_settling) return;
    var next = _drag + details.delta.dx;
    final atStart = _index <= 0 && next > 0;
    final atEnd = _index >= widget.readings.length - 1 && next < 0;
    if (atStart || atEnd) {
      next = _drag + details.delta.dx * 0.22;
    }
    if (details.delta.dx.abs() > 1) _dragMoved = true;
    setState(() => _drag = next.clamp(-width, width));
  }

  void _onDragEnd(double width, double velocity) {
    if (_settling) return;
    final goNext =
        (_drag < -width * 0.22 || velocity < -650) &&
        _index < widget.readings.length - 1;
    final goPrev = (_drag > width * 0.22 || velocity > 650) && _index > 0;
    if (goNext) {
      _animateTo(-width, indexDelta: 1);
      return;
    }
    if (goPrev) {
      _animateTo(width, indexDelta: -1);
      return;
    }
    _animateTo(0);
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peek = 16.w;
    final active = _index.clamp(0, widget.readings.length - 1);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final drag = _displayDrag;
              final leftProgress = drag < 0
                  ? (-drag / width).clamp(0.0, 1.0)
                  : 0.0;
              final rightProgress = drag > 0
                  ? (drag / width).clamp(0.0, 1.0)
                  : 0.0;

              final layers = <Widget>[];
              for (var depth = _visibleBehind; depth >= 0; depth--) {
                final index = _index + depth;
                if (index < 0 || index >= widget.readings.length) continue;
                final visualDepth = depth - leftProgress + rightProgress;
                layers.add(
                  _stackedCard(
                    width: width,
                    peek: peek,
                    visualDepth: visualDepth,
                    reading: widget.readings[index],
                    onOpen: depth == 0 && drag.abs() < 12 && !_dragMoved
                        ? () => widget.onOpen(index)
                        : null,
                  ),
                );
              }
              if (rightProgress > 0 && _index > 0) {
                layers.add(
                  _stackedCard(
                    width: width,
                    peek: peek,
                    visualDepth: rightProgress - 1,
                    reading: widget.readings[_index - 1],
                    onOpen: null,
                  ),
                );
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (_) {
                  if (_settling) return;
                  _dragMoved = false;
                },
                onHorizontalDragUpdate: (details) =>
                    _onDragUpdate(details, width),
                onHorizontalDragEnd: (details) {
                  _onDragEnd(width, details.primaryVelocity ?? 0);
                  _dragMoved = false;
                },
                onHorizontalDragCancel: () {
                  if (!_settling) _animateTo(0);
                  _dragMoved = false;
                },
                child: SizedBox(
                  height: 318.h,
                  child: Padding(
                    padding: EdgeInsets.only(right: peek * _visibleBehind),
                    child: Stack(clipBehavior: Clip.none, children: layers),
                  ),
                ),
              );
            },
          ),
        ),
        12.h.verticalSpace,
        _SparkPageDots(
          count: widget.readings.length,
          active: active,
          hasMore: widget.hasMore,
        ),
        if (widget.isLoadingMore) ...[
          8.h.verticalSpace,
          const _SparkPageLoader(),
        ],
      ],
    );
  }

  Widget _stackedCard({
    required double width,
    required double peek,
    required double visualDepth,
    required Reading reading,
    required VoidCallback? onOpen,
  }) {
    final depth = visualDepth.clamp(-1.15, 2.2);
    final dx = depth < 0 ? depth * width : depth * peek;
    final scale = depth <= 0 ? 1.0 : (1 - depth * 0.035).clamp(0.9, 1.0);
    final tilt = depth < 0 ? depth * 0.05 : 0.0;
    final dim = depth <= 0 ? 0.0 : (depth * 0.34).clamp(0.0, 0.62);

    return Positioned.fill(
      child: Transform.translate(
        offset: Offset(dx, depth > 0 ? depth * 2 : 0),
        child: Transform.rotate(
          angle: tilt,
          alignment: Alignment.bottomCenter,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: _SparkFace(reading: reading, dim: dim, onOpen: onOpen),
          ),
        ),
      ),
    );
  }
}

class _SparkPageDots extends StatelessWidget {
  const _SparkPageDots({
    required this.count,
    required this.active,
    required this.hasMore,
  });

  final int count;
  final int active;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    const window = 7;
    final start = count <= window ? 0 : (active - 3).clamp(0, count - window);
    final end = count <= window ? count : start + window;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = start; i < end; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            width: i == active ? 16.w : 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: i == active
                  ? AppColors.highlight
                  : const Color(0xFFD5D5DA),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        if (hasMore)
          Container(
            margin: EdgeInsets.only(left: 3.w),
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: const Color(0xFFD5D5DA),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
      ],
    );
  }
}

class _SparkPageLoader extends StatelessWidget {
  const _SparkPageLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

class _SparkFace extends StatelessWidget {
  const _SparkFace({required this.reading, required this.dim, this.onOpen});

  final Reading reading;
  final double dim;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final title = reading.question.trim().isNotEmpty
        ? reading.question
        : reading.title;
    final minutes = reading.estimatedReadTimeMinutes;
    final category = reading.interestName.trim();

    return GestureDetector(
      onTap: onOpen,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(
                imageUrl: reading.imgUrl,
                tag: 'CuriosityReading.card',
                placeholder: (_) => _ImageShimmerPlaceholder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
                errorBuilder: (_, _, _) => _ImageErrorPlaceholder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.72),
                    ],
                    stops: const [0.0, 0.42, 1],
                  ),
                ),
              ),
              if (dim > 0)
                ColoredBox(color: Colors.black.withValues(alpha: dim)),
              if (category.isNotEmpty)
                Positioned(
                  top: 14.h,
                  right: 14.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: AppText(
                      text: category,
                      style: AppTextStyles.medium(
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 16.h,
                child: Column(  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      text: title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bold(
                        fontSize: 26.sp,
                        height: 1.15,
                        color: Colors.white,
                      ),
                    ),
                    8.h.verticalSpace,
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 15.w,
                        ),
                        6.w.horizontalSpace,
                        AppText(
                          text: minutes > 0
                              ? '$minutes mins read'
                              : 'Quick read',
                          style: AppTextStyles.medium(
                            fontSize: 13.sp,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    14.h.verticalSpace,
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              width: 54,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.42),
                                    Colors.white.withValues(alpha: 0.22),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20.w,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 18.w,
                        ),
                        4.w.horizontalSpace,
                        AppText(
                          text: 'Spark',
                          style: AppTextStyles.semibold(
                            fontSize: 15.sp,
                            color: Colors.white,
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
    );
  }
}

class _ImageShimmerPlaceholder extends StatelessWidget {
  const _ImageShimmerPlaceholder({required this.borderRadius});

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D3A4A),
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder({required this.borderRadius});

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A3A4A),
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.white.setOpacity(0.7),
            size: 34.w,
          ),
          6.h.verticalSpace,
          AppText(
            text: 'Image unavailable',
            style: AppTextStyles.semiBold(
              fontSize: 11.sp,
              color: Colors.white.setOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _CuriosityReadingErrorUI extends StatelessWidget {
  const _CuriosityReadingErrorUI({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
      child: Container(
        height: 280.w,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        decoration: BoxDecoration(
          color: AppColors.extealighttealcolor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.teal.setOpacity(0.18)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 56.r,
              width: 56.r,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(14.r),
              child: SvgIcon(AppAssets.brain, color: AppColors.teal),
            ),
            16.h.verticalSpace,
            AppText(
              text: 'Couldn\'t load readings',
              style: AppTextStyles.bold(fontSize: 17.sp, color: AppColors.teal),
              textAlign: TextAlign.center,
            ),
            8.h.verticalSpace,
            AppText(
              text: message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.regular(
                fontSize: 13.sp,
                color: AppColors.black.setOpacity(0.65),
              ),
              textAlign: TextAlign.center,
            ),
            20.h.verticalSpace,
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.setOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: AppColors.white,
                      size: 18.r,
                    ),
                    8.w.horizontalSpace,
                    AppText(
                      text: 'Try again',
                      style: AppTextStyles.bold(
                        fontSize: 14.sp,
                        color: AppColors.white,
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
}

class _CuriosityReadingLoadingUI extends StatelessWidget {
  const _CuriosityReadingLoadingUI();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 28.w, 0),
      child: AppSkeletonizer(
        child: Container(
          height: 318.h,
          decoration: BoxDecoration(
            color: AppColors.shimmerBaseColor,
            borderRadius: BorderRadius.circular(28.r),
          ),
        ),
      ),
    );
  }
}
