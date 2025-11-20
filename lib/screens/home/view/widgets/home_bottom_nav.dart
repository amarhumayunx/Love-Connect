import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';

class HomeBottomNav extends StatelessWidget {
  final HomeViewModel viewModel;
  final HomeLayoutMetrics metrics;

  const HomeBottomNav({
    super.key,
    required this.viewModel,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.textLightPink.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: metrics.bottomNavHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.quickActionGridSpacing * 0.67,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: viewModel.bottomNavItems.map((item) {
                  final isSelected =
                      viewModel.selectedBottomNavIndex.value == item.index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => viewModel.onBottomNavTap(item.index),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              item.iconPath,
                              width: metrics.bottomNavIconSize,
                              height: metrics.bottomNavIconSize,
                              colorFilter: ColorFilter.mode(
                                isSelected
                                    ? AppColors.textDarkPink
                                    : AppColors.textLightPink,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(height: metrics.quickActionGridSpacing * 0.2),
                            Text(
                              item.label,
                              style: GoogleFonts.inter(
                                fontSize: metrics.bottomNavFontSize,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.textDarkPink
                                    : AppColors.textLightPink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

