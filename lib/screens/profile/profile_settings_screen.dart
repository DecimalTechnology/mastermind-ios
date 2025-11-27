import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _profileVisibility = true;
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _connectionRequests = true;
  bool _testimonialRequests = true;

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Profile Settings",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: kPrimaryColor, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Profile Visibility Section
            _buildSectionHeader('Profile Visibility'),
            _buildSwitchTile(
              'Public Profile',
              'Make your profile visible to all members',
              _profileVisibility,
              (value) => setState(() => _profileVisibility = value),
            ),

            const SizedBox(height: 20),

            // Notification Settings Section
            _buildSectionHeader('Notification Settings'),
            _buildSwitchTile(
              'Enable Notifications',
              'Receive notifications for important updates',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            if (_notificationsEnabled) ...[
              _buildSwitchTile(
                'Email Notifications',
                'Receive notifications via email',
                _emailNotifications,
                (value) => setState(() => _emailNotifications = value),
              ),
              _buildSwitchTile(
                'Push Notifications',
                'Receive push notifications on your device',
                _pushNotifications,
                (value) => setState(() => _pushNotifications = value),
              ),
            ],

            const SizedBox(height: 20),

            // Connection Settings Section
            _buildSectionHeader('Connection Settings'),
            _buildSwitchTile(
              'Connection Requests',
              'Allow others to send you connection requests',
              _connectionRequests,
              (value) => setState(() => _connectionRequests = value),
            ),
            _buildSwitchTile(
              'Testimonial Requests',
              'Allow others to request testimonials from you',
              _testimonialRequests,
              (value) => setState(() => _testimonialRequests = value),
            ),

            const SizedBox(height: 30),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: kPrimaryColor,
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implement actual settings save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings Save - Coming Soon!'),
        backgroundColor: kPrimaryColor,
        duration: Duration(seconds: 2),
      ),
    );
    // Don't navigate back since it's not actually implemented yret
  }
}
