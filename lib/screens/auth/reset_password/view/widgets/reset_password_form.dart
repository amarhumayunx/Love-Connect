import 'package:flutter/material.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_primary_button.dart';
import 'package:love_connect/screens/auth/reset_password/view/widgets/reset_password_confirm_password_field.dart';
import 'package:love_connect/screens/auth/reset_password/view/widgets/reset_password_layout_metrics.dart';
import 'package:love_connect/screens/auth/reset_password/view/widgets/reset_password_password_field.dart';
import 'package:love_connect/screens/auth/reset_password/view_model/reset_password_view_model.dart';

class ResetPasswordForm extends StatelessWidget {
  final ResetPasswordViewModel viewModel;
  final ResetPasswordLayoutMetrics metrics;

  const ResetPasswordForm({
    super.key,
    required this.viewModel,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResetPasswordPasswordField(viewModel: viewModel),
          SizedBox(height: metrics.spacingMedium),
          ResetPasswordConfirmPasswordField(viewModel: viewModel),
          SizedBox(height: metrics.spacingLarge),
          AuthPrimaryButton(
            label: AuthStrings.resetPassword,
            onPressed: viewModel.onResetPasswordTap,
            height: metrics.buttonHeight,
          ),
        ],
      ),
    );
  }
}

