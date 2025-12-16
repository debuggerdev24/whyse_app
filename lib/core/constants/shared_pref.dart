import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs._();
  static final SharedPrefs instance = SharedPrefs._();

  late SharedPreferences prefs;

  /// MUST be called before using SharedPrefs
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// ---------------- Token ----------------
  String? get token => prefs.getString('token');
  String? get refreshToken => prefs.getString('refresh_token');

  Future<void> setToken(String token) async {
    await prefs.setString('token', token);
  }

  Future<void> setRefreshToken(String token) async {
    await prefs.setString('refresh_token', token);
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

  Future<void> clear() async {
    await prefs.clear();
  }
}
