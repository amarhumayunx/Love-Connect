import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String userTagline;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;
  final VoidCallback? onProfileTap;
  final int notificationCount;
  final HomeLayoutMetrics metrics;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.userTagline,
    required this.onSearchTap,
    required this.onNotificationTap,
    this.onProfileTap,
    required this.notificationCount,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: metrics.headerHorizontalPadding,
        right: metrics.headerHorizontalPadding,
        top: metrics.headerTopPadding,
        bottom: metrics.headerBottomPadding,
      ),
      child: Row(
        children: [
          // Profile Picture
          GestureDetector(
            onTap: onProfileTap,
            child: SizedBox(
              width: metrics.profileImageSize,
              height: metrics.profileImageSize,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profile.jpg',
                  width: metrics.profileImageSize,
                  height: metrics.profileImageSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: metrics.headerHorizontalPadding * 0.5),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.inter(
                    fontSize: metrics.userNameFontSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDarkPink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: metrics.headerBottomPadding * 0.125),
                Text(
                  userTagline,
                  style: GoogleFonts.inter(
                    fontSize: metrics.userTaglineFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLightPink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Search Icon
          SizedBox(width: 4),
          // Notification Icon
          Material(
            color: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                InkWell(
                  onTap: onNotificationTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: metrics.iconSize + 12,
                    height: metrics.iconSize + 12,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/svg/notification.svg',
                      width: metrics.iconSize,
                      height: metrics.iconSize,
                    ),
                  ),
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: metrics.notificationBadgeSize,
                        minHeight: metrics.notificationBadgeSize,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: notificationCount > 9 ? 4 : 0,
                      ),
                      decoration: BoxDecoration(
                        shape: notificationCount > 9 
                            ? BoxShape.rectangle 
                            : BoxShape.circle,
                        borderRadius: notificationCount > 9 
                            ? BorderRadius.circular(metrics.notificationBadgeSize / 2)
                            : null,
                        color: AppColors.primaryRed,
                      ),
                      child: Center(
                        child: Text(
                          notificationCount > 99 ? '99+' : notificationCount.toString(),
                          style: GoogleFonts.inter(
                            fontSize: notificationCount > 9 
                                ? metrics.notificationBadgeSize * 0.45
                                : metrics.notificationBadgeSize * 0.55,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

