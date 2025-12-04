import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/auth/login/view/widgets/login_form_card.dart';
import 'package:love_connect/screens/auth/login/view/widgets/login_layout_metrics.dart';
import 'package:love_connect/screens/auth/login/view/widgets/login_logo.dart';
import 'package:love_connect/screens/auth/login/view_model/login_view_model.dart';

class LoginView extends StatefulWidget {
  final String? email;
  
  const LoginView({super.key, this.email});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel viewModel;

  @override
  void initState() {
    super.initState();
    // Use permanent: false to ensure proper disposal
    viewModel = Get.put(LoginViewModel(), permanent: false);
    // Pre-fill email if provided
    if (widget.email != null && widget.email!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.emailController.text = widget.email!;
      });
    }
  }

  @override
  void dispose() {
    Get.delete<LoginViewModel>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LoginLayoutMetrics metrics = LoginLayoutMetrics.fromContext(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: metrics.spacingTop),
            child: LoginLogo(height: metrics.logoHeight),
          ),
          SizedBox(height: metrics.spacingLarge),
          LoginFormCard(viewModel: viewModel, metrics: metrics),
        ],
      ),
    );
  }
}
