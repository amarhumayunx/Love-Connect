import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_text_field.dart';
import 'package:love_connect/screens/auth/sign_up/view_model/sign_up_view_model.dart';

class SignUpPasswordField extends StatelessWidget {
  final SignUpViewModel viewModel;

  const SignUpPasswordField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AuthTextField(
        label: 'Password',
        controller: viewModel.passwordController,
        hintText: AuthStrings.passwordHint,
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
            return 'Password is required';
          }
          
          if (value.length < 8) {
            return 'Password must be at least 8 characters';
          }
          
          if (!RegExp(r'[A-Z]').hasMatch(value)) {
            return 'Password must contain at least one uppercase letter';
          }
          
          if (!RegExp(r'[a-z]').hasMatch(value)) {
            return 'Password must contain at least one lowercase letter';
          }
          
          if (!RegExp(r'[0-9]').hasMatch(value)) {
            return 'Password must contain at least one number';
          }
          
          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
            return 'Password must contain at least one special character';
          }
          
          return null;
        },
      ),
    );
  }
}
