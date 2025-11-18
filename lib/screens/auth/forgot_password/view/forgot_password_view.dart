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
    final double horizontalPadding = context.widthPct(6);
    final double spacingLarge = context.responsiveSpacing(30);
    final double spacingMedium = context.responsiveSpacing(18);
    final double spacingSmall = context.responsiveSpacing(10);

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: spacingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: AppColors.primaryRed,
                ),
                SizedBox(height: spacingMedium),
                Text(
                  viewModel.model.title,
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(28),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDarkPink,
                  ),
                ),
                SizedBox(height: spacingSmall),
                Text(
                  viewModel.model.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(15),
                    color: AppColors.textLightPink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: spacingLarge),
                Center(
                  child: SvgPicture.asset(
                    AuthStrings.forgotPasswordIllustration,
                    height: context.responsiveImage(220),
                  ),
                ),
                SizedBox(height: spacingLarge),
                Form(
                  key: viewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: viewModel.emailController,
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
                        decoration: InputDecoration(
                          hintText: AuthStrings.emailHint,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
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
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: spacingMedium),
                      SizedBox(
                        width: double.infinity,
                        height: context.responsiveButtonHeight(),
                        child: ElevatedButton(
                          onPressed: viewModel.onSendCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            AuthStrings.sendCode,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: context.responsiveFont(16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

