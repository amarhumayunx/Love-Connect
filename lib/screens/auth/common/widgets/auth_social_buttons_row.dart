import 'package:flutter/material.dart';
import 'package:love_connect/screens/auth/common/models/social_button_model.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_social_button.dart';

class AuthSocialButtonsRow extends StatelessWidget {
  final List<SocialButtonModel> buttons;
  final ValueChanged<SocialButtonModel> onPressed;
  final double spacing;

  const AuthSocialButtonsRow({
    super.key,
    required this.buttons,
    required this.onPressed,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: spacing,
      runSpacing: spacing / 2,
      children: buttons
          .map(
            (button) => AuthSocialButton(
              button: button,
              onTap: () => onPressed(button),
            ),
          )
          .toList(),
    );
  }
}
