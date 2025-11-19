import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_text_field.dart';
import 'package:love_connect/screens/auth/reset_password/view_model/reset_password_view_model.dart';

class ResetPasswordPasswordField extends StatelessWidget {
  final ResetPasswordViewModel viewModel;

  const ResetPasswordPasswordField({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AuthTextField(
        label: 'Password',
        controller: viewModel.passwordController,
        hintText: viewModel.model.passwordHint,
        obscureText: viewModel.obscurePassword.value,
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.obscurePassword.value
                ? Icons.visibility_off
                : Icons.visibility,
            color: AppColors.textLightPink,
          ),
          onPressed: viewModel.togglePasswordVisibility,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a new password';
          }
          if (value.length < 8) {
            return 'Password must be at least 8 characters';
          }
          return null;
        },
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

