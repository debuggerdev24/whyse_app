import 'package:redstreakapp/core/utils/app_imports.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        title: AppText(text: 'Groups'),
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
              padding: EdgeInsets.fromLTRB(24.w, 14.w, 24.w, 0),
              child: ListView.separated(
                itemCount: _kGroups.length,
                separatorBuilder: (_, _) => Divider(
                  height: 24.w,
                  thickness: 1,
                  color: AppColors.black.withValues(alpha: 0.08),
                ),
                itemBuilder: (context, index) {
                  final group = _kGroups[index];
                  return _GroupTile(
                    group: group,
                    onTap: () {
                      context.pushNamed(AppRoutes.viewGroupScreen.name);
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

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, required this.onTap});

  final _GroupInfo group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lighttealcolor,
            ),
            child: Icon(Icons.person, size: 22.sp, color: AppColors.teal),
          ),
          16.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: group.name,
                  style: AppTextStyles.semibold(
                    fontSize: 16.sp,
                    color: AppColors.black,
                  ),
                ),
                AppText(
                  text: '${group.members} Members',
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
              text: '${group.badgeCount}',
              style: AppTextStyles.bold(fontSize: 12.sp, color: AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupInfo {
  const _GroupInfo({
    required this.name,
    required this.members,
    required this.badgeCount,
  });

  final String name;
  final int members;
  final int badgeCount;
}

const List<_GroupInfo> _kGroups = [
  _GroupInfo(name: 'Grp1e', members: 3, badgeCount: 10),
  _GroupInfo(name: 'Grp354', members: 4, badgeCount: 6),
  _GroupInfo(name: 'Grp356', members: 9, badgeCount: 4),
  _GroupInfo(name: 'Gp879', members: 5, badgeCount: 1),
  _GroupInfo(name: 'Gp152', members: 7, badgeCount: 7),
];
