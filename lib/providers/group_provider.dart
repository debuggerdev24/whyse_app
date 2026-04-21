import 'package:flutter/material.dart';
import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/models/group/group_members_model.dart';
import 'package:redstreakapp/models/group/group_response_model.dart';
import 'package:redstreakapp/services/group/group_api_service.dart';

class GroupProvider extends ChangeNotifier {
  DataState getGroupListState = DataState.loading;
  String? getGroupsListError;

  DataState getGroupMembersState = DataState.loading;
  String? getGroupMembersError;

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
      final result = await GroupApiService.instance.getMyGroups();
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
      final result = await GroupApiService.instance.getGroupMembers(groupId);
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
              .take(5)
              .map((e) => GroupMember.fromJson(e))
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
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      _createGroupLoading = true;
      notifyListeners();
      final result = await GroupApiService.instance.createGroup(
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
          onSuccess();
          notifyListeners();
        },
      );
      notifyListeners();
    } catch (e) {
      _createGroupLoading = false;
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
      final result = await GroupApiService.instance.joinGroupByCode(code);
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
      final result = await GroupApiService.instance.leaveGroup(groupId);
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
}
