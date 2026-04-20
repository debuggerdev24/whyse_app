import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';

class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,

        title: AppText(text: 'Create Group'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
      ),
      body: Column(
        children: [
          Divider(color: AppColors.black.withValues(alpha: 0.1), height: 1,),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.w),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  //* GroupTitle
                  AppText(
                    text: "Title",
                    style: AppTextStyles.semiBold(fontSize: 14.sp),
                  ),
                  8.w.verticalSpace,
                  AppTextField(labelText: "Group Name", hintText: "ex. Classroom A"),
                  20.w.verticalSpace,
                  //* Group Description
                  AppText(
                    text: "Description",
                    style: AppTextStyles.semiBold(fontSize: 14.sp),
                  ),
                  8.w.verticalSpace,
                  AppTextField(
                    maxLines: 4,
                    minLines: 4,
                    cursorColor: AppColors.black,
                    labelText: "Description",
                    hintText: "(Optional)",
                  ),
                  Spacer(),
                  AppFilledButton(text: "Create Group", onTap: () {
                    context.pushNamed(AppRoutes.addMembersScreen.name);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
