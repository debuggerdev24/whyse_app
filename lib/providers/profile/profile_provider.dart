import 'package:redstreakapp/core/enums/data_status.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/models/group/group_response_model.dart';
import 'package:redstreakapp/services/group/group_api_service.dart';

class ProfileProvider extends ChangeNotifier {
  DataState getGroupListState = DataState.loading;
  String? getGroupsListError;

  List<GroupResponse> _myGroupsList = [];
  List<GroupResponse> get myGroupsList => _myGroupsList;

  Future<void> getGroupsList({required}) async {
    try {
      getGroupListState = DataState.loading;
      _myGroupsList = [];
      notifyListeners();
      final result = await GroupApiService.instance.getMyGroups();
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
}
