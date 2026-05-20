import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/enums/user_gender.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/models/family/family_role_model.dart';
import 'package:redstreakapp/providers/family/family_provider.dart';
import 'package:shimmer/shimmer.dart';

void showAddFamilyMemberBottomSheet(
  BuildContext context, {
  required String memberName,
  UserGender? memberGender,
  required Future<String?> Function(FamilyRole role) onConfirm,
}) {
  context.read<FamilyProvider>().getFamilyRoles();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (sheetContext) {
      return AddFamilyMemberBottomSheet(
        memberName: memberName,
        memberGender: memberGender,
        onConfirm: onConfirm,
      );
    },
  );
}

class AddFamilyMemberBottomSheet extends StatefulWidget {
  const AddFamilyMemberBottomSheet({
    super.key,
    required this.memberName,
    this.memberGender,
    required this.onConfirm,
  });

  final String memberName;
  final UserGender? memberGender;
  final Future<String?> Function(FamilyRole role) onConfirm;

  @override
  State<AddFamilyMemberBottomSheet> createState() =>
      _AddFamilyMemberBottomSheetState();
}

class _AddFamilyMemberBottomSheetState extends State<AddFamilyMemberBottomSheet> {
  FamilyRole? _selectedRole;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final role = _selectedRole;
    if (role == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final error = await widget.onConfirm(role);
    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSubmitting = false);
    AppToast.error(context, userFacingMessage(error));
  }

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.78;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FamilySheetHandle(),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              child: Column(
                children: [
                  AppText(
                    text: 'Add to Family',
                    style: AppTextStyles.bold(
                      fontSize: 20,
                      color: AppColors.black,
                    ),
                  ),
                  6.h.verticalSpace,
                  AppText(  
                    text: 'How is ${widget.memberName} related to you?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.medium(
                      fontSize: 14,
                      color: AppColors.black.setOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            16.h.verticalSpace,
            Flexible(
              child: AbsorbPointer(
                absorbing: _isSubmitting,
                child: Opacity(
                  opacity: _isSubmitting ? 0.5 : 1,
                  child: _buildRolesList(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _selectedRole == null || _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.black,
                    disabledBackgroundColor: AppColors.black.setOpacity(0.25),
                    foregroundColor: AppColors.white,
                    disabledForegroundColor: AppColors.white.setOpacity(0.7),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: const StadiumBorder(),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 22.sp,
                          height: 22.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.white,
                          ),
                        )
                      : AppText(
                          text: 'Add Family Member',
                          style: AppTextStyles.semibold(
                            fontSize: 16,
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesList() {
    return Consumer<FamilyProvider>(
      builder: (context, provider, _) {
        switch (provider.familyRolesState) {
          case DataState.loading:
            return const _RolesLoadingList();
          case DataState.failed:
            return _RolesErrorState(
              message: userFacingMessage(provider.familyRolesError),
              onRetry: () => provider.getFamilyRoles(forceRefresh: true),
            );
          case DataState.success:
            final roles =
                provider.relationshipOptionsFor(widget.memberGender);
            if (roles.isEmpty) {
              return const _RolesEmptyState();
            }
            return ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: roles.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final role = roles[index];
                final isSelected = _selectedRole?.value == role.value;
                return FamilyRelationshipTile(
                  label: role.label,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedRole = role),
                );
              },
            );
        }
      },
    );
  }
}

class _RolesLoadingList extends StatelessWidget {
  const _RolesLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: 8,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (_, __) => const _RoleShimmerTile(),
    );
  }
}

class _RoleShimmerTile extends StatelessWidget {
  const _RoleShimmerTile();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

class _RolesErrorState extends StatelessWidget {
  const _RolesErrorState({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40.sp,
              color: AppColors.black.setOpacity(0.3),
            ),
            12.h.verticalSpace,
            AppText(
              text: message ?? 'Failed to load family roles',
              textAlign: TextAlign.center,
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: AppColors.black.setOpacity(0.55),
              ),
            ),
            16.h.verticalSpace,
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.teal.setOpacity(0.4)),
                ),
                child: AppText(
                  text: 'Retry',
                  style: AppTextStyles.semibold(
                    fontSize: 14.sp,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RolesEmptyState extends StatelessWidget {
  const _RolesEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: AppText(
          text: 'No family roles available',
          textAlign: TextAlign.center,
          style: AppTextStyles.medium(
            fontSize: 14.sp,
            color: AppColors.black.setOpacity(0.55),
          ),
        ),
      ),
    );
  }
}

class FamilyRelationshipTile extends StatelessWidget {
  const FamilyRelationshipTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.extealighttealcolor
                : AppColors.lightwhiteColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.teal.setOpacity(0.45)
                  : AppColors.black.setOpacity(0.08),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    text: label,
                    style: AppTextStyles.semibold(
                      fontSize: 16,
                      color: isSelected ? AppColors.teal : AppColors.black,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 22.sp,
                    color: AppColors.teal,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FamilySheetHandle extends StatelessWidget {
  const FamilySheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 4.h,
      margin: EdgeInsets.only(top: 12.h, bottom: 4.h),
      decoration: BoxDecoration(
        color: AppColors.black.setOpacity(0.15),
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}
