import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/profile/edit_profile_provider.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';

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
    final bottom = MediaQuery.paddingOf(context).bottom;

    return SettingsScaffold(
      title: 'Edit Interests',
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 12),
        child: GestureDetector(
          onTap: _saveInterests,
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.buttonBackground,
              borderRadius: BorderRadius.circular(28),
            ),
            child: AppText(
              text: 'Save',
              style: AppTextStyles.semibold(fontSize: 17, color: AppColors.onFill),
            ),
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingInterests) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            );
          }

          if (provider.interestsList.isNotEmpty && !_hasMatchedInterests) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _matchInterestsAfterLoad();
            });
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
            children: [
              AppText(
                text: 'Pick Your Interests',
                style: AppTextStyles.bold(fontSize: 28, color: settingsInk),
              ),
              SizedBox(height: 8.h),
              AppText(
                text:
                    'Choose topics you love to personalize your reading journey.',
                style: AppTextStyles.regular(fontSize: 15, color: settingsMuted),
              ),
              SizedBox(height: 18.h),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final interest in provider.interestsList)
                    _InterestChip(
                      label: interest['name'] as String,
                      selected: _selectedInterestIds.contains(interest['id']),
                      onTap: () => _toggleApiInterest(interest['id'] as String),
                    ),
                  for (final name in _customInterests)
                    _InterestChip(
                      label: name,
                      selected: _selectedCustomInterests.contains(name),
                      onTap: () => _toggleCustomInterest(name),
                    ),
                ],
              ),
              SizedBox(height: 18.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: AppTextField(
                  controller: _customInterestController,
                  hintText: 'Add a custom interest',
                  onSubmit: _addCustomInterest,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AppText(
          text: label,
          style: AppTextStyles.medium(
            fontSize: 14,
            color: selected ? Colors.white : settingsInk,
          ),
        ),
      ),
    );
  }
}
