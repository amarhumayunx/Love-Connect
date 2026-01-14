import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/core/widgets/confetti_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _showConfetti = false;
  
  // History and custom options
  final List<String> _history = [];
  final List<String> _customOptions = [];
  final TextEditingController _customOptionController = TextEditingController();
  bool _showAddOption = false;
  final int _maxHistory = 5;

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

    _loadHistory();
    _loadCustomOptions();
  }

  @override
  void dispose() {
    _controller.dispose();
    _customOptionController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('decision_maker_history') ?? [];
      setState(() {
        _history.clear();
        _history.addAll(historyJson);
      });
    } catch (e) {
      // Error loading history, continue with empty history
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('decision_maker_history', _history);
    } catch (e) {
      // Error saving history, continue silently
    }
  }

  Future<void> _loadCustomOptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customJson = prefs.getStringList('decision_maker_custom_options') ?? [];
      setState(() {
        _customOptions.clear();
        _customOptions.addAll(customJson);
      });
    } catch (e) {
      // Error loading custom options, continue with empty list
    }
  }

  Future<void> _saveCustomOptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('decision_maker_custom_options', _customOptions);
    } catch (e) {
      // Error saving custom options, continue silently
    }
  }

  List<String> get _allOptions {
    return [...widget.options, ..._customOptions];
  }

  void _spin() {
    if (_isSpinning || _allOptions.isEmpty) return;

    setState(() {
      _isSpinning = true;
      _selectedOption = null;
      _showConfetti = false;
    });

    // Sound effect and haptic feedback
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);

    _controller.reset();
    _controller.forward().then((_) {
      final selectedIndex = _random.nextInt(_allOptions.length);
      final selected = _allOptions[selectedIndex];
      
      setState(() {
        _selectedOption = selected;
        _isSpinning = false;
        _showConfetti = true;
      });

      // Add to history
      _history.insert(0, selected);
      if (_history.length > _maxHistory) {
        _history.removeLast();
      }
      _saveHistory();

      // Celebration sound and haptic
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);

      // Hide confetti after animation
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showConfetti = false;
          });
        }
      });
    });
  }

  void _addCustomOption() {
    final text = _customOptionController.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an option',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryRed.withOpacity(0.9),
        colorText: AppColors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (_allOptions.contains(text)) {
      Get.snackbar(
        'Error',
        'This option already exists',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryRed.withOpacity(0.9),
        colorText: AppColors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() {
      _customOptions.add(text);
      _showAddOption = false;
    });
    _customOptionController.clear();
    _saveCustomOptions();

    HapticFeedback.lightImpact();
  }

  void _removeCustomOption(String option) {
    setState(() {
      _customOptions.remove(option);
    });
    _saveCustomOptions();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
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
                SizedBox(height: context.responsiveSpacing(24)),

                // Add Custom Option Section
                Container(
                  padding: EdgeInsets.all(context.responsiveSpacing(12)),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundPink.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Custom Options',
                            style: GoogleFonts.inter(
                              fontSize: context.responsiveFont(14),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _showAddOption ? Icons.close : Icons.add,
                              color: AppColors.primaryRed,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _showAddOption = !_showAddOption;
                                if (!_showAddOption) {
                                  _customOptionController.clear();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      if (_showAddOption) ...[
                        SizedBox(height: context.responsiveSpacing(8)),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customOptionController,
                                decoration: InputDecoration(
                                  hintText: 'Enter option...',
                                  hintStyle: GoogleFonts.inter(
                                    color: AppColors.textLightPink,
                                    fontSize: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: AppColors.primaryRed,
                                      width: 1,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.primaryDark,
                                ),
                                onSubmitted: (_) => _addCustomOption(),
                              ),
                            ),
                            SizedBox(width: context.responsiveSpacing(8)),
                            ElevatedButton(
                              onPressed: _addCustomOption,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryRed,
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.responsiveSpacing(16),
                                  vertical: context.responsiveSpacing(8),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Add',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_customOptions.isNotEmpty) ...[
                        SizedBox(height: context.responsiveSpacing(8)),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _customOptions.map((option) {
                            return Chip(
                              label: Text(
                                option,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              deleteIcon: Icon(
                                Icons.close,
                                size: 16,
                                color: AppColors.primaryRed,
                              ),
                              onDeleted: () => _removeCustomOption(option),
                              backgroundColor: AppColors.white,
                              side: BorderSide(
                                color: AppColors.primaryRed.withOpacity(0.3),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: context.responsiveSpacing(24)),

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

                SizedBox(height: context.responsiveSpacing(24)),

                // History Section
                if (_history.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(context.responsiveSpacing(12)),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundPink.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Decisions',
                          style: GoogleFonts.inter(
                            fontSize: context.responsiveFont(14),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        SizedBox(height: context.responsiveSpacing(8)),
                        ..._history.take(5).map((item) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: context.responsiveSpacing(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 16,
                                  color: AppColors.textLightPink,
                                ),
                                SizedBox(width: context.responsiveSpacing(8)),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: GoogleFonts.inter(
                                      fontSize: context.responsiveFont(13),
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textLightPink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: context.responsiveSpacing(24)),
                ],

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
        ),
        // Confetti overlay
        if (_showConfetti)
          Positioned.fill(
            child: IgnorePointer(
              child: ConfettiWidget(
                duration: const Duration(seconds: 2),
              ),
            ),
          ),
      ],
    );
  }
}
