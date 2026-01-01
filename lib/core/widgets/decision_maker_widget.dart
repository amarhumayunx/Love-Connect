import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';

/// Decision maker widget (dice/spinner) for date night decisions
class DecisionMakerWidget extends StatefulWidget {
  final List<String> options;

  const DecisionMakerWidget({
    super.key,
    required this.options,
  });

  static void show(BuildContext context, List<String> options) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: context.widthPct(5),
          vertical: context.heightPct(10),
        ),
        child: DecisionMakerWidget(options: options),
      ),
      barrierDismissible: true,
    );
  }

  @override
  State<DecisionMakerWidget> createState() => _DecisionMakerWidgetState();
}

class _DecisionMakerWidgetState extends State<DecisionMakerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  final math.Random _random = math.Random();
  String? _selectedOption;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning || widget.options.isEmpty) return;

    setState(() {
      _isSpinning = true;
      _selectedOption = null;
    });

    HapticFeedback.mediumImpact();
    _controller.reset();
    _controller.forward().then((_) {
      final selectedIndex = _random.nextInt(widget.options.length);
      setState(() {
        _selectedOption = widget.options[selectedIndex];
        _isSpinning = false;
      });
      HapticFeedback.heavyImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.all(context.responsiveSpacing(24)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Title
          Text(
            'Decision Maker',
            style: GoogleFonts.inter(
              fontSize: context.responsiveFont(24),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: context.responsiveSpacing(8)),
          Text(
            'Can\'t decide? Let fate choose!',
            style: GoogleFonts.inter(
              fontSize: context.responsiveFont(14),
              fontWeight: FontWeight.w400,
              color: AppColors.textLightPink,
            ),
          ),
          SizedBox(height: context.responsiveSpacing(32)),

          // Spinner/Dice
          GestureDetector(
            onTap: _spin,
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * math.pi * 5,
                  child: Container(
                    width: context.responsiveImage(120),
                    height: context.responsiveImage(120),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryRed,
                          AppColors.textLightPink,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryRed.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.casino_rounded,
                        size: context.responsiveImage(60),
                        color: AppColors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: context.responsiveSpacing(32)),

          // Result
          if (_selectedOption != null)
            Container(
              padding: EdgeInsets.all(context.responsiveSpacing(16)),
              decoration: BoxDecoration(
                color: AppColors.backgroundPink,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'The choice is...',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textLightPink,
                    ),
                  ),
                  SizedBox(height: context.responsiveSpacing(8)),
                  Text(
                    _selectedOption!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(20),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'Tap the dice to decide!',
              style: GoogleFonts.inter(
                fontSize: context.responsiveFont(16),
                fontWeight: FontWeight.w500,
                color: AppColors.textLightPink,
              ),
            ),

          SizedBox(height: context.responsiveSpacing(32)),

          // Options list
          if (widget.options.isNotEmpty) ...[
            Text(
              'Options:',
              style: GoogleFonts.inter(
                fontSize: context.responsiveFont(14),
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            SizedBox(height: context.responsiveSpacing(12)),
            ...widget.options.map((option) => Padding(
                  padding: EdgeInsets.only(
                    bottom: context.responsiveSpacing(4),
                  ),
                  child: Text(
                    '• $option',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textLightPink,
                    ),
                  ),
                )),
          ],

          SizedBox(height: context.responsiveSpacing(24)),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
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
                    'Close',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.responsiveSpacing(12)),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSpinning ? null : _spin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: context.responsiveSpacing(14),
                    ),
                  ),
                  child: Text(
                    _isSpinning ? 'Spinning...' : 'Spin Again',
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
        ],
        ),
      ),
    );
  }
}
