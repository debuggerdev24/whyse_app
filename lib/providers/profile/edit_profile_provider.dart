import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redstreakapp/core/constants/app_constants.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/models/profile/profile_data_model.dart';
import 'package:redstreakapp/services/profile/profile_service.dart';

class EditProfileProvider extends ChangeNotifier {
  EditProfileProvider(this._profileService);

  final ProfileService _profileService;

  String firstName = '';
  String lastName = '';
  String username = '';
  String? avatarUrl;
  String email = '';
  String phone = '';
  bool phoneVerified = false;
  String? country;
  String? preferredLanguage;
  bool isPrivate = false;
  String socialInstagram = '';
  String socialX = '';
  String socialGoogle = '';
  List<String> interests = [];

  /// Picked image; uploaded only when user taps **Update Profile**.
  XFile? pendingAvatarFile;

  String? _avatarRelativeFromLastUpload;

  static const _kSelectCountry = 'Select Country';
  static const _kSelectLanguage = 'Select Language';

  void setInitialValues({
    required String firstName,
    required String lastName,
    required String username,
    required String? avatarUrl,
    required String email,
    required String phone,
    required bool phoneVerified,
    required String country,
    required String preferredLanguage,
    required bool isPrivate,
    required SocialAccounts socialAccounts,
    required List<String> interests,
  }) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.username = username;
    this.avatarUrl = avatarUrl;
    this.email = email;
    this.phone = phone;
    this.phoneVerified = phoneVerified;
    this.isPrivate = isPrivate;
    this.interests = List<String>.from(interests);
    socialInstagram = socialAccounts.instagram?.trim() ?? '';
    socialX = socialAccounts.x?.trim() ?? '';
    socialGoogle = socialAccounts.google?.trim() ?? '';
    pendingAvatarFile = null;
    _avatarRelativeFromLastUpload = null;

    final c = country.trim();
    if (c.isEmpty) {
      this.country = null;
    } else if (AppConstants.countries.contains(c)) {
      this.country = c;
    } else {
      final normalized = ProfileDataModel.countryFromApi(c);
      this.country = AppConstants.countries.contains(normalized)
          ? normalized
          : null;
    }

    final lang = preferredLanguage.trim();
    this.preferredLanguage = AppConstants.preferredLanguages.contains(lang)
        ? lang
        : null;
  }

  void setPendingAvatar(XFile? file) {
    pendingAvatarFile = file;
    notifyListeners();
  }

  void selectCountry(String? value) {
    if (value == null || value == _kSelectCountry) {
      country = null;
    } else {
      country = value;
    }
    notifyListeners();
  }

  void selectLanguage(String? value) {
    if (value == null || value == _kSelectLanguage) {
      preferredLanguage = null;
    } else {
      preferredLanguage = value;
    }
    notifyListeners();
  }

  void setIsPrivate(bool value) {
    isPrivate = value;
    notifyListeners();
  }

  void setSocialInstagram(String value) {
    socialInstagram = value.trim();
    notifyListeners();
  }

  void setSocialX(String value) {
    socialX = value.trim();
    notifyListeners();
  }

  void setSocialGoogle(String value) {
    socialGoogle = value.trim();
    notifyListeners();
  }

  void setInterests(List<String> value) {
    interests = List<String>.from(value);
    notifyListeners();
  }

  String countryDropdownValue() => country ?? _kSelectCountry;

  String languageDropdownValue() =>
      preferredLanguage ?? _kSelectLanguage;

  static List<String> countryMenuItems() => [
        _kSelectCountry,
        ...AppConstants.countries,
      ];

  static List<String> languageMenuItems() => [
        _kSelectLanguage,
        ...AppConstants.preferredLanguages,
      ];

  Future<Either<ApiException, Map<String, dynamic>>> submitUpdate() async {
    final countryName = (country == null || country == _kSelectCountry)
        ? ''
        : country!.trim();
    final language = (preferredLanguage == null ||
            preferredLanguage == _kSelectLanguage)
        ? ''
        : preferredLanguage!.trim();

    final body = <String, dynamic>{
      'username': username.trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'country': countryName,
      'preferredLanguage': language,
      'isPrivate': isPrivate,
      'interests': interests,
      'socialAccounts': {
        'instagram': socialInstagram,
        'x': socialX,
        'google': socialGoogle,
      },
    };

    _avatarRelativeFromLastUpload = null;

    if (pendingAvatarFile != null) {
      final path = pendingAvatarFile!.path;
      final uploadResult = await _profileService.uploadAvatar(path);
      switch (uploadResult) {
        case Left(:final value):
          return Left(value);
        case Right(:final value):
          final data = value['data'];
          if (data is Map<String, dynamic>) {
            final rel = data['avatarUrl']?.toString();
            if (rel != null && rel.isNotEmpty) {
              _avatarRelativeFromLastUpload = rel;
              avatarUrl = rel;
            }
          }
      }
      pendingAvatarFile = null;
      notifyListeners();
    }

    final patchResult = await _profileService.updateProfile(body);
    return patchResult.fold((l) => Left(l), (raw) {
      if (_avatarRelativeFromLastUpload != null) {
        final out = Map<String, dynamic>.from(raw as Map);
        final inner = out['data'];
        if (inner is Map<String, dynamic>) {
          out['data'] = {
            ...inner,
            'avatarUrl': _avatarRelativeFromLastUpload,
          };
        } else {
          out['data'] = {'avatarUrl': _avatarRelativeFromLastUpload};
        }
        _avatarRelativeFromLastUpload = null;
        return Right(out);
      }
      return Right(raw);
    });
  }
}
