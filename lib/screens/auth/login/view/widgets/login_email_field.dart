import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_text_field.dart';
import 'package:love_connect/screens/auth/login/view_model/login_view_model.dart';

class LoginEmailField extends StatelessWidget {
  final LoginViewModel viewModel;

  const LoginEmailField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      label: 'Email',
      controller: viewModel.emailController,
      hintText: viewModel.model.emailHint,
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
    );
  }
}
