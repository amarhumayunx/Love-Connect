import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';

class QuoteModal extends StatelessWidget {
  final String quote;

  const QuoteModal({
    super.key,
    this.quote = 'Love is composed of a single soul inhabiting two bodies',
  });

  static void show({String? quote}) {
    Get.dialog(
      QuoteModal(quote: quote ?? 'Love is composed of a single soul inhabiting two bodies'),
      barrierDismissible: true,
    );
  }

  Future<void> _copyQuote() async {
    await Clipboard.setData(ClipboardData(text: quote));
    Get.back();
    Get.snackbar(
      'Copied',
      'Quote copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryRed,
      colorText: AppColors.white,
      duration: Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Romantic Quote',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(18),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.primaryDark,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Quote
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                quote,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: context.responsiveFont(16),
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryDark,
                  height: 1.5,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Buttons
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(
                          double.infinity,
                          context.responsiveButtonHeight(),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _copyQuote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(
                          double.infinity,
                          context.responsiveButtonHeight(),
                        ),
                      ),
                      child: Text(
                        'Copy',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

