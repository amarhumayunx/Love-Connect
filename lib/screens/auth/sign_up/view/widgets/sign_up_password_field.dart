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
          if (value == null || value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }
}
