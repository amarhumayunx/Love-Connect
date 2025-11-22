import 'package:get/get.dart';
import 'package:love_connect/core/models/notification_model.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/notifications/model/notifications_model.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';

class NotificationsViewModel extends GetxController {
  final LocalStorageService _storageService = LocalStorageService();
  final NotificationsModel model = const NotificationsModel();
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final loadedNotifications = await _storageService.getNotifications();
      notifications.value = loadedNotifications..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to load notifications',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _storageService.markNotificationAsRead(notificationId);
      await loadNotifications();
      _updateHomeNotificationCount();
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to mark notification as read',
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _storageService.markAllNotificationsAsRead();
      await loadNotifications();
      _updateHomeNotificationCount();
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to mark all notifications as read',
      );
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _storageService.deleteNotification(notificationId);
      await loadNotifications();
      _updateHomeNotificationCount();
      SnackbarHelper.showSafe(
        title: 'Notification Deleted',
        message: 'Notification has been deleted',
      );
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to delete notification',
      );
    }
  }

  void _updateHomeNotificationCount() {
    try {
      final homeViewModel = Get.find<HomeViewModel>();
      homeViewModel.loadNotifications();
    } catch (e) {
      // HomeViewModel not found, ignore
    }
  }

  int get unreadCount {
    return notifications.where((n) => !n.isRead).length;
  }
}

