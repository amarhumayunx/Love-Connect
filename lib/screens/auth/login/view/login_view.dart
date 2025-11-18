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
    final double titleSize = context.responsiveFont(28);
    final double subtitleSize = context.responsiveFont(15);
    final double spacingLarge = context.responsiveSpacing(14);
    final double spacingMedium = context.responsiveSpacing(14);
    final double spacingSmall = context.responsiveSpacing(12);
    final double spacingTop = context.responsiveSpacing(30);
    final double logoHeight = context.responsiveImage(200);


    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: spacingTop),
              child: Image.asset(
                AppStrings.heart_logo_strings,
                height: logoHeight,
              ),
            ),
            SizedBox(height: spacingLarge),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                    top: spacingMedium,
                    right: spacingMedium,
                    left: spacingMedium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Form(
                  key: viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisSize: .min,
                    children: [
                      Text(
                        viewModel.model.title,
                        style: GoogleFonts.inter(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDarkPink,
                        ),
                      ),
                      SizedBox(height: spacingSmall),
                      Text(
                        viewModel.model.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: subtitleSize,
                          color: AppColors.textLightPink,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: spacingLarge),
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
                      SizedBox(height: spacingMedium),
                      Obx(
                        () => _buildTextField(
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
                      ),
                      SizedBox(height: spacingMedium),
                      Row(
                        children: [
                          Obx(
                            () => Checkbox(
                              value: viewModel.rememberMe.value,
                              activeColor: AppColors.primaryRed,
                              onChanged: viewModel.toggleRememberMe,
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
                                fontSize:
                                    context.responsiveFont(13),
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
                      ),
                      SizedBox(height: spacingMedium),
                      SizedBox(
                        width: double.infinity,
                        height: context.responsiveButtonHeight(),
                        child: ElevatedButton(
                          onPressed: viewModel.onLoginTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            AuthStrings.login,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize:
                                  context.responsiveFont(16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: spacingMedium),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.textLightPink.withOpacity(0.4),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacingSmall,
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
                      ),
                      SizedBox(height: spacingMedium),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: viewModel.model.socialButtons
                            .map(
                              (social) => _SocialButton(
                                assetPath: social.assetPath,
                                tooltip: social.tooltip,
                                onTap: () => viewModel.onSocialTap(
                                  social.tooltip,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: spacingLarge),
                      Center(
                        child: GestureDetector(
                          onTap: viewModel.onSignUpTap,
                          child: RichText(
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

