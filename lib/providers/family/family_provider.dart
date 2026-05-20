import 'package:flutter/foundation.dart';
import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/enums/user_gender.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/models/family/family_member_model.dart';
import 'package:redstreakapp/models/family/family_role_model.dart';
import 'package:redstreakapp/models/friend/friend_details_model.dart';
import 'package:redstreakapp/models/friend/friend_model.dart';
import 'package:redstreakapp/services/profile/family_api_service.dart';

class FamilyProvider extends ChangeNotifier {
  static const int profilePreviewLimit = 7;
  static const int familyListPageSize = 20;

  final List<FamilyMember> _familyMembers = [];

  List<FamilyMember> get familyMembers => List.unmodifiable(_familyMembers);

  List<FamilyMember> get profileFamilyMembers =>
      _familyMembers.take(profilePreviewLimit).toList();

  DataState familyMembersState = DataState.loading;
  String? familyMembersError;
  int _totalFamilyMembers = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  bool _loadedFullFamilyList = false;

  bool get hasMoreFamilyMembers => _currentPage < _totalPages;
  bool get isLoadingMoreFamilyMembers => _isLoadingMore;
  int get totalFamilyMembers => _totalFamilyMembers;

  DataState familyRolesState = DataState.loading;
  String? familyRolesError;
  List<FamilyRole> _familyRoles = [];
  List<FamilyRole> get familyRoles => List.unmodifiable(_familyRoles);

  DataState editFamilyRolesState = DataState.loading;
  String? editFamilyRolesError;
  List<FamilyRole> _editFamilyRoles = [];
  List<FamilyRole> get editFamilyRoles => List.unmodifiable(_editFamilyRoles);
  String? _lastEditExcludeId;

  static const Set<String> _maleRoleValues = {
    'FATHER',
    'BROTHER',
    'SON',
    'HUSBAND',
    'GRANDFATHER',
    'UNCLE',
    'NEPHEW',
    'GRANDSON',
    'COUSIN',
    'GUARDIAN',
  };

  static const Set<String> _femaleRoleValues = {
    'MOTHER',
    'SISTER',
    'DAUGHTER',
    'WIFE',
    'GRANDMOTHER',
    'AUNT',
    'NIECE',
    'GRANDDAUGHTER',
    'COUSIN',
    'GUARDIAN',
  };

  bool isFamilyMember(String userId) =>
      _familyMembers.any((m) => m.member.id == userId);

  String? relationshipFor(String userId) {
    try {
      return _familyMembers.firstWhere((m) => m.member.id == userId).relationship;
    } catch (_) {
      return null;
    }
  }

  List<FamilyRole> relationshipOptionsFor(UserGender? gender) {
    if (_familyRoles.isEmpty) return const [];

    switch (gender) {
      case UserGender.male:
        return _familyRoles
            .where((role) => _maleRoleValues.contains(role.value))
            .toList();
      case UserGender.female:
        return _familyRoles
            .where((role) => _femaleRoleValues.contains(role.value))
            .toList();
      case UserGender.unknown:
      case null:
        return _familyRoles;
    }
  }

  Future<void> getFamilyMembersPreview({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        familyMembersState == DataState.success &&
        !_loadedFullFamilyList &&
        _familyMembers.isNotEmpty) {
      return;
    }
    _loadedFullFamilyList = false;
    await _fetchFamilyMembers(
      page: 1,
      limit: profilePreviewLimit,
      replace: true,
    );
  }

  Future<void> getFamilyMembers({bool forceRefresh = false}) async {
    if (!forceRefresh && _loadedFullFamilyList) return;
    _loadedFullFamilyList = true;
    await _fetchFamilyMembers(
      page: 1,
      limit: familyListPageSize,
      replace: true,
    );
  }

  Future<void> loadMoreFamilyMembers() async {
    if (_isLoadingMore || !hasMoreFamilyMembers) return;
    await _fetchFamilyMembers(
      page: _currentPage + 1,
      limit: familyListPageSize,
      replace: false,
    );
  }

