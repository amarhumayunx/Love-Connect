import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/common/models/social_button_model.dart';

class LoginModel {
  final String title;
  final String subtitle;
  final String emailHint;
  final String passwordHint;
  final List<SocialButtonModel> socialButtons;

  const LoginModel({
    this.title = AuthStrings.welcomeBack,
    this.subtitle = AuthStrings.loveJourneySubtitle,
    this.emailHint = AuthStrings.emailHint,
    this.passwordHint = AuthStrings.passwordHint,
    this.socialButtons = const [
      SocialButtonModel(
        assetPath: AuthStrings.googleIcon,
        tooltip: 'Sign in with Google',
        type: SocialButtonType.google,
      ),
    ],
  });
}
