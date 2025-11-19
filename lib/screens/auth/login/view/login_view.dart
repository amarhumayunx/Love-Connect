import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/core/strings/get_started_screens_app_strings.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/auth/login/view_model/login_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(LoginViewModel());
  }

  @override
  void dispose() {
    Get.delete<LoginViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _LoginLayoutMetrics metrics = _LoginLayoutMetrics.fromContext(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: metrics.spacingTop),
            child: _buildLogo(metrics),
          ),
          SizedBox(height: metrics.spacingLarge),
          _buildFormCard(context, metrics),
        ],
      ),
    );
  }

  Widget _buildLogo(_LoginLayoutMetrics metrics) {
    return Image.asset(
      AppStrings.heart_logo_strings,
      height: metrics.logoHeight,
    );
  }

  Widget _buildFormCard(BuildContext context, _LoginLayoutMetrics metrics) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
          top: metrics.spacingMedium,
          right: metrics.spacingMedium,
          left: metrics.spacingMedium,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: metrics.spacingScrollView),
          child: SingleChildScrollView(
            child: Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Column(
                      children: [
                        _buildTitle(metrics),
                        SizedBox(height: context.responsiveSpacing(2)),
                        _buildSubtitle(metrics),
                      ],
                    ),
                  ),
                  SizedBox(height: metrics.spacingLarge),
                  _buildEmailField(context),
                  SizedBox(height: metrics.spacingMedium),
                  _buildPasswordField(context),
                  SizedBox(height: metrics.spacingMedium),
                  _buildRememberMeAndForgotPassword(context),
                  SizedBox(height: metrics.spacingMedium),
                  _buildLoginButton(context),
                  SizedBox(height: metrics.spacingMedium),
                  _buildOrDivider(context, metrics),
                  SizedBox(height: metrics.spacingMedium),
                  _buildSocialButtonsRow(),
                  SizedBox(height: metrics.spacingLarge),
                  _buildSignUpRedirect(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(_LoginLayoutMetrics metrics) {
    return Text(
      viewModel.model.title,
      style: GoogleFonts.inter(
        fontSize: metrics.titleSize,
        fontWeight: FontWeight.w700,
        color: AppColors.textDarkPink,
      ),
    );
  }

  Widget _buildSubtitle(_LoginLayoutMetrics metrics) {
    return Text(
      viewModel.model.subtitle,
      style: GoogleFonts.inter(
        fontSize: metrics.subtitleSize,
        color: AppColors.textLightPink,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 3),
          child: Text(
            'Email',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textDarkPink,
            ),
          ),
        ),
        _buildTextField(
          context: context,
          controller: viewModel.emailController,
          hint: viewModel.model.emailHint,
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
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Obx(
          () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 3),
            child: Text(
              'Password',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textDarkPink,
              ),
            ),
          ),
          _buildTextField(
            context: context,
            controller: viewModel.passwordController,
            hint: viewModel.model.passwordHint,
            obscureText: viewModel.obscurePassword.value,
            suffixIcon: IconButton(
              icon: Icon(
                viewModel.obscurePassword.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.textLightPink,
              ),
              onPressed: viewModel.togglePasswordVisibility,
            ),
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRememberMeAndForgotPassword(BuildContext context) {
    return Row(
      children: [
        Obx(
              () => Checkbox(
            value: viewModel.rememberMe.value,
            onChanged: viewModel.toggleRememberMe,
            activeColor: AppColors.textFieldBorder,
            checkColor: Colors.white,
            side: const BorderSide(
              color: AppColors.textFieldBorder,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            AuthStrings.rememberMe,
            style: GoogleFonts.inter(
              color: AppColors.textLightPink,
              fontWeight: FontWeight.w600,
              fontSize: context.responsiveFont(13),
            ),
          ),
        ),
        TextButton(
          onPressed: viewModel.onForgotPasswordTap,
          child: Text(
            AuthStrings.forgotPassword,
            style: GoogleFonts.inter(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.responsiveButtonHeight(),
      child: ElevatedButton(
        onPressed: viewModel.onLoginTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          AuthStrings.login,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: context.responsiveFont(18),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider(BuildContext context, _LoginLayoutMetrics metrics) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.textFieldBorder,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: metrics.spacingSmall,
          ),
          child: Text(
            AuthStrings.orText,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textLightPink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.textFieldBorder,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtonsRow() {
    return Row(
      mainAxisAlignment: .center,
      children: viewModel.model.socialButtons
          .map(
            (social) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: _SocialButton(
                        assetPath: social.assetPath,
                        tooltip: social.tooltip,
                        onTap: () => viewModel.onSocialTap(social.tooltip),
                      ),
            ),
      )
          .toList(),
    );
  }

  Widget _buildSignUpRedirect() {
    return Center(
      child: GestureDetector(
        onTap: viewModel.onSignUpTap,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: AuthStrings.dontHaveAccount,
            style: GoogleFonts.inter(
              color: AppColors.textLightPink,
            ),
            children: [
              TextSpan(
                text: AuthStrings.signUp,
                style: GoogleFonts.inter(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(
        color: AppColors.textDarkPink,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: AppColors.hinttext,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textFieldBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textFieldBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.textFieldBorder,
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String assetPath;
  final String tooltip;
  final VoidCallback onTap;

  const _SocialButton({
    required this.assetPath,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double size = context.responsiveImage(50);
    return Semantics(
      button: true,
      label: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: size * 0.9,
          height: size * 0.9,
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: SvgPicture.asset(
            assetPath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _LoginLayoutMetrics {
  final double titleSize;
  final double subtitleSize;
  final double spacingLarge;
  final double spacingMedium;
  final double spacingSmall;
  final double logoHeight;
  final double spacingTop;
  final double spacingScrollView;

  const _LoginLayoutMetrics({
    required this.titleSize,
    required this.subtitleSize,
    required this.spacingLarge,
    required this.spacingMedium,
    required this.spacingSmall,
    required this.logoHeight,
    required this.spacingTop,
    required this.spacingScrollView,
  });

  factory _LoginLayoutMetrics.fromContext(BuildContext context) {
    return _LoginLayoutMetrics(
      titleSize: context.responsiveFont(30),
      subtitleSize: context.responsiveFont(14),
      spacingLarge: context.responsiveSpacing(13),
      spacingMedium: context.responsiveSpacing(10),
      spacingSmall: context.responsiveSpacing(12),
      spacingTop: context.responsiveSpacing(40),
      logoHeight: context.responsiveImage(200),
      spacingScrollView: context.responsiveSpacing(20),
    );
  }
}