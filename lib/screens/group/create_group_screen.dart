import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/providers/group_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
          Divider(color: AppColors.black.withValues(alpha: 0.1), height: 1),
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
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          labelText: "Group Name",
                          hintText: "ex. Classroom A",
                          controller: _titleController,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a group name';
                            }
                            return null;
                          },
                        ),
                        
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
                          controller: _descriptionController,
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Selector<GroupProvider, bool>(
                    selector: (p0, p1) => p1.createGroupLoading,
                    builder: (context, value, _) {
                      return AppFilledButton(
                        isLoading: value,
                        loadingColor: AppColors.white,
                        text: "Create Group",
                        onTap: () {
                          if (value) return;
                          if (_formKey.currentState!.validate()) {
                            context.read<GroupProvider>().createGroup(
                              code: _titleController.text,
                              description: _descriptionController.text,
                              onSuccess: () {
                                AppToast.success(context, 'Group Created');
                                context.read<ProfileProvider>().getGroupsList();
                                context.pushReplacementNamed(
                                  AppRoutes.addMembersScreen.name,
                                );
                              },
                              onError: (error) {
                                AppToast.error(context, error);
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
