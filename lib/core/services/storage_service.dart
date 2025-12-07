import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile picture to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String?> uploadProfilePicture(File imageFile, String userId) async {
    try {
      final ref = _storage.ref().child('profile_pictures/$userId.jpg');
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
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
