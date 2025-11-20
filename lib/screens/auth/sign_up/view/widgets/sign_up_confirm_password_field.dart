import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_text_field.dart';
import 'package:love_connect/screens/auth/sign_up/view_model/sign_up_view_model.dart';

class SignUpConfirmPasswordField extends StatelessWidget {
  final SignUpViewModel viewModel;

  const SignUpConfirmPasswordField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AuthTextField(
        label: 'Confirm Password',
        controller: viewModel.confirmPasswordController,
        hintText: AuthStrings.confirmPasswordHint,
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
      ),
    );
  }
}
