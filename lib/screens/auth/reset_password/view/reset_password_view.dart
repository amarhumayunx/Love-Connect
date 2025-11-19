import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_header.dart';
import 'package:love_connect/screens/auth/reset_password/view/widgets/reset_password_back_button.dart';
import 'package:love_connect/screens/auth/reset_password/view/widgets/reset_password_form.dart';
import 'package:love_connect/screens/auth/reset_password/view/widgets/reset_password_layout_metrics.dart';
import 'package:love_connect/screens/auth/reset_password/view_model/reset_password_view_model.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  late final ResetPasswordViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(ResetPasswordViewModel());
  }

  @override
  void dispose() {
    Get.delete<ResetPasswordViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ResetPasswordLayoutMetrics.fromContext(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: metrics.horizontalPadding,
                      vertical: metrics.topPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ResetPasswordBackButton(),
                        SizedBox(height: metrics.spacingLarge),
                        Center(
                          child: AuthHeader(
                            title: AuthStrings.resetPasswordTitle,
                            subtitle: AuthStrings.resetPasswordSubtitle,
                            titleFontSize: metrics.titleFontSize,
                            subtitleFontSize: metrics.subtitleFontSize,
                            spacing: metrics.spacingSmall,
                          ),
                        ),
                        SizedBox(height: metrics.spacingLarge * 1.5),
                        ResetPasswordForm(
                          viewModel: viewModel,
                          metrics: metrics,
                        ),
                        SizedBox(height: metrics.spacingLarge),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

