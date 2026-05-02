import 'package:dartz/dartz.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/network/end_points.dart';

class FriendApiService {
  FriendApiService._();

  static final FriendApiService _instance = FriendApiService._();
  static FriendApiService instance = _instance;

  Future<Either<ApiException, Map<String, dynamic>>> getFriends({
    int page = 1,
    int limit = 20,
  }) async {
    return await BaseApiHelper.instance.get(
      EndPoints.getFriends(page: page, limit: limit),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> searchUsers({
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    return await BaseApiHelper.instance.get(
      EndPoints.searchFriends(page: page, limit: limit, q: q),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> sendFriendRequest({
    required String email,
  }) async {
    return await BaseApiHelper.instance.post(
      EndPoints.sendFriendRequest,
      data: {"email": email},
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getFriendRequests({
    int page = 1,
    int limit = 50,
  }) async {
    return await BaseApiHelper.instance.get(
      EndPoints.getFriendRequests(page: page, limit: limit),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> updateFriendRequest({
    required String friendshipId,
    required String status,
  }) async {
    return await BaseApiHelper.instance.patch(
      EndPoints.updateFriendRequest(friendshipId: friendshipId),
      data: {"status": status},
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> removeFriend({
    required String friendshipId,
  }) async {
    return await BaseApiHelper.instance.delete(
      EndPoints.removeFriend(friendshipId: friendshipId),
    );
  }
}
