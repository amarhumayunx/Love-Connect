import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:love_connect/core/models/user_profile_model.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/storage_service.dart';
import 'package:love_connect/core/services/user_database_service.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final LocalStorageService _storageService = LocalStorageService();
  final AuthService _authService = AuthService();
  final UserDatabaseService _userDbService = UserDatabaseService();
  final StorageService _storageServiceFirebase = StorageService();

  Future<UserProfileModel> loadProfile() async {
    try {
      final userId = _authService.currentUserId;
      final user = _authService.currentUser;

      if (userId == null) {
        // Fallback to local storage
        return await _storageService.getUserProfile();
      }

      // First check for local profile image
      final localImagePath = await getLocalProfileImagePath();
      
      // Try to load from Firebase first
      final firebaseProfile = await _userDbService.getUserProfile(userId);

      if (firebaseProfile != null) {
        // Use local image if available, otherwise use Firebase URL
        final String? profilePictureUrl = localImagePath != null 
            ? 'file://$localImagePath' // Mark as local file
            : firebaseProfile['profilePictureUrl'] as String?;
            
        return UserProfileModel(
          name: firebaseProfile['name'] as String? ?? 'User',
          about:
              firebaseProfile['about'] as String? ??
              'Keeping the love story alive.',
          profilePictureUrl: profilePictureUrl,
          email: user?.email ?? firebaseProfile['email'] as String?,
          gender: firebaseProfile['gender'] as String?,
        );
      } else {
        // Load from local storage and migrate to Firebase
        final localProfile = await _storageService.getUserProfile();
        final googlePhotoUrl = user?.photoURL;
        
        // Use local image if available, otherwise use Google photo
        final String? profilePictureUrl = localImagePath != null 
            ? 'file://$localImagePath' // Mark as local file
            : googlePhotoUrl;

        final profile = localProfile.copyWith(
          email: user?.email,
          profilePictureUrl: profilePictureUrl,
        );

        // Save to Firebase
        await _userDbService.saveUserProfile(
          userId: userId,
          name: profile.name,
          about: profile.about,
          profilePictureUrl: profile.profilePictureUrl,
          email: profile.email,
          gender: profile.gender,
        );

        return profile;
      }
    } catch (e) {
      // Fallback to local storage
      try {
        final profile = await _storageService.getUserProfile();
        final user = _authService.currentUser;
        
        // Check for local image even in fallback
        final userId = _authService.currentUserId;
        String? profilePictureUrl = user?.photoURL;
        if (userId != null) {
          final localImagePath = await getLocalProfileImagePath();
          if (localImagePath != null) {
            profilePictureUrl = 'file://$localImagePath';
          }
        }
        
        return profile.copyWith(
          email: user?.email,
          profilePictureUrl: profilePictureUrl,
        );
      } catch (e2) {
        if (kDebugMode) {
          debugPrint('Error loading profile: $e2');
        }
        throw Exception('Failed to load profile');
      }
    }
  }

  /// Save profile data (works the same for iOS and Android)
  /// Saves to:
  /// 1. Firebase Realtime Database (users/{userId}/profile/profilePictureUrl)
  /// 2. Local Storage (SharedPreferences) for offline access
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      final userId = _authService.currentUserId;
      final user = _authService.currentUser;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // If profilePictureUrl is a local file path, don't save it to Firebase
      // Only save Firebase URLs to Firebase
      String? firebaseImageUrl = profile.profilePictureUrl;
      if (firebaseImageUrl != null && firebaseImageUrl.startsWith('file://')) {
        // Don't save local file paths to Firebase
        // Keep the existing Firebase URL if any, or set to null
        final existingProfile = await _userDbService.getUserProfile(userId);
        firebaseImageUrl = existingProfile?['profilePictureUrl'] as String?;
      }

      // Save to Firebase Realtime Database (same for iOS and Android)
      await _userDbService.saveUserProfile(
        userId: userId,
        name: profile.name,
        about: profile.about,
        profilePictureUrl: firebaseImageUrl, // Only Firebase URLs, not local paths
        email: profile.email ?? user?.email,
        gender: profile.gender,
      );

      // Also save to local storage for offline access (same for iOS and Android)
      // This will save the local file path if available
      await _storageService.saveUserProfile(profile);

      // Update home screen if available
      try {
        final homeViewModel = Get.find<HomeViewModel>();
        homeViewModel.loadUserInfo();
      } catch (e) {
        // HomeViewModel not available, ignore
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving profile: $e');
      }
      rethrow;
    }
  }

  Future<File?> pickImage() async {
    try {
      // For Android, explicitly request permissions
      if (Platform.isAndroid) {
        PermissionStatus status;
        if (await Permission.photos.isRestricted) {
          status = await Permission.storage.request();
        } else {
          status = await Permission.photos.request();
          if (!status.isGranted) {
            // Fallback to storage permission for older Android versions
            status = await Permission.storage.request();
          }
        }

        if (!status.isGranted) {
          SnackbarHelper.showSafe(
            title: 'Permission Denied',
            message: 'Please grant photo access permission in app settings',
          );
          return null;
        }
      }
      
      // For iOS, image_picker automatically handles permissions
      // It will show the permission dialog automatically if Info.plist is configured correctly
      // No need to explicitly request permissions for iOS - image_picker does it automatically
      
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      
      // If image is null, user might have cancelled or there's an issue
      // Don't show error if user just cancelled
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking image: $e');
      }
      
      // Check if it's a permission error
      String errorMessage = 'Failed to pick image. Please try again.';
      if (e.toString().contains('permission') || e.toString().contains('Permission')) {
        errorMessage = 'Photo access permission is required. Please enable it in Settings > Love Connect > Photos';
      }
      
      SnackbarHelper.showSafe(
        title: 'Error',
        message: errorMessage,
      );
      return null;
    }
  }

  /// Save profile image to local system storage
  /// Returns the local file path where image is saved
  Future<String?> saveProfileImageLocally(File imageFile) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        if (kDebugMode) {
          debugPrint('ProfileService: Cannot save image locally - user not authenticated');
        }
        return null;
      }

      // Get app's documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String profileImagesDir = '${appDocDir.path}/profile_images';
      
      // Create directory if it doesn't exist
      final Directory dir = Directory(profileImagesDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Save image with user ID as filename
      final String localImagePath = '$profileImagesDir/profile_$userId.jpg';
      final File localImageFile = File(localImagePath);
      
      // Copy the selected image to local storage
      await imageFile.copy(localImagePath);

      if (kDebugMode) {
        debugPrint('ProfileService: Image saved locally at: $localImagePath');
      }

      // Save the local path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_profile_image_path_$userId', localImagePath);

      return localImagePath;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileService: Error saving image locally: $e');
      }
      return null;
    }
  }

  /// Get local profile image path for current user
  Future<String?> getLocalProfileImagePath() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final String? localPath = prefs.getString('local_profile_image_path_$userId');
      
      if (localPath != null) {
        // Check if file still exists
        final File file = File(localPath);
        if (await file.exists()) {
          return localPath;
        } else {
          // File doesn't exist, remove from preferences
          await prefs.remove('local_profile_image_path_$userId');
        }
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileService: Error getting local image path: $e');
      }
      return null;
    }
  }

  /// Upload profile picture to Firebase Storage
  /// Works the same for both iOS and Android
  /// Returns the download URL which is then saved to Firebase Database and Local Storage
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'Please sign in to upload images',
        );
        return null;
      }

      if (kDebugMode) {
        debugPrint('ProfileService: Uploading profile picture for user: $userId');
      }

      // Upload to Firebase Storage (same for iOS and Android)
      final downloadUrl = await _storageServiceFirebase.uploadProfilePicture(
        imageFile,
        userId,
      );
      
      if (downloadUrl != null && downloadUrl.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('ProfileService: Profile picture uploaded successfully');
        }
        return downloadUrl;
      } else {
        throw Exception('Upload failed: No download URL returned');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ProfileService: Error uploading profile picture: $e');
      }
      
      // Provide user-friendly error messages
      String errorMessage = 'Failed to upload image. Please check your internet connection and try again.';
      
      final errorString = e.toString().toLowerCase();
      
      if (errorString.contains('permission') || errorString.contains('unauthorized') || errorString.contains('forbidden')) {
        errorMessage = 'Permission denied. Please check Firebase Storage rules in Firebase Console.';
      } else if (errorString.contains('object-not-found') || errorString.contains('not-found')) {
        errorMessage = 'Storage configuration error. Please check Firebase Storage rules and ensure the bucket is properly configured.';
      } else if (errorString.contains('network') || errorString.contains('connection') || errorString.contains('timeout')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      } else if (errorString.contains('authenticated') || errorString.contains('sign in') || errorString.contains('unauthenticated')) {
        errorMessage = 'Please sign in to upload images.';
      } else if (errorString.contains('too large') || errorString.contains('exceeds')) {
        errorMessage = 'Image file is too large. Please select a smaller image (max 10MB).';
      } else if (errorString.contains('not found') || errorString.contains('does not exist')) {
        errorMessage = 'Image file not found. Please try selecting the image again.';
      } else if (errorString.contains('quota') || errorString.contains('limit')) {
        errorMessage = 'Storage quota exceeded. Please check your Firebase Storage quota.';
      }
      
      SnackbarHelper.showSafe(
        title: 'Upload Failed',
        message: errorMessage,
      );
      
      return null;
    }
  }

  UserProfileModel updateProfileFromAuth(UserProfileModel profile) {
    final user = _authService.currentUser;
    var updatedProfile = profile;

    // Update name from Firebase Auth if available
    if (user != null &&
        user.displayName != null &&
        profile.name == 'User') {
      updatedProfile = updatedProfile.copyWith(name: user.displayName!);
    }

    // Update email if not set
    if (updatedProfile.email == null && user?.email != null) {
      updatedProfile = updatedProfile.copyWith(email: user!.email);
    }

    // Update Google photo URL if not set
    if (updatedProfile.profilePictureUrl == null &&
        user?.photoURL != null) {
      updatedProfile = updatedProfile.copyWith(
        profilePictureUrl: user!.photoURL,
      );
    }

    return updatedProfile;
  }
}
