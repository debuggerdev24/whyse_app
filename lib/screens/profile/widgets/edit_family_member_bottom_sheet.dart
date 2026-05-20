import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/user_facing_message.dart';
import 'package:redstreakapp/models/family/family_member_model.dart';
import 'package:redstreakapp/models/family/family_role_model.dart';
import 'package:redstreakapp/providers/family/family_provider.dart';
import 'package:redstreakapp/screens/profile/widgets/add_family_member_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

void showEditFamilyMemberBottomSheet(
  BuildContext context, {
  required FamilyMember member,
}) {
  final provider = context.read<FamilyProvider>();
  provider.resetEditFamilyRoles();
  provider.getFamilyRolesForEdit(excludeFamilyMemberId: member.id);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return EditFamilyMemberBottomSheet(member: member);
    },
  );
}

class EditFamilyMemberBottomSheet extends StatefulWidget {
  const EditFamilyMemberBottomSheet({super.key, required this.member});

  final FamilyMember member;

  @override
  State<EditFamilyMemberBottomSheet> createState() =>
      _EditFamilyMemberBottomSheetState();
}

class _EditFamilyMemberBottomSheetState extends State<EditFamilyMemberBottomSheet> {
  FamilyRole? _selectedRole;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = FamilyRole(
      value: widget.member.role,
      label: widget.member.relationship,
      unique: false,
    );
  }

  String get _memberName =>
      widget.member.member.displayName ??
      widget.member.member.username ??
      'this member';

  void _saveRole() {
    final role = _selectedRole;
    if (role == null || _isSaving) return;
    if (role.value == widget.member.role) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSaving = true);
    context.read<FamilyProvider>().updateFamilyMemberRole(
      familyMemberId: widget.member.id,
      role: role.value,
      onSuccess: () {
        if (!mounted) return;
        Navigator.of(context).pop();
        AppToast.success(
          context,
          '$_memberName updated to ${role.label}',
        );
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        AppToast.error(context, userFacingMessage(error));
      },
    );
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
                    text: 'Edit Family Role',
                    style: AppTextStyles.bold(
                      fontSize: 20,
                      color: AppColors.black,
                    ),
                  ),
                  6.h.verticalSpace,
                  AppText(
                    text: 'Update how $_memberName is related to you',
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
            Flexible(child: _buildRolesList()),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedRole == null || _isSaving ? null : _saveRole,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.black,
                    disabledBackgroundColor: AppColors.black.setOpacity(0.25),
                    foregroundColor: AppColors.white,
                    disabledForegroundColor: AppColors.white.setOpacity(0.7),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: const StadiumBorder(),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 22.sp,
                          height: 22.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.white,
                          ),
                        )
                      : AppText(
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
        ),
      ),
    );
  }

  Widget _buildRolesList() {
    return Consumer<FamilyProvider>(
      builder: (context, provider, _) {
        switch (provider.editFamilyRolesState) {
          case DataState.loading:
            return const _EditRolesLoadingList();
          case DataState.failed:
            return _EditRolesErrorState(
              message: userFacingMessage(provider.editFamilyRolesError),
              onRetry: () => provider.getFamilyRolesForEdit(
                excludeFamilyMemberId: widget.member.id,
                forceRefresh: true,
              ),
            );
          case DataState.success:
            final roles = provider.editFamilyRoles;
            if (roles.isEmpty) {
              return const _EditRolesEmptyState();
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

class _EditRolesLoadingList extends StatelessWidget {
  const _EditRolesLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: 8,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (_, __) => const _EditRoleShimmerTile(),
    );
  }
}

class _EditRoleShimmerTile extends StatelessWidget {
  const _EditRoleShimmerTile();

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

class _EditRolesErrorState extends StatelessWidget {
  const _EditRolesErrorState({required this.message, required this.onRetry});

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

class _EditRolesEmptyState extends StatelessWidget {
  const _EditRolesEmptyState();

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
