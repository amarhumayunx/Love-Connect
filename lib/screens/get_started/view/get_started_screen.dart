import 'package:flutter/material.dart';
import 'package:love_connect/core/strings/get_started_screens_app_strings.dart';
import '../view_model/get_started_view_model.dart';
import 'package:google_fonts/google_fonts.dart';


class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final viewModel = GetStartedViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFD6D6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    AppStrings.app_logo_strings,
                    width: 170,
                    height: 67,
                  ),
                ],
              ),

              Center(
                child:
                Image.asset(
                    AppStrings.heart_logo_strings,
                ),
              ),

              const SizedBox(height: 35),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    viewModel.data.title,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF96435D),
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    viewModel.data.subtitle,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: GoogleFonts.inter().fontFamily,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFD892A1),
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100),

              Center(
                child: SizedBox(
                  width: 220,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: viewModel.onGetStartedClick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5364B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      AppStrings.getStarted,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
