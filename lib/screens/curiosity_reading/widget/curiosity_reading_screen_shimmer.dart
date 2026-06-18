import 'package:redstreakapp/core/utils/app_imports.dart';

class CuriosityReadingScreenShimmer extends StatelessWidget {
  const CuriosityReadingScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: AppSkeletonizer(
        child: Column(
          children: [
            SizedBox(
              height: 400.h,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                  ),

                  /// Top Bar
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12.h,
                    left: 25.w,
                    right: 25.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _circle(),
                        Container(
                          width: 140.w,
                          height: 20.h,
                          color: Colors.white,
                        ),
                        _circle(),
                      ],
                    ),
                  ),

                  /// Title
                  Positioned(
                    left: 25.w,
                    right: 25.w,
                    bottom: 60.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 26.h,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        10.verticalSpace,
                        Container(
                          height: 26.h,
                          width: 220.w,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),

                  /// White rounded section
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          topRight: Radius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: Column(
                  children: [
                    20.verticalSpace,

                    /// Article
                    ...List.generate(
                      8,
                      (index) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Container(
                          width: double.infinity,
                          height: 14.h,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    20.verticalSpace,

                    /// Key Facts Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 18.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        children: List.generate(
                          4,
                          (index) => Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Container(
                              width: double.infinity,
                              height: 12.h,
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}