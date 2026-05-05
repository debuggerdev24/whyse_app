import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/profile/edit_profile_provider.dart';

class EditInterestsScreen extends StatefulWidget {
  const EditInterestsScreen({super.key});

  @override
  State<EditInterestsScreen> createState() => _EditInterestsScreenState();
}

class _EditInterestsScreenState extends State<EditInterestsScreen> {
  final List<String> _customInterests = [];
  final TextEditingController _customInterestController =
      TextEditingController();
  final Set<String> _selectedInterestIds = {};
  final Set<String> _selectedCustomInterests = {};
  bool _hasMatchedInterests = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchDefaultInterests(context);
      _preSelectUserInterests();
    });
  }

  void _preSelectUserInterests() {
    final editProvider = context.read<EditProfileProvider>();
    final userInterests = editProvider.interests;
    final authProvider = context.read<AuthProvider>();

    for (final interest in userInterests) {
      final match = authProvider.interestsList.where(
        (item) => item['id'] == interest || item['name'] == interest,
      );
      if (match.isNotEmpty) {
        _selectedInterestIds.add(match.first['id']);
      } else {
        if (!_customInterests.contains(interest)) {
          _customInterests.add(interest);
          _selectedCustomInterests.add(interest);
        }
      }
    }
    if (userInterests.isNotEmpty) _hasMatchedInterests = true;
    setState(() {});
  }

  void _matchInterestsAfterLoad() {
    if (_hasMatchedInterests) return;

    final editProvider = context.read<EditProfileProvider>();
    final userInterests = editProvider.interests;
    final authProvider = context.read<AuthProvider>();

    _selectedInterestIds.clear();
    _selectedCustomInterests.clear();
    _customInterests.clear();

    for (final interest in userInterests) {
      final match = authProvider.interestsList.where(
        (item) => item['id'] == interest || item['name'] == interest,
      );
      if (match.isNotEmpty) {
        _selectedInterestIds.add(match.first['id']);
      } else {
        _customInterests.add(interest);
        _selectedCustomInterests.add(interest);
      }
    }
    _hasMatchedInterests = true;
    setState(() {});
  }

  @override
  void dispose() {
    _customInterestController.dispose();
    super.dispose();
  }

  String _getIconForInterest(String name) {
    if (name.toLowerCase().contains("adventure")) return AppAssets.adventure;
    if (name.toLowerCase().contains("mystery")) return AppAssets.mystery;
    if (name.toLowerCase().contains("science")) return AppAssets.science;
    if (name.toLowerCase().contains("fantasy")) return AppAssets.fantancy;
    if (name.toLowerCase().contains("history")) return AppAssets.histoy;
    if (name.toLowerCase().contains("nature")) return AppAssets.nature;
    if (name.toLowerCase().contains("comics")) return AppAssets.comics;
    return AppAssets.adventure;
  }

  void _toggleApiInterest(String id) {
    setState(() {
      if (_selectedInterestIds.contains(id)) {
        _selectedInterestIds.remove(id);
      } else {
        _selectedInterestIds.add(id);
      }
    });
  }

  void _toggleCustomInterest(String name) {
    setState(() {
      if (_selectedCustomInterests.contains(name)) {
        _selectedCustomInterests.remove(name);
      } else {
        _selectedCustomInterests.add(name);
      }
    });
  }

  void _addCustomInterest(String name) {
    if (name.trim().isEmpty) return;
    if (!_customInterests.contains(name)) {
      setState(() {
        _customInterests.add(name);
        _selectedCustomInterests.add(name);
      });
      _customInterestController.clear();
    }
  }

  List<String> _buildSelectedInterestNames() {
    final authProvider = context.read<AuthProvider>();
    final names = <String>[];

    for (final id in _selectedInterestIds) {
      final match = authProvider.interestsList.where(
        (item) => item['id'] == id,
      );
      if (match.isNotEmpty) {
        names.add(match.first['name'] as String);
      }
    }

    names.addAll(_selectedCustomInterests);
    return names;
  }

  void _saveInterests() {
    if (_selectedInterestIds.isEmpty && _selectedCustomInterests.isEmpty) {
      AppToast.error(context, "Please select at least one interest");
      return;
    }

    final interestNames = _buildSelectedInterestNames();
    context.read<EditProfileProvider>().setInterests(interestNames);

    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 18),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.pop(),
              child: SvgIcon(AppAssets.backButton, size: 13.sp),
            ),
          ),
        ),
        centerTitle: true,
        title: AppText(
          text: 'Edit Interests',
          style: AppTextStyles.semibold(fontSize: 20),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            color: AppColors.black.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingInterests) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              );
            }

            if (provider.interestsList.isNotEmpty && !_hasMatchedInterests) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _matchInterestsAfterLoad();
              });
            }

            return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: "Pick Your Interests",
                            style: AppTextStyles.bold(fontSize: 28.sp),
                          ),
                          10.h.verticalSpace,
                          AppText(
                            text:
                                "Choose topics you love to personalize your reading journey.",
                            style: AppTextStyles.medium(
                              fontSize: 15.sp,
                              color: AppColors.black.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    20.h.verticalSpace,
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          ...provider.interestsList.map((interest) {
                            final id = interest['id'];
                            final name = interest['name'];
                            return SelectionOption(
                              label: name,
                              isSelected: _selectedInterestIds.contains(id),
                              onTap: () => _toggleApiInterest(id),
                              iconPath: _getIconForInterest(name),
                            );
                          }),
                          ..._customInterests.map((name) {
                            return SelectionOption(
                              label: name,
                              isSelected:
                                  _selectedCustomInterests.contains(name),
                              onTap: () => _toggleCustomInterest(name),
                              iconPath: AppAssets.adventure,
                            );
                          }),
                          Padding(
                            padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
                            child: AppTextField(
                              controller: _customInterestController,
                              hintText: "Add Custom Interest...",
                              onSubmit: (val) => _addCustomInterest(val),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 12.h),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveInterests,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.orangeColor,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: const StadiumBorder(),
                          ),
                          child: AppText(
                            text: 'Save',
                            style: AppTextStyles.semibold(
                              fontSize: 16,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
          },
        ),
      ),
    );
  }
}
