import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:master_mind/providers/profile_provider.dart';
import 'package:master_mind/screens/profile/profile_edit_screen.dart';
import 'package:master_mind/screens/settings_screen.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/home_drawer.dart';
import 'package:master_mind/widgets/shimmer_avatar.dart';
import 'package:master_mind/providers/connection_Provider.dart';
import 'package:master_mind/providers/testimonial_provider.dart';
import 'package:master_mind/providers/event_provider.dart';
import 'package:master_mind/providers/Auth_provider.dart';
import 'package:master_mind/screens/profile/profile_settings_screen.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    // Load profile data
    await Provider.of<ProfileProvider>(context, listen: false).loadProfile();

    // Load connection statistics
    await Provider.of<ConnectionProvider>(context, listen: false)
        .getAllConnectionCount();

    // Load testimonial statistics
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final testimonialProvider =
        Provider.of<TestimonialProvider>(context, listen: false);
    final getToken = authProvider.authRepository.getAuthToken;
    await testimonialProvider.fetchTestimonialCountsWithToken(getToken);

    // Load event statistics (if available)
    try {
      await Provider.of<EventProvider>(context, listen: false).loadEvents();
    } catch (e) {
      // Event provider might not be available, ignore error
    }
  }

  Future<void> _pickImage() async {
    try {
      print('🔄 ProfileScreen: Starting image picker...');

      // Show image source options
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) {
        print('❌ ProfileScreen: User cancelled image selection');
        return; // User cancelled
      }

      print('✅ ProfileScreen: Image source selected: $source');

      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: source,
        imageQuality: 85, // Slightly higher quality
        maxWidth: 1024, // Higher resolution
        maxHeight: 1024,
      );

      if (pickedImage != null) {
        print(
            '✅ ProfileScreen: Image picked successfully: ${pickedImage.path}');

        setState(() {
          image = File(pickedImage.path);
        });
        print('✅ ProfileScreen: Local state updated with picked image');

        // Upload the image
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);

        // Show enhanced loading indicator
        final loadingSnackBar = ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(width: 16),
                const Text('Uploading profile picture...'),
              ],
            ),
            backgroundColor: kPrimaryColor,
            duration: const Duration(
                seconds: 30), // Very long duration, we'll hide it manually
            action: SnackBarAction(
              label: 'Cancel',
              textColor: Colors.white,
              onPressed: () {
                print('⚠️ ProfileScreen: User cancelled upload');
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );

        try {
          print('🔄 ProfileScreen: Starting image upload process...');
          await profileProvider.updateProfileImage(image!);

          // Check if upload was successful
          if (profileProvider.error == null) {
            print('✅ ProfileScreen: Upload successful, updating UI...');

            // Force a rebuild of the UI
            setState(() {
              image = null;
            });
            print('✅ ProfileScreen: Local state cleared');

            // Wait for backend response - no forced refresh
            print('✅ ProfileScreen: Waiting for backend response...');

            // The image will be updated automatically when the provider gets the new URL
            // No need to force refresh - let the backend response handle it naturally

            // Hide loading and show enhanced success message
            if (mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Profile picture updated successfully!',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );
              print('✅ ProfileScreen: Enhanced success message shown');
            }
          } else {
            // Handle error from provider
            print('❌ ProfileScreen: Upload failed: ${profileProvider.error}');
            throw Exception(profileProvider.error);
          }
        } catch (e) {
          print('❌ ProfileScreen: Upload error: $e');
          rethrow;
        } finally {
          // Always hide the loading snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            print('✅ ProfileScreen: Loading indicator hidden');
          }
        }
      }
    } catch (e) {
      print('❌ ProfileScreen: Image upload failed with error: $e');

      // Show enhanced error message
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to update profile picture: ${e.toString().length > 50 ? e.toString().substring(0, 50) + '...' : e.toString()}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                print('🔄 ProfileScreen: User retrying image upload');
                _pickImage();
              },
            ),
          ),
        );
      }

      // Reset image state on error
      setState(() {
        image = null;
      });
      print('✅ ProfileScreen: Local state reset after error');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
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

  // Method to manually refresh the profile image
  Future<void> _refreshProfileImage() async {
    print('🔄 ProfileScreen: Manually refreshing profile image...');
    try {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(width: 16),
              Text('Refreshing profile...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      // Force reload profile
      await profileProvider.forceReloadProfile();

      // Force UI refresh
      setState(() {
        // Force rebuild
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile refreshed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      print('✅ ProfileScreen: Profile image refreshed successfully');
    } catch (e) {
      print('❌ ProfileScreen: Failed to refresh profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh profile: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Method to handle 304 errors by waiting for natural refresh
  Future<void> _handleImageCacheError() async {
    print(
        '🔄 ProfileScreen: Handling image cache error - waiting for natural refresh...');
    try {
      // Just wait a bit and let the image load naturally
      await Future.delayed(const Duration(milliseconds: 1000));

      // Minimal UI update
      setState(() {
        // Only the image will rebuild
      });

      print('✅ ProfileScreen: Image cache error handled naturally');
    } catch (e) {
      print('❌ ProfileScreen: Failed to handle cache error: $e');
    }
  }

  Widget _buildProfileCard(profile) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: ShimmerAvatar(
              radius: 60,
              backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
              imageUrl: profile?.imageUrl,
              child: (image == null &&
                      (profile?.imageUrl == null || profile?.imageUrl == ""))
                  ? Icon(Icons.camera_alt, size: 40, color: kPrimaryColor)
                  : null,
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profile?.name != null &&
                    (profile!.name?.isNotEmpty ?? false))
                  Text(
                    profile!.name ?? '',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor),
                  ),
                const SizedBox(height: 6),
                if (profile?.company != null &&
                    (profile!.company?.isNotEmpty ?? false))
                  Text(
                    profile!.company ?? '',
                    style: TextStyle(
                        fontSize: 15,
                        color: kPrimaryColor.withValues(alpha: 0.7)),
                  ),
                const SizedBox(height: 10),
                if (profile?.region != null &&
                    (profile!.region?.isNotEmpty ?? false))
                  Text(
                    "Region: ${profile!.region ?? ''}",
                    style: TextStyle(
                        color: kPrimaryColor.withValues(alpha: 0.8),
                        fontSize: 14),
                  ),
                const SizedBox(height: 4),
                if (profile?.memberSince != null &&
                    (profile!.memberSince?.isNotEmpty ?? false))
                  Text(
                    "Member Since: ${profile!.memberSince ?? ''}",
                    style: TextStyle(color: kPrimaryColor, fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  bool _hasMissingDetails(profile) {
    if (profile == null) return true;

    final missingFields = <String>[];

    if (profile.name == null || profile.name.toString().trim().isEmpty) {
      missingFields.add('Name');
    }
    if (profile.company == null || profile.company.toString().trim().isEmpty) {
      missingFields.add('Company');
    }
    if (profile.region == null || profile.region.toString().trim().isEmpty) {
      missingFields.add('Region');
    }
    if (profile.memberSince == null ||
        profile.memberSince.toString().trim().isEmpty) {
      missingFields.add('Member Since');
    }
    if (profile.about == null || profile.about.toString().trim().isEmpty) {
      missingFields.add('About');
    }
    if (profile.industries == null || profile.industries.isEmpty) {
      missingFields.add('Industries');
    }
    if (profile.phonenumbers == null || profile.phonenumbers.isEmpty) {
      missingFields.add('Phone Numbers');
    }
    if (profile.email == null || profile.email.toString().trim().isEmpty) {
      missingFields.add('Email');
    }
    if (profile.website == null || profile.website.toString().trim().isEmpty) {
      missingFields.add('Website');
    }
    if (profile.imageUrl == null ||
        profile.imageUrl.toString().trim().isEmpty) {
      missingFields.add('Profile Picture');
    }
    if (profile.chapter == null || profile.chapter.toString().trim().isEmpty) {
      missingFields.add('Chapter');
    }
    if (!_hasSocialMediaLinks(profile)) {
      missingFields.add('Social Media');
    }

    return missingFields.isNotEmpty;
  }

  List<String> _getMissingFields(profile) {
    if (profile == null) return ['All profile details'];

    final missingFields = <String>[];

    if (profile.name == null || profile.name.toString().trim().isEmpty) {
      missingFields.add('Name');
    }
    if (profile.company == null || profile.company.toString().trim().isEmpty) {
      missingFields.add('Company');
    }
    if (profile.region == null || profile.region.toString().trim().isEmpty) {
      missingFields.add('Region');
    }
    if (profile.memberSince == null ||
        profile.memberSince.toString().trim().isEmpty) {
      missingFields.add('Member Since');
    }
    if (profile.about == null || profile.about.toString().trim().isEmpty) {
      missingFields.add('About');
    }
    if (profile.industries == null || profile.industries.isEmpty) {
      missingFields.add('Industries');
    }
    if (profile.phonenumbers == null || profile.phonenumbers.isEmpty) {
      missingFields.add('Phone Numbers');
    }
    if (profile.email == null || profile.email.toString().trim().isEmpty) {
      missingFields.add('Email');
    }
    if (profile.website == null || profile.website.toString().trim().isEmpty) {
      missingFields.add('Website');
    }
    if (profile.imageUrl == null ||
        profile.imageUrl.toString().trim().isEmpty) {
      missingFields.add('Profile Picture');
    }
    if (profile.chapter == null || profile.chapter.toString().trim().isEmpty) {
      missingFields.add('Chapter');
    }
    if (!_hasSocialMediaLinks(profile)) {
      missingFields.add('Social Media');
    }

    return missingFields;
  }

  // Profile Completion Progress Widget
  Widget _buildProfileCompletionProgress(profile) {
    // Calculate completion percentage and missing fields
    double completionPercentage = 0.0;
    List<String> missingFields = [];

    if (profile != null) {
      // Define all fields that contribute to profile completion
      final allFields = [
        {'name': 'Name', 'value': profile.name, 'required': true},
        {'name': 'Company', 'value': profile.company, 'required': true},
        {'name': 'Email', 'value': profile.email, 'required': true},
        {
          'name': 'Phone Number',
          'value': profile.phonenumbers,
          'required': true
        },
        {'name': 'Industries', 'value': profile.industries, 'required': true},
        {
          'name': 'Profile Picture',
          'value': profile.imageUrl,
          'required': false
        },
        {'name': 'About', 'value': profile.about, 'required': false},
        {'name': 'Chapter', 'value': profile.chapter, 'required': false},
        {'name': 'Region', 'value': profile.region, 'required': false},
        {'name': 'Website', 'value': profile.website, 'required': false},
        {
          'name': 'Social Media',
          'value': profile.socialMediaLinks,
          'required': false
        },
        {
          'name': 'Location',
          'value': profile.googleMapLocation,
          'required': false
        },
      ];

      int totalFields = allFields.length;
      int completedFields = 0;

      // Count completed fields and collect missing required ones
      for (var field in allFields) {
        String fieldName = field['name'] as String;
        dynamic fieldValue = field['value'];
        bool isRequired = field['required'] as bool;

        bool isCompleted = false;

        // Check if field is completed based on its type
        if (fieldName == 'Phone Number' || fieldName == 'Industries') {
          // For arrays, check if they have content
          isCompleted =
              fieldValue != null && fieldValue is List && fieldValue.isNotEmpty;
        } else if (fieldName == 'Social Media') {
          // For social media, check if any social links exist
          isCompleted = _hasSocialMediaLinks(profile);
        } else {
          // For strings, check if not null and not empty
          // Handle cases where the value might be "null" as a string
          if (fieldValue == null) {
            isCompleted = false;
          } else if (fieldValue.toString().toLowerCase() == 'null') {
            isCompleted = false;
          } else if (fieldValue.toString().trim().isEmpty) {
            isCompleted = false;
          } else {
            isCompleted = true;
          }
        }

        if (isCompleted) {
          completedFields++;
        } else if (isRequired) {
          missingFields.add(fieldName);
        } else {}
      }

      // Calculate percentage: all fields contribute to 100%
      completionPercentage =
          totalFields > 0 ? completedFields / totalFields : 0.0;

      // Ensure percentage is between 0 and 1
      completionPercentage = completionPercentage.clamp(0.0, 1.0);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completion',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              Text(
                '${(completionPercentage * 100).round()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completionPercentage,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
            minHeight: 8,
          ),
          // Show detailed field status

          if (missingFields.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Complete Your Profile',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please complete the following fields to have a complete profile:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    missingFields.take(3).join(', ') +
                        (missingFields.length > 3 ? '...' : ''),
                    style: TextStyle(
                      fontSize: 12,
                      color: kPrimaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (missingFields.length > 3) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${missingFields.length - 3} more fields to complete',
                      style: TextStyle(
                        fontSize: 11,
                        color: kPrimaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Tap the "Edit Profile" button below to update your information.',
                    style: TextStyle(
                      fontSize: 11,
                      color: kPrimaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: kPrimaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Profile Complete! ',
                  style: TextStyle(
                    fontSize: 12,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Helper method to check if user has social media links
  bool _hasSocialMediaLinks(profile) {
    if (profile?.socialMediaLinks == null) return false;

    final socialLinks = profile!.socialMediaLinks;

    // Check for both 'twitter' and 'x' keys (X was previously Twitter)
    bool hasLinks = (socialLinks['linkedin'] != null &&
            socialLinks['linkedin']!.isNotEmpty) ||
        (socialLinks['facebook'] != null &&
            socialLinks['facebook']!.isNotEmpty) ||
        (socialLinks['twitter'] != null &&
            socialLinks['twitter']!.isNotEmpty) ||
        (socialLinks['x'] != null && socialLinks['x']!.isNotEmpty) ||
        (socialLinks['instagram'] != null &&
            socialLinks['instagram']!.isNotEmpty);

    return hasLinks;
  }

  // Quick Actions Widget
  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  subtitle: 'Update your information',
                  color: kPrimaryColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileEditScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.qr_code,
                  title: 'QR Code',
                  subtitle: 'Show your QR code',
                  color: kPrimaryColor,
                  onTap: () => _showQRCode(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: kPrimaryColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Profile Statistics Widget
  Widget _buildProfileStats() {
    return Consumer3<ConnectionProvider, TestimonialProvider, EventProvider>(
      builder: (context, connectionProvider, testimonialProvider, eventProvider,
          child) {
        // Get connection count
        final connectionCount = connectionProvider
                .allconnectionsCount.value?.data.firstOrNull?.connections ??
            0;

        // Get testimonial count (received + given)
        final testimonialCount =
            (testimonialProvider.testimonialCounts['received'] ?? 0) +
                (testimonialProvider.testimonialCounts['given'] ?? 0);

        // Get event count (if available)
        final eventCount = eventProvider.events?.length ?? 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildStatCard(
                          'Connections',
                          connectionCount.toString(),
                          Icons.people,
                          kPrimaryColor)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStatCard(
                          'Testimonials',
                          testimonialCount.toString(),
                          Icons.message,
                          kPrimaryColor)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStatCard('Events', eventCount.toString(),
                          Icons.event, kPrimaryColor)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: kPrimaryColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _shareProfile() {
    final profile =
        Provider.of<ProfileProvider>(context, listen: false).profile;
    if (profile != null) {
      final shareText =
          'Check out my profile: ${profile.name} - ${profile.company}';
      // You can implement actual sharing using share_plus package
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sharing: $shareText'),
          backgroundColor: Colors.blue,
          action: SnackBarAction(
            label: 'Copy',
            textColor: Colors.white,
            onPressed: () {
              // Copy to clipboard
              // Clipboard.setData(ClipboardData(text: shareText));
            },
          ),
        ),
      );
    }
  }

  void _showQRCode() {
    final profile =
        Provider.of<ProfileProvider>(context, listen: false).profile;
    if (profile != null) {
      // Create QR code data with both user ID and profile ID in the expected format
      final qrData =
          'ProfileID:${profile.id ?? 'N/A'}|UserID:${profile.userid ?? 'N/A'}';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.qr_code,
                          color: kPrimaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile QR Code',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                            Text(
                              'Scan to view profile',
                              style: TextStyle(
                                fontSize: 12,
                                color: kPrimaryColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // QR Code Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: kPrimaryColor.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Real QR Code
                        QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                          foregroundColor: kPrimaryColor,
                          errorCorrectionLevel: QrErrorCorrectLevel.M,
                        ),
                        const SizedBox(height: 16),

                        // User Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                kPrimaryColor.withValues(alpha: 0.1),
                                kGradientEndColor.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: kPrimaryColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                profile.name ?? 'Unknown User',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.company ?? 'No Company',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: kPrimaryColor.withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'User ID: ${profile.userid?.toString() ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimaryColor,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Profile ID: ${profile.id?.toString() ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimaryColor,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: kPrimaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: kPrimaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Others can scan this QR code to view your profile',
                            style: TextStyle(
                              fontSize: 12,
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimaryColor,
                            side: BorderSide(color: kPrimaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Add share functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Share feature coming soon!'),
                                backgroundColor: kPrimaryColor,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  // Contact Action Methods
  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text('Opening phone app...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Clean phone number (remove spaces and special characters)
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

      // Try to launch phone with different modes
      bool launched = false;

      // First try with external application mode
      if (await canLaunchUrl(phoneUri)) {
        launched = await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
      }

      // If that fails, try with platform default mode
      if (!launched) {
        if (await canLaunchUrl(phoneUri)) {
          launched = await launchUrl(
            phoneUri,
            mode: LaunchMode.platformDefault,
          );
        }
      }

      if (launched) {
        // Show success message
        if (mounted) {}
      } else {
        _showErrorSnackBar('Phone app not available');
      }
    } catch (e) {
      _showErrorSnackBar('Phone call failed');
    }
  }

  Future<void> _sendEmail(String email) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text('Opening email app...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Clean email address
      String cleanEmail = email.trim();

      // Create mailto URI
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: cleanEmail,
      );

      // Try to launch email with different modes
      bool launched = false;

      // First try with external application mode
      if (await canLaunchUrl(emailUri)) {
        launched = await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );
      }

      // If that fails, try with platform default mode
      if (!launched) {
        if (await canLaunchUrl(emailUri)) {
          launched = await launchUrl(
            emailUri,
            mode: LaunchMode.platformDefault,
          );
        }
      }

      if (launched) {
        // Show success message
        if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('Email app opened for: $cleanEmail'),
          //     backgroundColor: Colors.green,
          //     duration: const Duration(seconds: 2),
          // //   ),
          // );
        }
      } else {
        _showErrorSnackBar('Email app not available');
      }
    } catch (e) {
      _showErrorSnackBar('Email failed');
    }
  }

  Future<void> _openLocation(String location) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text('Opening maps...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Clean location string
      String cleanLocation = location.trim();

      // Try to open in Google Maps
      final Uri mapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(cleanLocation)}',
      );

      // Try to launch maps with different modes
      bool launched = false;

      // First try with external application mode
      if (await canLaunchUrl(mapsUri)) {
        launched = await launchUrl(
          mapsUri,
          mode: LaunchMode.externalApplication,
        );
      }

      // If that fails, try with platform default mode
      if (!launched) {
        if (await canLaunchUrl(mapsUri)) {
          launched = await launchUrl(
            mapsUri,
            mode: LaunchMode.platformDefault,
          );
        }
      }

      // If still fails, try with inAppWebView mode
      if (!launched) {
        if (await canLaunchUrl(mapsUri)) {
          launched = await launchUrl(
            mapsUri,
            mode: LaunchMode.inAppWebView,
          );
        }
      }

      if (launched) {
        // Show success message
        if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          // SnackBar(
          //   content: Text('Maps opened for: $cleanLocation'),
          //   backgroundColor: Colors.green,
          //   duration: const Duration(seconds: 2),
          // // ),
          // );
        }
      } else {
        _showErrorSnackBar('Maps not available');
      }
    } catch (e) {
      _showErrorSnackBar('Location failed');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSocialMediaButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.8),
              color.withValues(alpha: 0.6)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSocialMediaIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'facebook':
        return Icons.facebook;
      case 'x':
        return FontAwesomeIcons.xTwitter; // Using a bird-like icon for X
      case 'instagram':
        return Icons.camera_alt;
      default:
        return Icons.link;
    }
  }

  Future<void> _launchSocialMedia(String url, String platform) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text('Opening $platform...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Clean and validate URL
      String cleanUrl = url.trim();

      // Sanitize URL: Add https:// if missing
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }

      final uri = Uri.parse(cleanUrl);

      // Try to launch URL with different modes
      bool launched = false;

      // First try with external application mode
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }

      // If that fails, try with platform default mode
      if (!launched) {
        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        }
      }

      // If still fails, try with inAppWebView mode
      if (!launched) {
        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
          );
        }
      }

      if (launched) {
        // Show success message
        if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('$platform opened successfully'),
          //     backgroundColor: Colors.green,
          //     duration: const Duration(seconds: 2),
          //   ),
          // );
        }
      } else {
        _showErrorSnackBar('$platform not available');
      }
    } catch (e) {
      _showErrorSnackBar('$platform failed');
    }
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Profile Visibility'),
                subtitle: const Text('Public'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement visibility toggle
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                subtitle: const Text('Enabled'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notification toggle
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Privacy'),
                subtitle: const Text('Manage privacy settings'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile;

    if (profileProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (profileProvider.error != null) {
      // Show only the first 4 words of the error message
      String reason = profileProvider.error!;
      List<String> words = reason.split(' ');
      String shortReason = words.take(4).join(' ');
      return Center(child: Text('Error: $shortReason'));
    }

    final hasSocialLinks = (profile?.socialMediaLinks['linkedin'] != null &&
            profile!.socialMediaLinks['linkedin']!.isNotEmpty) ||
        (profile?.socialMediaLinks['facebook'] != null &&
            profile!.socialMediaLinks['facebook']!.isNotEmpty) ||
        (profile?.socialMediaLinks['twitter'] != null &&
            profile!.socialMediaLinks['twitter']!.isNotEmpty);

    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refreshProfileImage,
            icon: const Icon(Icons.refresh, size: 28, color: kAppBarIconColor),
            tooltip: 'Refresh Profile',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings, size: 30, color: kAppBarIconColor),
            tooltip: 'Settings',
          )
        ],
      ),
      drawer: MyDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 140,
                          child: Consumer<ProfileProvider>(
                            builder: (context, profileProvider, child) {
                              final profile = profileProvider.profile;
                              final imageUrl = profile?.imageUrl;
                              final hasImage =
                                  imageUrl != null && imageUrl.isNotEmpty;

                              print(
                                  '🔄 ProfileScreen: Building CircleAvatar - hasImage: $hasImage, imageUrl: $imageUrl');

                              // Debug: Check if this is a new image URL
                              if (imageUrl != null && imageUrl.isNotEmpty) {
                                print(
                                    '🖼️ ProfileScreen: Displaying image: $imageUrl');
                              }

                              // Create a stable key based on the image URL
                              final uniqueKey =
                                  'profile-image-${imageUrl ?? 'no-image'}';

                              return Container(
                                key: ValueKey(uniqueKey),
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kPrimaryColor.withValues(alpha: 0.1),
                                ),
                                child: hasImage
                                    ? ClipOval(
                                        child: Image.network(
                                          imageUrl!,
                                          width: 140,
                                          height: 140,
                                          fit: BoxFit.cover,
                                          headers: {
                                            'Cache-Control': 'no-cache',
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            print(
                                                '❌ ProfileScreen: Image load error: $error');

                                            // Handle 304 Not Modified error specifically
                                            if (error
                                                .toString()
                                                .contains('304')) {
                                              print(
                                                  '⚠️ ProfileScreen: 304 Not Modified - handling cache error');
                                              // Handle the cache error
                                              _handleImageCacheError();
                                              return Icon(
                                                Icons.camera_alt,
                                                size: 40,
                                                color: kPrimaryColor,
                                              );
                                            }

                                            return Icon(
                                              Icons.camera_alt,
                                              size: 40,
                                              color: kPrimaryColor,
                                            );
                                          },
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(kPrimaryColor),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
                                        Icons.camera_alt,
                                        size: 40,
                                        color: kPrimaryColor,
                                      ),
                              );
                            },
                          ),
                        ),
                        // Add a camera icon overlay to indicate it's tappable
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 200,
                    height: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (profile?.name != null &&
                            (profile!.name?.isNotEmpty ?? false))
                          Text(
                            profile!.name ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: kPrimaryColor,
                            ),
                          ),
                        if (profile?.company != null &&
                            (profile!.company?.isNotEmpty ?? false))
                          Text(
                            profile!.company ?? '',
                            style: TextStyle(
                                fontSize: 14,
                                color: kPrimaryColor.withValues(alpha: 0.7)),
                          ),
                        const SizedBox(height: 5),
                        if (profile?.chapter != null &&
                            (profile!.chapter?.isNotEmpty ?? false))
                          Text(
                            "Chapter: ${profile!.chapter ?? ''}",
                            style: TextStyle(
                                color: kPrimaryColor.withValues(alpha: 0.8),
                                fontSize: 14),
                          ),
                        const SizedBox(height: 5),
                        if (profile?.region != null &&
                            (profile!.region?.isNotEmpty ?? false))
                          Text(
                            "Region: ${profile!.region ?? ''}",
                            style: TextStyle(
                                color: kPrimaryColor.withValues(alpha: 0.8)),
                          ),
                        const SizedBox(height: 5),
                        if (profile?.memberSince != null &&
                            (profile!.memberSince?.isNotEmpty ?? false))
                          Text(
                            "Member Since: ${profile!.memberSince ?? ''}",
                            style: TextStyle(
                                color: kPrimaryColor.withValues(alpha: 0.8),
                                fontSize: 14),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Profile Completion Progress
              _buildProfileCompletionProgress(profile),

              // Quick Actions Section
              _buildQuickActions(),

              // Profile Statistics
              _buildProfileStats(),

              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (profile?.name != null &&
                        (profile!.name?.isNotEmpty ?? false))
                      Text(
                        "About ${profile!.name ?? ''}",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: kPrimaryColor),
                      ),
                    const SizedBox(height: 10),
                    if (profile?.about != null &&
                        (profile!.about?.isNotEmpty ?? false))
                      Text(
                        profile!.about ?? '',
                        style: TextStyle(
                            fontSize: 14,
                            color: kPrimaryColor.withValues(alpha: 0.7)),
                        textAlign: TextAlign.justify,
                        softWrap: true,
                      ),
                  ],
                ),
              ),
              // Industries Section with Enhanced Design

              if (profile?.industries != null &&
                  (profile!.industries?.isNotEmpty ?? false))
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kPrimaryColor.withValues(alpha: 0.1),
                        Colors.white
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.work,
                                color: kPrimaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Professional Industries',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              kPrimaryColor.withValues(alpha: 0.8),
                              kGradientEndColor.withValues(alpha: 0.6)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.work_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                profile!.industries.isNotEmpty
                                    ? profile!.industries.first
                                        .split(',')
                                        .where((industry) =>
                                            industry.trim().isNotEmpty)
                                        .map((industry) => industry.trim())
                                        .join(',  ')
                                    : '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              // Contact Details section: remove phone numbers, only show website if present
              if (profile?.website != null &&
                  (profile!.website?.isNotEmpty ?? false))
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 15, 0, 5),
                  child: Text(
                    "Web Address",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryColor),
                  ),
                ),
              if (profile?.website != null &&
                  (profile!.website?.isNotEmpty ?? false))
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kPrimaryColor),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            profile!.website ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Contact Details section with interactive icons
              if ((profile?.phonenumbers != null &&
                      profile!.phonenumbers!.isNotEmpty) ||
                  (profile?.email != null && profile!.email!.isNotEmpty) ||
                  (profile?.googleMapLocation != null &&
                      profile!.googleMapLocation!.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 15, 0, 5),
                  child: Text(
                    "Contact Details",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryColor),
                  ),
                ),

              // Phone Numbers with Tappable Container
              if (profile?.phonenumbers != null &&
                  profile!.phonenumbers!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 8),
                  child: Column(
                    children: profile!.phonenumbers!.map((num) {
                      final phoneNumber = "+91 ${num?.toString()}" ?? "-";
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () => _makePhoneCall(phoneNumber),
                              child: Container(
                                width: 250, // Fixed width instead of Expanded
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: kPrimaryColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.green.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.phone,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          phoneNumber,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Email with Tappable Container
              if (profile?.email != null && profile!.email!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _sendEmail(profile!.email!),
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: kPrimaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryColor.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.email,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      profile!.email ?? "",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Location with Map Icon
              if (profile?.googleMapLocation != null &&
                  profile!.googleMapLocation!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kPrimaryColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    profile!.googleMapLocation ?? "",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _openLocation(profile!.googleMapLocation!),
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: kPrimaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: kPrimaryColor,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.map,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Enhanced Social Media Section
              if (hasSocialLinks)
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 15, 0, 5),
                  child: Text(
                    "Connect on Social Media",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryColor),
                  ),
                ),
              if (hasSocialLinks)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kPrimaryColor.withValues(alpha: 0.1),
                        Colors.white
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.share,
                                color: kPrimaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Social Media Profiles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (profile?.socialMediaLinks['linkedin'] != null &&
                              profile!.socialMediaLinks['linkedin']!.isNotEmpty)
                            _buildSocialMediaButton(
                              icon: FontAwesomeIcons.linkedin,
                              label: "LinkedIn",
                              color: kPrimaryColor,
                              onTap: () => _launchSocialMedia(
                                profile!.socialMediaLinks['linkedin']!,
                                'LinkedIn',
                              ),
                            ),
                          if (profile?.socialMediaLinks['facebook'] != null &&
                              profile!.socialMediaLinks['facebook']!.isNotEmpty)
                            _buildSocialMediaButton(
                              icon: Icons.facebook,
                              label: "Facebook",
                              color: kPrimaryColor,
                              onTap: () => _launchSocialMedia(
                                profile!.socialMediaLinks['facebook']!,
                                'Facebook',
                              ),
                            ),
                          if (profile?.socialMediaLinks['twitter'] != null &&
                              profile!.socialMediaLinks['twitter']!.isNotEmpty)
                            _buildSocialMediaButton(
                              icon: FontAwesomeIcons.xTwitter,
                              label: "X",
                              color: kPrimaryColor,
                              onTap: () => _launchSocialMedia(
                                profile!.socialMediaLinks['twitter']!,
                                'X',
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
