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

  static const String _plansKey = 'plans';
  static const String _journalEntriesKey = 'journal_entries';
  static const String _userProfileKey = 'user_profile';
  static const String _settingsKey = 'settings';
  static const String _notificationsKey = 'notifications';

  // Plans
  Future<List<PlanModel>> getPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? plansJson = prefs.getString(_plansKey);
      if (plansJson == null) return [];
      
      final List<dynamic> plansList = json.decode(plansJson);
      return plansList.map((json) => PlanModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> savePlan(PlanModel plan) async {
    final plans = await getPlans();
    final existingIndex = plans.indexWhere((p) => p.id == plan.id);
    
    if (existingIndex >= 0) {
      plans[existingIndex] = plan;
    } else {
      plans.add(plan);
    }
    
    await _savePlans(plans);
  }

  Future<void> deletePlan(String planId) async {
    final plans = await getPlans();
    plans.removeWhere((p) => p.id == planId);
    await _savePlans(plans);
  }

  Future<void> _savePlans(List<PlanModel> plans) async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = json.encode(plans.map((p) => p.toJson()).toList());
    await prefs.setString(_plansKey, plansJson);
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

  // Notifications
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_notificationsKey);
      if (notificationsJson == null) return [];
      
      final List<dynamic> notificationsList = json.decode(notificationsJson);
      return notificationsList.map((json) => NotificationModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotification(NotificationModel notification) async {
    final notifications = await getNotifications();
    final existingIndex = notifications.indexWhere((n) => n.id == notification.id);
    
    if (existingIndex >= 0) {
      notifications[existingIndex] = notification;
    } else {
      notifications.add(notification);
    }
    
    await _saveNotifications(notifications);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await _saveNotifications(notifications);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final notifications = await getNotifications();
    notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications(notifications);
  }

  Future<void> markAllNotificationsAsRead() async {
    final notifications = await getNotifications();
    final updatedNotifications = notifications.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotifications(updatedNotifications);
  }

  Future<void> _saveNotifications(List<NotificationModel> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = json.encode(notifications.map((n) => n.toJson()).toList());
    await prefs.setString(_notificationsKey, notificationsJson);
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_plansKey);
    await prefs.remove(_journalEntriesKey);
    await prefs.remove(_userProfileKey);
    await prefs.remove(_settingsKey);
    await prefs.remove(_notificationsKey);
    await prefs.remove('notifications');
    await prefs.remove('planReminder');
    await prefs.remove('emailNotifications');
    await prefs.remove('privateJournal');
    await prefs.remove('hideLocation');
    await prefs.remove('romanticTheme');
    await prefs.remove('appLock');
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

