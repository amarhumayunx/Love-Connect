import 'package:flutter/material.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_text_field.dart';
import 'package:love_connect/screens/auth/sign_up/view_model/sign_up_view_model.dart';

class SignUpNameField extends StatelessWidget {
  final SignUpViewModel viewModel;

  const SignUpNameField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      label: 'Name',
      controller: viewModel.nameController,
      hintText: AuthStrings.nameHint,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Name is required';
        }
        return null;
      },
    );
  }
}
