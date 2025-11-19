import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_primary_button.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_text_field.dart';
import 'package:love_connect/screens/auth/forgot_password/view/widgets/forgot_password_layout_metrics.dart';
import 'package:love_connect/screens/auth/forgot_password/view_model/forgot_password_view_model.dart';

class ForgotPasswordEmailForm extends StatelessWidget {
  final ForgotPasswordViewModel viewModel;
  final ForgotPasswordLayoutMetrics metrics;

  const ForgotPasswordEmailForm({
    super.key,
    required this.viewModel,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            label: 'Email',
            controller: viewModel.emailController,
            hintText: AuthStrings.emailHint,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: metrics.spacingLarge),
          AuthPrimaryButton(
            label: AuthStrings.sendCode,
            onPressed: viewModel.onSendCode,
            height: metrics.buttonHeight,
            expanded: true,
          ),
        ],
      ),
    );
  }
}
