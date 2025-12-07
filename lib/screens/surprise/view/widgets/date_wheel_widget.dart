import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/idea_model.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/surprise/view_model/surprise_view_model.dart';

class DateWheelWidget extends StatefulWidget {
  const DateWheelWidget({super.key});

  static void show(BuildContext context) {
    Get.dialog(
      const DateWheelWidget(),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }

  @override
  State<DateWheelWidget> createState() => _DateWheelWidgetState();
}

class _DateWheelWidgetState extends State<DateWheelWidget> {
  final SurpriseViewModel _viewModel = Get.find<SurpriseViewModel>();
  final StreamController<int> _selected = StreamController<int>.broadcast();
  bool _isSpinning = false;
  IdeaModel? _selectedIdea;
  late List<IdeaModel> _wheelIdeas;

  @override
  void initState() {
    super.initState();
    _wheelIdeas = _viewModel.allIdeas.take(8).toList();
    if (_wheelIdeas.length < 8 && _viewModel.allIdeas.length > 8) {
      // If we have less than 8, shuffle and take more
      final random = Random();
      final allIdeas = List<IdeaModel>.from(_viewModel.allIdeas)..shuffle(random);
      _wheelIdeas = allIdeas.take(8).toList();
    }
  }

  @override
  void dispose() {
    _selected.close();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedIdea = null;
    });

    HapticFeedback.mediumImpact();

    final random = Random();
    final selectedIndex = random.nextInt(_wheelIdeas.length);

    _selected.add(selectedIndex);

    // After animation completes
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _isSpinning = false;
          _selectedIdea = _wheelIdeas[selectedIndex];
        });
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _useIdea() async {
    if (_selectedIdea == null || _viewModel.isSavingPlan.value) return;

    // Save the plan
    final saved = await _viewModel.savePlanFromIdea(_selectedIdea!);

    if (saved && mounted) {
      Get.back(); // Close the wheel dialog

      // Show popup that plan can be changed
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Plan Saved!',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          content: Text(
            'Your plan "${_selectedIdea!.title}" has been added to upcoming plans (5 days from now at 12:00 AM).\n\nYou can change this plan anytime from your plans.',
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
    final wheelSize = (screenWidth * 0.85).clamp(250.0, 400.0);

    // Ensure we have at least 2 ideas for the wheel
    if (_wheelIdeas.length < 2) {
      _wheelIdeas = _viewModel.allIdeas.take(2).toList();
    }

    // Create items for the wheel
    final items = _wheelIdeas.map((idea) {
      return FortuneItem(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            idea.title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.widthPct(5),
        vertical: context.heightPct(5),
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
                      'Spin for a Plan',
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

                // Wheel
                Container(
                  width: wheelSize,
                  height: wheelSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryRed.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      FortuneWheel(
                        selected: _selected.stream,
                        items: items,
                        onAnimationEnd: () {
                          // Animation ended
                        },
                        styleStrategy: UniformStyleStrategy(
                          color: AppColors.primaryLight,
                          borderColor: AppColors.primaryDark.withOpacity(0.2),
                          borderWidth: 2,
                        ),
                        physics: CircularPanPhysics(
                          duration: const Duration(seconds: 3),
                          curve: Curves.decelerate,
                        ),
                      ),
                      // Center indicator
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRed.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_downward,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.responsiveSpacing(24)),

                // Spin button
                if (_selectedIdea == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSpinning ? null : _spinWheel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isSpinning
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: LoadingAnimationWidget.horizontalRotatingDots(
                          color: AppColors.white,
                          size: 20,
                        ),
                      )
                          : Text(
                        'Spin the Wheel',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),

                // Result
                if (_selectedIdea != null) ...[
                  Container(
                    padding: EdgeInsets.all(context.responsiveSpacing(20)),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundPink,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🎉 You got:',
                          style: GoogleFonts.inter(
                            fontSize: context.responsiveFont(16),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        SizedBox(height: context.responsiveSpacing(12)),
                        Text(
                          _selectedIdea!.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: context.responsiveFont(20),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryRed,
                          ),
                        ),
                        SizedBox(height: context.responsiveSpacing(8)),
                        Text(
                          '${_selectedIdea!.category} • ${_selectedIdea!.location}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: context.responsiveFont(14),
                            fontWeight: FontWeight.w400,
                            color: AppColors.textLightPink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.responsiveSpacing(16)),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryRed),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: context.responsiveSpacing(14),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: context.responsiveFont(14),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.responsiveSpacing(12)),
                      Expanded(
                        child: Obx(
                              () => ElevatedButton(
                            onPressed: _viewModel.isSavingPlan.value ? null : _useIdea,
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
                            child: _viewModel.isSavingPlan.value
                                ? SizedBox(
                              height: 20,
                              width: 20,
                              child: LoadingAnimationWidget.horizontalRotatingDots(
                                color: AppColors.white,
                                size: 20,
                              ),
                            )
                                : Text(
                              'Plan This',
                              style: GoogleFonts.inter(
                                fontSize: context.responsiveFont(14),
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
