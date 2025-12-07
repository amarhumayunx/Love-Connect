import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/user_profile_model.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/user_database_service.dart';
import 'package:love_connect/core/services/storage_service.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/profile/model/profile_model.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';

class ProfileViewModel extends GetxController {
  final LocalStorageService _storageService = LocalStorageService();
  final AuthService _authService = AuthService();
  final UserDatabaseService _userDbService = UserDatabaseService();
  final StorageService _storageServiceFirebase = StorageService();
  final ProfileModel model = const ProfileModel();
  final Rx<UserProfileModel> userProfile = UserProfileModel(
    name: 'User',
    about: 'Keeping the love story alive.',
  ).obs;
  final RxMap<String, bool> settings = <String, bool>{}.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    loadSettings();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final userId = _authService.currentUserId;
      final user = _authService.currentUser;

      if (userId == null) {
        // Fallback to local storage
        final profile = await _storageService.getUserProfile();
        userProfile.value = profile;
        isLoading.value = false;
        return;
      }

      // Try to load from Firebase first
      final firebaseProfile = await _userDbService.getUserProfile(userId);

      if (firebaseProfile != null) {
        userProfile.value = UserProfileModel(
          name: firebaseProfile['name'] as String? ?? 'User',
          about:
              firebaseProfile['about'] as String? ??
              'Keeping the love story alive.',
          profilePictureUrl: firebaseProfile['profilePictureUrl'] as String?,
          email: user?.email,
        );
      } else {
        // Load from local storage and migrate to Firebase
        final localProfile = await _storageService.getUserProfile();
        final googlePhotoUrl = user?.photoURL;

        userProfile.value = localProfile.copyWith(
          email: user?.email,
          profilePictureUrl: googlePhotoUrl,
        );

        // Save to Firebase
        await _userDbService.saveUserProfile(
          userId: userId,
          name: userProfile.value.name,
          about: userProfile.value.about,
          profilePictureUrl: userProfile.value.profilePictureUrl,
          email: userProfile.value.email,
        );
      }

      // Update name from Firebase Auth if available
      if (user != null &&
          user.displayName != null &&
          userProfile.value.name == 'User') {
        userProfile.value = userProfile.value.copyWith(name: user.displayName!);
      }

      // Update email if not set
      if (userProfile.value.email == null && user?.email != null) {
        userProfile.value = userProfile.value.copyWith(email: user!.email);
      }

      // Update Google photo URL if not set
      if (userProfile.value.profilePictureUrl == null &&
          user?.photoURL != null) {
        userProfile.value = userProfile.value.copyWith(
          profilePictureUrl: user!.photoURL,
        );
      }
    } catch (e) {
      // Fallback to local storage
      try {
        final profile = await _storageService.getUserProfile();
        final user = _authService.currentUser;
        userProfile.value = profile.copyWith(
          email: user?.email,
          profilePictureUrl: user?.photoURL,
        );
      } catch (e2) {
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'Failed to load profile',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSettings() async {
    try {
      final loadedSettings = await _storageService.getSettings();
      settings.value = loadedSettings;
    } catch (e) {
      // Use defaults
      settings.value = {
        'notifications': true,
        'planReminder': true,
        'privateJournal': true,
        'hideLocation': true,
        'romanticTheme': true,
      };
    }
  }

  Future<void> saveProfile(UserProfileModel profile) async {
    isLoading.value = true;
    try {
      final userId = _authService.currentUserId;
      final user = _authService.currentUser;

      if (userId == null) {
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'User not authenticated',
        );
        isLoading.value = false;
        return;
      }

      // Save to Firebase Realtime Database
      await _userDbService.saveUserProfile(
        userId: userId,
        name: profile.name,
        about: profile.about,
        profilePictureUrl: profile.profilePictureUrl,
        email: profile.email ?? user?.email,
      );

      // Also save to local storage for offline access
      await _storageService.saveUserProfile(profile);

      userProfile.value = profile;

      // Update home screen if available
      try {
        final homeViewModel = Get.find<HomeViewModel>();
        // Call public method to reload user info
        homeViewModel.loadUserInfo();
      } catch (e) {
        // HomeViewModel not available, ignore
      }

      Get.back();
      SnackbarHelper.showSafe(
        title: 'Profile Updated',
        message: 'Your profile has been saved',
      );
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to save profile',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSetting(String key, bool value) async {
    try {
      await _storageService.saveSetting(key, value);
      settings[key] = value;
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to update setting',
      );
    }
  }

  Future<void> clearAllData() async {
    try {
      await _storageService.clearAllData();
      SnackbarHelper.showSafe(
        title: 'Data Cleared',
        message: 'All local data has been cleared',
      );
    } catch (e) {
      SnackbarHelper.showSafe(title: 'Error', message: 'Failed to clear data');
    }
  }

  void showEditProfileModal() {
    Get.dialog(
      EditProfileModal(
        profile: userProfile.value,
        onSave: saveProfile,
        viewModel: this,
      ),
      barrierDismissible: true,
    );
  }

  Future<File?> pickImage() async {
    try {
      // Request permissions for Android 13+ (READ_MEDIA_IMAGES) or older (READ_EXTERNAL_STORAGE)
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

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      SnackbarHelper.showSafe(title: 'Error', message: 'Failed to pick image');
      return null;
    }
  }

  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return null;

      final downloadUrl = await _storageServiceFirebase.uploadProfilePicture(
        imageFile,
        userId,
      );
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  void showClearDataDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Data',
          style: TextStyle(color: Get.theme.colorScheme.onSurface),
        ),
        content: Text(
          'This will permanently remove all locally stored data for this app. You can\'t undo this action.',
          style: TextStyle(color: Get.theme.colorScheme.error),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }
}

