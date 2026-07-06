import 'package:redstreakapp/core/utils/app_imports.dart';

class StreakCalendarWidget extends StatefulWidget {
  const StreakCalendarWidget({
    super.key,
    required this.streakDays,
  });

  final Set<int> streakDays;

  @override
  State<StreakCalendarWidget> createState() => _StreakCalendarWidgetState();
}

class _StreakCalendarWidgetState extends State<StreakCalendarWidget> {
  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  List<DateTime?> _buildMonthGrid() {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday % 7;
    final cells = <DateTime?>[];

    for (var i = 0; i < leadingEmpty; i++) {
      cells.add(null);
    }
    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(_visibleMonth.year, _visibleMonth.month, day));
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final cells = _buildMonthGrid();
    final monthTitle =
        '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}';
    final inactiveColor = AppColors.black.withValues(alpha: 0.35);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Streak Calendar',
          style: AppTextStyles.semiBold(fontSize: 18.sp, color: AppColors.black),
        ),
        14.h.verticalSpace,
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 20.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _MonthNavButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => _shiftMonth(-1),
                  ),
                  Expanded(
                    child: Center(
                      child: AppText(
                        text: monthTitle,
                        style: AppTextStyles.semiBold(
                          fontSize: 16.sp,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                  _MonthNavButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => _shiftMonth(1),
                  ),
                ],
              ),
              18.h.verticalSpace,
              Row(
                children: _weekdayLabels
                    .map(
                      (label) => Expanded(
                        child: Center(
                          child: AppText(
                            text: label,
                            style: AppTextStyles.medium(
                              fontSize: 13.sp,
                              color: inactiveColor,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              12.h.verticalSpace,
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cells.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 0,
                ),
                itemBuilder: (context, index) {
                  final date = cells[index];
                  if (date == null) return const SizedBox.shrink();

                  final isStreakDay = widget.streakDays.contains(date.day);
                  return Center(
                    child: Container(
                      width: 34.w,
                      height: 34.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isStreakDay
                            ? AppColors.orangeColor
                            : Colors.transparent,
                      ),
                      child: AppText(
                        text: '${date.day}',
                        style: AppTextStyles.semiBold(
                          fontSize: 14.sp,
                          color: isStreakDay
                              ? AppColors.white
                              : inactiveColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  const _MonthNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 22.sp, color: AppColors.black),
    );
  }
}