  Future<void> _fetchFamilyMembers({
    required int page,
    required int limit,
    required bool replace,
  }) async {
    final isFirstPage = page == 1;

    if (isFirstPage && replace) {
      familyMembersState = DataState.loading;
      familyMembersError = null;
      _familyMembers.clear();
      _currentPage = 1;
      _totalPages = 1;
      _totalFamilyMembers = 0;
      notifyListeners();
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final result = await FamilyApiService.instance.getFamilyMembers(
        page: page,
        limit: limit,
      );

      result.fold(
        (failure) {
          if (isFirstPage && replace) {
            familyMembersState = DataState.failed;
            familyMembersError = failure.errorMsg;
          }
          Logger.error(
            '[FAMILY PROVIDER]: error getting family members: ${failure.errorMsg}',
          );
        },
        (response) {
          final data = response['data'] as Map<String, dynamic>;
          final members = (data['members'] as List)
              .map((e) => FamilyMember.fromJson(e as Map<String, dynamic>))
              .toList();
          final pagination = data['pagination'] as Map<String, dynamic>;

          if (isFirstPage && replace) {
            _familyMembers
              ..clear()
              ..addAll(members);
            familyMembersState = DataState.success;
            familyMembersError = null;
          } else {
            _familyMembers.addAll(members);
          }

          _currentPage = pagination['page'] as int;
          _totalPages = pagination['totalPages'] as int;
          _totalFamilyMembers = pagination['total'] as int;

          Logger.info(
            '[FAMILY PROVIDER]: family members fetched: ${_familyMembers.length}/$_totalFamilyMembers',
          );
        },
      );
    } catch (e) {
      if (isFirstPage && replace) {
        familyMembersState = DataState.failed;
        familyMembersError = e.toString();
      }
      Logger.error(
        '[FAMILY PROVIDER]: exception getting family members: ${e.toString()}',
      );
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> refreshFamilyMembersAfterChange() async {
    if (_loadedFullFamilyList) {
      await getFamilyMembers(forceRefresh: true);
    } else {
      await getFamilyMembersPreview(forceRefresh: true);
    }
  }

  Future<void> getFamilyRoles({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        familyRolesState == DataState.success &&
        _familyRoles.isNotEmpty) {
      return;
    }

    familyRolesState = DataState.loading;
    familyRolesError = null;
    notifyListeners();

    try {
      final result = await FamilyApiService.instance.getFamilyMembersRoles();
      result.fold(
        (failure) {
          familyRolesState = DataState.failed;
          familyRolesError = failure.errorMsg;
          Logger.error(
            '[FAMILY PROVIDER]: error getting family roles: ${failure.errorMsg}',
          );
        },
        (response) {
          final data = response['data'] as Map<String, dynamic>;
          final roles = (data['roles'] as List)
              .map((e) => FamilyRole.fromJson(e as Map<String, dynamic>))
              .toList();
          _familyRoles = roles;
          familyRolesState = DataState.success;
          familyRolesError = null;
          Logger.info(
            '[FAMILY PROVIDER]: family roles fetched: ${_familyRoles.length}',
          );
        },
      );
    } catch (e) {
      familyRolesState = DataState.failed;
      familyRolesError = e.toString();
      Logger.error(
        '[FAMILY PROVIDER]: exception getting family roles: ${e.toString()}',
      );
    }
    notifyListeners();
  }

  Future<void> getFamilyRolesForEdit({
    required String excludeFamilyMemberId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        editFamilyRolesState == DataState.success &&
        _lastEditExcludeId == excludeFamilyMemberId &&
        _editFamilyRoles.isNotEmpty) {
      return;
    }

    _lastEditExcludeId = excludeFamilyMemberId;
    editFamilyRolesState = DataState.loading;
    editFamilyRolesError = null;
    notifyListeners();

    try {
      final result = await FamilyApiService.instance.getFamilyMembersRoles(
        excludeFamilyMemberId: excludeFamilyMemberId,
      );
      result.fold(
        (failure) {
          editFamilyRolesState = DataState.failed;
          editFamilyRolesError = failure.errorMsg;
          Logger.error(
            '[FAMILY PROVIDER]: error getting edit family roles: ${failure.errorMsg}',
          );
        },
        (response) {
          final data = response['data'] as Map<String, dynamic>;
          _editFamilyRoles = (data['roles'] as List)
              .map((e) => FamilyRole.fromJson(e as Map<String, dynamic>))
              .toList();
          editFamilyRolesState = DataState.success;
          editFamilyRolesError = null;
        },
      );
    } catch (e) {
      editFamilyRolesState = DataState.failed;
      editFamilyRolesError = e.toString();
      Logger.error(
        '[FAMILY PROVIDER]: exception getting edit family roles: ${e.toString()}',
      );
    }
    notifyListeners();
  }

  void resetEditFamilyRoles() {
    _editFamilyRoles = [];
    _lastEditExcludeId = null;
    editFamilyRolesState = DataState.loading;
    editFamilyRolesError = null;
  }

  Future<void> updateFamilyMemberRole({
    required String familyMemberId,
    required String role,
    required VoidCallback onSuccess,
    required void Function(String error) onError,
  }) async {
    try {
      final result = await FamilyApiService.instance.updateFamilyMemberRole(
        familyMemberId: familyMemberId,
        role: role,
      );
      result.fold(
        (failure) {
          onError(failure.errorMsg);
          Logger.error(
            '[FAMILY PROVIDER]: error updating family role: ${failure.errorMsg}',
          );
        },
        (response) {
          final data = response['data'] as Map<String, dynamic>;
          final updated = FamilyMember.fromJson(
            data['member'] as Map<String, dynamic>,
          );
          final index =
              _familyMembers.indexWhere((m) => m.id == familyMemberId);
          if (index >= 0) {
            _familyMembers[index] = updated;
            notifyListeners();
          }
          onSuccess();
        },
      );
    } catch (e) {
      onError(e.toString());
      Logger.error(
        '[FAMILY PROVIDER]: exception updating family role: ${e.toString()}',
      );
    }
  }

  Future<void> removeFamilyMember({
    required String familyMemberId,
    required VoidCallback onSuccess,
    required void Function(String error) onError,
  }) async {
    try {
      final result = await FamilyApiService.instance.removeFamilyMember(
        familyMemberId: familyMemberId,
      );
      result.fold(
        (failure) {
          onError(failure.errorMsg);
          Logger.error(
            '[FAMILY PROVIDER]: error removing family member: ${failure.errorMsg}',
          );
        },
        (_) {
          _familyMembers.removeWhere((m) => m.id == familyMemberId);
          if (_totalFamilyMembers > 0) {
            _totalFamilyMembers -= 1;
          }
          notifyListeners();
          onSuccess();
        },
      );
    } catch (e) {
      onError(e.toString());
      Logger.error(
        '[FAMILY PROVIDER]: exception removing family member: ${e.toString()}',
      );
    }
  }

  bool isAddingFamilyMember = false;

  /// Returns `null` on success, or an error message on failure.
  Future<String?> addFamilyMemberToFamily({
    required FriendUser member,
    required String role,
    required String roleLabel,
  }) async {
    isAddingFamilyMember = true;
    notifyListeners();

    addFamilyMember(
      member: member,
      relationship: roleLabel,
      role: role,
    );

    try {
      final result = await FamilyApiService.instance.addFamilyMember(
        memberUserId: member.id,
        role: role,
      );
      return result.fold(
        (failure) {
          _familyMembers.removeWhere(
            (m) => m.member.id == member.id && m.id.startsWith('family-'),
          );
          if (_totalFamilyMembers > 0) {
            _totalFamilyMembers -= 1;
          }
          notifyListeners();
          Logger.error(
            '[FAMILY PROVIDER]: error adding family member: ${failure.errorMsg}',
          );
          return failure.errorMsg;
        },
        (response) {
          final data = response['data'] as Map<String, dynamic>;
          final created = FamilyMember.fromJson(
            data['member'] as Map<String, dynamic>,
          );
          final index =
              _familyMembers.indexWhere((m) => m.member.id == member.id);
          if (index >= 0) {
            _familyMembers[index] = created;
          } else {
            _familyMembers.insert(0, created);
            _totalFamilyMembers += 1;
          }
          notifyListeners();
          refreshFamilyMembersAfterChange();
          Logger.info('[FAMILY PROVIDER]: family member added via API');
          return null;
        },
      );
    } catch (e) {
      _familyMembers.removeWhere(
        (m) => m.member.id == member.id && m.id.startsWith('family-'),
      );
      if (_totalFamilyMembers > 0) {
        _totalFamilyMembers -= 1;
      }
      notifyListeners();
      Logger.error(
        '[FAMILY PROVIDER]: exception adding family member: ${e.toString()}',
      );
      return e.toString();
    } finally {
      isAddingFamilyMember = false;
      notifyListeners();
    }
  }

  Future<String?> addFamilyMemberFromProfile({
    required FriendProfile profile,
    required FamilyRole role,
  }) {
    return addFamilyMemberToFamily(
      member: FriendUser(
        id: profile.userId,
        displayName: profile.displayName,
        email: profile.email,
        username: profile.username,
        phone: profile.phone,
        avatarUrl: profile.avatarUrl,
      ),
      role: role.value,
      roleLabel: role.label,
    );
  }

  void addFamilyMember({
    required FriendUser member,
    required String relationship,
    String? role,
    String? familyMemberId,
  }) {
    final existingIndex =
        _familyMembers.indexWhere((m) => m.member.id == member.id);
    final resolvedRole = role ?? relationship.toUpperCase();
    if (existingIndex >= 0) {
      _familyMembers[existingIndex] = FamilyMember(
        id: familyMemberId ?? _familyMembers[existingIndex].id,
        role: resolvedRole,
        relationship: relationship,
        member: member,
      );
    } else {
      _familyMembers.insert(
        0,
        FamilyMember(
          id: familyMemberId ?? 'family-${member.id}',
          role: resolvedRole,
          relationship: relationship,
          member: member,
        ),
      );
      _totalFamilyMembers += 1;
    }
    if (familyMembersState != DataState.success) {
      familyMembersState = DataState.success;
    }
    notifyListeners();
  }

  void clear() {
    _familyMembers.clear();
    _familyRoles = [];
    familyMembersState = DataState.loading;
    familyMembersError = null;
    familyRolesState = DataState.loading;
    familyRolesError = null;
    resetEditFamilyRoles();
    _totalFamilyMembers = 0;
    _currentPage = 1;
    _totalPages = 1;
    _isLoadingMore = false;
    _loadedFullFamilyList = false;
    isAddingFamilyMember = false;
    notifyListeners();
  }
}
