import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/models/journal_entry_model.dart';
import 'package:love_connect/core/models/idea_model.dart';
import 'package:love_connect/core/models/user_profile_model.dart';
import 'package:love_connect/core/models/notification_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // CRITICAL: Store current logged-in user ID to track user-specific data
  static const String _currentUserIdKey = 'current_logged_in_user_id';
  
  static const String _plansKeyPrefix = 'plans_user_';
  static const String _journalEntriesKey = 'journal_entries';
  static const String _userProfileKey = 'user_profile';
  static const String _settingsKey = 'settings';
  static const String _notificationsKeyPrefix = 'notifications_user_';

  // Get storage key for user-specific plans
  String _getPlansKey(String? userId) {
    if (userId == null || userId.isEmpty) {
      // For unauthenticated users, use a default key (will be cleared on login)
      return '${_plansKeyPrefix}anonymous';
    }
    return '$_plansKeyPrefix$userId';
  }

  // Get storage key for user-specific notifications
  String _getNotificationsKey(String? userId) {
    if (userId == null || userId.isEmpty) {
      return '${_notificationsKeyPrefix}anonymous';
    }
    return '$_notificationsKeyPrefix$userId';
  }

  // Store current user ID (called on login)
  Future<void> setCurrentUserId(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId != null && userId.isNotEmpty) {
      await prefs.setString(_currentUserIdKey, userId);
    } else {
      await prefs.remove(_currentUserIdKey);
    }
  }

  // Get current user ID from storage
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserIdKey);
  }

  // Clear all data for a specific user (called on logout)
  Future<void> clearUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getPlansKey(userId));
    await prefs.remove(_getNotificationsKey(userId));
  }

  // Clear all anonymous/unauthenticated data
  Future<void> clearAnonymousData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getPlansKey(null));
    await prefs.remove(_getNotificationsKey(null));
  }

  // Plans - NOW USER-SPECIFIC
  Future<List<PlanModel>> getPlans({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Use provided userId or get from storage
      final effectiveUserId = userId ?? await getCurrentUserId();
      final plansKey = _getPlansKey(effectiveUserId);
      
      final String? plansJson = prefs.getString(plansKey);
      if (plansJson == null) return [];
      
      final List<dynamic> plansList = json.decode(plansJson);
      return plansList.map((json) => PlanModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> savePlan(PlanModel plan, {String? userId}) async {
    // Use provided userId or get from storage
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = userId ?? await getCurrentUserId();
    final plansKey = _getPlansKey(effectiveUserId);
    
    final plans = await getPlans(userId: effectiveUserId);
    final existingIndex = plans.indexWhere((p) => p.id == plan.id);
    
    if (existingIndex >= 0) {
      plans[existingIndex] = plan;
    } else {
      plans.add(plan);
    }
    
    await _savePlans(plans, plansKey);
  }

  Future<void> deletePlan(String planId, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = userId ?? await getCurrentUserId();
    final plansKey = _getPlansKey(effectiveUserId);
    
    final plans = await getPlans(userId: effectiveUserId);
    plans.removeWhere((p) => p.id == planId);
    await _savePlans(plans, plansKey);
  }

  Future<void> _savePlans(List<PlanModel> plans, String plansKey) async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = json.encode(plans.map((p) => p.toJson()).toList());
    await prefs.setString(plansKey, plansJson);
  }

  // Journal Entries
  Future<List<JournalEntryModel>> getJournalEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString(_journalEntriesKey);
      if (entriesJson == null) return [];
      
      final List<dynamic> entriesList = json.decode(entriesJson);
      return entriesList.map((json) => JournalEntryModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveJournalEntry(JournalEntryModel entry) async {
    final entries = await getJournalEntries();
    final existingIndex = entries.indexWhere((e) => e.id == entry.id);
    
    if (existingIndex >= 0) {
      entries[existingIndex] = entry;
    } else {
      entries.add(entry);
    }
    
    await _saveJournalEntries(entries);
  }

  Future<void> deleteJournalEntry(String entryId) async {
    final entries = await getJournalEntries();
    entries.removeWhere((e) => e.id == entryId);
    await _saveJournalEntries(entries);
  }

  Future<void> _saveJournalEntries(List<JournalEntryModel> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = json.encode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_journalEntriesKey, entriesJson);
  }

  // User Profile
  Future<UserProfileModel> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? profileJson = prefs.getString(_userProfileKey);
      if (profileJson == null) {
        return UserProfileModel(
          name: 'User',
          about: 'Keeping the love story alive.',
        );
      }
      
      final Map<String, dynamic> profileMap = json.decode(profileJson);
      return UserProfileModel.fromJson(profileMap);
    } catch (e) {
      return UserProfileModel(
        name: 'User',
        about: 'Keeping the love story alive.',
      );
    }
  }

  Future<void> saveUserProfile(UserProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = json.encode(profile.toJson());
    await prefs.setString(_userProfileKey, profileJson);
  }

  // Settings
  Future<Map<String, bool>> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'notifications': prefs.getBool('notifications') ?? true,
        'planReminder': prefs.getBool('planReminder') ?? true,
        'emailNotifications': prefs.getBool('emailNotifications') ?? true,
        'privateJournal': prefs.getBool('privateJournal') ?? true,
        'hideLocation': prefs.getBool('hideLocation') ?? true,
        'romanticTheme': prefs.getBool('romanticTheme') ?? true,
        'appLock': prefs.getBool('appLock') ?? false,
      };
    } catch (e) {
      return {
        'notifications': true,
        'planReminder': true,
        'emailNotifications': true,
        'privateJournal': true,
        'hideLocation': true,
        'romanticTheme': true,
        'appLock': false,
      };
    }
  }

  Future<void> saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Notifications - NOW USER-SPECIFIC
  Future<List<NotificationModel>> getNotifications({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Use provided userId or get from storage
      final effectiveUserId = userId ?? await getCurrentUserId();
      final notificationsKey = _getNotificationsKey(effectiveUserId);
      
      final String? notificationsJson = prefs.getString(notificationsKey);
      if (notificationsJson == null) return [];
      
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      return notificationsList.map((json) => NotificationModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotification(NotificationModel notification, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = userId ?? await getCurrentUserId();
    final notificationsKey = _getNotificationsKey(effectiveUserId);
    
    final notifications = await getNotifications(userId: effectiveUserId);
    final existingIndex = notifications.indexWhere((n) => n.id == notification.id);
    
    if (existingIndex >= 0) {
      notifications[existingIndex] = notification;
    } else {
      notifications.add(notification);
    }
    
    await _saveNotifications(notifications, notificationsKey);
  }

  Future<void> markNotificationAsRead(String notificationId, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = userId ?? await getCurrentUserId();
    final notificationsKey = _getNotificationsKey(effectiveUserId);
    
    final notifications = await getNotifications(userId: effectiveUserId);
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await _saveNotifications(notifications, notificationsKey);
    }
  }

  Future<void> deleteNotification(String notificationId, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = userId ?? await getCurrentUserId();
    final notificationsKey = _getNotificationsKey(effectiveUserId);
    
    final notifications = await getNotifications(userId: effectiveUserId);
    notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications(notifications, notificationsKey);
  }

  Future<void> markAllNotificationsAsRead({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = userId ?? await getCurrentUserId();
    final notificationsKey = _getNotificationsKey(effectiveUserId);
    
    final notifications = await getNotifications(userId: effectiveUserId);
    final updatedNotifications = notifications.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotifications(updatedNotifications, notificationsKey);
  }

  Future<void> _saveNotifications(List<NotificationModel> notifications, String notificationsKey) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = json.encode(notifications.map((n) => n.toJson()).toList());
    await prefs.setString(notificationsKey, notificationsJson);
  }

  // Clear all data for current user
  Future<void> clearAllData({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveUserId = userId ?? await getCurrentUserId();
    
    // Clear user-specific data
    if (effectiveUserId != null) {
      await clearUserData(effectiveUserId);
    }
    
    // Clear anonymous data
    await clearAnonymousData();
    
    // Clear general data
    await prefs.remove(_journalEntriesKey);
    await prefs.remove(_userProfileKey);
    await prefs.remove(_settingsKey);
    await prefs.remove('notifications');
    await prefs.remove('planReminder');
    await prefs.remove('emailNotifications');
    await prefs.remove('privateJournal');
    await prefs.remove('hideLocation');
    await prefs.remove('romanticTheme');
    await prefs.remove('appLock');
    await prefs.remove(_currentUserIdKey);
  }

  // Clear all data from all users (for complete reset)
  Future<void> clearAllUsersData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    // Remove all user-specific plans
    for (final key in keys) {
      if (key.startsWith(_plansKeyPrefix) || key.startsWith(_notificationsKeyPrefix)) {
        await prefs.remove(key);
      }
    }
    
    // Clear general data
    await prefs.remove(_journalEntriesKey);
    await prefs.remove(_userProfileKey);
    await prefs.remove(_settingsKey);
    await prefs.remove('notifications');
    await prefs.remove('planReminder');
    await prefs.remove('emailNotifications');
    await prefs.remove('privateJournal');
    await prefs.remove('hideLocation');
    await prefs.remove('romanticTheme');
    await prefs.remove('appLock');
    await prefs.remove(_currentUserIdKey);
  }

  // Get default ideas
  List<IdeaModel> getDefaultIdeas() {
    return [
      IdeaModel(
        id: '1',
        title: 'Sunrise Walk',
        category: 'Walk',
        location: 'Beachfront',
      ),
      IdeaModel(
        id: '2',
        title: 'Picnic',
        category: 'Dinner',
        location: 'Riverside Park',
      ),
      IdeaModel(
        id: '3',
        title: 'Movie Marathon',
        category: 'Movie',
        location: 'Home',
      ),
      IdeaModel(
        id: '4',
        title: 'Stargazing',
        category: 'Trip',
        location: 'City Rooftop',
      ),
      IdeaModel(
        id: '5',
        title: 'Surprise Dessert',
        category: 'Surprise',
        location: 'Favorite Bakery',
      ),
    ];
  }
}

