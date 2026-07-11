import 'package:redstreakapp/core/widgets/app_skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:redstreakapp/core/constants/app_assets.dart';
import 'package:redstreakapp/core/widgets/app_network_image.dart';
import 'package:redstreakapp/services/profile/profile_service.dart';

/// Shimmer block matching avatar dimensions (parent may clip to circle).
class UserAvatarShimmerFill extends StatelessWidget {
  const UserAvatarShimmerFill({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonizer(
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
      ),
    );
  }
}

/// Square image; clip with [ClipOval] in the parent for a circle.
///
/// When [showPlaceholderShimmerWhenEmpty] is true and there is no URL yet
/// (e.g. profile still loading), shows a shimmer instead of the default asset.
class UserAvatarImage extends StatelessWidget {
  const UserAvatarImage({
    super.key,
    required this.avatarUrl,
    required this.size,
    this.showPlaceholderShimmerWhenEmpty = false,
  });

  final String? avatarUrl;
  final double size;

  /// If true and [avatarUrl] resolves to no URL, show shimmer instead of default.
  final bool showPlaceholderShimmerWhenEmpty;

  @override
  Widget build(BuildContext context) {
    final url = profileAvatarAbsoluteUrl(avatarUrl);
    if (url.isEmpty) {
      if (showPlaceholderShimmerWhenEmpty) {
        return UserAvatarShimmerFill(size: size);
      }
      return Image.asset(
        AppAssets.profile,
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    }
    return AppNetworkImage(
      imageUrl: url,
      tag: 'UserAvatarImage',
      width: size,
      height: size,
      placeholder: (_) => UserAvatarShimmerFill(size: size),
      errorBuilder: (_, _, _) => Image.asset(
        AppAssets.profile,
        fit: BoxFit.cover,
        width: size,
        height: size,
      ),
    );
  }
}
