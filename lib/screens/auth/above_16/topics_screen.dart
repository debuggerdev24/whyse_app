
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/core/utils/de_bouncing.dart';
import 'package:redstreakapp/core/widgets/app_button.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/core/widgets/custom_toast.dart';
import 'package:redstreakapp/core/widgets/onboarding_widgets.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/core/routes/user_routes.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  //* Local state for custom topics
  final List<String> customTopics = [];
  final TextEditingController customTopicController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final Set<String> selectedTopicIds = {};
  final Set<String> selectedCustomTopics = {};


  void _removeCustomTopic(String title) {
    setState(() {
      customTopics.remove(title);
      selectedCustomTopics.remove(title);
    });
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchDefaultTopics(context);
    });
  }

  @override
  void dispose() {

    searchController.dispose();
    customTopicController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
      if (!mounted) return;
      final query = value.trim();
      context.read<AuthProvider>().fetchDefaultTopics(
            context,
            search: query.isEmpty ? null : query,
          );
  }

  void _toggleApiTopic(String id) {
    setState(() {
      if (selectedTopicIds.contains(id)) {
        selectedTopicIds.remove(id);
      } else {
        selectedTopicIds.add(id);
      }
    });
  }

  void _toggleCustomTopic(String title) {
    setState(() {

      if (selectedCustomTopics.contains(title)) {
        selectedCustomTopics.remove(title);
      } else {
        selectedCustomTopics.add(title);
      }
    });
  }

  void _addCustomTopic(String title) {
    if (title.trim().isEmpty) return;
    if (!customTopics.contains(title)) {
      setState(() {
        customTopics.insert(0, title); //
        AppToast.success(context, "Topic added successfully");
        selectedCustomTopics.add(title); // Auto-select
      });
      customTopicController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      resizeToAvoidBottomInset: false,

      // Fixed bottom button
      body: SafeArea(
        bottom: false,
        child: Consumer<AuthProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.w
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OnboardingHeader(
                        currentStep: 4,
                        totalSteps: 5,
                        onBack: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.goNamed(AppRoutes.interestsScreen.name);
                          }
                        },
                      ),
                      AppText(
                        text: "Choose Your Favorite Topics",
                        style: AppTextStyles.bold(fontSize: 32.sp),
                      ),

                      10.w.verticalSpace,

                      AppText(
                        text:
                            "Here are some topics we think you'll love based on your interests. You can pick the ones that excite you the most!",
                        style: AppTextStyles.medium(
                          fontSize: 16.sp,
                          color: AppColors.black.withValues(alpha: 0.8),
                        ),
                      ),

                      16.w.verticalSpace,
                      // Search topics (filters API list)
                      AppTextField(
                        controller: searchController,
                        hintText: "Search topics...",
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 14.w, right: 10.w),
                          child: SvgIcon(
                            AppAssets.searchIcon,
                            size: 20.w,
                            color: AppColors.teal,
                          ),
                        ),
                        onChanged: (value) => deBouncer.run(() {
                          _onSearchChanged(value);
                        },),
                      ),
                      
                      14.w.verticalSpace,
                      // Custom Topic Input
                      AppTextField(
                        controller: customTopicController,
                        hintText: "Add Topic...",
                        onSubmit: (val) => _addCustomTopic(val),
                        onTapOutside: () {
                        _addCustomTopic(customTopicController.text);
                        },
                      ),
                      20.w.verticalSpace,
                      // Loading State
                      if (provider.isLoadingTopics)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.teal,
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: GridView(
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20.w,
                                  mainAxisSpacing: 25.h,
                                  childAspectRatio: 1.4,
                                ),
                            children: [
                              // API topics only (with images from API)
                              ...provider.topicsList.map((topic) {
                                final id = topic['id'];
                                return TopicCard(
                                  label: topic['title'],
                                  imagePath: topic["thumbnailUrl"],
                                  isSelected: selectedTopicIds.contains(id),
                                  onTap: () => _toggleApiTopic(id),
                                );
                              }),
                            ],
                          ),
                        ),
                      // Custom-added topics: text-only, horizontal scroll, removable
                      if (customTopics.isNotEmpty) ...[
                        12.w.verticalSpace,
                        SizedBox(
                          height: 44.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.only(right: 24.w),
                            itemCount: customTopics.length,
                            separatorBuilder: (_, __) => SizedBox(width: 10.w),
                            itemBuilder: (context, index) {
                              final title = customTopics[index];
                              return _CustomTopicChip(
                                label: title,
                                isSelected: selectedCustomTopics.contains(title),
                                onTap: () => _toggleCustomTopic(title),
                                onRemove: () => _removeCustomTopic(title),
                              );
                            },
                          ),
                        ),
                      ],
                      AppFilledButton(
                        text: "Next",
                        backgroundColor: AppColors.primaryColor,
                        margin: EdgeInsets.only(bottom: 8.h, top: 12.h),

                        onTap: () async {
                          if (selectedTopicIds.isEmpty &&
                              selectedCustomTopics.isEmpty) {
                            AppToast.error(
                              context,
                              "Please select at least one topic",
                            );
                            return;
                          }

                          final success = await provider.saveTopics(
                            context,
                            topicIds: selectedTopicIds.toList(),
                            customTopics: selectedCustomTopics.toList(),
                          );

                          if (success && context.mounted) {
                            context.pushNamed(AppRoutes.goalsScreen.name);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                if (provider.isSaveTopicsLoading) FullPageIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Text-only chip for custom topics: label, optional selection state, tap to toggle, X to remove.
class _CustomTopicChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _CustomTopicChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.teal.withValues(alpha: 0.12)
                : AppColors.black.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? AppColors.teal
                  : AppColors.black.withValues(alpha: 0.12),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: label,
                style: AppTextStyles.semibold(
                  fontSize: 14.sp,
                  color: isSelected
                      ? AppColors.teal
                      : AppColors.black.withValues(alpha: 0.85),
                ),
              ),
              8.w.horizontalSpace,
              GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  Icons.close_rounded,
                  size: 18.sp,
                  color: isSelected
                      ? AppColors.teal
                      : AppColors.black.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
