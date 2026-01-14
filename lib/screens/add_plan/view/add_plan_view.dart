import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/core/widgets/banner_ad_widget.dart';
import 'package:love_connect/core/services/admob_service.dart';
import 'package:love_connect/screens/add_plan/view/widgets/add_plan_layout_metrics.dart';
import 'package:love_connect/screens/add_plan/view/widgets/custom_date_picker.dart';
import 'package:love_connect/screens/add_plan/view/widgets/custom_time_picker.dart';
import 'package:love_connect/screens/add_plan/view_model/add_plan_view_model.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';

class AddPlanView extends StatefulWidget {
  final String? planId;
  final VoidCallback? onClose;

  const AddPlanView({super.key, this.planId, this.onClose});

  @override
  State<AddPlanView> createState() => _AddPlanViewState();
}

class _AddPlanViewState extends State<AddPlanView> {
  late final AddPlanViewModel viewModel;
  late final TextEditingController titleController;
  late final TextEditingController placeController;
  HomeViewModel? homeViewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(
      AddPlanViewModel(planId: widget.planId, onCloseCallback: widget.onClose),
    );

    // Try to find HomeViewModel to check navigation source
    try {
      homeViewModel = Get.find<HomeViewModel>();
    } catch (e) {
      // HomeViewModel not found, likely navigated via Get.to() from outside MainNavigationView
      homeViewModel = null;
    }

    // Get arguments if passed from Ideas screen
    final args = Get.arguments as Map<String, dynamic>?;

    titleController = TextEditingController(text: args?['title'] ?? '');
    placeController = TextEditingController(text: args?['place'] ?? '');

    if (args != null) {
      if (args['title'] != null) {
        viewModel.updateTitle(args['title']);
      }
      if (args['place'] != null) {
        viewModel.updatePlace(args['place']);
      }
      if (args['type'] != null) {
        viewModel.updateType(args['type']);
      }
    }

