import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/user_profile_model.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/profile/view_model/profile_view_model.dart';

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
  int _aboutMaxLines = 1;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profile.name);
    aboutController = TextEditingController(text: widget.profile.about);
    _profilePictureUrl = widget.profile.profilePictureUrl;

    // Check if profilePictureUrl is a local file path
    if (_profilePictureUrl != null && _profilePictureUrl!.startsWith('file://')) {
      final String filePath = _profilePictureUrl!.substring(7);
      _selectedImagePath = filePath;
      _profilePictureUrl = null; // Clear Firebase URL since we have local image
    }

    // Also try to load local image path if available
    _loadLocalImage();

    // Calculate initial maxLines for about field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateAboutLines();
    });

    // Listen to text changes to update maxLines dynamically
    aboutController.addListener(() {
      _calculateAboutLines();
    });
  }

  Future<void> _loadLocalImage() async {
    final localPath = await widget.viewModel.getLocalProfileImagePath();
    if (localPath != null && _selectedImagePath == null) {
      setState(() {
        _selectedImagePath = localPath;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final imageFile = await widget.viewModel.pickImage();
      if (imageFile == null) {
        // User cancelled or permission denied - don't show error
        return;
      }

      // Save to local system storage first (especially for iOS)
      setState(() {
        _selectedImagePath = imageFile.path;
        _isUploading = false; // Not uploading to Firebase yet
      });

      // Save image to local system storage
      final localImagePath = await widget.viewModel.saveProfileImageLocally(
        imageFile,
      );

      if (localImagePath != null && localImagePath.isNotEmpty) {
        setState(() {
          _selectedImagePath = localImagePath; // Update to saved local path
        });
        SnackbarHelper.showSafe(
          title: 'Success',
          message: 'Profile picture saved locally',
        );
      } else {
        // Keep showing the selected image even if local save fails
        setState(() {
          _selectedImagePath = imageFile.path;
        });
        SnackbarHelper.showSafe(
          title: 'Warning',
          message: 'Image selected but could not save locally',
        );
      }

      // Note: Firebase upload is commented out for now
      // Later, you can uncomment this to upload to Firebase:
      setState(() {
        _isUploading = true;
      });

      final downloadUrl = await widget.viewModel.uploadProfilePicture(
        imageFile,
      );

      if (downloadUrl != null && downloadUrl.isNotEmpty) {
        setState(() {
          _profilePictureUrl = downloadUrl;
          _selectedImagePath = null; // Clear local path after successful upload
          _isUploading = false;
        });
        SnackbarHelper.showSafe(
          title: 'Success',
          message: 'Profile picture updated successfully',
        );
      } else {
        // Error message is already shown by uploadProfilePicture method
        setState(() {
          _isUploading = false;
        });
      }

    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to save image: ${e.toString()}',
      );
    }
  }

  Widget _buildProfileImage() {
    if (_isUploading) {
      return _buildCircularImageContainer(
        child: LoadingAnimationWidget.horizontalRotatingDots(
          color: AppColors.primaryRed,
          size: 50,
        ),
      );
    }

    if (_selectedImagePath != null) {
      return _buildCircularImageContainer(
        child: Image.file(
          File(_selectedImagePath!),
          fit: BoxFit.cover,
          errorBuilder: _errorImageBuilder,
        ),
      );
    }

    if (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty) {
      return _buildCircularImageContainer(
        child: Image.network(
          _profilePictureUrl!,
          fit: BoxFit.cover,
          errorBuilder: _errorImageBuilder,
        ),
      );
    }

    return _buildCircularImageContainer(
      child: Image.asset('assets/images/profile.jpg', fit: BoxFit.cover),
    );
  }

  Widget _buildCircularImageContainer({required Widget child}) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      child: ClipOval(
        child: child,
      ),
    );
  }

  Widget _errorImageBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return Image.asset(
      'assets/images/profile.jpg',
      fit: BoxFit.cover,
    );
  }

  InputDecoration _buildTextFieldDecoration({EdgeInsets? iconPadding}) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textLightPink, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textLightPink, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textLightPink, width: 1),
      ),
      suffixIcon: Padding(
        padding: iconPadding ?? EdgeInsets.all(12),
        child: SvgPicture.asset(
          'assets/svg/new_svg/pencil.svg',
          width: 16,
          height: 16,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(
            AppColors.primaryDark,
            BlendMode.srcIn,
          ),
        ),
      ),
      suffixIconConstraints: BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
    );
  }
  TextStyle _buildLabelTextStyle(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: context.responsiveFont(14),
      fontWeight: FontWeight.w500,
      color: AppColors.primaryDark,
    );
  }

  TextStyle _buildTextFieldTextStyle(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: context.responsiveFont(14),
      color: AppColors.primaryDark,
    );
  }

  void _calculateAboutLines() {
    if (!mounted) return;
    
    try {
      final text = aboutController.text;
      if (text.isEmpty) {
        if (_aboutMaxLines != 1) {
          setState(() {
            _aboutMaxLines = 1;
          });
        }
        return;
      }

      // Get the text style
      final textStyle = _buildTextFieldTextStyle(context);
      
      // Calculate available width (screen width - padding - border - icon)
      final screenWidth = MediaQuery.of(context).size.width;
      final horizontalPadding = 20.0 * 2; // Left and right padding
      final textFieldPadding = 12.0 * 2; // Left and right content padding
      final borderWidth = 1.0 * 2; // Left and right border
      final iconWidth = 40.0; // Suffix icon width
      final availableWidth = screenWidth - horizontalPadding - textFieldPadding - borderWidth - iconWidth - 40; // Extra margin for safety

      // Use TextPainter to measure text
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: null,
      );

      textPainter.layout(maxWidth: availableWidth);
      
      final lineCount = textPainter.computeLineMetrics().length;
      final newMaxLines = lineCount > 0 ? lineCount : 1;
      
      // Only update if the value changed to avoid unnecessary rebuilds
      if (_aboutMaxLines != newMaxLines) {
        setState(() {
          _aboutMaxLines = newMaxLines;
        });
      }
    } catch (e) {
      // If calculation fails, default to 1 line
      if (_aboutMaxLines != 1) {
        setState(() {
          _aboutMaxLines = 1;
        });
      }
    }
  }

  Widget _buildEmailSection(BuildContext context) {
    if (widget.profile.email == null || widget.profile.email!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          color: AppColors.backgroundPink,
        ),
        child: Text(
          widget.profile.email!,
          style: GoogleFonts.inter(
            fontSize: context.responsiveFont(14),
            fontWeight: FontWeight.w500,
            color: AppColors.primaryDark,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Stack(
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
    );
  }

  Widget _buildNameField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name', style: _buildLabelTextStyle(context)),
          SizedBox(height: 8),
          TextField(
            controller: nameController,
            style: _buildTextFieldTextStyle(context),
            decoration: _buildTextFieldDecoration(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About', style: _buildLabelTextStyle(context)),
          SizedBox(height: 8),
          TextField(
            controller: aboutController,
            minLines: 1,
            maxLines: _aboutMaxLines,
            style: _buildTextFieldTextStyle(context),
            decoration: _buildTextFieldDecoration(),
          ),
        ],
      ),
    );
  }

  Future<String?> _resolveImageUrl() async {
    if (_selectedImagePath == null) {
      return _profilePictureUrl;
    }

    final imageFile = File(_selectedImagePath!);
    if (!await imageFile.exists()) {
      return _profilePictureUrl;
    }

    final localImagePath = await widget.viewModel.getLocalProfileImagePath();
    if (localImagePath != null && localImagePath == _selectedImagePath) {
      return 'file://$_selectedImagePath';
    }

    final savedPath = await widget.viewModel.saveProfileImageLocally(imageFile);
    if (savedPath != null) {
      setState(() {
        _selectedImagePath = savedPath;
      });
      return 'file://$savedPath';
    }

    return 'file://$_selectedImagePath';
  }

  Future<void> _handleSave() async {
    final imageUrl = await _resolveImageUrl();

    widget.onSave(
      UserProfileModel(
        name: nameController.text.trim(),
        about: aboutController.text.trim(),
        profilePictureUrl: imageUrl,
        email: widget.profile.email,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.textLightPink, width: 1),
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
              onPressed: _handleSave,
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
            _buildProfilePictureSection(),
            SizedBox(height: 16),
            _buildEmailSection(context),
            SizedBox(height: 24),
            _buildNameField(context),
            SizedBox(height: 16),
            _buildAboutField(context),
            SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }
}