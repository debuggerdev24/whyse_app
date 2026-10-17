import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/group/group_response_model.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/screens/group/group_details_screen.dart';
import 'package:redstreakapp/screens/profile/widgets/profile_section_actions.dart';

class GroupBlock extends StatefulWidget {
  const GroupBlock({super.key});

  @override
  State<GroupBlock> createState() => _GroupBlockState();
}

class _GroupBlockState extends State<GroupBlock> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProfileProvider>().getGroupsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ProfileProvider, _GroupViewModel>(
      selector: (_, p) => _GroupViewModel.fromProvider(p),
      builder: (context, vm, _) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(color: AppColors.black.setOpacity(0.08)),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                16.w.verticalSpace,
                _GroupList(vm: vm),
                20.w.verticalSpace,
                const _ActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GroupViewModel {
  final DataState state;
  final List<GroupResponse> groups;
  final String? error;

  _GroupViewModel({
    required this.state,
    required this.groups,
    required this.error,
  });

  bool get isLoading => state == DataState.loading;
  bool get isError => state == DataState.failed;
  bool get isSuccess => state == DataState.success;

  factory _GroupViewModel.fromProvider(ProfileProvider p) {
    return _GroupViewModel(
      state: p.getGroupListState,
      groups: p.myGroupsList,
      error: p.getGroupsListError,
    );
  }
}

class _GroupList extends StatelessWidget {
  final _GroupViewModel vm;

  const _GroupList({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: const _ShimmerList(),
      );
    }
    if (vm.isError) {
      return SizedBox(
        height: 100.h,
        child: Center(child: _ErrorWidget(message: vm.error)),
      );
    }
    if (vm.groups.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ProfileDashedAddButton(
          onTap: () => context.pushNamed(AppRoutes.createGroupScreen.name),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final g in vm.groups)
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: GroupItem(groupResponse: g),
            ),
          ProfileDashedAddButton(
            onTap: () => context.pushNamed(AppRoutes.createGroupScreen.name),
          ),
        ],
      ),
    );
  }
}

class GroupItem extends StatelessWidget {
  final GroupResponse groupResponse;

  const GroupItem({super.key, required this.groupResponse});

  @override
  Widget build(BuildContext context) {
    final group = groupResponse.group;
    final imageUrl = group.thumbnailUrl;

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoutes.viewGroupScreen.name,
          extra: GroupDetailsScreenParams(
            id: group.id,
            groupName: group.title,
            thumbnail: group.thumbnailUrl,
            description: group.description,
            inviteCode: group.joinCode,
            myRole: groupResponse.myRole,
          ),
        );
      },
      child: SizedBox(
        width: 72.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: imageUrl == null
                    ? AppColors.black.setOpacity(0.1)
                    : null,
              ),
              alignment: Alignment.center,
              child: imageUrl == null
                  ? const Icon(Icons.group)
                  : ClipOval(
                      child: AppNetworkImage(
                        imageUrl: imageUrl,
                        tag: 'GroupBlock.thumbnail',
                        placeholder: (_) => const _ImageShimmer(),
                        errorBuilder: (_, __, ___) => Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.black.setOpacity(0.1),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.group),
                        ),
                      ),
                    ),
            ),
            8.h.verticalSpace,
            AppText(
              text: group.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.medium(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText(
          text: 'Groups',
          style: AppTextStyles.bold(
            fontSize: 22,
            color: const Color(0xFF1C1C1E),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            context.pushNamed(AppRoutes.groupListScreen.name);
          },
          child: AppText(
            text: 'View all',
            style: AppTextStyles.semibold(
              fontSize: 16,
              color: profileViewAllColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(5, (i) {
        return Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: const _ShimmerItem(),
        );
      }),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String? message;

  const _ErrorWidget({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: AppText(text: message ?? 'Something went wrong'));
  }
}

class _ShimmerItem extends StatelessWidget {
  const _ShimmerItem();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: const [_ImageShimmer(), SizedBox(height: 8), _TextShimmer()],
      ),
    );
  }
}

class _ImageShimmer extends StatelessWidget {
  const _ImageShimmer();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _TextShimmer extends StatelessWidget {
  const _TextShimmer();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: Container(width: 30, height: 10, color: Colors.white),
    );
  }
}

class _GroupPillButton extends StatelessWidget {
  const _GroupPillButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: filled
              ? null
              : Border.all(color: const Color(0xFFE4E4E4)),
        ),
        child: AppText(
          text: label,
          style: AppTextStyles.semibold(
            fontSize: 16,
            color: filled ? Colors.white : const Color(0xFF1C1C1E),
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GroupPillButton(
            label: 'Create Group',
            filled: false,
            onTap: () => context.pushNamed(AppRoutes.createGroupScreen.name),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _GroupPillButton(
            label: 'Join Group',
            filled: true,
            onTap: () => context.pushNamed(AppRoutes.joinGroupScreen.name),
          ),
        ),
      ],
    );
  }
}

