import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/auth/common/models/social_button_model.dart';

class AuthSocialButton extends StatelessWidget {
  final SocialButtonModel button;
  final VoidCallback onTap;

  const AuthSocialButton({
    super.key,
    required this.button,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double size = context.responsiveImage(50);
    return Semantics(
      button: true,
      label: button.tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Container(
          width: size * 0.9,
          height: size * 0.9,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SvgPicture.asset(button.assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
