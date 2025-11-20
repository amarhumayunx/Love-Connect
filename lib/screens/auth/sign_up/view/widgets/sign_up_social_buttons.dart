import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_social_buttons_row.dart';
import 'package:love_connect/screens/auth/sign_up/view_model/sign_up_view_model.dart';

class SignUpSocialButtons extends StatelessWidget {
  final SignUpViewModel viewModel;

  const SignUpSocialButtons({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(
        () => AuthSocialButtonsRow(
          buttons: viewModel.model.socialButtons,
          onPressed: viewModel.onSocialTap,
          isDisabled: viewModel.isLoading.value,
        ),
      ),
    );
  }
}
