import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/kback_button.dart';
import 'package:redstreakapp/providers/auth_provider.dart';
import 'package:redstreakapp/routes/user_routes.dart';

class ParentEmailScreen extends StatefulWidget {
  const ParentEmailScreen({super.key});

  @override
  State<ParentEmailScreen> createState() => _ParentEmailScreenState();
}

class _ParentEmailScreenState extends State<ParentEmailScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const CustomBackAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              117.h.verticalSpace,
              AppText(
                text: "Need Parent’s help to Proceed",
                style: AppTextStyles.sfProDisplayBold(
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
                controller: _emailController,
                hintText: "Email",
                keyboardType: TextInputType.emailAddress,
              ),
              const Spacer(),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return AppButton(
                    isLoading: authProvider.isLoading,
                    onPressed: () async {
                      final email = _emailController.text.trim();
                      final success = await authProvider.saveParentEmail(
                        context,
                        email,
                      );
                      if (success && context.mounted) {
                        context.pushNamed(
                          UserAppRoutes.consentStatusScreen.name,
                        );
                      }
                    },
                    text: "Send Request",
                    backgroundColor: AppColors.yellowcolor,
                  );
                },
              ),
              10.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