    // Listen to model changes
    ever(viewModel.model, (model) {
      if (titleController.text != model.title) {
        titleController.text = model.title;
      }
      if (placeController.text != model.place) {
        placeController.text = model.place;
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    placeController.dispose();
    Get.delete<AddPlanViewModel>();
    super.dispose();
  }

  Future<void> _selectDate() async {
    await showDialog(
      context: context,
      builder: (context) => CustomDatePicker(
        initialDate: viewModel.model.value.date,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        onDateSelected: (picked) {
          if (picked != null) {
            viewModel.updateDate(picked);
          }
        },
      ),
    );
  }

  Future<void> _selectTime() async {
    final currentTime = viewModel.model.value.time;
    final initialTime = currentTime != null
        ? TimeOfDay.fromDateTime(currentTime)
        : TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (context) => CustomTimePicker(
        initialTime: initialTime,
        onTimeSelected: (picked) {
          if (picked != null) {
            viewModel.updateTime(picked);
          }
        },
      ),
    );
  }

  Future<void> _selectType() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: viewModel.planTypes.map((type) {
            return ListTile(
              title: Text(
                type,
                style: GoogleFonts.inter(
                  color: AppColors.primaryDark,
                  fontSize: 16,
                ),
              ),
              onTap: () => Get.back(result: type),
            );
          }).toList(),
        ),
      ),
    );
    if (selected != null) {
      viewModel.updateType(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final metrics = AddPlanLayoutMetrics.fromContext(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.backgroundPink,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
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
                    // Show back arrow only if NOT navigated from navbar
                    homeViewModel != null
                        ? Obx(
                          () => homeViewModel!.isFromNavbar('addPlan')
                          ? const SizedBox.shrink() // Hide back arrow if from navbar
                          : GestureDetector(
                        onTap: () {
                          if (widget.onClose != null) {
                            widget.onClose!();
                          } else {
                            Get.back();
                          }
                        },
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
                    )
                        : GestureDetector(
                      onTap: () {
                        if (widget.onClose != null) {
                          widget.onClose!();
                        } else {
                          Get.back();
                        }
                      },
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
                        'Add Plan',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(24),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: metrics.cardPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _buildLabel('Title', metrics),
                      SizedBox(height: metrics.sectionSpacing * 0.5),
                      _buildTextField(
                        controller: titleController,
                        hintText: 'Surprise Date',
                        onChanged: viewModel.updateTitle,
                        metrics: metrics,
                      ),
                      SizedBox(height: metrics.sectionSpacing),

                      // Date and Time Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Date', metrics),
                                SizedBox(height: metrics.sectionSpacing * 0.5),
                                _buildDateField(metrics),
                              ],
                            ),
                          ),
                          SizedBox(width: metrics.sectionSpacing),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Time', metrics),
                                SizedBox(height: metrics.sectionSpacing * 0.5),
                                _buildTimeField(metrics),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: metrics.sectionSpacing),

                      // Place
                      _buildLabel('Place', metrics),
                      SizedBox(height: metrics.sectionSpacing * 0.5),
                      _buildTextField(
                        controller: placeController,
                        hintText: 'The Rosewood',
                        onChanged: viewModel.updatePlace,
                        metrics: metrics,
                      ),
                      SizedBox(height: metrics.sectionSpacing),

                      // Type
                      _buildLabel('Type', metrics),
                      SizedBox(height: metrics.sectionSpacing * 0.5),
                      _buildTypeField(metrics),
                      SizedBox(height: metrics.sectionSpacing * 2),

                      // Buttons
                      Row(
                        children: [
                          Expanded(child: _buildCancelButton(metrics)),
                          SizedBox(width: metrics.sectionSpacing),
                          Expanded(child: _buildSaveButton(metrics)),
                        ],
                      ),
                      SizedBox(height: metrics.sectionSpacing * 2),
                    ],
                  ),
                ),
              ),
              
              // Banner Ad at the bottom
              SafeArea(
                top: false,
                child: BannerAdWidget(
                  adUnitId: AdMobService.instance.addPlanBannerAdUnitId,
                  useAnchoredAdaptive: true,
                  margin: EdgeInsets.symmetric(
                    vertical: context.responsiveSpacing(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, AddPlanLayoutMetrics metrics) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: metrics.labelFontSize,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryDark,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Function(String) onChanged,
    required AddPlanLayoutMetrics metrics,
  }) {
    return Container(
      height: metrics.inputFieldHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.IdeaColorText, width: 1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          fontSize: metrics.inputFieldFontSize,
          color: AppColors.primaryDark,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: metrics.inputFieldFontSize,
            color: AppColors.textLightPink,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: metrics.cardPadding * 0.6,
            vertical: metrics.sectionSpacing * 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(AddPlanLayoutMetrics metrics) {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        height: metrics.inputFieldHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.IdeaColorText, width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: metrics.cardPadding * 0.6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
                  () => Text(
                DateFormat('dd/MM/yyyy').format(viewModel.model.value.date),
                style: GoogleFonts.inter(
                  fontSize: metrics.inputFieldFontSize,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: AppColors.primaryRed,
              size: metrics.iconSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(AddPlanLayoutMetrics metrics) {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        height: metrics.inputFieldHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.IdeaColorText, width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: metrics.cardPadding * 0.6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
                  () => Text(
                viewModel.model.value.time != null
                    ? DateFormat('hh:mm a').format(viewModel.model.value.time!)
                    : '--:--',
                style: GoogleFonts.inter(
                  fontSize: metrics.inputFieldFontSize,
                  color: viewModel.model.value.time != null
                      ? AppColors.primaryDark
                      : AppColors.textLightPink,
                ),
              ),
            ),
            Icon(
              Icons.access_time,
              color: AppColors.primaryRed,
              size: metrics.iconSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeField(AddPlanLayoutMetrics metrics) {
    return GestureDetector(
      onTap: _selectType,
      child: Container(
        height: metrics.inputFieldHeight,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.IdeaColorText, width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: metrics.cardPadding * 0.6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
                  () => Text(
                viewModel.model.value.type,
                style: GoogleFonts.inter(
                  fontSize: metrics.inputFieldFontSize,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primaryRed,
              size: metrics.iconSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(AddPlanLayoutMetrics metrics) {
    return OutlinedButton(
      onPressed: () {
        if (widget.onClose != null) {
          widget.onClose!();
        } else {
          Get.back();
        }
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(34)),
        minimumSize: Size(double.infinity, metrics.buttonHeight),
      ),
      child: Text(
        'Cancel',
        style: GoogleFonts.inter(
          fontSize: metrics.buttonFontSize,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryRed,
        ),
      ),
    );
  }

  Widget _buildSaveButton(AddPlanLayoutMetrics metrics) {
    return Obx(
          () => ElevatedButton(
        onPressed: viewModel.isSaving.value ? null : viewModel.savePlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(34),
          ),
          minimumSize: Size(double.infinity, metrics.buttonHeight),
        ),
        child: viewModel.isSaving.value
            ? SizedBox(
          width: 20,
          height: 20,
          child: LoadingAnimationWidget.horizontalRotatingDots(
            color: AppColors.white,
            size: 20,
          ),
        )
            : Text(
          'Save Plan',
          style: GoogleFonts.inter(
            fontSize: metrics.buttonFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}