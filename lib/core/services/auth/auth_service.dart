import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:love_connect/core/models/auth/auth_result.dart';
import 'package:love_connect/core/services/user_database_service.dart';

/// Authentication service for handling all authentication methods
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // GoogleSignIn 7.0+ uses singleton pattern - GoogleSignIn.instance
  // Configuration is done through initialize() method
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;
  
  // Initialize GoogleSignIn with platform-specific settings
  Future<void> _initializeGoogleSignIn() async {
    // Web client ID from `android/app/google-services.json` (client_type: 3)
    const String androidWebClientId =
        '960358609510-s6k0ntus13ijjq1e4r5eua6s7redc0js.apps.googleusercontent.com';

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS configuration: clientId for native sign-in, serverClientId for Firebase Auth
      await _googleSignIn.initialize(
        clientId: '960358609510-uielc1r0poq2as3grlkdm32gpnvfk40u.apps.googleusercontent.com', // iOS Client ID
        serverClientId: '960358609510-uielc1r0poq2as3grlkdm32gpnvfk40u.apps.googleusercontent.com', // Use iOS client ID as serverClientId (ideally should be Web Client ID)
      );
    } else {
      // Android configuration: use Web client ID as serverClientId for Firebase Auth
      await _googleSignIn.initialize(
        serverClientId: androidWebClientId,
      );
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if an email exists in Firebase Auth by checking the database
  /// This is a workaround since fetchSignInMethodsForEmail is not available in Flutter
  /// We check the database which should be in sync with Firebase Auth
  Future<bool> checkEmailExists(String email) async {
    try {
      if (!_isValidEmail(email)) {
        return false;
      }

      // Check database for user existence
      // The database should be in sync with Firebase Auth
      final userDbService = UserDatabaseService();
      return await userDbService.checkUserExistsByEmail(email.trim());
    } catch (e) {
      // On any error, return false to be safe
      return false;
    }
  }

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        return AuthResult.failure(
          errorMessage: 'Please enter a valid email address',
          errorCode: 'invalid-email',
        );
      }

      // Validate password strength
      final passwordValidation = _validatePassword(password);
      if (!passwordValidation.isValid) {
        return AuthResult.failure(
          errorMessage: passwordValidation.errorMessage,
          errorCode: 'weak-password',
        );
      }

      // Create user account
      // Note: password should not be trimmed - preserve exact user input
      // Email is trimmed but case is preserved (Firebase Auth handles case-insensitivity)
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName.trim());
        await _safeReloadUser(userCredential.user);
      }

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Save user data to Firestore database
      final userId = userCredential.user?.uid;
      final userEmail = userCredential.user?.email;
      if (userId != null && userEmail != null) {
        final userDbService = UserDatabaseService();
        await userDbService.saveUserData(
          userId: userId,
          email: userEmail,
          displayName: displayName ?? userCredential.user?.displayName,
          isEmailVerified: false,
        );
      }

      // Verify account was created successfully
      if (userCredential.user == null) {
        return AuthResult.failure(
          errorMessage: 'Account creation failed. Please try again.',
          errorCode: 'account-creation-failed',
        );
      }

      return AuthResult.success(
        userId: userCredential.user?.uid,
        email: userCredential.user?.email,
        displayName: userCredential.user?.displayName ?? displayName,
      );
    } on FirebaseAuthException catch (e) {
      // Log the error for debugging
      print('Sign up error: ${e.code} - ${e.message}');
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      // Log unexpected errors
      print('Unexpected sign up error: $e');
      return AuthResult.failure(
        errorMessage: 'An unexpected error occurred. Please try again.',
        errorCode: 'unknown-error',
      );
    }
  }

  /// Sign in with email and password
  /// This method handles authentication and ensures database sync
  Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (!_isValidEmail(email)) {
        return AuthResult.failure(
          errorMessage: 'Please enter a valid email address',
          errorCode: 'invalid-email',
        );
      }

      // Note: password should not be trimmed - preserve exact user input
      // Email is trimmed but case is preserved (Firebase Auth handles case-insensitivity)
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Ensure user data is synced to database after successful login
      final userId = userCredential.user?.uid;
      final userEmail = userCredential.user?.email;
      if (userId != null && userEmail != null) {
        final userDbService = UserDatabaseService();
        // Check if user exists in database, if not, create it
        final userExists = await userDbService.checkUserExistsById(userId);
        if (!userExists) {
          // User exists in Firebase Auth but not in database - sync it
          await userDbService.saveUserData(
            userId: userId,
            email: userEmail,
            displayName: userCredential.user?.displayName,
            isEmailVerified: userCredential.user?.emailVerified ?? false,
          );
        } else {
          // Update verification status if needed
          await userDbService.updateEmailVerificationStatus(
            userId: userId,
            isVerified: userCredential.user?.emailVerified ?? false,
          );
        }
      }

      // Verify login was successful
      if (userCredential.user == null) {
        return AuthResult.failure(
          errorMessage: 'Login failed. Please check your credentials and try again.',
          errorCode: 'login-failed',
        );
      }

      return AuthResult.success(
        userId: userCredential.user?.uid,
        email: userCredential.user?.email,
        displayName: userCredential.user?.displayName,
      );
    } on FirebaseAuthException catch (e) {
      // Log the error for debugging
      print('Sign in error: ${e.code} - ${e.message}');
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      // Log unexpected errors
      print('Unexpected sign in error: $e');
      return AuthResult.failure(
        errorMessage: 'An unexpected error occurred. Please try again.',
        errorCode: 'unknown-error',
      );
    }
  }

  /// Sign in with Google
  /// [skipFirestoreSave] - If true, skips automatic Firestore save (for checking user existence first)
  Future<AuthResult> signInWithGoogle({bool skipFirestoreSave = false}) async {
    try {
      await _setupGoogleSignIn();
      
      final googleUser = await _authenticateWithGoogle();
      if (googleUser == null) {
        return AuthResult.failure(
          errorMessage: 'Sign in was canceled',
          errorCode: 'sign-in-canceled',
        );
      }

      final credential = await _createFirebaseCredential(googleUser);
      return await _signInToFirebase(credential, saveToFirestore: !skipFirestoreSave);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return _handleGoogleSignInError(e);
    }
  }

  /// Setup and initialize GoogleSignIn
  Future<void> _setupGoogleSignIn() async {
    final googleSignIn = _googleSignIn;
    await _initializeGoogleSignIn();
    await googleSignIn.signOut();
  }

  /// Authenticate with Google using event-based API (version 7.0+)
  Future<GoogleSignInAccount?> _authenticateWithGoogle() async {
    final googleSignIn = _googleSignIn;
    GoogleSignInAccount? googleUser;
    final completer = Completer<void>();

    final subscription = _setupAuthenticationEventListener(
      googleSignIn,
      completer,
      (user) => googleUser = user,
    );

    try {
      await _triggerAuthentication(googleSignIn, subscription);
      await _waitForAuthentication(completer, subscription);
    } catch (e) {
      subscription.cancel();
      if (e is TimeoutException) {
        throw Exception('Sign-in timed out. Please try again.');
      }
      rethrow;
    } finally {
      subscription.cancel();
    }

    return googleUser;
  }

  /// Setup authentication event listener
  StreamSubscription<GoogleSignInAuthenticationEvent> _setupAuthenticationEventListener(
    GoogleSignIn googleSignIn,
    Completer<void> completer,
    void Function(GoogleSignInAccount) onSignIn,
  ) {
    return googleSignIn.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        onSignIn(event.user);
        if (!completer.isCompleted) completer.complete();
      } else if (event is GoogleSignInAuthenticationEventSignOut) {
        if (!completer.isCompleted) completer.complete();
      }
    });
  }

  /// Trigger Google authentication
  Future<void> _triggerAuthentication(
    GoogleSignIn googleSignIn,
    StreamSubscription subscription,
  ) async {
    if (!googleSignIn.supportsAuthenticate()) {
      subscription.cancel();
      throw Exception('Google sign in is not supported on this platform.');
    }

    try {
      await googleSignIn.authenticate(scopeHint: ['email', 'profile']);
    } catch (e) {
      subscription.cancel();
      if (e.toString().contains('canceled') || e.toString().contains('cancelled')) {
        throw Exception('Sign in was canceled');
      }
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  /// Wait for authentication event with timeout
  Future<void> _waitForAuthentication(
    Completer<void> completer,
    StreamSubscription subscription,
  ) async {
    try {
      await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          subscription.cancel();
          throw TimeoutException('Sign-in timed out');
        },
      );
    } catch (e) {
      subscription.cancel();
      if (e is TimeoutException) {
        throw Exception('Sign-in timed out. Please try again.');
      }
      rethrow;
    }
  }

  /// Create Firebase credential from Google authentication
  Future<OAuthCredential> _createFirebaseCredential(
    GoogleSignInAccount googleUser,
  ) async {
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Failed to get authentication token. Please try again.');
    }

    return GoogleAuthProvider.credential(
      accessToken: null, // accessToken is optional when idToken is present
      idToken: idToken,
    );
  }

  /// Sign in to Firebase with Google credential
  Future<AuthResult> _signInToFirebase(OAuthCredential credential, {bool saveToFirestore = true}) async {
    final userCredential = await _auth.signInWithCredential(credential);
    
    // Save/update user data to Firestore database for social sign-ins (if enabled)
    if (saveToFirestore) {
      final userId = userCredential.user?.uid;
      final userEmail = userCredential.user?.email;
      if (userId != null && userEmail != null) {
        final userDbService = UserDatabaseService();
        await userDbService.saveUserData(
          userId: userId,
          email: userEmail,
          displayName: userCredential.user?.displayName,
          isEmailVerified: userCredential.user?.emailVerified ?? false,
        );
      }
    }
    
    return AuthResult.success(
      userId: userCredential.user?.uid,
      email: userCredential.user?.email,
      displayName: userCredential.user?.displayName,
    );
  }

  /// Handle Google Sign-In errors
  AuthResult _handleGoogleSignInError(dynamic e) {
    String errorMessage = 'Google sign in failed. Please try again.';
    
    if (e.toString().contains('network')) {
      errorMessage = 'Network error. Please check your internet connection.';
    } else if (e.toString().contains('sign_in_canceled') || 
               e.toString().contains('canceled')) {
      return AuthResult.failure(
        errorMessage: 'Sign in was canceled',
        errorCode: 'sign-in-canceled',
      );
    } else if (e.toString().isNotEmpty) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    
    return AuthResult.failure(
      errorMessage: errorMessage,
      errorCode: 'google-sign-in-failed',
    );
  }

  /// Sign up with Google (same as sign in, but creates account if doesn't exist)
  /// [skipFirestoreSave] - If true, skips automatic Firestore save (for checking user existence first)
  Future<AuthResult> signUpWithGoogle({bool skipFirestoreSave = false}) async {
    return signInWithGoogle(skipFirestoreSave: skipFirestoreSave);
  }

  /// Sign in with Apple
  Future<AuthResult> signInWithApple() async {
    try {
      // Generate a random nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in to Firebase with the Apple credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);

      // If display name is available from Apple, update it
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (displayName.isNotEmpty) {
          await userCredential.user?.updateDisplayName(displayName);
          await _safeReloadUser(userCredential.user);
        }
      }

      // Save/update user data to Firestore database for Apple sign-in
      final userId = userCredential.user?.uid;
      final userEmail = userCredential.user?.email ?? appleCredential.email;
      if (userId != null && userEmail != null) {
        final userDbService = UserDatabaseService();
        await userDbService.saveUserData(
          userId: userId,
          email: userEmail,
          displayName: userCredential.user?.displayName,
          isEmailVerified: userCredential.user?.emailVerified ?? false,
        );
      }

      return AuthResult.success(
        userId: userCredential.user?.uid,
        email: userCredential.user?.email ?? appleCredential.email,
        displayName: userCredential.user?.displayName,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      String errorMessage = 'Apple sign in failed';
      if (e.code == AuthorizationErrorCode.canceled) {
        errorMessage = 'Sign in was canceled';
      } else if (e.code == AuthorizationErrorCode.failed) {
        errorMessage = 'Apple sign in failed. Please try again.';
      } else if (e.code == AuthorizationErrorCode.invalidResponse) {
        errorMessage = 'Invalid response from Apple. Please try again.';
      } else if (e.code == AuthorizationErrorCode.notHandled) {
        errorMessage = 'Apple sign in is not available.';
      } else if (e.code == AuthorizationErrorCode.unknown) {
        errorMessage = 'An unknown error occurred. Please try again.';
      }

      return AuthResult.failure(
        errorMessage: errorMessage,
        errorCode: e.code.toString(),
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'Apple sign in failed. Please try again.',
        errorCode: 'apple-sign-in-failed',
      );
    }
  }

  /// Sign up with Apple (same as sign in)
  Future<AuthResult> signUpWithApple() async {
    return signInWithApple();
  }

  /// Sign out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      if (!_isValidEmail(email)) {
        return AuthResult.failure(
          errorMessage: 'Please enter a valid email address',
          errorCode: 'invalid-email',
        );
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'Failed to send password reset email. Please try again.',
        errorCode: 'unknown-error',
      );
    }
  }

  /// Resend email verification
  Future<AuthResult> resendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure(
          errorMessage: 'No user is currently signed in',
          errorCode: 'no-user',
        );
      }

      await user.sendEmailVerification();
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'Failed to send verification email. Please try again.',
        errorCode: 'unknown-error',
      );
    }
  }

  /// Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Safely reload user data, handling iOS network errors gracefully
  /// Safely reload user data, handling network errors gracefully
  /// Network errors are common and can be safely ignored - cached user data is still valid
  /// If user-not-found error occurs, the user is signed out automatically
  Future<void> _safeReloadUser(User? user) async {
    if (user == null) return;
    
    try {
      await user.reload();
    } on FirebaseAuthException catch (e) {
      // Handle user-not-found error - user was deleted from Firebase
      if (e.code == 'user-not-found') {
        // Sign out the user since they no longer exist
        try {
          await signOut();
        } catch (_) {
          // Ignore errors during sign out
        }
        // Silently return - user will be treated as not authenticated
        return;
      }
      
      // Handle network-related errors - can be safely ignored
      // Cached user data is still valid and can be used
      if (e.code == 'network-request-failed' || 
          e.code == 'unknown' ||
          e.code == 'internal-error') {
        // Check if it's a network/connection error
        final errorMessage = e.message?.toLowerCase() ?? '';
        if (errorMessage.contains('connection') ||
            errorMessage.contains('reset') ||
            errorMessage.contains('network') ||
            errorMessage.contains('timeout') ||
            errorMessage.contains('unreachable')) {
          // Silently handle network errors - cached user data is still valid
          return;
        }
      }
      
      // Handle other common errors that can occur
      if (e.code == 'user-disabled' || e.code == 'invalid-user-token') {
        try {
          await signOut();
        } catch (_) {
          // Ignore errors during sign out
        }
        return;
      }
      
      // Re-throw other FirebaseAuthExceptions that we don't handle
      rethrow;
    } catch (e) {
      // Handle any other exceptions, especially network-related ones
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('connection') ||
          errorString.contains('reset') ||
          errorString.contains('network') || 
          errorString.contains('timeout') || 
          errorString.contains('unreachable') ||
          errorString.contains('interrupted') ||
          errorString.contains('internal error')) {
        // Silently handle network/connection errors - cached user data is still valid
        return;
      }
      // Re-throw for non-network errors
      rethrow;
    }
  }

  /// Reload user data
  /// On iOS, network errors are handled gracefully to prevent app crashes
  Future<void> reloadUser() async {
    await _safeReloadUser(_auth.currentUser);
  }

  /// Change password for authenticated user
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure(
          errorMessage: 'No user is currently signed in',
          errorCode: 'no-user',
        );
      }

      // Validate new password strength
      final passwordValidation = _validatePassword(newPassword);
      if (!passwordValidation.isValid) {
        return AuthResult.failure(
          errorMessage: passwordValidation.errorMessage,
          errorCode: 'weak-password',
        );
      }

      // Re-authenticate user with current password
      final email = user.email;
      if (email == null) {
        return AuthResult.failure(
          errorMessage: 'User email not found',
          errorCode: 'no-email',
        );
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'Failed to change password. Please try again.',
        errorCode: 'unknown-error',
      );
    }
  }

  // Private helper methods

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }

  _PasswordValidation _validatePassword(String password) {
    if (password.length < 8) {
      return _PasswordValidation(
        isValid: false,
        errorMessage: 'Password must be at least 8 characters long',
      );
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return _PasswordValidation(
        isValid: false,
        errorMessage: 'Password must contain at least one uppercase letter',
      );
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return _PasswordValidation(
        isValid: false,
        errorMessage: 'Password must contain at least one lowercase letter',
      );
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return _PasswordValidation(
        isValid: false,
        errorMessage: 'Password must contain at least one number',
      );
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return _PasswordValidation(
        isValid: false,
        errorMessage: 'Password must contain at least one special character',
      );
    }

    return _PasswordValidation(isValid: true);
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak. Please use at least 8 characters with uppercase, lowercase, numbers, and special characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email address. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support for assistance.';
      case 'user-not-found':
        // For security, don't reveal if email exists or not
        return 'Invalid email or password. Please check your credentials and try again.';
      case 'wrong-password':
        // For security, don't reveal if email exists or not
        return 'Invalid email or password. Please check your credentials and try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials and try again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email but uses a different sign-in method. Please use the original sign-in method.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a few minutes before trying again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'requires-recent-login':
        return 'For security, please sign out and sign in again to perform this action.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please check and try again.';
      case 'invalid-verification-id':
        return 'Verification session expired. Please try again.';
      case 'session-expired':
        return 'Your session has expired. Please sign in again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

class _PasswordValidation {
  final bool isValid;
  final String errorMessage;

  _PasswordValidation({
    required this.isValid,
    this.errorMessage = '',
  });
}

