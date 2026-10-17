import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/group/group_response_model.dart';
import 'package:redstreakapp/providers/profile/group_provider.dart';
import 'package:redstreakapp/screens/group/group_details_screen.dart';
import 'package:redstreakapp/screens/group/widget/group_image_widget.dart';
import 'package:redstreakapp/screens/settings/widget/settings_chrome.dart';

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
    return SettingsScaffold(
      title: 'Groups',
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
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
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE5E5EA),
                    ),
                    itemBuilder: (context, index) {
                      final group = vm.groups[index].group;
                      return _GroupTile(
                        group: group,
                        memberCount: vm.groups[index].memberCount,
                        onTap: () {
                          context.pushNamed(
                            AppRoutes.groupDetailsScreen.name,
                            extra: GroupDetailsScreenParams(
                              id: group.id,
                              groupName: group.title,
                              thumbnail: group.thumbnailUrl,
                              description: group.description,
                              inviteCode: group.joinCode,
                              myRole: vm.groups[index].myRole,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
        ),
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
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) => const _ShimmerTile(),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppSkeletonizer(
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
    return AppSkeletonizer(
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
  const _GroupTile({
    required this.group,
    required this.onTap,
    required this.memberCount,
  });

  final Group group;
  final int memberCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            GroupImageWidget(size: 48.w, imageUrl: group.thumbnailUrl),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: group.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semibold(
                      fontSize: 16,
                      color: const Color(0xFF1C1C1E),
                    ),
                  ),
                  AppText(
                    text: '$memberCount Members',
                    style: AppTextStyles.medium(
                      fontSize: 14,
                      color: const Color(0xFFF6A01A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
