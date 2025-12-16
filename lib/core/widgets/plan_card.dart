import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';

class PlanCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  final String title;
  final String price;
  final List<String> features;

  const PlanCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.title,
    required this.price,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: EdgeInsets.only(right: 11.w),

            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 1,
                  spreadRadius: -2,
                  offset: const Offset(0, 2),
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.teal : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      22.h.verticalSpace,

                      // TITLE
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: AppText(
                          text: title,
                          style: AppTextStyles.textStyle16Semibold,
                        ),
                      ),

                      10.h.verticalSpace,

                      // FEATURES (NO padding changed)
                      ...features.map((e) => _bullet(e)).toList(),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding:
                              EdgeInsets.only(bottom: 13.h, right: 15.w),
                          child: AppText(
                            text: price,
                            style: AppTextStyles.sfProDisplayBold(
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isSelected)
            Positioned(
              right:0,
              top: -8,
              bottom: -9,
              child: SvgIcon(
                AppAssets.check,
                size: 32.w,
              ),
            ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 23.w,
      ),
      child: Row(
        children: [
          SvgIcon(AppAssets.done, size: 20.w),
          6.w.horizontalSpace,
          AppText(
            text: text,
            style: AppTextStyles.sfProDisplayMedium(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}


