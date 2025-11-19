import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/auth/login/view/widgets/login_form_card.dart';
import 'package:love_connect/screens/auth/login/view/widgets/login_layout_metrics.dart';
import 'package:love_connect/screens/auth/login/view/widgets/login_logo.dart';
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
