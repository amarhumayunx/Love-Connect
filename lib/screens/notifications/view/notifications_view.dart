import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/notification_model.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/core/widgets/banner_ad_widget.dart';
import 'package:love_connect/core/services/admob_service.dart';
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
                horizontal: context.widthPct(5),
                vertical: context.responsiveSpacing(16),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(context.responsiveSpacing(8)),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryRed.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primaryDark,
                        size: context.responsiveImage(20),
                      ),
                    ),
                  ),
                  SizedBox(width: context.responsiveSpacing(16)),
                  Expanded(
                    child: Text(
                      viewModel.model.title,
                      style: GoogleFonts.inter(
                        fontSize: context.responsiveFont(24),
                        fontWeight: FontWeight.w700,
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
                  return Center(
                    child: LoadingAnimationWidget.horizontalRotatingDots(
                      color: AppColors.primaryRed,
                      size: 50,
                    ),
                  );
                }

                if (viewModel.notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/new_svg/notification_svg.svg',
                          width: context.responsiveImage(100),
                          height: context.responsiveImage(100),
                          colorFilter: ColorFilter.mode(
                            AppColors.textLightPink.withOpacity(0.5),
                            BlendMode.srcIn,
                          ),
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
            
            // Banner Ad at the bottom
            SafeArea(
              top: false,
              child: BannerAdWidget(
                adUnitId: AdMobService.instance.notificationBannerAdUnitId,
                useAnchoredAdaptive: true,
                margin: EdgeInsets.symmetric(
                  vertical: context.responsiveSpacing(8),
                ),
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
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svg/new_svg/notification_svg.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          isUnread
                              ? AppColors.primaryRed
                              : AppColors.textLightPink,
                          BlendMode.srcIn,
                        ),
                      ),
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
            GestureDetector(
              onTap: () => viewModel.deleteNotification(notification.id),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: SvgPicture.asset(
                  'assets/svg/new_svg/delete.svg',
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    AppColors.primaryRed.withOpacity(0.7),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}