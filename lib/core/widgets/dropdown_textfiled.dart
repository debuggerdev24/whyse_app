import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';

class CustomDropDown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const CustomDropDown({
    Key? key,
    required this.hint,
    required this.items,
    this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: AppColors.darkGrey.withOpacity(0.1),
        canvasColor: Colors.white,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.black.withOpacity(0.1), width: 1),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.black,
              size: 22.sp,
            ),

            dropdownColor: Colors.white,
            elevation: 3,

            style: AppTextStyles.sfProDisplayRegular(
              fontSize: 16.sp,
              color: AppColors.black,
            ),

            hint: AppText(
              text: hint,
              style: AppTextStyles.sfProDisplaySemibold(
                fontSize: 14.sp,
                color: AppColors.black.withOpacity(0.3),
              ),
            ),

            isExpanded: true,
            borderRadius: BorderRadius.circular(12.r),

            items: items.map((String item) {
              return DropdownMenuItem(
                value: item,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: AppText(
                    text: item,
                    style: AppTextStyles.sfProDisplayMedium(
                      fontSize: 16.sp,
                      color: AppColors.black,
                    ),
                  ),
                ),
              );
            }).toList(),

            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
