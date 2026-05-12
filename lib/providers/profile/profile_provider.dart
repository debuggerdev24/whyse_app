import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/group/group_response_model.dart';
import 'package:redstreakapp/models/profile/profile_data_model.dart';
import 'package:redstreakapp/services/profile/group_api_service.dart';
import 'package:redstreakapp/services/profile/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;
  final GroupApiService _groupApiService;

  ProfileProvider(this._profileService, this._groupApiService);

  DataState getGroupListState = DataState.loading;
  DataState getProfileState = DataState.loading;
  String? getGroupsListError;
  String? getProfileError;

  List<GroupResponse> _myGroupsList = [];
  List<GroupResponse> get myGroupsList => _myGroupsList;
  ProfileDataModel? profileData;

  Future<void> getGroupsList() async {
    try {
      getGroupListState = DataState.loading;
      _myGroupsList = [];
      notifyListeners();
      final result = await _groupApiService.getMyGroups();
      result.fold(
        (l) {
          getGroupListState = DataState.failed;
          getGroupsListError = l.apiErrorMsg ?? l.errorMsg;
          Logger.error(
            '[PROFILE PROVIDER]: error getting groups list: ${l.toString()}',
          );
        },
        (r) {
          _myGroupsList = (r['data'] as List)
              .take(5)
              .map((e) => GroupResponse.fromJson(e))
              .toList();
          getGroupListState = DataState.success;
        },
      );
      notifyListeners();
    } catch (e) {
      getGroupListState = DataState.failed;
      getGroupsListError = e.toString();
      Logger.error(
        '[PROFILE PROVIDER]: exception in getting groups list: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  Future<void> getProfile() async {
    try {
      getProfileState = DataState.loading;
      getProfileError = null;
      notifyListeners();

      final result = await _profileService.getProfile();
      result.fold(
        (l) {
          getProfileState = DataState.failed;
          getProfileError = l.apiErrorMsg ?? l.errorMsg;
          Logger.error(
            '[PROFILE PROVIDER]: error getting profile: ${l.toString()}',
          );
        },
        (r) {
          getProfileState = DataState.success;
          profileData = ProfileDataModel.fromJson(r['data']);
          getProfileError = null;
        },
      );
      notifyListeners();
    } catch (e) {
      getProfileState = DataState.failed;
      getProfileError = e.toString();
      Logger.error(
        '[PROFILE PROVIDER]: exception in getting profile: ${e.toString()}',
      );
      notifyListeners();
    }
  }

  void applyProfileAfterUpdate(Map<String, dynamic> data) {
    if (profileData == null) return;
    profileData = ProfileDataModel.mergeFromUpdate(data, profileData!);
    notifyListeners();
  }

  void clearSessionData() {
    getGroupListState = DataState.loading;
    getProfileState = DataState.loading;
    getGroupsListError = null;
    getProfileError = null;
    _myGroupsList = [];
    profileData = null;
    notifyListeners();
  }
}
