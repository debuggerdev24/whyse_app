import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color color;

  const CustomBackButton({super.key, this.onTap, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 27.w, top: 20.h),
      child: GestureDetector(
        onTap:
            onTap ??
            () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(AppAssets.backButton, size: 13.sp, color: color),
            12.w.horizontalSpace,
            AppText(
              text: "Back",
              style: AppTextStyles.textStyle14Semibold.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------- READY-TO-USE APP BAR WITH BACK BUTTON ----------
class CustomBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color backgroundColor;
  final VoidCallback? onBack;

  const CustomBackAppBar({
    super.key,
    this.backgroundColor = AppColors.backgroundColor,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Align(
        alignment: Alignment.centerLeft,
        child: CustomBackButton(onTap: onBack),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(90.h);
}
