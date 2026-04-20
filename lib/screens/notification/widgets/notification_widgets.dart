import 'package:redstreakapp/core/utils/app_imports.dart';

class NotificationItemData {
  const NotificationItemData({
    required this.name,
    required this.message,
    required this.avatarEmoji,
  });

  final String name;
  final String message;
  final String avatarEmoji;
}

class NotificationSection extends StatelessWidget {
  const NotificationSection({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<NotificationItemData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: title,
          style: AppTextStyles.bold(fontSize: 20.sp),
        ),
        13.w.verticalSpace,
        ...List.generate(items.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 16.w),
            child: NotificationTile(item: items[index]),
          );
        }),
      ],
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item});

  final NotificationItemData item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE6CF),
            borderRadius: BorderRadius.circular(26.r),
          ),
          alignment: Alignment.center,
          child: Text(
            item.avatarEmoji,
            style: TextStyle(fontSize: 26.sp),
          ),
        ),
        12.w.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: item.name,
                style: AppTextStyles.bold(fontSize: 16.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              2.w.verticalSpace,
              AppText(
                text: item.message,
                style: AppTextStyles.regular(
                  fontSize: 12.sp,
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        10.w.horizontalSpace,
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 8.w),
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: AppText(
              text: 'Accept',
              style: AppTextStyles.bold(
                fontSize: 16.sp,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
