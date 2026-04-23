import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/home/curiosity_reading_provider.dart';
import 'package:shimmer/shimmer.dart';

class CuriosityReadingScreen extends StatelessWidget {
  const CuriosityReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Consumer<CuriosityReadingProvider>(
        builder: (context, provider, child) {
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                provider.nextReading();
              }
            },
            child: Column(
              key: ValueKey(provider.currentIndex),
              children: [
                _buildHeaderSection(
                  context,
                  title: provider
                      .curiosityReadingList[provider.currentIndex]['title'],
                  imageUrl: provider
                      .curiosityReadingList[provider.currentIndex]['imageUrl'],
                  onBackTap: () => context.pop(),
                  onBookmarkTap: () {},
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 25.w),
                    child: Column(
                      children: [
                        AppText(
                          text:
                              provider.curiosityReadingList[provider
                                  .currentIndex]['description'],
                          style: AppTextStyles.regular(
                            fontSize: 16,
                            color: AppColors.black.setOpacity(0.8),
                          ),
                        ).animate().fadeInRight(
                          delay: 200.ms,
                          curve: Curves.decelerate,
                        ),
                        18.h.verticalSpace,
                        Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: AppColors.teal.setOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding: .symmetric(vertical: 14.r, horizontal: 20.r),
                          child: AppText(
                            text:
                                provider.curiosityReadingList[provider
                                    .currentIndex]['fact'],
                            style: AppTextStyles.medium(
                              fontSize: 14,
                              color: AppColors.teal,
                            ),
                          ),
                        ).animate().fadeInRight(
                          delay: 400.ms,
                          curve: Curves.decelerate,
                        ),
                        25.w.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
      height: 400.h,
      width: double.maxFinite,
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(color: Colors.white),
              ),
              fit: BoxFit.cover,
            ).animate().fadeIn(delay: 200.ms),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.6),
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
                        text: 'Curiosity Reading',
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
                    padding: EdgeInsets.all(25.w),
                    child: AppText(
                      text: title,
                      style: AppTextStyles.bold(
                        fontSize: 24,
                        color: AppColors.white,
                      ),
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
