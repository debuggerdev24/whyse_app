import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/screens/home/home_screen.dart';

class TabScreen extends StatefulWidget {
  final int initialIndex;
  const TabScreen({super.key, this.initialIndex = 0});

  @override
  State<StatefulWidget> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  late int currentIndex;

  final List<Widget> screens = [
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
    HomeScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  Widget bottomNavigationBar() {
    return KBottomNavBar(
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      items: [
        BottomNavItem(icon: AppAssets.note, isSelected: currentIndex == 0),
        BottomNavItem(icon: AppAssets.book, isSelected: currentIndex == 1),
        BottomNavItem(icon: AppAssets.dumble, isSelected: currentIndex == 2),
        BottomNavItem(icon: AppAssets.star, isSelected: currentIndex == 3),
      ],
    );
  }
}

class KBottomNavBar extends StatelessWidget {
  const KBottomNavBar({
    super.key,
    required this.items,
    this.onTap,
    this.currentIndex = 0,
  });

  final List<BottomNavItem> items;
  final ValueChanged<int>? onTap;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 18,
            spreadRadius: -3,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      height: 74.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(onTap: () => onTap?.call(i), child: items[i]),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    Key? key,
    required this.icon,
    this.label,
    this.isSelected = false,
  }) : super(key: key);

  final String icon;
  final String? label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected
        ? AppColors.black
        : AppColors.darkGrey.withOpacity(0.3);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
      child: Column(
        children: [
          SvgPicture.asset(
            icon,
            width: 32.w,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }
}
