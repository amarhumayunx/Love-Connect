import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile picture to Firebase Storage
  /// Works the same for both iOS and Android
  /// Returns the download URL of the uploaded image
  /// Image is saved at: profile_pictures/{userId}.jpg
  Future<String?> uploadProfilePicture(File imageFile, String userId) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        if (kDebugMode) {
          debugPrint('StorageService: Image file does not exist at path: ${imageFile.path}');
        }
        throw Exception('Image file not found');
      }

      // Check file size (max 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        if (kDebugMode) {
          debugPrint('StorageService: Image file too large: ${fileSize / 1024 / 1024}MB');
        }
        throw Exception('Image file is too large. Maximum size is 10MB');
      }

      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) {
          debugPrint('StorageService: User not authenticated');
        }
        throw Exception('User not authenticated');
      }

      if (kDebugMode) {
        debugPrint('StorageService: Starting upload for user: $userId');
        debugPrint('StorageService: File path: ${imageFile.path}');
        debugPrint('StorageService: File size: ${fileSize / 1024}KB');
        debugPrint('StorageService: Storage bucket: ${_storage.app.options.storageBucket}');
      }

      final ref = _storage.ref().child('profile_pictures/$userId.jpg');
      
      if (kDebugMode) {
        debugPrint('StorageService: Storage reference path: profile_pictures/$userId.jpg');
        debugPrint('StorageService: Current user UID: ${user.uid}');
        debugPrint('StorageService: User ID matches: ${user.uid == userId}');
      }
      
      // Upload with metadata
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (kDebugMode) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          debugPrint('StorageService: Upload progress: ${progress.toStringAsFixed(2)}%');
        }
      });

      // Wait for upload to complete and check for errors
      final snapshot = await uploadTask.whenComplete(() {
        if (kDebugMode) {
          debugPrint('StorageService: Upload task completed');
        }
      });
      
      // Check if upload was successful
      if (snapshot.state != TaskState.success) {
        if (kDebugMode) {
          debugPrint('StorageService: Upload failed with state: ${snapshot.state}');
        }
        throw Exception('Upload failed: ${snapshot.state}');
      }
      
      if (kDebugMode) {
        debugPrint('StorageService: Upload successful. Bytes transferred: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
        debugPrint('StorageService: Upload metadata: ${snapshot.metadata}');
      }

      // Get download URL - use the snapshot's ref to ensure we're getting the right URL
      String downloadUrl;
      try {
        downloadUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        // Fallback: try getting URL from the original ref
        if (kDebugMode) {
          debugPrint('StorageService: Error getting download URL from snapshot, trying ref: $e');
        }
        downloadUrl = await ref.getDownloadURL();
      }
      
      if (kDebugMode) {
        debugPrint('StorageService: Download URL obtained: $downloadUrl');
      }

      return downloadUrl;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('StorageService: Error uploading profile picture: $e');
        debugPrint('StorageService: Stack trace: $stackTrace');
      }
      rethrow; // Re-throw to let caller handle the error
    }
  }

  /// Delete profile picture from Firebase Storage
  Future<bool> deleteProfilePicture(String userId) async {
    try {
      final ref = _storage.ref().child('profile_pictures/$userId.jpg');
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get current user ID from Firebase Auth
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
}
