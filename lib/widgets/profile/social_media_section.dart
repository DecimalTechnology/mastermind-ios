import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:master_mind/utils/const.dart';

class SocialMediaSection extends StatelessWidget {
  final dynamic profile;

  const SocialMediaSection({
    super.key,
    required this.profile,
  });

  bool _hasSocialLinks() {
    if (profile?.socialMediaLinks == null) return false;

    final socialLinks = profile!.socialMediaLinks;
    return (socialLinks['linkedin'] != null &&
            socialLinks['linkedin']!.isNotEmpty) ||
        (socialLinks['facebook'] != null &&
            socialLinks['facebook']!.isNotEmpty) ||
        (socialLinks['twitter'] != null &&
            socialLinks['twitter']!.isNotEmpty) ||
        (socialLinks['instagram'] != null &&
            socialLinks['instagram']!.isNotEmpty);
  }

  Future<void> _launchSocialMedia(
      BuildContext context, String url, String platform) async {
    try {
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

      if (!launched) {
        _showErrorSnackBar(context, '$platform not available');
      }
    } catch (e) {
      _showErrorSnackBar(context, '$platform failed');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Context may be invalid after launching external app
      debugPrint('Could not show snackbar: $message');
    }
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

  @override
  Widget build(BuildContext context) {
    if (!_hasSocialLinks()) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor.withValues(alpha: 0.1), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
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
                    child: Icon(Icons.share, color: kPrimaryColor, size: 20),
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
                        context,
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
                        context,
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
                        context,
                        profile!.socialMediaLinks['twitter']!,
                        'X',
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
