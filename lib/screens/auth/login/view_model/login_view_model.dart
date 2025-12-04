import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/auth/google_sign_in_service.dart';
import 'package:love_connect/core/services/app_preferences_service.dart';
import 'package:love_connect/core/services/user_database_service.dart';
import 'package:love_connect/screens/auth/common/models/social_button_model.dart';
import 'package:love_connect/screens/auth/forgot_password/view/forgot_password_view.dart';
import 'package:love_connect/screens/auth/login/model/login_model.dart';
import 'package:love_connect/screens/auth/sign_up/view/sign_up_view.dart';
import 'package:love_connect/screens/auth/verification/view/verification_view.dart';
import 'package:love_connect/screens/home/view/main_navigation_view.dart';

import '../../../../core/models/auth/auth_result.dart';

class LoginViewModel extends GetxController {
  final LoginModel model = const LoginModel();
  final AuthService _authService = AuthService();
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  final AppPreferencesService _prefsService = AppPreferencesService();
  final UserDatabaseService _userDbService = UserDatabaseService();
  late final GlobalKey<FormState> formKey;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool rememberMe = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Create a unique key for this form instance to avoid conflicts
    formKey = GlobalKey<FormState>();
    _loadRememberedEmail();
  }

  /// Load remembered email if "Remember Me" was previously checked
  Future<void> _loadRememberedEmail() async {
    final rememberedEmail = await _prefsService.getRememberedEmail();
    final isRememberMeEnabled = await _prefsService.isRememberMeEnabled();
    
    if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
      emailController.text = rememberedEmail;
      rememberMe.value = isRememberMeEnabled;
    }
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
    
    // If user unchecks "Remember Me", clear saved email
    if (!rememberMe.value) {
      _prefsService.clearRememberedEmail();
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> onLoginTap() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final email = emailController.text.trim();
      final password = passwordController.text; // Don't trim password - preserve exact input
      
      // Validate password is not empty
      if (password.isEmpty) {
        SnackbarHelper.showSafe(
          title: 'Login Failed',
          message: 'Password cannot be empty.',
        );
        return;
      }
      
      // Check if user is already signed in - if so, sign out first to allow fresh login
      if (_authService.isAuthenticated) {
        final currentUserEmail = _authService.currentUser?.email?.trim().toLowerCase();
        final inputEmail = email.toLowerCase();
        
        // If same user, allow them to continue (they're already logged in)
        if (currentUserEmail == inputEmail) {
          // User is already logged in with this email - proceed to check verification
          await _authService.reloadUser();
          final isVerified = _authService.isEmailVerified;
          
          // Update verification status in database
          final userId = _authService.currentUserId;
          if (userId != null) {
            await _userDbService.updateEmailVerificationStatus(
              userId: userId,
              isVerified: isVerified,
            );
          }
          
          if (!isVerified) {
            // Send verification email
            await _authService.resendEmailVerification();
            
            // Navigate to verification screen
            SmoothNavigator.offAll(
              () => VerificationView(email: email),
              transition: Transition.fadeIn,
              duration: SmoothNavigator.slowDuration,
            );
          } else {
            // Navigate to home screen
            SmoothNavigator.offAll(
              () => const MainNavigationView(),
              transition: Transition.fadeIn,
              duration: SmoothNavigator.slowDuration,
            );
          }
          return;
        } else {
          // Different user is signed in - sign out first
          await _authService.signOut();
        }
      }
      
      // Attempt to sign in - Firebase will handle authentication
      // If user doesn't exist, we'll get 'user-not-found' error
      final result = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (result.success) {
        // Account exists and login successful
        // Save email if "Remember Me" is checked
        if (rememberMe.value) {
          await _prefsService.saveRememberedEmail(email);
        } else {
          // Clear saved email if "Remember Me" is unchecked
          await _prefsService.clearRememberedEmail();
        }
        
        // Check if email is verified
        await _authService.reloadUser();
        final isVerified = _authService.isEmailVerified;
        
        // Update verification status in database
        final userId = _authService.currentUserId;
        if (userId != null) {
          await _userDbService.updateEmailVerificationStatus(
            userId: userId,
            isVerified: isVerified,
          );
        }
        
        if (!isVerified) {
          // Send verification email
          await _authService.resendEmailVerification();
          
          // Navigate to verification screen
          SmoothNavigator.offAll(
            () => VerificationView(email: email),
            transition: Transition.fadeIn,
            duration: SmoothNavigator.slowDuration,
          );
        } else {
          // Navigate to home screen with navbar after successful login
          SmoothNavigator.offAll(
            () => const MainNavigationView(),
            transition: Transition.fadeIn,
            duration: SmoothNavigator.slowDuration,
          );
        }
      } else {
        // Handle authentication failures
        String errorMessage = result.errorMessage ?? 'Invalid email or password. Please check your credentials and try again.';
        
        // Handle specific cases
        if (result.errorCode == 'user-not-found') {
          // User doesn't exist - redirect to sign up
          SnackbarHelper.showSafe(
            title: 'Account Not Found',
            message: 'No account found with this email. Please create an account first.',
            duration: const Duration(seconds: 4),
          );
          
          // Navigate to sign up screen with email pre-filled
          SmoothNavigator.to(
            () => SignUpView(email: email),
            transition: Transition.cupertino,
            duration: SmoothNavigator.extraSlowDuration,
            curve: SmoothNavigator.smoothCurve,
          );
          return;
        } else if (result.errorCode == 'user-disabled') {
          errorMessage = 'This account has been disabled. Please contact support.';
        } else if (result.errorCode == 'too-many-requests') {
          errorMessage = 'Too many failed attempts. Please try again later.';
        } else if (result.errorCode == 'network-request-failed') {
          errorMessage = 'Network error. Please check your internet connection and try again.';
        } else if (result.errorCode == 'wrong-password' || result.errorCode == 'invalid-credential') {
          // For security, use generic message
          errorMessage = 'Invalid email or password. Please check your credentials and try again.';
        }
        
        SnackbarHelper.showSafe(
          title: 'Login Failed',
          message: errorMessage,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onForgotPasswordTap() {
    SmoothNavigator.to(
      () => const ForgotPasswordView(),
      transition: Transition.downToUp,
    );
  }

  Future<void> onSocialTap(SocialButtonModel provider) async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      AuthResult result;

      switch (provider.type) {
        case SocialButtonType.google:
          // Skip database save initially to check if user exists first
          result = await _googleSignInService.signIn(skipDatabaseSave: true);
          break;
        case SocialButtonType.apple:
          result = await _authService.signInWithApple();
          break;
        default:
          SnackbarHelper.showSafe(
            title: provider.tooltip,
            message: AuthStrings.featurePending,
          );
          return;
      }

      if (result.success) {
        // Reload user to get latest data
        await _authService.reloadUser();
        final userEmail = _authService.currentUser?.email;
        final userId = _authService.currentUserId;

        if (userEmail == null) {
          // Email is required, sign out and show error
          await _authService.signOut();
          SnackbarHelper.showSafe(
            title: 'Sign In Failed',
            message: 'Unable to retrieve email address. Please try again.',
          );
          return;
        }

        // Check if user exists in database
        // If user doesn't exist in database, it means this is a new account
        // and they should complete sign-up first
        final userExistsInDb = await _userDbService.checkUserExistsById(userId ?? '');

        if (!userExistsInDb) {
          // New account - user signed in with Google but hasn't completed sign-up
          // Sign out and redirect to sign-up to complete registration
          await _authService.signOut();
          
          SnackbarHelper.showSafe(
            title: 'Account Not Found',
            message: 'Please complete your account registration first.',
            duration: const Duration(seconds: 4),
          );
          
          // Navigate to sign-up screen with email pre-filled
          SmoothNavigator.to(
            () => SignUpView(email: userEmail),
            transition: Transition.cupertino,
            duration: SmoothNavigator.extraSlowDuration,
            curve: SmoothNavigator.smoothCurve,
          );
          return;
        }

        // User exists in database - this is a valid login
        // Ensure data is synced and up-to-date
        if (userId != null) {
          final currentUser = _authService.currentUser;
          // Update user data to ensure it's current
          await _userDbService.saveUserData(
            userId: userId,
            email: userEmail,
            displayName: currentUser?.displayName,
            isEmailVerified: currentUser?.emailVerified ?? false,
          );
        }

        // Check email verification status
        final isVerified = _authService.isEmailVerified;

        // Update verification status in database
        if (userId != null) {
          await _userDbService.updateEmailVerificationStatus(
            userId: userId,
            isVerified: isVerified,
          );
        }

        if (!isVerified) {
          // Account exists but not verified, send verification email and navigate to verification screen
          await _authService.resendEmailVerification();
          
          SmoothNavigator.offAll(
            () => VerificationView(email: userEmail),
            transition: Transition.fadeIn,
            duration: SmoothNavigator.slowDuration,
          );
        } else {
          // Navigate to home screen with navbar after successful login
          SmoothNavigator.offAll(
            () => const MainNavigationView(),
            transition: Transition.fadeIn,
            duration: SmoothNavigator.slowDuration,
          );
        }
      } else {
        // Only show error if user didn't cancel
        if (result.errorCode != 'sign-in-canceled') {
          SnackbarHelper.showSafe(
            title: '${provider.tooltip} Failed',
            message: result.errorMessage ?? 'An error occurred. Please try again.',
          );
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onSignUpTap() {
    SmoothNavigator.to(
      () => const SignUpView(),
      transition: Transition.cupertino,
      duration: SmoothNavigator.extraSlowDuration,
      curve: SmoothNavigator.smoothCurve,
    );
  }

}
