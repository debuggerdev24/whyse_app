import 'package:dartz/dartz.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/network/end_points.dart';
import 'package:redstreakapp/models/friend/friend_details_model.dart';

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

  Future<Either<ApiException, Map<String, dynamic>>> getFriendsExcludingFamily({
    int page = 1,
    int limit = 20,
  }) async {
    return await BaseApiHelper.instance.get(
      EndPoints.getFriendsExcludingFamily(page: page, limit: limit),
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

  Future<Either<ApiException, FriendDetailsResponse>> getFriendsDetails({
    required String friendId,
  }) async {
    return BaseApiHelper.instance.get<FriendDetailsResponse>(
      EndPoints.getFriendsDetails(friendId: friendId),
      parser: (result) =>
          FriendDetailsResponse.fromJson(result as Map<String, dynamic>),
    );
  }

  Future<Either<ApiException, FriendProfileListResponse>>
  getUserProfileFriendsList({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    return BaseApiHelper.instance.get<FriendProfileListResponse>(
      EndPoints.getUserProfileSectionList(
        userId: userId,
        section: 'friends',
        page: page,
        limit: limit,
      ),
      parser: (result) =>
          FriendProfileListResponse.fromJson(result as Map<String, dynamic>),
    );
  }

  Future<Either<ApiException, UserProfileGroupsListResponse>>
  getUserProfileGroupsList({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    return BaseApiHelper.instance.get<UserProfileGroupsListResponse>(
      EndPoints.getUserProfileSectionList(
        userId: userId,
        section: 'groups',
        page: page,
        limit: limit,
      ),
      parser: (result) => UserProfileGroupsListResponse.fromJson(
        result as Map<String, dynamic>,
      ),
    );
  }

  Future<Either<ApiException, UserProfileTopicsListResponse>>
  getUserProfileTopicsList({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    return BaseApiHelper.instance.get<UserProfileTopicsListResponse>(
      EndPoints.getUserProfileSectionList(
        userId: userId,
        section: 'topics',
        page: page,
        limit: limit,
      ),
      parser: (result) => UserProfileTopicsListResponse.fromJson(
        result as Map<String, dynamic>,
      ),
    );
  }
}
