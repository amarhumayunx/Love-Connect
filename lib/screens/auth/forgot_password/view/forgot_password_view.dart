import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/auth/forgot_password/view_model/forgot_password_view_model.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final ForgotPasswordViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(ForgotPasswordViewModel());
  }

  @override
  void dispose() {
    Get.delete<ForgotPasswordViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    // Responsive padding and spacing
    final double horizontalPadding = screenWidth * 0.05; // 6% of width
    final double topPadding = screenHeight * 0.01; // 2% of height
    final double spacingLarge = screenHeight * 0.032; // 3.5% of height
    final double spacingMedium = screenHeight * 0.020; // 2.2% of height
    final double spacingSmall = screenHeight * 0.010; // 1.2% of height

    // Responsive font sizes
    final double titleFontSize = screenWidth * 0.075; // 6.5% of width
    final double subtitleFontSize = screenWidth * 0.036; // 3.8% of width
    final double buttonFontSize = screenWidth * 0.042; // 4.2% of width
    final double hintFontSize = screenWidth * 0.037; // 3.7% of width

    // Responsive image height (max 25% of screen height)
    final double imageHeight = (screenHeight * 0.25).clamp(180.0, 250.0);

    // Responsive button height
    final double buttonHeight = (screenHeight * 0.065).clamp(50.0, 65.0);

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: topPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        IconButton(
                          onPressed: Get.back,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                          ),
                          color: AppColors.backArrow,
                        ),

                        SizedBox(height: spacingLarge),

                        // Title
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Forgot password',
                                style: GoogleFonts.inter(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDarkPink,
                                  height: 1.2,
                                ),
                              ),

                              SizedBox(height: spacingSmall),

                              // Subtitle
                              Text(
                                'Enter your email for reset password',
                                style: GoogleFonts.inter(
                                  fontSize: subtitleFontSize,
                                  color: AppColors.textLightPink,
                                  fontWeight: FontWeight.w400,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: spacingLarge * 0.2),

                        // Illustration
                        Center(
                          child: Image.asset(
                            AuthStrings.forgotPasswordIllustration,
                            height: imageHeight,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: spacingLarge * 0.7),

                        // Form
                        Form(
                          key: viewModel.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email label
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Email',
                                  style: GoogleFonts.inter(
                                    fontSize: hintFontSize,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textDarkPink,
                                  ),
                                ),
                              ),

                              // Email input field
                              TextFormField(
                                controller: viewModel.emailController,
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: AppColors.textFieldBorder,
                                style: GoogleFonts.inter(
                                  fontSize: hintFontSize,
                                  color: AppColors.textDarkPink,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!GetUtils.isEmail(value)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: hintFontSize,
                                    color: AppColors.textLightPink.withOpacity(0.6),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.045,
                                    vertical: screenHeight * 0.02,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.textFieldBorder,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.textFieldBorder,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.textFieldBorder,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.textFieldBorder,
                                      width: 1,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.textFieldBorder,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: spacingLarge),

                              // Send code button
                              SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: ElevatedButton(
                                  onPressed: viewModel.onSendCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryRed,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Send code',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: buttonFontSize,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Add flexible space at bottom to prevent overflow
                        SizedBox(height: spacingLarge),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}