import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static const String _tokenKey = "token",
      _refreshTokenKey = "refresh_token",
      _consentReqStatusKey = "consent_request_status";

  late SharedPreferences prefs;

  /// MUST be called before using SharedPrefs
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// ---------------- Token ----------------
  String? get getAuthToken => prefs.getString(_tokenKey);
  String? get getRefreshToken => prefs.getString(_refreshTokenKey);
  bool get getConsentRequestStatus =>
      prefs.getBool(_consentReqStatusKey) ?? false;

  Future<void> removeAuthToken() async {
    await prefs.remove(_tokenKey);
  }

  Future<void> removeRefreshToken() async {
    await prefs.remove(_refreshTokenKey);
  }

  Future<void> saveAuthToken(String token) async {
    await prefs.setString(token, token);
  }

  Future<void> saveRefreshToken(String token) async {
    await prefs.setString(_refreshTokenKey, token);
  }

  Future<void> saveParentConsentStatus({required bool status}) async {
    await prefs.setBool(_consentReqStatusKey, status);
  }

  /// ---------------- Onboarding ----------------
  static const _emailKey = 'onboarding_email';
  static const _onboardingIdKey = 'onboarding_id';

  String? get onboardingEmail => prefs.getString(_emailKey);
  String? get onboardingId => prefs.getString(_onboardingIdKey);

  Future<void> setOnboardingEmail(String email) async {
    await prefs.setString(_emailKey, email);
  }

  Future<void> saveOnboardingId(String id) async {
    await prefs.setString(_onboardingIdKey, id);
  }

  static const _ageCompletedKey = 'age_completed';
  bool get isAgeCompleted => prefs.getBool(_ageCompletedKey) ?? false;
  Future<void> setAgeCompleted(bool val) async {
    await prefs.setBool(_ageCompletedKey, val);
  }

  Future<void> clearOnboardingSession() async {
    await prefs.remove(_emailKey);
    await prefs.remove(_onboardingIdKey);
    await prefs.remove(_ageCompletedKey);
  }

  Future<void> clear() async {
    await prefs.clear();
  }
}
