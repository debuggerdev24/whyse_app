import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/kback_button.dart';
import 'package:redstreakapp/providers/auth_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class AgeEntryScreen extends StatefulWidget {
  const AgeEntryScreen({super.key});

  @override
  State<AgeEntryScreen> createState() => _AgeEntryScreenState();
}

class _AgeEntryScreenState extends State<AgeEntryScreen> {
  final TextEditingController _dateController = TextEditingController();

  /// Show Cupertino Bottom Sheet Picker
  void _showCupertinoPicker(BuildContext context) {
    DateTime selectedDate = DateTime.now().subtract(
      const Duration(days: 365 * 18),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SizedBox(
          height: 250.h,
          child: Column(
            children: [
              /// DONE Button
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 16.w, top: 10.h),
                child: GestureDetector(
                  onTap: () {
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).setDate(selectedDate);

                    _dateController.text =
                        '${selectedDate.month.toString().padLeft(2, '0')}/'
                        '${selectedDate.day.toString().padLeft(2, '0')}/'
                        '${selectedDate.year}';

                    Navigator.pop(context);
                  },
                  child: Text(
                    "Done",
                    style: TextStyle(
                      color: AppColors.teal,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  maximumDate: DateTime.now(),
                  // minimumDate: DateTime(1900),
                  initialDateTime: DateTime.now().subtract(
                    const Duration(days: 365 * 18),
                  ),
                  onDateTimeChanged: (value) {
                    selectedDate = value;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ageProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomBackAppBar(
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            // Fallback if history is missing
            context.goNamed(UserAppRoutes.signUpScreen.name);
          }
        },
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            30.h.verticalSpace,

            AppText(
              text: 'Let us know your\nage',
              style: AppTextStyles.sfProDisplayBold(fontSize: 40.sp),
            ),

            12.h.verticalSpace,

            AppText(
              text: 'Enter your Date of Birth',
              style: AppTextStyles.textStyle16Medium,
            ),

            18.h.verticalSpace,

            /// Cupertino Picker Trigger
            GestureDetector(
              onTap: () => _showCupertinoPicker(context),
              child: AbsorbPointer(
                child: AppTextField(
                  hintText: "MM/DD/YYYY",
                  controller: _dateController,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: SvgIcon(AppAssets.datepicker, size: 24.w),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: AppButton(
          backgroundColor: AppColors.yellowcolor,
          text: "Continue",
          onPressed: () async {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );

            if (authProvider.selectedDate == null) {
              CustomToast.showError(
                context,
                "Please select your date of birth",
              );
              return;
            }

            final success = await authProvider.saveUserAge(context);

            if (success && context.mounted) {
              // if (authProvider.apiIsUnder16) {
              // context.pushNamed(UserAppRoutes.parentEmailScreen.name);
              //  else {
              context.pushNamed(UserAppRoutes.createAccountScreen.name);
              // }
            }
          },
        ),
      ),
    );
  }
}
