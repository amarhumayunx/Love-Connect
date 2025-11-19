import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_text_field.dart';
import 'package:love_connect/screens/auth/sign_up/view_model/sign_up_view_model.dart';

class SignUpEmailField extends StatelessWidget {
  final SignUpViewModel viewModel;

  const SignUpEmailField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      label: 'Email',
      controller: viewModel.emailController,
      hintText: 'Enter your email',
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
