import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/constants/text_style.dart';
import 'package:redstreakapp/core/widgets/app_text.dart';
import 'package:redstreakapp/providers/auth_provider.dart';
import 'package:redstreakapp/providers/home_provider.dart';
import 'package:redstreakapp/screens/home/widgets/add_reading_bottom_sheet.dart';
import 'package:redstreakapp/core/widgets/home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().getAllStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              24.h.verticalSpace,
              const CalendarStrip(),
              24.h.verticalSpace,
              const YourPlanSection(),
              24.h.verticalSpace,
              // const PracticeZoneSection(),
              24.h.verticalSpace,
              // BottomStatsCard(),
              80.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
