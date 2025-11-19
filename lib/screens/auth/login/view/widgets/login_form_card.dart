import 'package:flutter/material.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_header.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_primary_button.dart';
import 'package:love_connect/screens/auth/login/view/widgets/login_email_field.dart';
import 'package:love_connect/screens/auth/login/view/widgets/login_layout_metrics.dart';
import 'package:love_connect/screens/auth/login/view/widgets/login_or_divider.dart';
import 'package:love_connect/screens/auth/login/view/widgets/login_password_field.dart';
import 'package:love_connect/screens/auth/login/view/widgets/login_remember_forgot_row.dart';
import 'package:love_connect/screens/auth/login/view/widgets/login_sign_up_redirect.dart';
import 'package:love_connect/screens/auth/login/view/widgets/login_social_buttons.dart';
import 'package:love_connect/screens/auth/login/view_model/login_view_model.dart';

class LoginFormCard extends StatelessWidget {
  final LoginViewModel viewModel;
  final LoginLayoutMetrics metrics;

  const LoginFormCard({
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
                  LoginEmailField(viewModel: viewModel),
                  SizedBox(height: metrics.spacingMedium),
                  LoginPasswordField(viewModel: viewModel),
                  SizedBox(height: metrics.spacingMedium),
                  LoginRememberForgotRow(viewModel: viewModel),
                  SizedBox(height: metrics.spacingMedium),
                  AuthPrimaryButton(
                    label: AuthStrings.login,
                    onPressed: viewModel.onLoginTap,
                  ),
                  SizedBox(height: metrics.spacingMedium),
                  LoginOrDivider(horizontalPadding: metrics.spacingSmall),
                  SizedBox(height: metrics.spacingMedium),
                  Center(child: LoginSocialButtons(viewModel: viewModel)),
                  SizedBox(height: metrics.spacingLarge),
                  Center(child: LoginSignUpRedirect(viewModel: viewModel)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
