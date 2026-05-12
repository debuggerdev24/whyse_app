import 'package:flutter/material.dart';
import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/models/group/group_members_model.dart';
import 'package:redstreakapp/models/group/group_response_model.dart';
import 'package:redstreakapp/models/group/group_shared_topic_model.dart';
import 'package:redstreakapp/models/group/search_user_model.dart';
import 'package:redstreakapp/models/group/shareable_topic_model.dart';
import 'package:redstreakapp/services/profile/group_api_service.dart';

class GroupProvider extends ChangeNotifier {
  final GroupApiService _groupApiService;
  GroupProvider(this._groupApiService);

  DataState getGroupListState = DataState.loading;
  String? getGroupsListError;

  DataState getGroupMembersState = DataState.loading;
  String? getGroupMembersError;

  DataState getAllUsersState = DataState.loading;
  String? getAllUsersError;

  List<SearchUser> _allUsersList = [];
  List<SearchUser> get allUsersList => _allUsersList;

  int _usersCurrentPage = 1;
  bool _usersHasNextPage = true;
  bool get usersHasNextPage => _usersHasNextPage;

  bool _isLoadingMoreUsers = false;
  bool get isLoadingMoreUsers => _isLoadingMoreUsers;

  String _usersSearchQuery = '';
  String get usersSearchQuery => _usersSearchQuery;

  final Set<String> _selectedUserIds = {};
  Set<String> get selectedUserIds => _selectedUserIds;
  int get selectedUsersCount => _selectedUserIds.length;

  bool isUserSelected(String userId) => _selectedUserIds.contains(userId);

  void toggleUserSelection(String userId) {
    if (_selectedUserIds.contains(userId)) {
      _selectedUserIds.remove(userId);
    } else {
      _selectedUserIds.add(userId);
    }
    notifyListeners();
  }

  void clearUserSelection() {
    _selectedUserIds.clear();
    notifyListeners();
  }

  List<SearchUser> get selectedUsers =>
      _allUsersList.where((u) => _selectedUserIds.contains(u.id)).toList();

  bool _addMembersLoading = false;
  bool get addMembersLoading => _addMembersLoading;

