import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
/// Turns API thumbnail paths into a full URL [CachedNetworkImage] can load.
///
/// Supports two shapes returned by the backend:
///   * Absolute `http(s)://` URLs (e.g. `https://upload.wikimedia.org/...`)
///     — returned as-is.
///   * Site-relative paths (e.g. `uploads/stories/thumbnails/.../foo.png`
///     or `/storage/...`) — base URL is prepended.
String resolveNetworkImageUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = DioClient.baseUrl.replaceAll(RegExp(r'/+$'), '');
  if (trimmed.startsWith('/')) {
    return '$base$trimmed';
  }
  return '$base/$trimmed';
}

/// Same as [resolveNetworkImageUrl] but preserves `null` / empty inputs by
/// returning `null`. Useful for nullable model fields like `avatarUrl` where
/// the UI still wants to distinguish "no image" from "broken image".
String? resolveNullableNetworkImageUrl(String? url) {
  if (url == null) return null;
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  return resolveNetworkImageUrl(trimmed);
}

/// Logs a failed network image load with the URL and the underlying error.
///
/// Call this from `CachedNetworkImage`'s `errorWidget` callback so we can see
/// in the console which URL failed and why (404, DNS error, malformed URL,
/// etc.). The optional [tag] helps identify where the image is rendered.
///
/// Example:
/// ```dart
/// errorWidget: (context, url, error) {
///   logNetworkImageError(tag: 'ContinueReading.card', url: url, error: error);
///   return _ImageErrorPlaceholder(...);
/// },
/// ```
void logNetworkImageError({
  String? tag,
  required String url,
  required Object error,
}) {
  final prefix = (tag == null || tag.isEmpty) ? '' : '[$tag] ';
  Logger.error(
    '${prefix}Image failed to load → url="$url" | error=$error',
    tag: 'NetworkImage',
  );
}

/// Returns true when the image request was rejected due to rate limiting.
bool isNetworkImageRateLimited(Object error) {
  final statusCode = _networkImageHttpStatusCode(error);
  return statusCode == 429;
}

int? _networkImageHttpStatusCode(Object error) {
  try {
    final dynamic e = error;
    final statusCode = e.statusCode;
    if (statusCode is int) return statusCode;
  } catch (_) {
    // Not an HTTP status-bearing error.
  }
  return null;
}
/// Backoff delay for rate-limit retries: 2s → 4s → 8s → 16s → 30s (capped).
Duration networkImageRateLimitRetryDelay(int attempt) {
  final seconds = (2 * (1 << attempt.clamp(0, 4))).clamp(2, 30);
  return Duration(seconds: seconds);
}

void logNetworkImageRateLimitRetry({
  String? tag,
  required String url,
  required int attempt,
  required Duration retryIn,
}) {
  final prefix = (tag == null || tag.isEmpty) ? '' : '[$tag] ';
  Logger.info(
    '${prefix}Image rate limited (429), retry #${attempt + 1} in '
    '${retryIn.inSeconds}s → url="$url"',
    tag: 'NetworkImage',
  );
}
