import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';

class AchivementsTabBarSelection extends StatefulWidget {
  const AchivementsTabBarSelection({
    super.key,
    required this.onTabSelected,
  });

  final Function(int) onTabSelected;

  @override
  State<AchivementsTabBarSelection> createState() =>
      _AchivementsTabBarSelectionState();
}

class _AchivementsTabBarSelectionState
    extends State<AchivementsTabBarSelection> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _tabItem('PERSONAL', _selectedIndex == 0, () {
          setState(() => _selectedIndex = 0);
          widget.onTabSelected(0);
        }),
        _tabItem('FRIENDS', _selectedIndex == 1, () {
          setState(() => _selectedIndex = 1);
          widget.onTabSelected(1);
        }),
      ],
    );
  }

  Widget _tabItem(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? AppColors.orangeColor
                    : AppColors.black.setOpacity(0.1),
                width: 2.w,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: Center(
            child: Text(
              title,
              style: AppTextStyles.semiBold(
                fontSize: 14.sp,
                color: isSelected ? AppColors.orangeColor : AppColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
