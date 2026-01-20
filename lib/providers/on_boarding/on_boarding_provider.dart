import 'package:flutter/material.dart';

class OnBoardingProvider extends ChangeNotifier {
  String? selectedCountry;
  String? selectedLanguage;

  void setCountry(String? value) {
    selectedCountry = value;
    notifyListeners();
  }

  void setLanguage(String? value) {
    selectedLanguage = value;
    notifyListeners();
  }

  void clearSelections() {
    selectedCountry = null;
    selectedLanguage = null;
    notifyListeners();
  }
}
