import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/kback_button.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

class AgeEntryScreen extends StatefulWidget {
  const AgeEntryScreen({super.key});

  @override
  State<AgeEntryScreen> createState() => _AgeEntryScreenState();
}

class _AgeEntryScreenState extends State<AgeEntryScreen> {
  final TextEditingController _dateController = TextEditingController();
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _dateController.clear();
    super.initState();
  }

  // Show Cupertino Bottom Sheet Picker
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
                    context.read<AuthProvider>().setDate(selectedDate);

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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      // appBar: CustomBackAppBar(
      //   onBack: () {
      //     if (context.canPop()) {
      //       context.pop();
      //     } else {
      //       context.goNamed(AppRoutes.signUpScreen.name);
      //     }
      //   },
      // ),
      body: Consumer<AuthProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomBackButton(margin: EdgeInsets.only(top: 20.h)),
                      // 30.h.verticalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: 'Let us know your\nage',
                            style: AppTextStyles.sfProDisplayBold(
                              fontSize: 40.sp,
                              height: 1.1,
                            ),
                          ),

                          12.h.verticalSpace,

                          AppText(
                            text: 'Enter your Date of Birth',
                            style: AppTextStyles.textStyle16Medium,
                          ),

                          18.h.verticalSpace,

                          // Cupertino Picker Trigger
                          GestureDetector(
                            onTap: () => _showCupertinoPicker(context),
                            child: AbsorbPointer(
                              child: AppTextField(
                                hintText: "MM/DD/YYYY",
                                controller: _dateController,
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(13.0),
                                  child: SvgIcon(
                                    AppAssets.datepicker,
                                    size: 24.w,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: AlignmentGeometry.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),

                          child: AppFilledButton(
                            backgroundColor: AppColors.primaryColor,
                            text: "Continue",
                            onTap: () async {
                              if (_dateController.text.trim().isEmpty) {
                                AppToast.error(
                                  context,
                                  "Please enter birth date",
                                );
                                return;
                              }
                              if (provider.selectedDate == null) {
                                AppToast.error(
                                  context,
                                  "Please select your date of birth",
                                );
                                return;
                              }

                              await provider.saveAge(
                                context: context,
                                onSuccess: () {
                                  AppToast.success(
                                    context,
                                    "Age saved successfully",
                                  );
                                  _dateController.clear();

                                  if (provider.isUnder16) {
                                    context.pushNamed(
                                      AppRoutes.parentEmailScreen.name,
                                    );
                                    return;
                                  }
                                  provider.clearCreateAccountFields();
                                  context.pushNamed(
                                    AppRoutes.createAccountScreen.name,
                                    // extra: false,
                                  );
                                },
                                onFailed: (error) {
                                  AppToast.success(context, error);
                                },
                              );

                              // if (success && context.mounted) {
                              // if (authProvider.apiIsUnder16) {
                              // context.pushNamed(UserAppRoutes.parentEmailScreen.name);
                              // } else {
                              // }
                              // }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider.isSaveUserAgeLoading) FullPageIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }
}
