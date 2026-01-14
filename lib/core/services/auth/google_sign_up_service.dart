import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:love_connect/core/models/auth/auth_result.dart';
import 'package:love_connect/core/services/user_database_service.dart';

/// Service for handling Google Sign Up authentication
/// Follows MVVM pattern - handles only sign up logic
class GoogleSignUpService {
  static final GoogleSignUpService _instance = GoogleSignUpService._internal();
  factory GoogleSignUpService() => _instance;
  GoogleSignUpService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  /// Initialize GoogleSignIn with platform-specific settings
  Future<void> _initializeGoogleSignIn() async {
    // Web client ID from `android/app/google-services.json` (client_type: 3)
    const String androidWebClientId =
        '960358609510-s6k0ntus13ijjq1e4r5eua6s7redc0js.apps.googleusercontent.com';

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _googleSignIn.initialize(
        clientId: '960358609510-uielc1r0poq2as3grlkdm32gpnvfk40u.apps.googleusercontent.com',
        serverClientId: '960358609510-uielc1r0poq2as3grlkdm32gpnvfk40u.apps.googleusercontent.com',
      );
    } else {
      // Android configuration: use Web client ID as serverClientId for Firebase Auth
      await _googleSignIn.initialize(
        serverClientId: androidWebClientId,
      );
    }
  }

  /// Sign up with Google
  /// [skipDatabaseSave] - If true, skips automatic database save (for checking user existence first)
  Future<AuthResult> signUp({bool skipDatabaseSave = false}) async {
    try {
      await _setupGoogleSignIn();
      
      final googleUser = await _authenticateWithGoogle();
      if (googleUser == null) {
        return AuthResult.failure(
          errorMessage: 'Sign up was canceled',
          errorCode: 'sign-up-canceled',
        );
      }

      final credential = await _createFirebaseCredential(googleUser);
      return await _signUpToFirebase(credential, saveToDatabase: !skipDatabaseSave);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return _handleGoogleSignUpError(e);
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
        throw Exception('Sign-up timed out. Please try again.');
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
      throw Exception('Google sign up is not supported on this platform.');
    }

    try {
      await googleSignIn.authenticate(scopeHint: ['email', 'profile']);
    } catch (e) {
      subscription.cancel();
      if (e.toString().contains('canceled') || e.toString().contains('cancelled')) {
        throw Exception('Sign up was canceled');
      }
      throw Exception('Google sign up failed: ${e.toString()}');
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
          throw TimeoutException('Sign-up timed out');
        },
      );
    } catch (e) {
      subscription.cancel();
      if (e is TimeoutException) {
        throw Exception('Sign-up timed out. Please try again.');
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

    // Firebase Auth can work with just idToken, accessToken is optional
    return GoogleAuthProvider.credential(
      idToken: idToken,
    );
  }

  /// Sign up to Firebase with Google credential
  Future<AuthResult> _signUpToFirebase(
    OAuthCredential credential, {
    bool saveToDatabase = true,
  }) async {
    final userCredential = await _auth.signInWithCredential(credential);
    
    // Save user data to database for Google sign-up (if enabled)
    if (saveToDatabase) {
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

  /// Handle Google Sign-Up errors
  AuthResult _handleGoogleSignUpError(dynamic e) {
    String errorMessage = 'Google sign up failed. Please try again.';
    
    if (e.toString().contains('network')) {
      errorMessage = 'Network error. Please check your internet connection.';
    } else if (e.toString().contains('sign_up_canceled') || 
               e.toString().contains('canceled')) {
      return AuthResult.failure(
        errorMessage: 'Sign up was canceled',
        errorCode: 'sign-up-canceled',
      );
    } else if (e.toString().isNotEmpty) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    
    return AuthResult.failure(
      errorMessage: errorMessage,
      errorCode: 'google-sign-up-failed',
    );
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email address. Please sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support for assistance.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email but uses a different sign-in method. Please use the original sign-in method.';
      case 'operation-not-allowed':
        return 'This sign-up method is not enabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a few minutes before trying again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

