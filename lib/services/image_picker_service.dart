import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:master_mind/providers/profile_provider.dart';

class ImagePickerService {
  static Future<ImageSource?> _showImageSourceDialog(
      BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  static Future<File?> pickImage(BuildContext context) async {
    try {
      // Show image source options
      final ImageSource? source = await _showImageSourceDialog(context);
      if (source == null) return null; // User cancelled

      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: source,
        imageQuality: 80, // Compress image for better performance
        maxWidth: 800, // Limit image size
      );

      if (pickedImage != null) {
        return File(pickedImage.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> uploadProfileImage(
    BuildContext context,
    File imageFile,
    ProfileProvider profileProvider,
  ) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Uploading profile picture...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Upload the image
      await profileProvider.updateProfileImage(imageFile);

      // Manually trigger profile reload to ensure UI updates
      await profileProvider.loadProfile();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile picture: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () =>
                  uploadProfileImage(context, imageFile, profileProvider),
            ),
          ),
        );
      }
      return false;
    }
  }
}
