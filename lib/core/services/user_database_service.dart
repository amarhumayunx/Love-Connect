import 'package:firebase_database/firebase_database.dart';

class UserDatabaseService {
  static final UserDatabaseService _instance = UserDatabaseService._internal();
  factory UserDatabaseService() => _instance;
  UserDatabaseService._internal();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  static const String _usersPath = 'users';
  static const String _usersByEmailPath = 'usersByEmail';

  DatabaseReference get _usersRef => _database.ref(_usersPath);

  DatabaseReference get _usersByEmailRef => _database.ref(_usersByEmailPath);

  Future<bool> checkUserExistsByEmail(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final snapshot = await _usersByEmailRef.child(normalizedEmail).get();

      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkUserExistsById(String userId) async {
    try {
      final snapshot = await _usersRef.child(userId).get();

      return snapshot.exists;
    } catch (e) {
      return false;
    }
  }

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

      await _usersRef.child(userId).update(userData);

      await _usersByEmailRef.child(normalizedEmail).set(userId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Save user profile data (name, about, profilePictureUrl)
  Future<bool> saveUserProfile({
    required String userId,
    required String name,
    required String about,
    String? profilePictureUrl,
    String? email,
    String? gender,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final profileData = <String, dynamic>{
        'name': name,
        'about': about,
        'updatedAt': now,
      };

      if (profilePictureUrl != null) {
        profileData['profilePictureUrl'] = profilePictureUrl;
      }

      if (email != null) {
        profileData['email'] = email.trim().toLowerCase();
      }

      if (gender != null) {
        profileData['gender'] = gender;
      }

      await _usersRef.child(userId).child('profile').update(profileData);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final snapshot = await _usersRef.child(userId).child('profile').get();

      if (snapshot.exists && snapshot.value != null) {
        final value = snapshot.value;
        if (value is Map) {
          final data = value as Map<Object?, Object?>;
          return data.map((key, value) => MapEntry(key.toString(), value));
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

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
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserDataByEmail(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();

      final emailSnapshot = await _usersByEmailRef.child(normalizedEmail).get();

      if (!emailSnapshot.exists) {
        return null;
      }

      String? userId;
      final value = emailSnapshot.value;
      if (value is String) {
        userId = value;
      } else if (value is Map) {
        userId = value['userId']?.toString();
      }

      if (userId == null || userId.isEmpty) {
        return null;
      }

      final userSnapshot = await _usersRef.child(userId).get();

      if (userSnapshot.exists && userSnapshot.value != null) {
        final value = userSnapshot.value;
        if (value is Map) {
          final data = value as Map<Object?, Object?>;
          return data.map((key, value) => MapEntry(key.toString(), value));
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserDataById(String userId) async {
    try {
      final snapshot = await _usersRef.child(userId).get();

      if (snapshot.exists && snapshot.value != null) {
        final value = snapshot.value;
        if (value is Map) {
          final data = value as Map<Object?, Object?>;
          return data.map((key, value) => MapEntry(key.toString(), value));
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteUserData(String userId) async {
    try {
      final userData = await getUserDataById(userId);
      final email = userData?['email'] as String?;

      await _usersRef.child(userId).remove();

      if (email != null) {
        final normalizedEmail = email.trim().toLowerCase();
        await _usersByEmailRef.child(normalizedEmail).remove();
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
