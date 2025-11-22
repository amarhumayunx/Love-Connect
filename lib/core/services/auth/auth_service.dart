import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:love_connect/core/models/auth/auth_result.dart';

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
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS configuration: clientId for native sign-in, serverClientId for Firebase Auth
      await _googleSignIn.initialize(
        clientId: '960358609510-uielc1r0poq2as3grlkdm32gpnvfk40u.apps.googleusercontent.com', // iOS Client ID
        serverClientId: '960358609510-uielc1r0poq2as3grlkdm32gpnvfk40u.apps.googleusercontent.com', // Use iOS client ID as serverClientId (ideally should be Web Client ID)
      );
    } else {
      // Android configuration: serverClientId optional if SHA-1 is configured, but recommended
      await _googleSignIn.initialize(
        // serverClientId is optional for Android if SHA-1 is configured in Firebase Console
        // Uncomment below and add your Web Client ID if you have one
        // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
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
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName.trim());
        await userCredential.user?.reload();
      }

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      return AuthResult.success(
        userId: userCredential.user?.uid,
        email: userCredential.user?.email,
        displayName: userCredential.user?.displayName ?? displayName,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'An unexpected error occurred. Please try again.',
        errorCode: 'unknown-error',
      );
    }
  }

  /// Sign in with email and password
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

      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return AuthResult.success(
        userId: userCredential.user?.uid,
        email: userCredential.user?.email,
        displayName: userCredential.user?.displayName,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'An unexpected error occurred. Please try again.',
        errorCode: 'unknown-error',
      );
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
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
      return await _signInToFirebase(credential);
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
    final googleAuth = await googleUser.authentication;
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
  Future<AuthResult> _signInToFirebase(OAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
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
  Future<AuthResult> signUpWithGoogle() async {
    return signInWithGoogle();
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
          await userCredential.user?.reload();
        }
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

  /// Reload user data
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
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
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'The credential is invalid or has expired.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An error occurred. Please try again.';
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

