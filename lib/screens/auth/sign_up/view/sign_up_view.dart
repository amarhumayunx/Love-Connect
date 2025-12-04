import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/auth/sign_up/view/widgets/sign_up_form_card.dart';
import 'package:love_connect/screens/auth/sign_up/view/widgets/sign_up_layout_metrics.dart';
import 'package:love_connect/screens/auth/sign_up/view/widgets/sign_up_logo.dart';
import 'package:love_connect/screens/auth/sign_up/view_model/sign_up_view_model.dart';

class SignUpView extends StatefulWidget {
  final String? email;
  
  const SignUpView({super.key, this.email});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  late final SignUpViewModel viewModel;

  @override
  void initState() {
    super.initState();
    // Use permanent: false to ensure proper disposal
    viewModel = Get.put(SignUpViewModel(email: widget.email), permanent: false);
  }

  @override
  void dispose() {
    Get.delete<SignUpViewModel>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SignUpLayoutMetrics metrics = SignUpLayoutMetrics.fromContext(
      context,
    );
    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: metrics.spacingTop),
            child: SignUpLogo(height: metrics.logoHeight),
          ),
          SizedBox(height: metrics.spacingLarge),
          SignUpFormCard(viewModel: viewModel, metrics: metrics),
        ],
      ),
    );
  }
}
