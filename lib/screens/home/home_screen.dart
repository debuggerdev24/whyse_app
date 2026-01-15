import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          children: [
            const HomeHeader(),
            24.h.verticalSpace,
            const CalendarStrip(),
            24.h.verticalSpace,
            const YourPlanSection(),

            24.h.verticalSpace,

            const PracticeZoneSection(),
            24.h.verticalSpace,
            BottomStatsCard(),
            10.h.verticalSpace,
          ],
        ),
      ),
    );
  }
}
