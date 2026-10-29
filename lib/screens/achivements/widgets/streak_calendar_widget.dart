import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/gamification/streak_score_model.dart';

class StreakCalendarWidget extends StatefulWidget {
  const StreakCalendarWidget({
    super.key,
    required this.calendarDays,
    this.onMonthChanged,
  });

  final List<StreakCalendarDay> calendarDays;
  final void Function(int year, int month)? onMonthChanged;

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
    widget.onMonthChanged?.call(_visibleMonth.year, _visibleMonth.month);
  }

  Set<int> _completedDaysForVisibleMonth() {
    final days = <int>{};
    for (final day in widget.calendarDays) {
      if (!day.isCompleted) continue;
      final parsed = DateTime.tryParse(day.date);
      if (parsed == null) continue;
      if (parsed.year == _visibleMonth.year &&
          parsed.month == _visibleMonth.month) {
        days.add(parsed.day);
      }
    }
    return days;
  }

  Set<int> _frozenDaysForVisibleMonth() {
    final days = <int>{};
    for (final day in widget.calendarDays) {
      if (!day.isFrozen) continue;
      final parsed = DateTime.tryParse(day.date);
      if (parsed == null) continue;
      if (parsed.year == _visibleMonth.year &&
          parsed.month == _visibleMonth.month) {
        days.add(parsed.day);
      }
    }
    return days;
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
    final completedDays = _completedDaysForVisibleMonth();
    final frozenDays = _frozenDaysForVisibleMonth();
    final monthTitle =
        '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}';
    final now = DateTime.now();

    final weeks = <List<DateTime?>>[];
    for (var i = 0; i < cells.length; i += 7) {
      final week = cells.skip(i).take(7).toList();
      while (week.length < 7) {
        week.add(null);
      }
      weeks.add(week);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Streak Calendar',
          style: AppTextStyles.semibold(
            fontSize: 18,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _MonthNavButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => _shiftMonth(-1),
            ),
            Expanded(
              child: AppText(
                text: monthTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.semibold(
                  fontSize: 16,
                  color: AppColors.black,
                ),
              ),
            ),
            _MonthNavButton(
              icon: Icons.chevron_right_rounded,
              onTap: () => _shiftMonth(1),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final label in _weekdayLabels)
              Expanded(
                child: AppText(
                  text: label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.medium(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (final week in weeks)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                for (final date in week)
                  Expanded(
                    child: _DayCell(
                      date: date,
                      now: now,
                      isCompleted: date != null && completedDays.contains(date.day),
                      isFrozen: date != null && frozenDays.contains(date.day),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.now,
    required this.isCompleted,
    required this.isFrozen,
  });

  final DateTime? date;
  final DateTime now;
  final bool isCompleted;
  final bool isFrozen;

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox(height: 40);

    final isToday =
        date!.year == now.year && date!.month == now.month && date!.day == now.day;
    final isFuture = date!.isAfter(DateTime(now.year, now.month, now.day));
    final Color textColor = isCompleted
        ? Colors.white
        : isFuture
        ? const Color(0xFFC7C7CC)
        : AppColors.black;

    return SizedBox(
      height: 40,
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.orangeColor
                : isFrozen
                ? AppColors.accentFill(const Color(0xFFE7F6F6))
                : Colors.transparent,
            border: isToday && !isCompleted
                ? Border.all(color: AppColors.orangeColor, width: 1.5)
                : null,
          ),
          child: isFrozen
              ? const SvgIcon(AppAssets.snow, size: 16)
              : AppText(
                  text: '${date!.day}',
                  style: AppTextStyles.semibold(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
        ),
      ),
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
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.accentFill(const Color(0xFFF2F2F7)),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.black),
      ),
    );
  }
}
