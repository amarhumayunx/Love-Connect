import 'package:firebase_database/firebase_database.dart';

/// Service for managing user data in Firebase Realtime Database
class UserDatabaseService {
  static final UserDatabaseService _instance = UserDatabaseService._internal();
  factory UserDatabaseService() => _instance;
  UserDatabaseService._internal();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const String _usersPath = 'users';
  static const String _usersByEmailPath = 'usersByEmail';

  /// Get reference to users node
  DatabaseReference get _usersRef => _database.ref(_usersPath);

  /// Get reference to usersByEmail node (for email-based queries)
  DatabaseReference get _usersByEmailRef => _database.ref(_usersByEmailPath);

  /// Check if a user exists in the database by email
  /// Returns true if user exists, false otherwise
  /// Returns false on error to allow fallback to auth check
  Future<bool> checkUserExistsByEmail(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final snapshot = await _usersByEmailRef
          .child(normalizedEmail)
          .get();

      return snapshot.exists;
    } catch (e) {
      // Handle Realtime Database API not enabled or other errors
      // Log error but don't throw - allow fallback to auth check
      print('Realtime Database checkUserExistsByEmail error: $e');
      // If Realtime Database API is not enabled, return false to fallback to auth check
      return false;
    }
  }

  /// Check if a user exists in the database by user ID
  /// Returns true if user exists, false otherwise
  Future<bool> checkUserExistsById(String userId) async {
    try {
      final snapshot = await _usersRef
          .child(userId)
          .get();

      return snapshot.exists;
    } catch (e) {
      // If there's an error, return false to allow fallback to auth check
      print('Realtime Database checkUserExistsById error: $e');
      return false;
    }
  }

  /// Save user data to Realtime Database
  /// This should be called after successful account creation
  /// Returns false if Realtime Database API is not enabled or other errors occur
  Future<bool> saveUserData({
    required String userId,
    required String email,
    String? displayName,
    DateTime? createdAt,
    bool? isEmailVerified,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final now = DateTime.now().millisecondsSinceEpoch;
      final userData = <String, dynamic>{
        'userId': userId,
        'email': normalizedEmail,
        'displayName': displayName ?? '',
        'createdAt': createdAt?.millisecondsSinceEpoch ?? now,
        'updatedAt': now,
        'isEmailVerified': isEmailVerified ?? false,
      };

      // Save user data by userId
      await _usersRef.child(userId).set(userData);

      // Also save email mapping for quick lookup - store userId as String
      // Firebase Realtime Database accepts String values directly
      await _usersByEmailRef.child(normalizedEmail).set(userId);

      return true;
    } catch (e) {
      // Handle Realtime Database API not enabled or other errors
      // Log error but don't throw - auth is still successful
      print('Realtime Database saveUserData error: $e');
      // Check if it's a permission denied error (API not enabled)
      if (e.toString().contains('PERMISSION_DENIED') || 
          e.toString().contains('API has not been used')) {
        print('Realtime Database API is not enabled. Please enable it in Firebase Console.');
      }
      return false;
    }
  }

  /// Update user email verification status
  Future<bool> updateEmailVerificationStatus({
    required String userId,
    required bool isVerified,
  }) async {
    try {
      final updates = <String, dynamic>{
        'isEmailVerified': isVerified,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _usersRef.child(userId).update(updates);

      return true;
    } catch (e) {
      // Handle Realtime Database API not enabled or other errors
      print('Realtime Database updateEmailVerificationStatus error: $e');
      return false;
    }
  }

  /// Get user data by email
  Future<Map<String, dynamic>?> getUserDataByEmail(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      
      // First, get userId from email mapping
      final emailSnapshot = await _usersByEmailRef
          .child(normalizedEmail)
          .get();

      if (!emailSnapshot.exists) {
        return null;
      }

      // Handle both String and Map types for backward compatibility
      String? userId;
      final value = emailSnapshot.value;
      if (value is String) {
        userId = value;
      } else if (value is Map) {
        // If it's a Map, try to extract userId
        userId = value['userId']?.toString();
      }
      
      if (userId == null || userId.isEmpty) {
        return null;
      }

      // Then, get user data by userId
      final userSnapshot = await _usersRef.child(userId).get();

      if (userSnapshot.exists && userSnapshot.value != null) {
        final value = userSnapshot.value;
        // Ensure value is a Map before casting
        if (value is Map) {
          final data = value as Map<Object?, Object?>;
          // Convert to Map<String, dynamic>
          return data.map((key, value) => MapEntry(key.toString(), value));
        }
      }
      return null;
    } catch (e) {
      print('Realtime Database getUserDataByEmail error: $e');
      return null;
    }
  }

  /// Get user data by user ID
  Future<Map<String, dynamic>?> getUserDataById(String userId) async {
    try {
      final snapshot = await _usersRef.child(userId).get();

      if (snapshot.exists && snapshot.value != null) {
        final value = snapshot.value;
        // Ensure value is a Map before casting
        if (value is Map) {
          final data = value as Map<Object?, Object?>;
          // Convert to Map<String, dynamic>
          return data.map((key, value) => MapEntry(key.toString(), value));
        }
      }
      return null;
    } catch (e) {
      print('Realtime Database getUserDataById error: $e');
      return null;
    }
  }

  /// Delete user data from Realtime Database
  /// This should be called when a user account is deleted
  Future<bool> deleteUserData(String userId) async {
    try {
      // Get user email before deleting
      final userData = await getUserDataById(userId);
      final email = userData?['email'] as String?;

      // Delete user data
      await _usersRef.child(userId).remove();

      // Delete email mapping if email exists
      if (email != null) {
        final normalizedEmail = email.trim().toLowerCase();
        await _usersByEmailRef.child(normalizedEmail).remove();
      }

      return true;
    } catch (e) {
      print('Realtime Database deleteUserData error: $e');
      return false;
    }
  }
}
