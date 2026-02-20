import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/utils/field_validator.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';

import '../../core/utils/shared_pref.dart';
import '../../core/widgets/custom_toast.dart';
import '../../core/widgets/kback_button.dart';
import '../../routes/user_routes.dart';

class ParentEmailScreen extends StatefulWidget {
  const ParentEmailScreen({super.key});

  @override
  State<ParentEmailScreen> createState() => _ParentEmailScreenState();
}

class _ParentEmailScreenState extends State<ParentEmailScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    context.read<AuthProvider>().parentEmailCtr.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomBackButton(margin: EdgeInsets.only(top: 20.h)),
                        120.h.verticalSpace,
                        AppText(
                          text: "Need Parent’s help to Proceed",
                          style: AppTextStyles.sfProDisplayBold(
                            height: 1.2,
                            fontSize: 40.sp,
                            color: AppColors.black,
                          ),
                        ),
                        13.h.verticalSpace,
                        AppText(
                          text: "Enter your Parent’s email to proceed.",
                          style: AppTextStyles.sfProDisplayMedium(
                            fontSize: 16.sp,
                            color: AppColors.black,
                          ),
                        ),
                        18.h.verticalSpace,
                        AppTextField(
                          controller: provider.parentEmailCtr,
                          hintText: "Email",
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => FieldValidators().email(value),
                        ),
                        const Spacer(),
                        AppFilledButton(
                          isLoading: provider.isLoading,
                          onTap: () async {
                            // context.pushNamed(AppRoutes.consentStatusScreen.name);
                            // return;
                            if (formKey.currentState!.validate()) {
                              await provider.saveParentEmail(
                                context: context,

                                onFailed: (error) {
                                  AppToast.error(context, error);
                                },
                                onSuccess: () {
                                  AppToast.success(
                                    context,
                                    "The consent request has been sent to the parent. Verify your email.",
                                  );

                                  context.pushNamed(
                                    AppRoutes.consentStatusScreen.name,
                                  );
                                  LocalStorageService.instance
                                      .saveParentConsentStatus(status: false);
                                },
                              );
                            }
                          },
                          text: "Send Request",
                          backgroundColor: AppColors.primaryColor,
                        ),

                        10.h.verticalSpace,
                      ],
                    ),
                  ),
                ),
                if (provider.isSaveParentEmailLoading) FullPageIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }
}
