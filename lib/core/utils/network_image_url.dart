import 'package:redstreakapp/core/network/base_api_service.dart';

/// Turns API thumbnail paths into a full URL [CachedNetworkImage] can load.
/// Supports absolute `http(s)://` URLs and site-relative paths like `/storage/...`.
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
