import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_primary_button.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_text_field.dart';
import 'package:love_connect/screens/settings/change_password/view/widgets/change_password_layout_metrics.dart';
import 'package:love_connect/screens/settings/change_password/view_model/change_password_view_model.dart';

class ChangePasswordForm extends StatelessWidget {
  final ChangePasswordViewModel viewModel;
  final ChangePasswordLayoutMetrics metrics;

  const ChangePasswordForm({
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
          // Current Password
          Obx(
            () => AuthTextField(
              label: 'Current Password',
              controller: viewModel.currentPasswordController,
              hintText: 'Enter your current password',
              obscureText: viewModel.obscureCurrentPassword.value,
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.obscureCurrentPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.textLightPink,
                ),
                onPressed: viewModel.toggleCurrentPasswordVisibility,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
          ),
          SizedBox(height: metrics.spacingMedium),

          // New Password
          Obx(
            () => AuthTextField(
              label: 'New Password',
              controller: viewModel.newPasswordController,
              hintText: 'Enter your new password',
              obscureText: viewModel.obscureNewPassword.value,
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.obscureNewPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.textLightPink,
                ),
                onPressed: viewModel.toggleNewPasswordVisibility,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
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
              textInputAction: TextInputAction.next,
            ),
          ),
          SizedBox(height: metrics.spacingMedium),

          // Confirm Password
          Obx(
            () => AuthTextField(
              label: 'Confirm New Password',
              controller: viewModel.confirmPasswordController,
              hintText: 'Confirm your new password',
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
                  return 'Please confirm your new password';
                }
                if (value != viewModel.newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
            ),
          ),
          SizedBox(height: metrics.spacingLarge),

          // Change Password Button
          Obx(
            () => AuthPrimaryButton(
              label: 'Change Password',
              onPressed: viewModel.onChangePasswordTap,
              isLoading: viewModel.isLoading.value,
              height: metrics.buttonHeight,
            ),
          ),
        ],
      ),
    );
  }
}

