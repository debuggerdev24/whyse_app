import 'package:dartz/dartz.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/network/end_points.dart';

class GroupApiService {
  GroupApiService._();

  static final GroupApiService _instance = GroupApiService._();
  static GroupApiService instance = _instance;

  Future<Either<ApiException, Map<String, dynamic>>> getMyGroups() async {
    return await BaseApiHelper.instance.get(EndPoints.getMyGroups);
  }

  Future<Either<ApiException, Map<String, dynamic>>> getGroupMembers(
    String groupId,
  ) async {
    return await BaseApiHelper.instance.get(
      EndPoints.getGroupMembers(groupId: groupId),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> leaveGroup(
    String groupId,
  ) async {
    return await BaseApiHelper.instance.post(
      EndPoints.leaveGroup(groupId: groupId),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> joinGroupByCode(
    String code,
  ) async {
    return await BaseApiHelper.instance.post(
      EndPoints.joinGroupByCode,
      data: {"code": code.trim()},
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> createGroup({
    required String title,
    String? description,
  }) async {
    return await BaseApiHelper.instance.post(
      EndPoints.createGroup,
      data: description == null
          ? {"title": title}
          : {"title": title, "description": description},
    );
  }
}
