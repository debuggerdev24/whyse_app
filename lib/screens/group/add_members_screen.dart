import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_textfiled.dart';
import 'package:redstreakapp/models/group/search_user_model.dart';
import 'package:redstreakapp/providers/group_provider.dart';

class AddMembersScreen extends StatefulWidget {
  final String groupId;
  const AddMembersScreen({super.key, required this.groupId});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final DeBouncer _searchDebouncer = DeBouncer(milliSecond: 400);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().getAllUsers(
        onSuccess: () {},
        onError: (error) {},
      );
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<GroupProvider>().loadMoreUsers();
    }
  }

  void _onSearchChanged(String value) {
    _searchDebouncer.run(() {
      context.read<GroupProvider>().getAllUsers(
        query: value,
        onSuccess: () {},
        onError: (error) {},
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        title: AppText(text: 'Add Members'),
      ),
      body: Consumer<GroupProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Divider(color: AppColors.black.withValues(alpha: 0.1), height: 1),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "Add Members",
                        style: AppTextStyles.semiBold(fontSize: 14.sp),
                      ),
                      8.w.verticalSpace,
                      AppTextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        hintText: "Search by name or email",
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
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 12.w),
                          child: Icon(
                            Icons.search_rounded,
                            size: 20.sp,
                            color: AppColors.black.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      18.w.verticalSpace,
                      AppText(
                        text: "Members",
                        style: AppTextStyles.semiBold(fontSize: 14.sp),
                      ),
                      8.w.verticalSpace,
                      Expanded(child: _buildUsersList(provider)),
                      12.w.verticalSpace,
                      AppFilledButton(
                        text: provider.selectedUsersCount > 0
                            ? "Add Members (${provider.selectedUsersCount})"
                            : "Add Members",
                        isLoading: provider.addMembersLoading,
                        onTap: provider.selectedUsersCount > 0
                            ? () {
                                provider.addMembersToGroup(
                                  groupId: widget.groupId,
                                  onSuccess: () {
                                    AppToast.success(
                                      context,
                                      'Members added successfully',
                                    );
                                    provider.clearUserSelection();
                                    provider.getGroupMembers(
                                      groupId: widget.groupId,
                                    );
                                    context.pop();
                                  },
                                  onError: (error) {
                                    AppToast.error(context, error);
                                  },
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUsersList(GroupProvider provider) {
    switch (provider.getAllUsersState) {
      case DataState.loading:
        return _buildLoadingState();
      case DataState.failed:
        return _buildErrorState(provider);
      case DataState.success:
        if (provider.allUsersList.isEmpty) {
          return _buildEmptyState();
        }
        return _buildSuccessList(provider);
    }
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      separatorBuilder: (_, __) => Divider(
        height: 24.w,
        thickness: 1,
        color: AppColors.black.withValues(alpha: 0.08),
      ),
      itemBuilder: (context, index) {
        return const _ShimmerMemberTile();
      },
    );
  }

  Widget _buildErrorState(GroupProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: AppColors.black.withValues(alpha: 0.3),
            ),
            12.h.verticalSpace,
            AppText(
              text: provider.getAllUsersError ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: AppTextStyles.medium(
                fontSize: 14.sp,
                color: AppColors.black.withValues(alpha: 0.55),
              ),
            ),
            16.h.verticalSpace,
            GestureDetector(
              onTap: () {
                context.read<GroupProvider>().getAllUsers(
                  query: _searchController.text,
                  onSuccess: () {},
                  onError: (error) {},
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.teal.withValues(alpha: 0.4),
                  ),
                ),
                child: AppText(
                  text: "Retry",
                  style: AppTextStyles.semiBold(
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 48.sp,
            color: AppColors.black.withValues(alpha: 0.25),
          ),
          12.h.verticalSpace,
          AppText(
            text: "No users found",
            style: AppTextStyles.semiBold(
              fontSize: 16.sp,
              color: AppColors.black.withValues(alpha: 0.45),
            ),
          ),
          4.h.verticalSpace,
          AppText(
            text: "Try searching with a different keyword",
            style: AppTextStyles.medium(
              fontSize: 13.sp,
              color: AppColors.black.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessList(GroupProvider provider) {
    final users = provider.allUsersList;
    final itemCount = users.length + (provider.usersHasNextPage ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      itemCount: itemCount,
      separatorBuilder: (_, __) => Divider(
        height: 24.w,
        thickness: 1,
        color: AppColors.black.withValues(alpha: 0.08),
      ),
      itemBuilder: (context, index) {
        if (index == users.length) {
          return _buildPaginationLoader();
        }
        final user = users[index];
        return _MemberTile(
          user: user,
          isSelected: provider.isUserSelected(user.id),
          onToggle: () => provider.toggleUserSelection(user.id),
        );
      },
    );
  }

  Widget _buildPaginationLoader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: SizedBox(
          width: 24.sp,
          height: 24.sp,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.teal,
          ),
        ),
      ),
    );
  }
}

// ================= MEMBER TILE =================

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.user,
    required this.isSelected,
    required this.onToggle,
  });

  final SearchUser user;
  final bool isSelected;
  final VoidCallback onToggle;

  static const List<Color> _avatarColors = [
    Color(0xFF53C3BF),
    Color(0xFFD7B086),
    Color(0xFF66C99D),
    Color(0xFF7B9FD4),
    Color(0xFFD48B8B),
    Color(0xFFA68BD4),
    Color(0xFFD4C36A),
    Color(0xFF6AC8D4),
  ];

  Color get _avatarColor {
    final hash = user.id.codeUnits.fold<int>(0, (prev, c) => prev + c);
    return _avatarColors[hash % _avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: _avatarColor,
            child: AppText(
              text: user.initials,
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
                  text: user.fullName,
                  style: AppTextStyles.bold(
                    fontSize: 18.sp,
                    color: AppColors.black,
                  ),
                ),
                2.h.verticalSpace,
                AppText(
                  text: user.email ?? '',
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24.sp,
            height: 24.sp,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.teal : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? AppColors.teal
                    : AppColors.black.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: isSelected
                ? Icon(Icons.check, size: 14.sp, color: AppColors.white)
                : null,
          ),
        ],
      ),
    );
  }
}

// ================= SHIMMER LOADING TILE =================

class _ShimmerMemberTile extends StatelessWidget {
  const _ShimmerMemberTile();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 20.r, backgroundColor: AppColors.shimmerBaseColor),
        16.w.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 14.h,
                width: 140.w,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBaseColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              6.h.verticalSpace,
              Container(
                height: 11.h,
                width: 190.w,
                decoration: BoxDecoration(
                  color: AppColors.shimmerBaseColor.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
        10.w.horizontalSpace,
        Container(
          height: 34.h,
          width: 90.w,
          decoration: BoxDecoration(
            color: AppColors.shimmerBaseColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}