// Edit Profile Modal Widget
class EditProfileModal extends StatefulWidget {
  final UserProfileModel profile;
  final Function(UserProfileModel) onSave;
  final ProfileViewModel viewModel;

  const EditProfileModal({
    super.key,
    required this.profile,
    required this.onSave,
    required this.viewModel,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late final TextEditingController nameController;
  late final TextEditingController aboutController;
  String? _selectedImagePath;
  String? _profilePictureUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profile.name);
    aboutController = TextEditingController(text: widget.profile.about);
    _profilePictureUrl = widget.profile.profilePictureUrl;
  }

  @override
  void dispose() {
    nameController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final imageFile = await widget.viewModel.pickImage();
    if (imageFile == null) return;

    setState(() {
      _selectedImagePath = imageFile.path;
      _isUploading = true;
    });

    try {
      final downloadUrl = await widget.viewModel.uploadProfilePicture(
        imageFile,
      );
      if (downloadUrl != null) {
        setState(() {
          _profilePictureUrl = downloadUrl;
          _isUploading = false;
        });
      } else {
        setState(() {
          _isUploading = false;
        });
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'Failed to upload image',
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to upload image',
      );
    }
  }

  Widget _buildProfileImage() {
    if (_isUploading) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryRed),
        ),
      );
    }

    if (_selectedImagePath != null) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: ClipOval(
          child: Image.file(File(_selectedImagePath!), fit: BoxFit.cover),
        ),
      );
    }

    if (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: ClipOval(
          child: Image.network(
            _profilePictureUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/profile.jpg',
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      child: ClipOval(
        child: Image.asset('assets/images/profile.jpg', fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            // Profile Picture (with camera icon overlay)
            Stack(
              children: [
                _buildProfileImage(),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Email Display
            if (widget.profile.email != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  widget.profile.email!,
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLightPink,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 24),

            // Name Field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      color: AppColors.primaryDark,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.edit,
                          color: AppColors.primaryRed,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // About Field
                  Text(
                    'About',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: aboutController,
                    maxLines: 3,
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      color: AppColors.primaryDark,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 8, top: 8),
                        child: Icon(
                          Icons.edit,
                          color: AppColors.primaryRed,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSave(
                          UserProfileModel(
                            name: nameController.text.trim(),
                            about: aboutController.text.trim(),
                            profilePictureUrl: _profilePictureUrl,
                            email: widget.profile.email,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
