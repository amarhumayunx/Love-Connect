import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/core/strings/get_started_screens_app_strings.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/auth/sign_up/view_model/sign_up_view_model.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  late final SignUpViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(SignUpViewModel());
  }

  @override
  void dispose() {
    Get.delete<SignUpViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _SignUpLayoutMetrics metrics =
        _SignUpLayoutMetrics.fromContext(context);
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

  Widget _buildLogo(_SignUpLayoutMetrics metrics) {
    return Image.asset(
      AppStrings.heart_logo_strings,
      height: metrics.logoHeight,
    );
  }

  Widget _buildFieldWithLabel(BuildContext context, String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: context.responsiveFont(14),
            color: AppColors.textDarkPink,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.responsiveSpacing(4)),
        field,
      ],
    );
  }

  Widget _buildFormCard(BuildContext context, _SignUpLayoutMetrics metrics) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(
            top: metrics.spacingMedium,
            right: metrics.spacingMedium,
            left: metrics.spacingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: viewModel.formKey,
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                _buildTitle(metrics),
                SizedBox(height: context.responsiveSpacing(2)),
                _buildSubtitle(metrics),
                SizedBox(height: metrics.spacingLarge),
                _buildNameField(context),
                SizedBox(height: metrics.spacingMedium),
                _buildEmailField(context),
                SizedBox(height: metrics.spacingMedium),
                _buildPasswordField(context),
                SizedBox(height: metrics.spacingMedium),
                _buildConfirmPasswordField(context),
                SizedBox(height: metrics.spacingLarge),
                _buildSignUpButton(context),
                SizedBox(height: metrics.spacingMedium),
                _buildOrDivider(context),
                SizedBox(height: metrics.spacingMedium),
                _buildSocialButtonsRow(),
                SizedBox(height: metrics.spacingLarge),
                _buildLoginRedirect(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(_SignUpLayoutMetrics metrics) {
    return Text(
      viewModel.model.title,
      style: GoogleFonts.inter(
        fontSize: metrics.titleSize,
        fontWeight: FontWeight.w700,
        color: AppColors.textDarkPink,
      ),
    );
  }

  Widget _buildSubtitle(_SignUpLayoutMetrics metrics) {
    return Text(
      viewModel.model.subtitle,
      style: GoogleFonts.inter(
        fontSize: metrics.subtitleSize,
        color: AppColors.textLightPink,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    return _buildTextField(
      context: context,
      controller: viewModel.nameController,
      hint: AuthStrings.nameHint,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Name is required';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return _buildTextField(
      context: context,
      controller: viewModel.emailController,
      hint: AuthStrings.emailHint,
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

  Widget _buildPasswordField(BuildContext context) {
    return Obx(
      () => _buildTextField(
        context: context,
        controller: viewModel.passwordController,
        hint: AuthStrings.passwordHint,
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
          if (value == null || value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildConfirmPasswordField(BuildContext context) {
    return Obx(
      () => _buildTextField(
        context: context,
        controller: viewModel.confirmPasswordController,
        hint: AuthStrings.confirmPasswordHint,
        obscureText: viewModel.obscureConfirmPassword.value,
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.obscureConfirmPassword.value
                ? Icons.visibility_off
                : Icons.visibility,
            color: AppColors.textLightPink,
          ),
          onPressed: viewModel.toggleConfirmPasswordVisibility,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Confirm your password';
          }
          if (value != viewModel.passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.responsiveButtonHeight(),
      child: ElevatedButton(
        onPressed: viewModel.onSignUpTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          AuthStrings.signUp,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: context.responsiveFont(16),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.textLightPink.withOpacity(0.4),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveSpacing(6),
          ),
          child: Text(
            AuthStrings.orText,
            style: GoogleFonts.inter(
              color: AppColors.textLightPink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.textLightPink.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: viewModel.model.socialButtons
          .map(
            (social) => _SocialButton(
              assetPath: social.assetPath,
              tooltip: social.tooltip,
              onTap: () => viewModel.onSocialTap(social.tooltip),
            ),
          )
          .toList(),
    );
  }

  Widget _buildLoginRedirect() {
    return Center(
      child: GestureDetector(
        onTap: viewModel.onLoginTap,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: AuthStrings.alreadyHaveAccount,
            style: GoogleFonts.inter(
              color: AppColors.textLightPink,
            ),
            children: [
              TextSpan(
                text: AuthStrings.login,
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
          color: AppColors.textLightPink,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.textLightPink.withOpacity(0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.textLightPink.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.primaryRed,
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
    final double size = context.responsiveImage(60);
    return Semantics(
      button: true,
      label: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size * 0.9,
          height: size * 0.9,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: SvgPicture.asset(
            assetPath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _SignUpLayoutMetrics {
  final double titleSize;
  final double subtitleSize;
  final double spacingLarge;
  final double spacingMedium;
  final double logoHeight;

  final double spacingTop;

  const _SignUpLayoutMetrics({
    required this.titleSize,
    required this.subtitleSize,
    required this.spacingLarge,
    required this.spacingMedium,
    required this.logoHeight,
    required this.spacingTop,
  });

  factory _SignUpLayoutMetrics.fromContext(BuildContext context) {
    return _SignUpLayoutMetrics(
      titleSize: context.responsiveFont(28),
      subtitleSize: context.responsiveFont(15),
      spacingLarge: context.responsiveSpacing(14),
      spacingMedium: context.responsiveSpacing(14),
      spacingTop: context.responsiveSpacing(80),
      logoHeight: context.responsiveImage(200),
    );
  }
}

