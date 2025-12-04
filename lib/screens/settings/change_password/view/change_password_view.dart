import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/settings/change_password/view_model/change_password_view_model.dart';
import 'package:love_connect/screens/settings/change_password/view/widgets/change_password_form.dart';
import 'package:love_connect/screens/settings/change_password/view/widgets/change_password_layout_metrics.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  late final ChangePasswordViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(ChangePasswordViewModel());
  }

  @override
  void dispose() {
    Get.delete<ChangePasswordViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ChangePasswordLayoutMetrics.fromContext(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.horizontalPadding,
                vertical: metrics.topSpacing,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.primaryDark,
                      size: metrics.iconSize,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    viewModel.model.title,
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(20),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: metrics.horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: metrics.titleSpacing),
                    Text(
                      viewModel.model.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: context.responsiveFont(14),
                        fontWeight: FontWeight.w400,
                        color: AppColors.textLightPink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: metrics.formSpacing),
                    ChangePasswordForm(viewModel: viewModel, metrics: metrics),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

