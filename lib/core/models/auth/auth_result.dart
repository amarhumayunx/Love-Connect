/// Result class for authentication operations
class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? errorCode;
  final String? userId;
  final String? email;
  final String? displayName;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.errorCode,
    this.userId,
    this.email,
    this.displayName,
  });

  factory AuthResult.success({
    String? userId,
    String? email,
    String? displayName,
  }) {
    return AuthResult(
      success: true,
      userId: userId,
      email: email,
      displayName: displayName,
    );
  }

  factory AuthResult.failure({
    required String errorMessage,
    String? errorCode,
  }) {
    return AuthResult(
      success: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }
}

