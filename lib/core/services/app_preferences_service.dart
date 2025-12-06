import 'package:shared_preferences/shared_preferences.dart';


class AppPreferencesService {
  static final AppPreferencesService _instance = AppPreferencesService._internal();
  factory AppPreferencesService() => _instance;
  AppPreferencesService._internal();

  static const String _keyIsFirstTime = 'is_first_time';
  static const String _keyHasSeenGetStarted = 'has_seen_get_started';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyRememberedEmail = 'remembered_email';

  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstTime) ?? true;
  }

  Future<void> setNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstTime, false);
  }

  Future<bool> hasSeenGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenGetStarted) ?? false;
  }

  Future<void> setHasSeenGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenGetStarted, true);
  }


  Future<void> saveRememberedEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, true);
    await prefs.setString(_keyRememberedEmail, email);
  }


  Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    if (rememberMe) {
      return prefs.getString(_keyRememberedEmail);
    }
    return null;
  }


  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }


  Future<void> clearRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberMe);
    await prefs.remove(_keyRememberedEmail);
  }


  Future<void> resetPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsFirstTime);
    await prefs.remove(_keyHasSeenGetStarted);
    await prefs.remove(_keyRememberMe);
    await prefs.remove(_keyRememberedEmail);
  }


  Future<void> resetGetStartedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasSeenGetStarted);
  }
}

