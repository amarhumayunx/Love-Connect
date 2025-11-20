import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_social_buttons_row.dart';
import 'package:love_connect/screens/auth/login/view_model/login_view_model.dart';

class LoginSocialButtons extends StatelessWidget {
  final LoginViewModel viewModel;

  const LoginSocialButtons({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AuthSocialButtonsRow(
        buttons: viewModel.model.socialButtons,
        onPressed: viewModel.onSocialTap,
        isDisabled: viewModel.isLoading.value,
      ),
    );
  }
}
