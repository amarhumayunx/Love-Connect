import 'package:flutter/material.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_header.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_primary_button.dart';
import 'package:love_connect/screens/auth/sign_up/view/widgets/sign_up_confirm_password_field.dart';
import 'package:love_connect/screens/auth/sign_up/view/widgets/sign_up_email_field.dart';
import 'package:love_connect/screens/auth/sign_up/view/widgets/sign_up_layout_metrics.dart';
import 'package:love_connect/screens/auth/sign_up/view/widgets/sign_up_login_redirect.dart';
import 'package:love_connect/screens/auth/sign_up/view/widgets/sign_up_name_field.dart';
import 'package:love_connect/screens/auth/sign_up/view/widgets/sign_up_or_divider.dart';
import 'package:love_connect/screens/auth/sign_up/view/widgets/sign_up_password_field.dart';
import 'package:love_connect/screens/auth/sign_up/view/widgets/sign_up_social_buttons.dart';
import 'package:love_connect/screens/auth/sign_up/view_model/sign_up_view_model.dart';

class SignUpFormCard extends StatelessWidget {
  final SignUpViewModel viewModel;
  final SignUpLayoutMetrics metrics;

  const SignUpFormCard({
    super.key,
    required this.viewModel,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
          top: metrics.spacingMedium,
          right: metrics.spacingMedium,
          left: metrics.spacingMedium,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: metrics.spacingScrollView),
          child: SingleChildScrollView(
            child: Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: AuthHeader(
                      title: viewModel.model.title,
                      subtitle: viewModel.model.subtitle,
                      titleFontSize: metrics.titleSize,
                      subtitleFontSize: metrics.subtitleSize,
                      spacing: metrics.spacingMedium * 0.2,
                    ),
                  ),
                  SizedBox(height: metrics.spacingLarge),
                  SignUpNameField(viewModel: viewModel),
                  SizedBox(height: metrics.spacingMedium),
                  SignUpEmailField(viewModel: viewModel),
                  SizedBox(height: metrics.spacingMedium),
                  SignUpPasswordField(viewModel: viewModel),
                  SizedBox(height: metrics.spacingMedium),
                  SignUpConfirmPasswordField(viewModel: viewModel),
                  SizedBox(height: metrics.spacingtopsignpbutton),
                  Center(
                    child: AuthPrimaryButton(
                      label: AuthStrings.signUp,
                      onPressed: viewModel.onSignUpTap,
                    ),
                  ),
                  SizedBox(height: metrics.spacingMedium),
                  SignUpOrDivider(
                    horizontalPadding: metrics.spacingMedium * 0.6,
                  ),
                  SizedBox(height: metrics.spacingMedium),
                  SignUpSocialButtons(viewModel: viewModel),
                  SizedBox(height: metrics.spacingLarge),
                  Center(child: SignUpLoginRedirect(viewModel: viewModel)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
