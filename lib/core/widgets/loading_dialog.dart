import 'package:redstreakapp/core/utils/app_imports.dart';

showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IntrinsicWidth(
              child: Container(
                padding: EdgeInsets.all(15.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: CupertinoActivityIndicator(
                    color: AppColors.teal,
                    radius: 16.r,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
