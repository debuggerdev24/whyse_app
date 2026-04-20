import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';

class AddMembersScreen extends StatelessWidget {
  const AddMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        title: AppText(text: 'Add Members'),
      ),
      body: Column(
        children: [
          Divider(color: AppColors.black.withValues(alpha: 0.1), height: 1),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //* Add members field
                  AppText(
                    text: "Add Members",
                    style: AppTextStyles.semiBold(fontSize: 14.sp),
                  ),
                  8.w.verticalSpace,
                  AppTextField(
                    hintText: "Enter email/username/phone no",
                    hintStyle: AppTextStyles.medium(
                      fontSize: 14.sp,
                      color: AppColors.black.withValues(alpha: 0.25),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.black.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: Center(
                        widthFactor: 1,
                        child: AppText(
                          text: "Add",
                          style: AppTextStyles.semibold(
                            fontSize: 16.sp,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  18.w.verticalSpace,
                  AppText(
                    text: "Members",
                    style: AppTextStyles.semiBold(fontSize: 14.sp),
                  ),
                  8.w.verticalSpace,
                  Expanded(
                    child: ListView.separated(
                      itemCount: _kMembers.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 24.w,
                        thickness: 1,
                        color: AppColors.black.withValues(alpha: 0.08),
                      ),
                      itemBuilder: (context, index) {
                        final member = _kMembers[index];
                        return _MemberTile(member: member);
                      },
                    ),
                  ),
                  12.w.verticalSpace,
                  AppFilledButton(text: "Create Group", onTap: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final _MemberInfo member;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: member.avatarColor,
          child: AppText(
            text: member.initials,
            style: AppTextStyles.bold(
              fontSize: 13.sp,
              color: AppColors.white,
            ),
          ),
        ),
        16.w.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: member.name,
                style: AppTextStyles.bold(
                  fontSize: 18.sp,
                  color: AppColors.black,
                ),
              ),
              2.h.verticalSpace,
              AppText(
                text: member.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.medium(
                  fontSize: 13.sp,
                  color: AppColors.black.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
        10.w.horizontalSpace,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.black.withValues(alpha: 0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: "Member",
                style: AppTextStyles.medium(
                  fontSize: 13.sp,
                  color: AppColors.black,
                ),
              ),
              5.w.horizontalSpace,
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16.sp,
                color: AppColors.black.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MemberInfo {
  const _MemberInfo({
    required this.name,
    required this.email,
    required this.initials,
    required this.avatarColor,
  });

  final String name;
  final String email;
  final String initials;
  final Color avatarColor;
}

const List<_MemberInfo> _kMembers = [
  _MemberInfo(
    name: "Emma Rodriguez",
    email: "rodriemma14@gmail.com",
    initials: "ER",
    avatarColor: Color(0xFF53C3BF),
  ),
  _MemberInfo(
    name: "Sofia Mendes",
    email: "sofimendes654@gmail.com",
    initials: "SM",
    avatarColor: Color(0xFFD7B086),
  ),
  _MemberInfo(
    name: "Ava Thompson",
    email: "avathompson895@gmail.com",
    initials: "AT",
    avatarColor: Color(0xFF66C99D),
  ),
];
