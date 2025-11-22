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
              child: Obx(
                () {
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
                      return _buildNotificationCard(notification, metrics, context);
                    },
                  );
                },
              ),
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
        margin: EdgeInsets.only(bottom: metrics.sectionSpacing * 0.5),
        padding: EdgeInsets.all(metrics.cardPadding),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.white : AppColors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: isUnread
              ? Border.all(color: AppColors.primaryRed.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread indicator
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.only(
                  top: 6,
                  right: metrics.cardPadding * 0.5,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryRed,
                ),
              ),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: metrics.sectionSpacing * 0.3),
                  Text(
                    notification.message,
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(12),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textLightPink,
                    ),
                  ),
                  SizedBox(height: metrics.sectionSpacing * 0.3),
                  Text(
                    dateFormat.format(notification.date),
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(10),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textLightPink,
                    ),
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: AppColors.primaryRed,
                size: 20,
              ),
              onPressed: () => viewModel.deleteNotification(notification.id),
            ),
          ],
        ),
      ),
    );
  }
}

