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
