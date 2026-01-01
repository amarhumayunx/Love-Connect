import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';

/// Reusable empty state widget for Plans and Journal
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.responsiveSpacing(40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with decorative background
            Container(
              width: context.responsiveImage(120),
              height: context.responsiveImage(120),
              decoration: BoxDecoration(
                color: AppColors.backgroundPink,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: context.responsiveImage(60),
                color: AppColors.textLightPink,
              ),
            ),
            SizedBox(height: context.responsiveSpacing(24)),
            
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: context.responsiveFont(24),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            SizedBox(height: context.responsiveSpacing(12)),
            
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: context.responsiveFont(16),
                fontWeight: FontWeight.w400,
                color: AppColors.textLightPink,
                height: 1.5,
              ),
            ),
            
            // Action button (optional)
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: context.responsiveSpacing(32)),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveSpacing(24),
                    vertical: context.responsiveSpacing(14),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for Plans
class PlansEmptyState extends StatelessWidget {
  final VoidCallback? onAddPlan;

  const PlansEmptyState({super.key, this.onAddPlan});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.calendar_today_rounded,
      title: 'No plans yet?',
      message: 'Time to ask them out! Create your first date plan and start making beautiful memories together. 💕',
      actionLabel: 'Create Plan',
      onAction: onAddPlan,
    );
  }
}

/// Empty state for Journal
class JournalEmptyState extends StatelessWidget {
  final VoidCallback? onAddEntry;

  const JournalEmptyState({super.key, this.onAddEntry});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.book_rounded,
      title: 'Your love story begins here',
      message: 'Start documenting your beautiful moments together. Every memory is worth preserving! ✨',
      actionLabel: 'Add Entry',
      onAction: onAddEntry,
    );
  }
}
