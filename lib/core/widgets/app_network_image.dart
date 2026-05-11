import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:redstreakapp/core/constants/app_color.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';
import 'package:redstreakapp/core/widgets/global_widgets.dart';
import 'package:shimmer/shimmer.dart';

/// Signature for a custom error widget builder, mirroring
/// [CachedNetworkImage]'s [LoadingErrorWidgetBuilder].
typedef AppNetworkImageErrorBuilder =
    Widget Function(BuildContext context, String url, Object error);

/// Shared network image widget used everywhere instead of [CachedNetworkImage]
/// directly.
///
/// Why use this:
/// - Resolves relative API paths (e.g. `uploads/...`) to absolute URLs via
///   [resolveNullableNetworkImageUrl] – no need to call it at every call site.
/// - Empty / null URLs short-circuit to the error widget so the network layer
///   isn't spammed with bogus requests (and we don't log a "404" for them).
/// - Provides sensible defaults: shimmer placeholder + [NoImageFound] error.
/// - Centralises failure logging via [logNetworkImageError]; pass [tag] so
///   the console clearly shows where the image lives (e.g.
///   `ContinueReading.card`).
///
/// All visual aspects can still be overridden when a screen needs something
/// custom – override [placeholder] and/or [errorBuilder].
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.tag,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorBuilder,
    this.errorTitle = 'No image found',
    this.errorSubtitle,
    this.errorCompact = false,
    this.errorIconOnly = false,
  });

  /// Raw URL or relative API path. May be `null` or empty.
  final String? imageUrl;

  /// Identifier shown in error logs (e.g. `"ContinueReading.card"`).
  final String? tag;

  final double? width;
  final double? height;
  final BoxFit fit;

  /// Optional clip radius applied to the entire content
  /// (image, placeholder and error widget).
  final BorderRadius? borderRadius;

  /// Custom placeholder. If null, a shimmer block is shown.
  final WidgetBuilder? placeholder;

  /// Custom error widget. If null, a [NoImageFound] is shown using the
  /// `error*` fields below.
  final AppNetworkImageErrorBuilder? errorBuilder;

  /// Defaults for the built-in [NoImageFound] error widget.
  /// Ignored when [errorBuilder] is provided.
  final String errorTitle;
  final String? errorSubtitle;
  final bool errorCompact;
  final bool errorIconOnly;

  @override
  Widget build(BuildContext context) {
    final resolved = resolveNullableNetworkImageUrl(imageUrl) ?? '';

    Widget content;
    if (resolved.isEmpty) {
      // No URL at all – show the error/empty widget directly. We intentionally
      // do NOT log here: empty URLs are an expected "no image yet" state, not
      // a failure.
      content = _buildError(context, '', const _EmptyImageUrlError());
    } else {
      content = CachedNetworkImage(
        imageUrl: resolved,
        width: width,
        height: height,
        fit: fit,
        placeholder: (ctx, _) => _buildPlaceholder(ctx),
        errorWidget: (ctx, failedUrl, error) {
          logNetworkImageError(tag: tag, url: failedUrl, error: error);
          return _buildError(ctx, failedUrl, error);
        },
      );
    }

    if (borderRadius != null) {
      content = ClipRRect(borderRadius: borderRadius!, child: content);
    }

    if (width != null || height != null) {
      content = SizedBox(width: width, height: height, child: content);
    }

    return content;
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) return placeholder!(context);
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBaseColor,
      highlightColor: AppColors.shimmerHighlightColor,
      child: Container(color: AppColors.shimmerBaseColor),
    );
  }

  Widget _buildError(BuildContext context, String url, Object error) {
    if (errorBuilder != null) return errorBuilder!(context, url, error);
    return NoImageFound(
      title: errorTitle,
      subtitle: errorSubtitle,
      compact: errorCompact,
      iconOnly: errorIconOnly,
    );
  }
}

/// Sentinel error used when an image is requested with a null/empty URL.
class _EmptyImageUrlError implements Exception {
  const _EmptyImageUrlError();
  @override
  String toString() => 'Image URL is null or empty';
}
