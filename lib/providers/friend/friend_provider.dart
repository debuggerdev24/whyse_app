import 'package:flutter/material.dart';
import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/services/profile/friend_api_service.dart';

class FriendProvider extends ChangeNotifier {
  // ============== Friends list ==============
  DataState getFriendsState = DataState.loading;
  String? getFriendsError;

  List<FriendResponse> _friendsList = [];
  List<FriendResponse> get friendsList => _friendsList;

  int _currentPage = 1;
  int _totalPages = 1;
  bool get hasNextPage => _currentPage < _totalPages;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  // ============== Search users ==============
  DataState searchUsersState = DataState.loading;
  String? searchUsersError;

  List<FriendUser> _searchUsersList = [];
  List<FriendUser> get searchUsersList => _searchUsersList;

  int _searchCurrentPage = 1;
  int _searchTotalPages = 1;
  bool get searchHasNextPage => _searchCurrentPage < _searchTotalPages;

  bool _isSearchLoadingMore = false;
  bool get isSearchLoadingMore => _isSearchLoadingMore;

  String _searchQuery = '';

  Future<void> getFriends() async {
    try {
      getFriendsState = DataState.loading;
      getFriendsError = null;
      _friendsList = [];
      _currentPage = 1;
      _totalPages = 1;
      notifyListeners();

      final result = await FriendApiService.instance.getFriends(page: 1);
      result.fold(
        (l) {
          getFriendsState = DataState.failed;
          getFriendsError = l.errorMsg;
          Logger.error(
            '[FRIEND PROVIDER]: error getting friends: ${l.errorMsg}',
          );
        },
        (r) {
          final data = r['data'] as Map<String, dynamic>;
          final friends = (data['friends'] as List)
              .map((e) => FriendResponse.fromJson(e as Map<String, dynamic>))
              .toList();
          final pagination = data['pagination'] as Map<String, dynamic>;
          _friendsList = friends;
          _currentPage = pagination['page'] as int;
          _totalPages = pagination['totalPages'] as int;
          getFriendsState = DataState.success;
          Logger.info(
            '[FRIEND PROVIDER]: friends fetched: ${_friendsList.length}',
          );
        },
      );
      notifyListeners();
    } catch (e) {
      getFriendsState = DataState.failed;
      getFriendsError = e.toString();
      Logger.error(
        '[FRIEND PROVIDER]: exception getting friends: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  Future<void> loadMoreFriends() async {
    if (_isLoadingMore || !hasNextPage) return;
    try {
      _isLoadingMore = true;
      notifyListeners();

      final nextPage = _currentPage + 1;
      final result = await FriendApiService.instance.getFriends(page: nextPage);
      result.fold(
        (l) {
          Logger.error(
            '[FRIEND PROVIDER]: error loading more friends: ${l.errorMsg}',
          );
        },
        (r) {
          final data = r['data'] as Map<String, dynamic>;
          final friends = (data['friends'] as List)
              .map((e) => FriendResponse.fromJson(e as Map<String, dynamic>))
              .toList();
          final pagination = data['pagination'] as Map<String, dynamic>;
          _friendsList.addAll(friends);
          _currentPage = pagination['page'] as int;
          _totalPages = pagination['totalPages'] as int;
        },
      );
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      Logger.error(
        '[FRIEND PROVIDER]: exception loading more friends: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  // ============== Search users methods ==============

  Future<void> searchUsers({String? query}) async {
    try {
      _searchQuery = query ?? '';
      searchUsersState = DataState.loading;
      searchUsersError = null;
      _searchUsersList = [];
      _searchCurrentPage = 1;
      _searchTotalPages = 1;
      notifyListeners();

      final result = await FriendApiService.instance.searchUsers(
        page: 1,
        q: _searchQuery.isEmpty ? null : _searchQuery,
      );
      result.fold(
        (l) {
          searchUsersState = DataState.failed;
          searchUsersError = l.errorMsg;
          Logger.error(
            '[FRIEND PROVIDER]: error searching users: ${l.errorMsg}',
          );
        },
        (r) {
          final data = r['data'] as Map<String, dynamic>;
          final users = (data['users'] as List)
              .map((e) => FriendUser.fromJson(e as Map<String, dynamic>))
              .toList();
          final pagination = data['pagination'] as Map<String, dynamic>;
          _searchUsersList = users;
          _searchCurrentPage = pagination['page'] as int;
          _searchTotalPages = pagination['totalPages'] as int;
          searchUsersState = DataState.success;
          Logger.info(
            '[FRIEND PROVIDER]: search users fetched: ${_searchUsersList.length}',
          );
        },
      );
      notifyListeners();
    } catch (e) {
      searchUsersState = DataState.failed;
      searchUsersError = e.toString();
      Logger.error(
        '[FRIEND PROVIDER]: exception searching users: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  Future<void> loadMoreSearchUsers() async {
    if (_isSearchLoadingMore || !searchHasNextPage) return;
    try {
      _isSearchLoadingMore = true;
      notifyListeners();

      final nextPage = _searchCurrentPage + 1;
      final result = await FriendApiService.instance.searchUsers(
        page: nextPage,
        q: _searchQuery.isEmpty ? null : _searchQuery,
      );
      result.fold(
        (l) {
          Logger.error(
            '[FRIEND PROVIDER]: error loading more search users: ${l.errorMsg}',
          );
        },
        (r) {
          final data = r['data'] as Map<String, dynamic>;
          final users = (data['users'] as List)
              .map((e) => FriendUser.fromJson(e as Map<String, dynamic>))
              .toList();
          final pagination = data['pagination'] as Map<String, dynamic>;
          _searchUsersList.addAll(users);
          _searchCurrentPage = pagination['page'] as int;
          _searchTotalPages = pagination['totalPages'] as int;
        },
      );
      _isSearchLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isSearchLoadingMore = false;
      Logger.error(
        '[FRIEND PROVIDER]: exception loading more search users: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  // ============== Send friend request ==============

  bool _isSendingRequest = false;
  bool get isSendingRequest => _isSendingRequest;

  Future<void> sendFriendRequest({
    required String email,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    if (_isSendingRequest) return;
    try {
      _isSendingRequest = true;
      notifyListeners();

      final result = await FriendApiService.instance.sendFriendRequest(
        email: email,
      );
      result.fold(
        (l) {
          _isSendingRequest = false;
          onError(l.errorMsg);
          Logger.error(
            '[FRIEND PROVIDER]: error sending friend request: ${l.errorMsg}',
          );
          notifyListeners();
        },
        (r) {
          _isSendingRequest = false;
          onSuccess();
          Logger.info('[FRIEND PROVIDER]: friend request sent successfully');
          notifyListeners();
        },
      );
    } catch (e) {
      _isSendingRequest = false;
      onError(e.toString());
      Logger.error(
        '[FRIEND PROVIDER]: exception sending friend request: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  // ============== Friend requests (pending) ==============

  DataState getRequestsState = DataState.loading;
  String? getRequestsError;

  List<FriendRequestResponse> _requestsList = [];
  List<FriendRequestResponse> get requestsList => _requestsList;

  Future<void> getFriendRequests() async {
    try {
      getRequestsState = DataState.loading;
      getRequestsError = null;
      _requestsList = [];
      notifyListeners();

      final result = await FriendApiService.instance.getFriendRequests();
      result.fold(
        (l) {
          getRequestsState = DataState.failed;
          getRequestsError = l.errorMsg;
          Logger.error(
            '[FRIEND PROVIDER]: error getting friend requests: ${l.errorMsg}',
          );
        },
        (r) {
          final data = r['data'] as Map<String, dynamic>;
          final requests = (data['requests'] as List)
              .map((e) =>
                  FriendRequestResponse.fromJson(e as Map<String, dynamic>))
              .toList();
          _requestsList = requests;
          getRequestsState = DataState.success;
          Logger.info(
            '[FRIEND PROVIDER]: friend requests fetched: ${_requestsList.length}',
          );
        },
      );
      notifyListeners();
    } catch (e) {
      getRequestsState = DataState.failed;
      getRequestsError = e.toString();
      Logger.error(
        '[FRIEND PROVIDER]: exception getting friend requests: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  Future<void> acceptFriendRequest({
    required String friendshipId,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final result = await FriendApiService.instance.updateFriendRequest(
        friendshipId: friendshipId,
        status: 'ACCEPTED',
      );
      result.fold(
        (l) {
          onError(l.errorMsg);
          Logger.error(
            '[FRIEND PROVIDER]: error accepting request: ${l.errorMsg}',
          );
        },
        (r) {
          _requestsList.removeWhere((req) => req.friendshipId == friendshipId);
          notifyListeners();
          onSuccess();
          Logger.info('[FRIEND PROVIDER]: friend request accepted');
        },
      );
    } catch (e) {
      onError(e.toString());
      Logger.error(
        '[FRIEND PROVIDER]: exception accepting request: ${e.toString()}',
      );
    }
  }

  Future<void> declineFriendRequest({
    required String friendshipId,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final result = await FriendApiService.instance.updateFriendRequest(
        friendshipId: friendshipId,
        status: 'DECLINED',
      );
      result.fold(
        (l) {
          onError(l.errorMsg);
          Logger.error(
            '[FRIEND PROVIDER]: error declining request: ${l.errorMsg}',
          );
        },
        (r) {
          _requestsList.removeWhere((req) => req.friendshipId == friendshipId);
          notifyListeners();
          onSuccess();
          Logger.info('[FRIEND PROVIDER]: friend request declined');
        },
      );
    } catch (e) {
      onError(e.toString());
      Logger.error(
        '[FRIEND PROVIDER]: exception declining request: ${e.toString()}',
      );
    }
  }

  // ============== Remove friend ==============

  Future<void> removeFriend({
    required String friendshipId,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final result = await FriendApiService.instance.removeFriend(
        friendshipId: friendshipId,
      );
      result.fold(
        (l) {
          onError(l.errorMsg);
          Logger.error(
            '[FRIEND PROVIDER]: error removing friend: ${l.errorMsg}',
          );
        },
        (r) {
          _friendsList.removeWhere((f) => f.friendshipId == friendshipId);
          notifyListeners();
          onSuccess();
          Logger.info('[FRIEND PROVIDER]: friend removed successfully');
        },
      );
    } catch (e) {
      onError(e.toString());
      Logger.error(
        '[FRIEND PROVIDER]: exception removing friend: ${e.toString()}',
      );
    }
  }
}
