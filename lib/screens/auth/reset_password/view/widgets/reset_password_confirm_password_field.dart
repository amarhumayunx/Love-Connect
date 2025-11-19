import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_text_field.dart';
import 'package:love_connect/screens/auth/reset_password/view_model/reset_password_view_model.dart';

class ResetPasswordConfirmPasswordField extends StatelessWidget {
  final ResetPasswordViewModel viewModel;

  const ResetPasswordConfirmPasswordField({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AuthTextField(
        label: 'Confirm password',
        controller: viewModel.confirmPasswordController,
        hintText: viewModel.model.confirmPasswordHint,
        obscureText: viewModel.obscureConfirmPassword.value,
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.obscureConfirmPassword.value
                ? Icons.visibility_off
                : Icons.visibility,
            color: AppColors.textLightPink,
          ),
          onPressed: viewModel.toggleConfirmPasswordVisibility,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please confirm your password';
          }
          if (value != viewModel.passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
        textInputAction: TextInputAction.done,
      ),
    );
  }
}

