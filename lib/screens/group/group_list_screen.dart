import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/group/group_response_model.dart';
import 'package:redstreakapp/providers/group_provider.dart';
import 'package:redstreakapp/screens/group/group_details_screen.dart';
import 'package:redstreakapp/screens/group/widget/group_image_widget.dart';
import 'package:shimmer/shimmer.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<GroupProvider>().getGroupsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        title: const AppText(text: 'Groups'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
      ),
      body: Column(
        children: [
          Divider(color: AppColors.black.setOpacity(0.1), height: 1),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 14.w, 24.w, 0),
              child: Selector<GroupProvider, _GroupListVM>(
                selector: (_, p) => _GroupListVM.fromProvider(p),
                builder: (context, vm, _) {
                  if (vm.isLoading) return const _LoadingList();
                  if (vm.isError) {
                    return _ErrorState(
                      message: vm.error,
                      onRetry: () {
                        context.read<GroupProvider>().getGroupsList();
                      },
                    );
                  }
                  if (vm.groups.isEmpty) return const _EmptyState();

                  return ListView.separated(
                    itemCount: vm.groups.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 24.w,
                      thickness: 1,
                      color: AppColors.black.setOpacity(0.08),
                    ),
                    itemBuilder: (context, index) {
                      final group = vm.groups[index].group;
                      return _GroupTile(
                        group: group,
                        onGroupTap: () {
                          context.pushNamed(
                            AppRoutes.groupDetailsScreen.name,
                            extra: GroupDetailsScreenParams(
                              id: group.id,
                              groupName: group.title,
                              thumbnail: group.thumbnailUrl,
                              description: group.description,
                              inviteCode: group.joinCode
                            ),
                          );
                        },
                        onTap: () {
                          context.pushNamed(
                            AppRoutes.viewGroupScreen.name,
                            extra: GroupDetailsScreenParams(
                              id: group.id,
                              groupName: group.title,
                              thumbnail: group.thumbnailUrl,
                              description: group.description,
                              inviteCode: group.joinCode
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupListVM {
  final DataState state;
  final List<GroupResponse> groups;
  final String? error;

  _GroupListVM({
    required this.state,
    required this.groups,
    required this.error,
  });

  bool get isLoading => state == DataState.loading;
  bool get isError => state == DataState.failed;

  factory _GroupListVM.fromProvider(GroupProvider p) {
    return _GroupListVM(
      state: p.getGroupListState,
      groups: p.myGroupsList,
      error: p.getGroupsListError,
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => const _ShimmerTile(),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.shimmerBaseColor,
          highlightColor: AppColors.shimmerHighlightColor,
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
        16.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(width: 120, height: 12),
              const SizedBox(height: 8),
              _shimmerBox(width: 80, height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shimmerBox({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(width: width, height: height, color: Colors.white),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _ErrorState({this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: AppColors.orangeColor),
          12.verticalSpace,
          AppText(
            text: message ?? 'Something went wrong',
            textAlign: TextAlign.center,
          ),
          16.verticalSpace,
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppText(
        text: 'No groups found',
        style: AppTextStyles.medium(fontSize: 14),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, required this.onTap, required this.onGroupTap});

  final Group group;
  final VoidCallback onTap, onGroupTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onGroupTap,

      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          GestureDetector(onTap: onGroupTap ,child: GroupImageWidget(size: 48.w, imageUrl: group.thumbnailUrl)),
          16.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: group.title,
                  style: AppTextStyles.semibold(
                    fontSize: 16.sp,
                    color: AppColors.black,
                  ),
                ),
                AppText(
                  text: '0 Members',
                  style: AppTextStyles.semibold(
                    fontSize: 14.sp,
                    color: AppColors.orangeColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: AppColors.lighttealcolor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: AppText(
              text: '8',
              style: AppTextStyles.bold(fontSize: 12.sp, color: AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }
}