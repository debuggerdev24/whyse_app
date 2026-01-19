import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  late SharedPreferences prefs;

  /// MUST be called before using SharedPrefs
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// ---------------- Token ----------------
  String? get authToken => prefs.getString('token');
  String? get refreshToken => prefs.getString('refresh_token');

  Future<void> saveAuthToken(String token) async {
    await prefs.setString("token", token);
  }

  Future<void> removeAuthToken() async {
    await prefs.remove("token");
  }

  Future<void> removeRefreshToken() async {
    await prefs.remove("refresh_token");
  }

  Future<void> saveRefreshToken(String token) async {
    await prefs.setString("refresh_token", token);
  }

  /// ---------------- Onboarding ----------------
  static const _emailKey = 'onboarding_email';
  static const _onboardingIdKey = 'onboarding_id';

  String? get onboardingEmail => prefs.getString(_emailKey);
  String? get onboardingId => prefs.getString(_onboardingIdKey);

  Future<void> setOnboardingEmail(String email) async {
    await prefs.setString(_emailKey, email);
  }

  Future<void> setOnboardingId(String id) async {
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
