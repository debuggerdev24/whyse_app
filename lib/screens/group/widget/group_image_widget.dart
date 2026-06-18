import 'package:redstreakapp/core/extensions/color.extensions.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';

class GroupImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? size;
  const GroupImageWidget({super.key, required this.imageUrl, this.size});

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 64.w;
    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: imageUrl == null ? AppColors.black.setOpacity(0.1) : null,
      ),
      alignment: Alignment.center,
      child: imageUrl == null
          ? const Icon(Icons.group)
          : ClipOval(
              child: AppNetworkImage(
                imageUrl: imageUrl,
                tag: 'GroupImage',
                width: dimension,
                height: dimension,
                placeholder: (_) => _ImageShimmer(dimension),
                errorBuilder: (_, __, ___) => Container(
                  width: dimension,
                  height: dimension,
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
    return AppSkeletonizer(child: Container(
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
