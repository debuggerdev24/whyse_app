// import 'package:flutter/material.dart';
// import 'package:redstreakapp/core/helper/log_helper.dart';
// import 'package:redstreakapp/services/auth/auth_api_service.dart';
// import 'package:redstreakapp/services/home/home_api_service.dart';
//
// import '../../models/home/story_models/story_model.dart';
//
// class HomeProvider extends ChangeNotifier {
//   bool isGetStoryLoading = false;
//   List<Story> _stories = [];
//
//   List<Story> get stories => _stories;
//
//   Future<void> getAllStories() async {
//     isGetStoryLoading = true;
//     notifyListeners();
//     //
//     final response = await HomeApiService.instance.getAllStories();
//
//     response.fold(
//       (l) {
//         Logger.error(l.errorMsg);
//       },
//       (r) {
//         final data = r['data'] as List;
//         _stories = data.map((e) => Story.fromJson(e)).toList();
//         isGetStoryLoading = false;
//         notifyListeners();
//       },
//     );
//   }
// }
