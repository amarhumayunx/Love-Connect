import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_header.dart';
import 'package:love_connect/screens/auth/forgot_password/view/widgets/forgot_password_back_button.dart';
import 'package:love_connect/screens/auth/forgot_password/view/widgets/forgot_password_email_form.dart';
import 'package:love_connect/screens/auth/forgot_password/view/widgets/forgot_password_illustration.dart';
import 'package:love_connect/screens/auth/forgot_password/view/widgets/forgot_password_layout_metrics.dart';
import 'package:love_connect/screens/auth/forgot_password/view_model/forgot_password_view_model.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final ForgotPasswordViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(ForgotPasswordViewModel());
  }

  @override
  void dispose() {
    Get.delete<ForgotPasswordViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ForgotPasswordLayoutMetrics.fromContext(context);

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
                        const ForgotPasswordBackButton(),

                        SizedBox(height: metrics.spacingLarge),

                        Center(
                          child: AuthHeader(
                            title: AuthStrings.forgotPasswordTitle,
                            subtitle: AuthStrings.forgotPasswordSubtitle,
                            titleFontSize: metrics.titleFontSize,
                            subtitleFontSize: metrics.subtitleFontSize,
                            spacing: metrics.spacingSmall,
                          ),
                        ),

                        SizedBox(height: metrics.spacingLarge * 0.2),

                        Center(
                          child: ForgotPasswordIllustration(
                            height: metrics.imageHeight,
                          ),
                        ),

                        SizedBox(height: metrics.spacingLarge * 0.7),

                        ForgotPasswordEmailForm(
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
