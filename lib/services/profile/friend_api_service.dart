import 'package:dartz/dartz.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/network/end_points.dart';
import 'package:redstreakapp/models/friend/friend_details_model.dart';

class FriendApiService {
  static const bool enableApiLogging = false;
  static final _api = BaseApiHelper(enableApiLogging: enableApiLogging);

  FriendApiService._();

  static final FriendApiService _instance = FriendApiService._();
  static FriendApiService instance = _instance;

  Future<Either<ApiException, Map<String, dynamic>>> getFriends({
    int page = 1,
    int limit = 20,
  }) async {
    return await _api.get(
      EndPoints.getFriends(page: page, limit: limit),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getFriendsExcludingFamily({
    int page = 1,
    int limit = 20,
  }) async {
    return await _api.get(
      EndPoints.getFriendsExcludingFamily(page: page, limit: limit),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> searchUsers({
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    return await _api.get(
      EndPoints.searchFriends(page: page, limit: limit, q: q),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> sendFriendRequest({
    required String email,
  }) async {
    return await _api.post(
      EndPoints.sendFriendRequest,
      data: {"email": email},
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> getFriendRequests({
    int page = 1,
    int limit = 50,
  }) async {
    return await _api.get(
      EndPoints.getFriendRequests(page: page, limit: limit),
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> updateFriendRequest({
    required String friendshipId,
    required String status,
  }) async {
    return await _api.patch(
      EndPoints.updateFriendRequest(friendshipId: friendshipId),
      data: {"status": status},
    );
  }

  Future<Either<ApiException, Map<String, dynamic>>> removeFriend({
    required String friendshipId,
  }) async {
    return await _api.delete(
      EndPoints.removeFriend(friendshipId: friendshipId),
    );
  }

  Future<Either<ApiException, FriendDetailsResponse>> getFriendsDetails({
    required String friendId,
  }) async {
    return _api.get<FriendDetailsResponse>(
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
    return _api.get<FriendProfileListResponse>(
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
    return _api.get<UserProfileGroupsListResponse>(
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
    return _api.get<UserProfileTopicsListResponse>(
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
