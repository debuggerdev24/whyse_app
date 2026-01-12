import 'package:flutter/material.dart';
import 'package:redstreakapp/services/auth/auth_api_service.dart';

import '../../models/home/story_models/story_model.dart';

class HomeProvider extends ChangeNotifier {

  bool _isLoading = false;
  List<Story> _stories = [];


  bool get isLoading => _isLoading;
  List<Story> get stories => _stories;


  Future<void> getAllStories() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await AuthApiServices().getAllStories();
      if (response != null && response['success'] == true) {
        final data = response['data'] as List;
        _stories = data.map((e) => Story.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching stories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


}
