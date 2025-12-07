import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/notification_model.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';
import 'package:love_connect/screens/notifications/view_model/notifications_view_model.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late final NotificationsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(NotificationsViewModel());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload notifications when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        viewModel.loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    Get.delete<NotificationsViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = HomeLayoutMetrics.fromContext(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.headerHorizontalPadding,
                vertical: metrics.sectionSpacing * 0.5,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.primaryDark,
                      size: metrics.iconSize,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Text(
                      viewModel.model.title,
                      style: GoogleFonts.inter(
                        fontSize: context.responsiveFont(20),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  Obx(
                    () => viewModel.unreadCount > 0
                        ? TextButton(
                            onPressed: viewModel.markAllAsRead,
                            child: Text(
                              'Mark all read',
                              style: GoogleFonts.inter(
                                fontSize: context.responsiveFont(12),
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryRed,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Obx(() {
                if (viewModel.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  );
                }

                if (viewModel.notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 48,
                              color: AppColors.textLightPink,
                            ),
                            SizedBox(height: metrics.sectionSpacing),
                            Text(
                              'No notifications yet',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: context.responsiveFont(14),
                                fontWeight: FontWeight.w500,
                                color: AppColors.textLightPink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: metrics.cardPadding,
                    vertical: metrics.sectionSpacing * 0.5,
                  ),
                  itemCount: viewModel.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = viewModel.notifications[index];
                    return _buildNotificationCard(
                      notification,
                      metrics,
                      context,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    HomeLayoutMetrics metrics,
    BuildContext context,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: () {
        if (isUnread) {
          viewModel.markAsRead(notification.id);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: metrics.sectionSpacing * 0.6),
        padding: EdgeInsets.all(metrics.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textLightPink.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isUnread
              ? Border.all(
                  color: AppColors.primaryRed.withOpacity(0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and unread indicator
            Container(
              margin: EdgeInsets.only(right: metrics.cardPadding * 0.8),
              child: Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isUnread
                          ? AppColors.primaryRed.withOpacity(0.1)
                          : AppColors.textLightPink.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: isUnread
                          ? AppColors.primaryRed
                          : AppColors.textLightPink,
                      size: 20,
                    ),
                  ),
                  if (isUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryRed,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.inter(
                            fontSize: context.responsiveFont(15),
                            fontWeight: isUnread
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: AppColors.primaryDark,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: metrics.sectionSpacing * 0.25),
                  Text(
                    notification.message,
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(13),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textLightPink,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: metrics.sectionSpacing * 0.3),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.textLightPink,
                      ),
                      SizedBox(width: 4),
                      Text(
                        dateFormat.format(notification.date),
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(11),
                          fontWeight: FontWeight.w400,
                          color: AppColors.textLightPink,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: AppColors.primaryRed.withOpacity(0.7),
                size: 22,
              ),
              onPressed: () => viewModel.deleteNotification(notification.id),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
