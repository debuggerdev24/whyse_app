import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/network/end_points.dart';
import 'package:redstreakapp/core/utils/network_image_url.dart';

/// Builds a displayable image URL when the API returns a relative path.
String profileAvatarAbsoluteUrl(String? pathOrUrl) =>
    resolveNullableNetworkImageUrl(pathOrUrl) ?? '';

String _basenameFromPath(String path) {
  final i = path.lastIndexOf(RegExp(r'[/\\]'));
  return i < 0 ? path : path.substring(i + 1);
}

class ProfileService {
  final BaseApiHelper apiHelper;

  ProfileService(this.apiHelper);

  Future<Either<ApiException, Map<String, dynamic>>> getProfile() async {
    return await apiHelper.get(EndPoints.profile);
  }

  Future<Either<ApiException, Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> body,
  ) async {
    return await apiHelper.patch<Map<String, dynamic>>(
      EndPoints.profile,
      data: body,
    );
  }

  /// Multipart field name `avatar` (same as curl `--form 'avatar=@...'`).
  Future<Either<ApiException, Map<String, dynamic>>> uploadAvatar(
    String filePath,
  ) async {
    final name = _basenameFromPath(filePath);
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        filePath,
        filename: name.isEmpty ? 'avatar.jpg' : name,
      ),
    });
    return await apiHelper.post<Map<String, dynamic>>(
      EndPoints.profileAvatar,
      data: formData,
    );
  }
}
