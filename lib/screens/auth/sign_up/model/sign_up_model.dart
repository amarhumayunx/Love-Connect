import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/common/models/social_button_model.dart';

class SignUpModel {
  final String title;
  final String subtitle;
  final List<SocialButtonModel> socialButtons;

  const SignUpModel({
    this.title = AuthStrings.createAccountTitle,
    this.subtitle = AuthStrings.createAccountSubtitle,
    this.socialButtons = const [
      SocialButtonModel(
        assetPath: AuthStrings.googleIcon,
        tooltip: 'Sign up with Google',
        type: SocialButtonType.google,
      ),
    ],
  });
}
