import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage app preferences and first-time status
class AppPreferencesService {
  static final AppPreferencesService _instance = AppPreferencesService._internal();
  factory AppPreferencesService() => _instance;
  AppPreferencesService._internal();

  static const String _keyIsFirstTime = 'is_first_time';
  static const String _keyHasSeenGetStarted = 'has_seen_get_started';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyRememberedEmail = 'remembered_email';

  /// Check if this is the first time the app is being run
  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstTime) ?? true;
  }

  /// Mark that the app has been run (not first time anymore)
  Future<void> setNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstTime, false);
  }

  /// Check if user has seen the get started screen
  Future<bool> hasSeenGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenGetStarted) ?? false;
  }

  /// Mark that user has seen the get started screen
  Future<void> setHasSeenGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenGetStarted, true);
  }

  /// Save remembered email for "Remember Me" functionality
  Future<void> saveRememberedEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, true);
    await prefs.setString(_keyRememberedEmail, email);
  }

  /// Get remembered email if "Remember Me" was checked
  Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    if (rememberMe) {
      return prefs.getString(_keyRememberedEmail);
    }
    return null;
  }

  /// Check if "Remember Me" is enabled
  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// Clear remembered email (when user unchecks "Remember Me" or logs out)
  Future<void> clearRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberMe);
    await prefs.remove(_keyRememberedEmail);
  }

  /// Reset all preferences (useful for testing or logout)
  Future<void> resetPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsFirstTime);
    await prefs.remove(_keyHasSeenGetStarted);
    await prefs.remove(_keyRememberMe);
    await prefs.remove(_keyRememberedEmail);
  }

  /// Reset only get started status (keep first time status)
  Future<void> resetGetStartedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasSeenGetStarted);
  }
}

