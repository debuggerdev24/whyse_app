import 'package:dartz/dartz.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/network/end_points.dart';

class GroupApiService {
  static const bool enableApiLogging = false;
  static final _defaultApiHelper =
      BaseApiHelper(enableApiLogging: enableApiLogging);

  final BaseApiHelper _apiHelper;

  GroupApiService([BaseApiHelper? apiHelper])
      : _apiHelper = apiHelper ?? _defaultApiHelper;

  Future<Either<ApiException, Map<String, dynamic>>> getMyGroups() async {
    return await _apiHelper.get(EndPoints.getMyGroups);
  }

  Future<Either<ApiException, Map<String, dynamic>>> getGroupMembers(
    String groupId,
  ) async {
    return await _apiHelper.get(
      EndPoints.getGroupMembers(groupId: groupId),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> leaveGroup(
    String groupId,
  ) async {
    return await _apiHelper.post(
      EndPoints.leaveGroup(groupId: groupId),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> joinGroupByCode(
    String code,
  ) async {
    return await _apiHelper.post(
      EndPoints.joinGroupByCode,
      data: {"code": code.trim()},
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> createGroup({
    required String title,
    String? description,
  }) async {
    return await _apiHelper.post(
      EndPoints.createGroup,
      data: description == null
          ? {"title": title}
          : {"title": title, "description": description},
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> addGroupMembers({
    required String groupId,
    required List<String> userIds,
    String role = 'MEMBER',
  }) async {
    return await _apiHelper.post(
      EndPoints.addGroupMembers(groupId: groupId),
      data: {
        "userIds": userIds,
        "role": role,
      },
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> removeGroupMember({
    required String groupId,
    required String userId,
  }) async {
    return await _apiHelper.delete(
      EndPoints.removeGroupMember(groupId: groupId, userId: userId),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> searchUsers({
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    return await _apiHelper.get(
      EndPoints.searchUsers(page: page, limit: limit, q: q),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getGroupSharedTopics({
    required String groupId,
  }) async {
    return await _apiHelper.get(
      EndPoints.groupSharedTopics(groupId: groupId),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> shareTopicsInGroup({
    required String groupId,
    required List<String> topicIds,
  }) async {
    return await _apiHelper.post(
      EndPoints.shareTopicsInGroup(groupId: groupId),
      data: {"topicIds": topicIds},
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getShareableTopics({
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiHelper.get(
      EndPoints.getShareableTopics(page: page, limit: limit),
    );
  }
}
