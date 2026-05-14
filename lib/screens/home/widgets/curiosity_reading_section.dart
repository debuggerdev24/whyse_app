import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/providers/home/curiosity_reading_provider.dart';
import 'package:shimmer/shimmer.dart';

class CuriosityReadingSection extends StatelessWidget {
  const CuriosityReadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              SvgIcon(AppAssets.brain, size: 24.w),
              const SizedBox(width: 5),
              AppText(
                text: "Curiosity Reading",
                style: AppTextStyles.bold(
                  fontSize: 20.sp,
                  color: AppColors.teal,
                ),
              ),
              SvgIcon(AppAssets.rightArrow, size: 24.w),
            ],
          ),
        ),
        // 6.w.verticalSpace,
        Consumer<CuriosityReadingProvider>(
          builder: (context, provider, child) {
            return SizedBox(
              height: 280.w,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(
                  left: 10.w,
                  right: 18.w,
                  top: 0,
                  bottom: 0,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: provider.curiosityReadingList.length,  
                itemBuilder: (context, index) {
                  return ArticleCard(
                    onReadTap: () {
                      provider.setCurrentIndex(index);
                      context.pushNamed(AppRoutes.curiosityReadingScreen.name);
                    },
                    item: _CuriosityItem(
                      title: provider.curiosityReadingList[index]['title'],
                      imageUrl:
                          provider.curiosityReadingList[index]['imageUrl'],
                    ),
                    cardWidth: 260.w,
                    cardHeight: 280.w,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class ArticleCard extends StatelessWidget {
  final _CuriosityItem item;
  final VoidCallback? onReadTap;
  final double cardWidth;
  final double cardHeight;

  const ArticleCard({
    super.key,
    required this.item,
    this.onReadTap,
    this.cardWidth = 260,
    this.cardHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onReadTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.setOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              AppNetworkImage(
                imageUrl: item.imageUrl,
                tag: 'CuriosityReading.card',
                placeholder: (_) => _ImageShimmerPlaceholder(
                  borderRadius: BorderRadius.circular(20),
                ),
                errorBuilder: (_, __, ___) => _ImageErrorPlaceholder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.setOpacity(0.65)],
                    stops: const [0.35, 1.0],
                  ),
                ),
              ),

              // Brain icon (top right)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: Colors.black.setOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(4),
                  child: SvgIcon(
                    AppAssets.brain,
                    size: 24.w,
                    color: AppColors.white,
                  ),
                ),
              ),

              // Title and Read button (bottom left)
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // const SizedBox(height: 8),
                    // _ReadButton(onTap: onReadTap),
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

class _CuriosityItem {
  const _CuriosityItem({required this.title, required this.imageUrl});

  final String title;
  final String imageUrl;
}

class _ImageShimmerPlaceholder extends StatelessWidget {
  const _ImageShimmerPlaceholder({required this.borderRadius});

  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2D3A4A),
      highlightColor: const Color(0xFF405165),
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
