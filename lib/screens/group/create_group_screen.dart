import 'package:image_picker/image_picker.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_dropdown.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/providers/profile/group_provider.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/screens/group/add_members_screen.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _groupType = 'Private-Invite only';
  XFile? _thumbnail;

  static const _types = ['Private-Invite only', 'Public'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (!mounted || file == null) return;
    setState(() => _thumbnail = file);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    const fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide.none,
    );

    return SettingsScaffold(
      title: 'Create Group',
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 12),
        child: Selector<GroupProvider, bool>(
          selector: (_, provider) => provider.createGroupLoading,
          builder: (context, loading, _) {
            return GestureDetector(
              onTap: loading ? null : _onNext,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : AppText(
                        text: 'Next',
                        style: AppTextStyles.semibold(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            );
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          children: [
            _label('Title'),
            _whiteField(
              child: AppTextField(
                hintText: 'eg. Classroom A',
                controller: _titleController,
                border: fieldBorder,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 16.h),
            _label('Description'),
            _whiteField(
              child: AppTextField(
                maxLines: 5,
                minLines: 5,
                hintText: 'Optional Description',
                controller: _descriptionController,
                border: fieldBorder,
              ),
            ),
            SizedBox(height: 16.h),
            _label('Type'),
            _whiteField(
              child: AppDropdown(
                filled: false,
                value: _groupType,
                items: _types,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _groupType = value);
                },
              ),
            ),
            SizedBox(height: 16.h),
            _label('Thumbnail'),
            Row(
              children: [
                GestureDetector(
                  onTap: _pickThumbnail,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: settingsInk,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: AppText(
                      text: 'Choose file',
                      style: AppTextStyles.medium(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: AppText(
                    text: _thumbnail?.name ?? 'No file chosen',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regular(
                      fontSize: 14,
                      color: settingsMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onNext() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final title = _titleController.text.trim();
    context.read<GroupProvider>().createGroup(
      code: title,
      description: _descriptionController.text.trim(),
      onSuccess: (groupId) {
        AppToast.success(context, 'Group Created');
        context.read<ProfileProvider>().getGroupsList();
        context.pushReplacementNamed(
          AppRoutes.addMembersScreen.name,
          extra: AddMembersScreenArgs(groupId: groupId, title: title),
        );
      },
      onError: (error) {
        AppToast.error(context, error);
      },
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: AppText(
        text: text,
        style: AppTextStyles.medium(fontSize: 14, color: settingsInk),
      ),
    );
  }

  Widget _whiteField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}
