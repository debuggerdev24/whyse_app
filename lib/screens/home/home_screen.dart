import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:redstreakapp/core/widgets/app_layout.dart';
import 'package:redstreakapp/core/widgets/home_widgets.dart';
import 'package:redstreakapp/screens/home/widgets/story_topics_section.dart';

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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.w),
          children: [
            const HomeHeader(),
            20.w.verticalSpace,
            
            const CalendarStrip(),
            24.w.verticalSpace,
            const StoryTopicsSection(),
            24.w.verticalSpace,
            const PracticeZoneSection(),
            24.w.verticalSpace,
            BottomStatsCard(),
            10.w.verticalSpace,
          ],
        ),
      ),
    );
  }
}