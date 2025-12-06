import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/surprise/view_model/surprise_view_model.dart';
import 'package:scratcher/scratcher.dart';

class ScratchCardWidget extends StatefulWidget {
  const ScratchCardWidget({super.key});

  static void show(BuildContext context) {
    Get.dialog(
      const ScratchCardWidget(),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  @override
  State<ScratchCardWidget> createState() => _ScratchCardWidgetState();
}

class _ScratchCardWidgetState extends State<ScratchCardWidget> {
  final SurpriseViewModel _viewModel = Get.find<SurpriseViewModel>();
  final GlobalKey<ScratcherState> _scratcherKey = GlobalKey<ScratcherState>();
  late String _coupon;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _coupon = _viewModel.getRandomCoupon();
  }

  void _onScratchUpdate(double value) {
    if (value >= 0.5 && !_isRevealed) {
      setState(() {
        _isRevealed = true;
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _claimReward() async {
    if (_viewModel.isSavingJournal.value) return;

    // Save coupon to journal
    final saved = await _viewModel.saveCouponToJournal(_coupon);
    
    if (saved && mounted) {
      Get.back(); // Close the scratch card dialog
      
      // Show success message
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Coupon Saved!',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          content: Text(
            'Your love coupon "$_coupon" has been saved to your journal for today! 💝',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textDarkPink,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final cardHeight = (screenHeight * 0.4).clamp(300.0, 450.0);
    final cardWidth = (screenWidth * 0.8).clamp(280.0, 350.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.widthPct(5),
        vertical: context.heightPct(8),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.85,
          maxWidth: screenWidth * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(context.responsiveSpacing(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lucky Love Coupon',
                      style: GoogleFonts.inter(
                        fontSize: context.responsiveFont(20),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          color: AppColors.primaryRed,
                          size: context.responsiveImage(24),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.responsiveSpacing(24)),

                // Instructions
                Text(
                  'Scratch to reveal your surprise!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(14),
                    fontWeight: FontWeight.w400,
                    color: AppColors.textLightPink,
                  ),
                ),
                SizedBox(height: context.responsiveSpacing(16)),

                // Scratch Card
                Center(
                  child: Scratcher(
                    key: _scratcherKey,
                    brushSize: 50,
                    threshold: 50,
                    color: AppColors.primaryRed,
                    onChange: _onScratchUpdate,
                    onThreshold: () {
                      HapticFeedback.heavyImpact();
                      setState(() {
                        _isRevealed = true;
                      });
                    },
                    child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFE0B2), // Light Peach
                            Color(0xFFFFCCBC), // Peach
                            Color(0xFFFFAB91), // Darker Peach
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryRed.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.primaryRed.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Background pattern
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryRed.withOpacity(0.1),
                                    AppColors.primaryLight.withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Content
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(context.responsiveSpacing(20)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.card_giftcard_rounded,
                                    size: context.responsiveImage(60),
                                    color: AppColors.primaryRed,
                                  ),
                                  SizedBox(height: context.responsiveSpacing(20)),
                                  Text(
                                    _coupon,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: context.responsiveFont(18),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(height: context.responsiveSpacing(16)),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: context.responsiveSpacing(16),
                                      vertical: context.responsiveSpacing(8),
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryRed.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '💝',
                                      style: GoogleFonts.inter(
                                        fontSize: context.responsiveFont(24),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.responsiveSpacing(24)),

                // Action buttons
                if (_isRevealed)
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _viewModel.isSavingJournal.value ? null : _claimReward,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          disabledBackgroundColor: AppColors.primaryRed.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: context.responsiveSpacing(14),
                          ),
                          elevation: 0,
                        ),
                        child: _viewModel.isSavingJournal.value
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Claim Your Reward',
                                style: GoogleFonts.inter(
                                  fontSize: context.responsiveFont(16),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),
                  )
                else
                  Text(
                    'Keep scratching...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(12),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textLightPink,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

