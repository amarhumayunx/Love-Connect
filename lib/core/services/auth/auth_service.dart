import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:love_connect/core/models/auth/auth_result.dart';
import 'package:love_connect/core/services/user_database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  Future<void> _initializeGoogleSignIn() async {
    const String androidWebClientId =
        '1047344298062-teer5r32396gsgok09sof5u2asogr97m.apps.googleusercontent.com';

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _googleSignIn.initialize(
        clientId:
            '1047344298062-62d6im3dnt0c68rkgrpbt8tjo5744r1k.apps.googleusercontent.com',
        serverClientId:
            '1047344298062-62d6im3dnt0c68rkgrpbt8tjo5744r1k.apps.googleusercontent.com',
      );
    } else {
      await _googleSignIn.initialize(serverClientId: androidWebClientId);
    }
  }

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  bool get isAuthenticated => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> checkEmailExists(String email) async {
    try {
      if (!_isValidEmail(email)) {
        return false;
      }

      final userDbService = UserDatabaseService();
      return await userDbService.checkUserExistsByEmail(email.trim());
    } catch (e) {
      return false;
    }
  }

  Future<AuthResult> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      if (!_isValidEmail(email)) {
        return AuthResult.failure(
          errorMessage: 'Please enter a valid email address',
          errorCode: 'invalid-email',
        );
      }

      final passwordValidation = _validatePassword(password);
      if (!passwordValidation.isValid) {
        return AuthResult.failure(
          errorMessage: passwordValidation.errorMessage,
          errorCode: 'weak-password',
        );
      }

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName.trim());
        await _safeReloadUser(userCredential.user);
      }

      await userCredential.user?.sendEmailVerification();

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

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      final userId = userCredential.user?.uid;
      final userEmail = userCredential.user?.email;
      if (userId != null && userEmail != null) {
        final userDbService = UserDatabaseService();
        final userExists = await userDbService.checkUserExistsById(userId);
        if (!userExists) {
          await userDbService.saveUserData(
            userId: userId,
            email: userEmail,
            displayName: userCredential.user?.displayName,
            isEmailVerified: userCredential.user?.emailVerified ?? false,
          );
        } else {
          await userDbService.updateEmailVerificationStatus(
            userId: userId,
            isVerified: userCredential.user?.emailVerified ?? false,
          );
        }
      }

      if (userCredential.user == null) {
        return AuthResult.failure(
          errorMessage:
              'Login failed. Please check your credentials and try again.',
          errorCode: 'login-failed',
        );
      }

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
      return await _signInToFirebase(
        credential,
        saveToFirestore: !skipFirestoreSave,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return _handleGoogleSignInError(e);
    }
  }

  Future<void> _setupGoogleSignIn() async {
    final googleSignIn = _googleSignIn;
    await _initializeGoogleSignIn();
    await googleSignIn.signOut();
  }

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

  StreamSubscription<GoogleSignInAuthenticationEvent>
  _setupAuthenticationEventListener(
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
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled')) {
        throw Exception('Sign in was canceled');
      }
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

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

  Future<OAuthCredential> _createFirebaseCredential(
    GoogleSignInAccount googleUser,
  ) async {
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Failed to get authentication token. Please try again.');
    }

    // Firebase Auth can work with just idToken, accessToken is optional
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  Future<AuthResult> _signInToFirebase(
    OAuthCredential credential, {
    bool saveToFirestore = true,
  }) async {
    final userCredential = await _auth.signInWithCredential(credential);

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

  Future<AuthResult> signUpWithGoogle({bool skipFirestoreSave = false}) async {
    return signInWithGoogle(skipFirestoreSave: skipFirestoreSave);
  }

  Future<AuthResult> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final appleCredential = await _getAppleCredential(rawNonce);
      final oauthCredential = _createAppleOAuthCredential(
        appleCredential,
        rawNonce,
      );
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      await _updateAppleDisplayName(appleCredential, userCredential.user);
      await _saveAppleUserData(appleCredential, userCredential.user);

      return AuthResult.success(
        userId: userCredential.user?.uid,
        email: userCredential.user?.email ?? appleCredential.email,
        displayName: userCredential.user?.displayName,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      return AuthResult.failure(
        errorMessage: _getAppleSignInErrorMessage(e.code),
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

  Future<AuthorizationCredentialAppleID> _getAppleCredential(
    String rawNonce,
  ) async {
    final nonce = _sha256ofString(rawNonce);

    return await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
  }

  OAuthCredential _createAppleOAuthCredential(
    AuthorizationCredentialAppleID appleCredential,
    String rawNonce,
  ) {
    return OAuthProvider(
      "apple.com",
    ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);
  }

  Future<void> _updateAppleDisplayName(
    AuthorizationCredentialAppleID appleCredential,
    User? user,
  ) async {
    if (user == null) return;

    final hasName =
        appleCredential.givenName != null || appleCredential.familyName != null;
    if (!hasName) return;

    final displayName =
        '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
            .trim();
    if (displayName.isEmpty) return;

    await user.updateDisplayName(displayName);
    await _safeReloadUser(user);
  }

  Future<void> _saveAppleUserData(
    AuthorizationCredentialAppleID appleCredential,
    User? user,
  ) async {
    final userId = user?.uid;
    final userEmail = user?.email ?? appleCredential.email;
    if (userId == null || userEmail == null) return;

    final userDbService = UserDatabaseService();
    await userDbService.saveUserData(
      userId: userId,
      email: userEmail,
      displayName: user?.displayName,
      isEmailVerified: user?.emailVerified ?? false,
    );
  }

  String _getAppleSignInErrorMessage(AuthorizationErrorCode code) {
    switch (code) {
      case AuthorizationErrorCode.canceled:
        return 'Sign in was canceled';
      case AuthorizationErrorCode.failed:
        return 'Apple sign in failed. Please try again.';
      case AuthorizationErrorCode.invalidResponse:
        return 'Invalid response from Apple. Please try again.';
      case AuthorizationErrorCode.notHandled:
        return 'Apple sign in is not available.';
      case AuthorizationErrorCode.unknown:
        return 'An unknown error occurred. Please try again.';
      default:
        return 'Apple sign in failed';
    }
  }

  Future<AuthResult> signUpWithApple() async {
    return signInWithApple();
  }

  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

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

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> _safeReloadUser(User? user) async {
    if (user == null) return;

    try {
      await user.reload();
    } on FirebaseAuthException catch (e) {
      await _handleFirebaseAuthException(e);
    } catch (e) {
      if (!_isNetworkError(e.toString())) {
        rethrow;
      }
    }
  }

  Future<void> _handleFirebaseAuthException(FirebaseAuthException e) async {
    if (_requiresSignOut(e.code)) {
      await _signOutSafely();
      return;
    }

    if (_isNetworkErrorCode(e.code) && _isNetworkError(e.message ?? '')) {
      return;
    }

    throw e;
  }

  bool _requiresSignOut(String code) {
    return code == 'user-not-found' ||
        code == 'user-disabled' ||
        code == 'invalid-user-token';
  }

  bool _isNetworkErrorCode(String code) {
    return code == 'network-request-failed' ||
        code == 'unknown' ||
        code == 'internal-error';
  }

  bool _isNetworkError(String errorMessage) {
    final lowerMessage = errorMessage.toLowerCase();
    return lowerMessage.contains('connection') ||
        lowerMessage.contains('reset') ||
        lowerMessage.contains('network') ||
        lowerMessage.contains('timeout') ||
        lowerMessage.contains('unreachable') ||
        lowerMessage.contains('interrupted') ||
        lowerMessage.contains('internal error');
  }

  Future<void> _signOutSafely() async {
    try {
      await signOut();
    } catch (_) {}
  }

  Future<void> reloadUser() async {
    await _safeReloadUser(_auth.currentUser);
  }

  Future<AuthResult> deleteUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure(
          errorMessage: 'No user is currently signed in',
          errorCode: 'no-user',
        );
      }

      await user.delete();
      await signOut();

      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        errorMessage: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      return AuthResult.failure(
        errorMessage: 'Failed to delete account. Please try again.',
        errorCode: 'unknown-error',
      );
    }
  }

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

      final passwordValidation = _validatePassword(newPassword);
      if (!passwordValidation.isValid) {
        return AuthResult.failure(
          errorMessage: passwordValidation.errorMessage,
          errorCode: 'weak-password',
        );
      }

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
        return 'Invalid email or password. Please check your credentials and try again.';
      case 'wrong-password':
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

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

class _PasswordValidation {
  final bool isValid;
  final String errorMessage;

  _PasswordValidation({required this.isValid, this.errorMessage = ''});
}
