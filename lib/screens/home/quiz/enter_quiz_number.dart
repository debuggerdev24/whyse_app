import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/providers/home/story_provider.dart';

const int _kMinEach = 1;

/// Question counts UI. [storyId] is passed when navigating (e.g. from Take Quiz).
class EnterQuizNumbersScreen extends StatefulWidget {
  final String storyId;

  const EnterQuizNumbersScreen({super.key, required this.storyId});

  @override
  State<EnterQuizNumbersScreen> createState() => _EnterQuizNumbersScreenState();
}

class _EnterQuizNumbersScreenState extends State<EnterQuizNumbersScreen> {
  int _mcq = _kMinEach;
  int _open = _kMinEach;
  int _trueFalse = _kMinEach;

  int get _total => _mcq + _open + _trueFalse;

  @override
  Widget build(BuildContext context) {
    final fieldDecoration = BoxDecoration(
      color: AppColors.lightwhiteColor,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: AppColors.black.withValues(alpha: 0.08)),
    );

    return AppLayout(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Material(
            color: AppColors.white,
            elevation: 3,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText(
                    text: 'Question generation',
                    style: AppTextStyles.bold(
                      fontSize: 17.sp,
                      color: AppColors.black,
                    ),
                  ),
                  20.h.verticalSpace,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: 'No of MCQ',
                              style: AppTextStyles.medium(
                                fontSize: 12.sp,
                                color: AppColors.black.withValues(alpha: 0.75),
                              ),
                            ),
                            8.h.verticalSpace,
                            Container(
                              height: 44.h,
                              decoration: fieldDecoration,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: _mcq > _kMinEach
                                        ? () => setState(() => _mcq--)
                                        : null,
                                    icon: Icon(
                                      Icons.remove,
                                      size: 20.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  AppText(
                                    text: '$_mcq',
                                    style: AppTextStyles.bold(
                                      fontSize: 16.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() => _mcq++),
                                    icon: Icon(
                                      Icons.add,
                                      size: 20.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      12.w.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: 'No of Open questions',
                              style: AppTextStyles.medium(
                                fontSize: 12.sp,
                                color: AppColors.black.withValues(alpha: 0.75),
                              ),
                            ),
                            8.h.verticalSpace,
                            Container(
                              height: 44.h,
                              decoration: fieldDecoration,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: _open > _kMinEach
                                        ? () => setState(() => _open--)
                                        : null,
                                    icon: Icon(
                                      Icons.remove,
                                      size: 20.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  AppText(
                                    text: '$_open',
                                    style: AppTextStyles.bold(
                                      fontSize: 16.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() => _open++),
                                    icon: Icon(
                                      Icons.add,
                                      size: 20.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  14.h.verticalSpace,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: 'No of True and False',
                              style: AppTextStyles.medium(
                                fontSize: 12.sp,
                                color: AppColors.black.withValues(alpha: 0.75),
                              ),
                            ),
                            8.h.verticalSpace,
                            Container(
                              height: 44.h,
                              decoration: fieldDecoration,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: _trueFalse > _kMinEach
                                        ? () => setState(() => _trueFalse--)
                                        : null,
                                    icon: Icon(
                                      Icons.remove,
                                      size: 20.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  AppText(
                                    text: '$_trueFalse',
                                    style: AppTextStyles.bold(
                                      fontSize: 16.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        setState(() => _trueFalse++),
                                    icon: Icon(
                                      Icons.add,
                                      size: 20.sp,
                                      color: AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      12.w.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: 'Total questions',
                              style: AppTextStyles.medium(
                                fontSize: 12.sp,
                                color: AppColors.black.withValues(alpha: 0.75),
                              ),
                            ),
                            8.h.verticalSpace,
                            Container(
                              height: 44.h,
                              alignment: Alignment.center,
                              decoration: fieldDecoration,
                              child: AppText(
                                text: '$_total',
                                style: AppTextStyles.bold(
                                  fontSize: 16.sp,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  22.w.verticalSpace,
                  AppFilledButton(
                    text: 'Generate question',
                    onTap: () {
                      final provider = context.read<StoryProvider>();
                      provider.createQuiz(
                        storyId: widget.storyId,
                        noOfMcq: _mcq,
                        noOfOpenQuestions: _open,
                        noOfTrueFalse: _trueFalse,
                      );
                    },
                    isLoading: false,
                    backgroundColor: AppColors.teal,
                    fixedSize: Size(double.infinity, 48.h),
                    radius: 999,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
