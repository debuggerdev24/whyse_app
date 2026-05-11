import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/models/group/group_response_model.dart';
import 'package:redstreakapp/providers/profile/profile_provider.dart';
import 'package:redstreakapp/screens/group/group_details_screen.dart';
import 'package:shimmer/shimmer.dart';

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
                _Header(showViewAll: vm.isSuccess && vm.groups.isNotEmpty),
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
      return SizedBox(
        height: 92.w,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: const _ShimmerList(),
        ),
      );
    }
    if (vm.isError) {
      return SizedBox(
        height: 92.w,
        child: Center(child: _ErrorWidget(message: vm.error)),
      );
    }
    if (vm.groups.isEmpty) {
      return const _EmptyState();
    }
    return SizedBox(
      height: 92.w,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: vm.groups
              .map(
                (g) => Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: GroupItem(group: g.group),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class GroupItem extends StatelessWidget {
  final Group group;

  const GroupItem({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
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
          ),
        );
      },
      child: SizedBox(
        width: 72.w,
        child: Column(
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
            8.w.verticalSpace,
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
  final bool showViewAll;

  const _Header({required this.showViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText(text: 'Groups', style: AppTextStyles.bold(fontSize: 20)),
        const Spacer(),
        if (showViewAll)
          GestureDetector(
            onTap: () {
              context.pushNamed(AppRoutes.groupListScreen.name);
            },
            child: AppText(
              text: 'View all',
              style: AppTextStyles.semibold(
                fontSize: 15,
                color: AppColors.teal,
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
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
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
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(width: 30, height: 10, color: Colors.white),
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
          child: OutlinedButton(
            onPressed: () {
              context.pushNamed(AppRoutes.createGroupScreen.name);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.black,
              backgroundColor: AppColors.white,
              side: BorderSide(color: AppColors.black.withValues(alpha: 0.15)),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: const StadiumBorder(),
            ),
            child: AppText(
              text: 'Create Group',
              style: AppTextStyles.semibold(
                fontSize: 15,
                color: AppColors.black,
              ),
            ),
          ),
        ),
        16.w.horizontalSpace,
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.pushNamed(AppRoutes.joinGroupScreen.name);
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.black,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: const StadiumBorder(),
            ),
            child: AppText(
              text: 'Join Group',
              style: AppTextStyles.semibold(
                fontSize: 15,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 36.w,
            color: AppColors.black.setOpacity(0.2),
          ),
          8.h.verticalSpace,
          AppText(
            text: 'No groups yet',
            style: AppTextStyles.semibold(
              fontSize: 14,
              color: AppColors.black.setOpacity(0.45),
            ),
          ),
          4.h.verticalSpace,
          AppText(
            text: 'Create or join a group to start reading together',
            textAlign: TextAlign.center,
            style: AppTextStyles.medium(
              fontSize: 12,
              color: AppColors.black.setOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }
}
