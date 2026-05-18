import 'package:redstreakapp/core/enums/user_gender.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';

const List<String> _allFamilyRelationshipOptions = [
  'Father',
  'Mother',
  'Brother',
  'Sister',
  'Son',
  'Daughter',
  'Husband',
  'Wife',
  'Grandfather',
  'Grandmother',
  'Uncle',
  'Aunt',
  'Cousin',
  'Other',
];

const List<String> _maleFamilyRelationshipOptions = [
  'Father',
  'Brother',
  'Son',
  'Husband',
  'Grandfather',
  'Uncle',
  'Cousin',
  'Other',
];

const List<String> _femaleFamilyRelationshipOptions = [
  'Mother',
  'Sister',
  'Daughter',
  'Wife',
  'Grandmother',
  'Aunt',
  'Cousin',
  'Other',
];

/// Relationship labels shown based on the family member's gender.
List<String> familyRelationshipOptionsFor(UserGender? gender) {
  switch (gender) {
    case UserGender.male:
      return _maleFamilyRelationshipOptions;
    case UserGender.female:
      return _femaleFamilyRelationshipOptions;
    case UserGender.unknown:
    case null:
      return _allFamilyRelationshipOptions;
  }
}

void showAddFamilyMemberBottomSheet(
  BuildContext context, {
  required String memberName,
  UserGender? memberGender,
  required void Function(String relationship) onConfirm,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return AddFamilyMemberBottomSheet(
        memberName: memberName,
        memberGender: memberGender,
        onConfirm: (relationship) {
          Navigator.of(sheetContext).pop();
          onConfirm(relationship);
        },
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
  final ValueChanged<String> onConfirm;

  @override
  State<AddFamilyMemberBottomSheet> createState() =>
      _AddFamilyMemberBottomSheetState();
}

class _AddFamilyMemberBottomSheetState extends State<AddFamilyMemberBottomSheet> {
  String? _selectedRelationship;

  List<String> get _relationshipOptions =>
      familyRelationshipOptionsFor(widget.memberGender);

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
            _SheetHandle(),
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
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _relationshipOptions.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final relationship = _relationshipOptions[index];
                  final isSelected = _selectedRelationship == relationship;
                  return _RelationshipTile(
                    label: relationship,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() => _selectedRelationship = relationship);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedRelationship == null
                      ? null
                      : () => widget.onConfirm(_selectedRelationship!),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.black,
                    disabledBackgroundColor: AppColors.black.setOpacity(0.25),
                    foregroundColor: AppColors.white,
                    disabledForegroundColor: AppColors.white.setOpacity(0.7),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: const StadiumBorder(),
                  ),
                  child: AppText(
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
}

class _RelationshipTile extends StatelessWidget {
  const _RelationshipTile({
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

class _SheetHandle extends StatelessWidget {
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
