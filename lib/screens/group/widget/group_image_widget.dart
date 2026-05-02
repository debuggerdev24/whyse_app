import 'package:cached_network_image/cached_network_image.dart';
import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:shimmer/shimmer.dart';

class GroupImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? size;
  const GroupImageWidget({super.key, required this.imageUrl, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? 64.w,
      height: size ?? 64.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: imageUrl == null ? AppColors.black.setOpacity(0.1) : null,
      ),
      alignment: Alignment.center,
      child: imageUrl == null
          ? const Icon(Icons.group)
          : ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _ImageShimmer(size ?? 64.w),
                // errorWidget: (_, __, ___) =>
                //     const NoImageFound(compact: true, iconOnly: true),
                errorWidget: (_, __, ___) => Container(
                  width: size ?? 64.w,
                  height: size ?? 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.black.setOpacity(0.1),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.group),
                ),
              ),
            ),
    );
  }
}

class _ImageShimmer extends StatelessWidget {
  const _ImageShimmer(this.size);
  final double size;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}
