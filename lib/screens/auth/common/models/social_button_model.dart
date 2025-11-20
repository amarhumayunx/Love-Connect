enum SocialButtonType {
  google,
  apple,
  facebook,
}

class SocialButtonModel {
  final String assetPath;
  final String tooltip;
  final SocialButtonType type;

  const SocialButtonModel({
    required this.assetPath,
    required this.tooltip,
    required this.type,
  });
}
