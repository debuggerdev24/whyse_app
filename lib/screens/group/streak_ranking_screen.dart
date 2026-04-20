import 'package:redstreakapp/core/utils/app_imports.dart';

class StreakRankingScreen extends StatelessWidget {
  const StreakRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(
              AppAssets.thunder,
              size: 16.sp,
              color: AppColors.orangeColor,
            ),
            6.w.horizontalSpace,
            AppText(
              text: 'Streaks Ranking',
              style: AppTextStyles.semibold(
                fontSize: 21.sp,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Divider(color: AppColors.black.withValues(alpha: 0.1), height: 1),
          10.w.verticalSpace,
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 20.h),
              itemCount: _kRankingItems.length,
              separatorBuilder: (_, _) => Divider(
                height: 24.w,
                thickness: 1,
                color: AppColors.black.withValues(alpha: 0.08),
              ),
              itemBuilder: (context, index) {
                final item = _kRankingItems[index];
                return _RankingRow(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.item});

  final _RankingItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.extealighttealcolor,
          ),
          alignment: Alignment.center,
          child: AppText(
            text: '${item.rank}',
            style: AppTextStyles.semibold(
              fontSize: 12.sp,
              color: AppColors.teal,
            ),
          ),
        ),
        16.w.horizontalSpace,
        Container(
          width: 40.w,
          height: 40.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lighttealcolor,
          ),
          child: Icon(
            Icons.person,
            size: 20.sp,
            color: AppColors.teal,
          ),
        ),
        12.w.horizontalSpace,
        Expanded(
          child: AppText(
            text: item.name,
            style: AppTextStyles.semibold(
              fontSize: 16.sp,
              color: AppColors.black,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.black.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgIcon(
                AppAssets.thunder,
                size: 13.sp,
                color: AppColors.orangeColor,
              ),
              4.w.horizontalSpace,
              AppText(
                text: '${item.score}',
                style: AppTextStyles.semibold(
                  fontSize: 16.sp,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankingItem {
  const _RankingItem({
    required this.rank,
    required this.name,
    required this.score,
  });

  final int rank;
  final String name;
  final int score;
}

const List<_RankingItem> _kRankingItems = [
  _RankingItem(rank: 1, name: 'Emma Rodriguez', score: 10),
  _RankingItem(rank: 2, name: 'Liam Kumar', score: 6),
  _RankingItem(rank: 3, name: 'Sofia Mendes', score: 4),
  _RankingItem(rank: 4, name: 'Noah Patel', score: 1),
  _RankingItem(rank: 5, name: 'You', score: 1),
];