  Future<void> addMembersToGroup({
    required String groupId,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    if (_selectedUserIds.isEmpty) return;
    try {
      _addMembersLoading = true;
      notifyListeners();
      final result = await _groupApiService.addGroupMembers(
        groupId: groupId,
        userIds: _selectedUserIds.toList(),
      );
      result.fold(
        (l) {
          _addMembersLoading = false;
          onError(l.errorMsg);
          Logger.error(
            '[GROUP PROVIDER]: error adding members: ${l.errorMsg}',
          );
          notifyListeners();
        },
        (r) {
          _addMembersLoading = false;
          _selectedUserIds.clear();
          onSuccess();
          notifyListeners();
        },
      );
    } catch (e) {
      _addMembersLoading = false;
      onError(e.toString());
      Logger.error(
        '[GROUP PROVIDER]: exception adding members: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  Future<void> removeMemberFromGroup({
    required String groupId,
    required String userId,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final result = await _groupApiService.removeGroupMember(
        groupId: groupId,
        userId: userId,
      );
      result.fold(
        (l) {
          onError(l.errorMsg);
          Logger.error(
            '[GROUP PROVIDER]: error removing member: ${l.errorMsg}',
          );
        },
        (r) {
          _groupMembersList.removeWhere((m) => m.userId == userId);
          notifyListeners();
          onSuccess();
        },
      );
    } catch (e) {
      onError(e.toString());
      Logger.error(
        '[GROUP PROVIDER]: exception removing member: ${e.toString()}',
      );
    }
  }

  bool _joinGroupLoading = false;
  bool get joinGroupLoading => _joinGroupLoading;

  bool _createGroupLoading = false;
  bool get createGroupLoading => _createGroupLoading;

  bool _leaveGroupLoading = false;
  bool get leaveGroupLoading => _leaveGroupLoading;


  List<GroupResponse> _myGroupsList = [];
  List<GroupResponse> get myGroupsList => _myGroupsList;

  List<GroupMember> _groupMembersList = [];
  List<GroupMember> get groupMembersList => _groupMembersList;

  Future<void> getGroupsList() async {
    try {
      getGroupListState = DataState.loading;
      getGroupsListError = null;
      _myGroupsList = [];
      notifyListeners();
      final result = await _groupApiService.getMyGroups();
      result.fold(
        (l) {
          getGroupListState = DataState.failed;
          getGroupsListError = l.errorMsg;
          Logger.error(
            '[GROUP PROVIDER]: error getting groups list: ${l.toString()}',
          );
          notifyListeners();
        },
        (r) {
          _myGroupsList = (r['data'] as List)
              .map((e) => GroupResponse.fromJson(e))
              .toList();
          getGroupListState = DataState.success;
          Logger.info(
            '[GROUP PROVIDER]: groups list fetched: ${_myGroupsList.length}',
          );
          notifyListeners();
        },
      );
    } catch (e) {
      getGroupListState = DataState.failed;
      getGroupsListError = e.toString();
      Logger.error(
        '[GROUP PROVIDER]: exception in getting groups list: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  Future<void> getGroupMembers({required String groupId}) async {
    try {
      getGroupMembersState = DataState.loading;
      getGroupMembersError = null;
      _groupMembersList = [];
      notifyListeners();
      final result = await _groupApiService.getGroupMembers(groupId);
      result.fold(
        (l) {
          getGroupMembersState = DataState.failed;
          getGroupMembersError = l.errorMsg;
          Logger.error(
            '[GROUP PROVIDER]: error getting group members: ${l.toString()}',
          );
        },
        (r) {
          _groupMembersList = (r['data']['members'] as List)
              .map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
              .toList();
          getGroupMembersState = DataState.success;
        },
      );
      notifyListeners();
    } catch (e) {
      getGroupMembersState = DataState.failed;
      getGroupMembersError = e.toString();
      Logger.error(
        '[GROUP PROVIDER]: exception in getting group members: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  Future<void> createGroup({
    required String code,
    String? description,
    required Function(String groupId) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      _createGroupLoading = true;
      notifyListeners();
      final result = await _groupApiService.createGroup(
        title: code,
        description: description,
      );
      result.fold(
        (l) {
          _createGroupLoading = false;
          onError(l.errorMsg);
          Logger.error('[GROUP PROVIDER]: error creating group: ${l.errorMsg}');
          notifyListeners();
        },
        (r) {
          _createGroupLoading = false;
          onSuccess(r['data']['id']);
          notifyListeners();
        },
      );
      notifyListeners();
    } catch (e) {
      _createGroupLoading = false;
      onError(e.toString());
      Logger.error(
        '[GROUP PROVIDER]: exception in creating group: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  Future<void> joinGroupByCode({
    required String code,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      _joinGroupLoading = true;
      notifyListeners();
      final result = await _groupApiService.joinGroupByCode(code);
      result.fold(
        (l) {
          _joinGroupLoading = false;
          onError(l.errorMsg);
          Logger.error(
            '[GROUP PROVIDER]: error joining group by code: ${l.errorMsg}',
          );
          notifyListeners();
        },
        (r) {
          _joinGroupLoading = false;
          onSuccess();
          notifyListeners();
        },
      );
      notifyListeners();
    } catch (e) {
      _joinGroupLoading = false;
      Logger.error(
        '[GROUP PROVIDER]: exception in joining group by code: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  Future<void> leaveGroup({
    required String groupId,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      _leaveGroupLoading = true;
      notifyListeners();
      final result = await _groupApiService.leaveGroup(groupId);
      result.fold(
        (l) {
          _leaveGroupLoading = false;
          onError(l.errorMsg);
          Logger.error(
            '[GROUP PROVIDER]: error leave group loading: ${l.errorMsg}',
          );
          notifyListeners();
        },
        (r) {
          _leaveGroupLoading = false;
          onSuccess();
          notifyListeners();
        },
      );
      notifyListeners();
    } catch (e) {
      _leaveGroupLoading = false;
      Logger.error(
        '[GROUP PROVIDER]: exception in leave group loading: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  Future<void> getAllUsers({
    String? query,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      _usersSearchQuery = query ?? '';
      getAllUsersState = DataState.loading;
      getAllUsersError = null;
      _allUsersList = [];
      _usersCurrentPage = 1;
      _usersHasNextPage = true;
      notifyListeners();

      final result = await _groupApiService.searchUsers(
        page: 1,
        q: _usersSearchQuery.isEmpty ? null : _usersSearchQuery,
      );
      result.fold(
        (l) {
          getAllUsersState = DataState.failed;
          getAllUsersError = l.errorMsg;
          onError(l.errorMsg);
          Logger.error(
            '[GROUP PROVIDER]: error getting users: ${l.errorMsg}',
          );
        },
        (r) {
          final data = r['data'] as Map<String, dynamic>;
          final users = (data['users'] as List)
              .map((e) => SearchUser.fromJson(e as Map<String, dynamic>))
              .toList();
          final pagination = data['pagination'] as Map<String, dynamic>;
          _allUsersList = users;
          _usersCurrentPage = pagination['page'] as int;
          _usersHasNextPage = pagination['hasNextPage'] as bool;
          getAllUsersState = DataState.success;
          getAllUsersError = null;
          onSuccess();
        },
      );
      notifyListeners();
    } catch (e) {
      getAllUsersState = DataState.failed;
      getAllUsersError = e.toString();
      Logger.error(
        '[GROUP PROVIDER]: exception in getting users: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  Future<void> loadMoreUsers() async {
    if (_isLoadingMoreUsers || !_usersHasNextPage) return;
    try {
      _isLoadingMoreUsers = true;
      notifyListeners();

      final nextPage = _usersCurrentPage + 1;
      final result = await _groupApiService.searchUsers(
        page: nextPage,
        q: _usersSearchQuery.isEmpty ? null : _usersSearchQuery,
      );
      result.fold(
        (l) {
          Logger.error(
            '[GROUP PROVIDER]: error loading more users: ${l.errorMsg}',
          );
        },
        (r) {
          final data = r['data'] as Map<String, dynamic>;
          final users = (data['users'] as List)
              .map((e) => SearchUser.fromJson(e as Map<String, dynamic>))
              .toList();
          final pagination = data['pagination'] as Map<String, dynamic>;
          _allUsersList.addAll(users);
          _usersCurrentPage = pagination['page'] as int;
          _usersHasNextPage = pagination['hasNextPage'] as bool;
        },
      );
      _isLoadingMoreUsers = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMoreUsers = false;
      Logger.error(
        '[GROUP PROVIDER]: exception loading more users: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  // ---------- Group Shared Topics ----------

  List<GroupSharedTopic>? groupSharedTopics;
  bool isGroupSharedTopicsLoading = false;

  Future<void> getGroupSharedTopics({required String groupId}) async {
    groupSharedTopics = null;
    isGroupSharedTopicsLoading = true;
    notifyListeners();

    try {
      final result = await _groupApiService.getGroupSharedTopics(
        groupId: groupId,
      );
      result.fold(
        (error) {
          Logger.error(
            '[GROUP PROVIDER]: error getting shared topics: ${error.errorMsg}',
          );
        },
        (r) {
          final data = r['data'];
          final list = data is Map ? data['items'] : data;
          if (list is List) {
            groupSharedTopics = list
                .map((e) => GroupSharedTopic.fromJson(
                      Map<String, dynamic>.from(e as Map? ?? {}),
                    ))
                .toList();
          } else {
            groupSharedTopics = [];
          }
        },
      );
    } catch (e) {
      Logger.error(
        '[GROUP PROVIDER]: exception in getting shared topics: $e',
      );
      groupSharedTopics = [];
    } finally {
      isGroupSharedTopicsLoading = false;
      notifyListeners();
    }
  }

  // ---------- Shareable Topics (Select Series screen) ----------

  List<ShareableTopicItem> shareableTopics = [];
  bool isShareableTopicsLoading = false;
  bool isLoadingMoreShareableTopics = false;
  bool hasMoreShareableTopics = true;
  int _shareableTopicsPage = 1;
  bool isSharingTopics = false;

  Future<void> fetchShareableTopics({bool refresh = false}) async {
    if (isShareableTopicsLoading) return;
    if (refresh) {
      _shareableTopicsPage = 1;
      shareableTopics = [];
      hasMoreShareableTopics = true;
    }
    isShareableTopicsLoading = true;
    notifyListeners();

    try {
      final result = await _groupApiService.getShareableTopics(
        page: _shareableTopicsPage,
        limit: 10,
      );
      result.fold(
        (error) => Logger.error('[GROUP PROVIDER] shareable topics: ${error.errorMsg}'),
        (r) {
          final data = r['data'];
          if (data is Map) {
            final items = ((data['items'] as List?) ?? [])
                .map((e) => ShareableTopicItem.fromJson(
                      Map<String, dynamic>.from(e as Map? ?? {}),
                    ))
                .toList();
            if (refresh || _shareableTopicsPage == 1) {
              shareableTopics = items;
            } else {
              shareableTopics.addAll(items);
            }
            final pagination = data['pagination'] as Map?;
            final totalPages = pagination?['totalPages'] as int? ?? 1;
            hasMoreShareableTopics = _shareableTopicsPage < totalPages;
          }
        },
      );
    } catch (e) {
      Logger.error('[GROUP PROVIDER] shareable topics exception: $e');
    } finally {
      isShareableTopicsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreShareableTopics() async {
    if (isLoadingMoreShareableTopics || !hasMoreShareableTopics) return;
    _shareableTopicsPage++;
    isLoadingMoreShareableTopics = true;
    notifyListeners();

    try {
      final result = await _groupApiService.getShareableTopics(
        page: _shareableTopicsPage,
        limit: 10,
      );
      result.fold(
        (error) {
          _shareableTopicsPage--;
          Logger.error('[GROUP PROVIDER] load more shareable topics: ${error.errorMsg}');
        },
        (r) {
          final data = r['data'];
          if (data is Map) {
            final items = ((data['items'] as List?) ?? [])
                .map((e) => ShareableTopicItem.fromJson(
                      Map<String, dynamic>.from(e as Map? ?? {}),
                    ))
                .toList();
            shareableTopics.addAll(items);
            final pagination = data['pagination'] as Map?;
            final totalPages = pagination?['totalPages'] as int? ?? 1;
            hasMoreShareableTopics = _shareableTopicsPage < totalPages;
          }
        },
      );
    } catch (e) {
      _shareableTopicsPage--;
      Logger.error('[GROUP PROVIDER] load more shareable topics exception: $e');
    } finally {
      isLoadingMoreShareableTopics = false;
      notifyListeners();
    }
  }

  Future<String?> shareTopicsInGroup({
    required String groupId,
    required List<String> topicIds,
  }) async {
    isSharingTopics = true;
    notifyListeners();

    String? message;
    try {
      final result = await _groupApiService.shareTopicsInGroup(
        groupId: groupId,
        topicIds: topicIds,
      );
      result.fold(
        (error) {
          Logger.error('[GROUP PROVIDER] share topics: ${error.errorMsg}');
        },
        (r) {
          message = r['message']?.toString();
          getGroupSharedTopics(groupId: groupId);
        },
      );
    } catch (e) {
      Logger.error('[GROUP PROVIDER] share topics exception: $e');
    } finally {
      isSharingTopics = false;
      notifyListeners();
    }
    return message;
  }

  void clearSessionData() {
    getGroupListState = DataState.loading;
    getGroupsListError = null;
    getGroupMembersState = DataState.loading;
    getGroupMembersError = null;
    getAllUsersState = DataState.loading;
    getAllUsersError = null;
    _allUsersList = [];
    _usersCurrentPage = 1;
    _usersHasNextPage = true;
    _isLoadingMoreUsers = false;
    _usersSearchQuery = '';
    _selectedUserIds.clear();
    _addMembersLoading = false;
    _joinGroupLoading = false;
    _createGroupLoading = false;
    _leaveGroupLoading = false;
    _myGroupsList = [];
    _groupMembersList = [];
    groupSharedTopics = null;
    isGroupSharedTopicsLoading = false;
    shareableTopics = [];
    isShareableTopicsLoading = false;
    isLoadingMoreShareableTopics = false;
    hasMoreShareableTopics = true;
    _shareableTopicsPage = 1;
    isSharingTopics = false;
    notifyListeners();
  }
}
