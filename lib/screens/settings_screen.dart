import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/screens/profile/profile_edit_screen.dart';
import 'package:master_mind/screens/Reset_pass_screen.dart';
import 'package:master_mind/screens/content_screen.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/Auth_provider.dart';
import 'package:master_mind/screens/auth/Login_form.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Oxygen Mastermind',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.info, color: kOxygenMMPurple),
      children: [
        const Text(
            'Oxygen Mastermind is a networking and event management app.'),
        const SizedBox(height: 8),
        const Text('Developed by Decimal Technologies.'),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        if (PlatformUtils.isIOS) {
          Navigator.of(context).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (context) => const LoginForm()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginForm()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kAppBarIconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Account Settings Section
            _buildSectionHeader('Account Settings'),
            _buildActionTile(
              'Edit Profile',
              'Update your profile information',
              Icons.person,
              () {
                if (PlatformUtils.isIOS) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const ProfileEditScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileEditScreen()),
                  );
                }
              },
            ),
            _buildActionTile(
              'Reset Password',
              'Change your account password',
              Icons.lock,
              () {
                if (PlatformUtils.isIOS) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const ResetPasswordScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ResetPasswordScreen()),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            // App Settings Section
            _buildSectionHeader('App Settings'),
            _buildSwitchTile(
              'Enable Notifications',
              'Receive notifications for important updates',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),

            const SizedBox(height: 20),

            // Support Section
            _buildSectionHeader('Support'),
            _buildActionTile(
              'Help & FAQ',
              'Get help and find answers to common questions',
              Icons.help_outline,
              () {
                if (PlatformUtils.isIOS) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const ContentScreen(
                        title: 'Help & FAQ',
                        content: _faqContent,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContentScreen(
                        title: 'Help & FAQ',
                        content: _faqContent,
                      ),
                    ),
                  );
                }
              },
            ),
            _buildActionTile(
              'Send Feedback',
              'Share your thoughts and suggestions',
              Icons.feedback,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feedback - Coming Soon!'),
                    backgroundColor: Colors.blue,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Legal Section
            _buildSectionHeader('Legal'),
            _buildActionTile(
              'Privacy Policy',
              'Read our privacy policy',
              Icons.privacy_tip,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContentScreen(
                      title: 'Privacy Policy',
                      content: _privacyPolicyContent,
                    ),
                  ),
                );
              },
            ),
            _buildActionTile(
              'Terms of Service',
              'Read our terms of service',
              Icons.article,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContentScreen(
                      title: 'Terms of Service',
                      content: _termsOfServiceContent,
                    ),
                  ),
                );
              },
            ),
            _buildActionTile(
              'About',
              'App information and version details',
              Icons.info_outline,
              _showAboutDialog,
            ),

            const SizedBox(height: 20),

            // Account Actions Section
            _buildSectionHeader('Account Actions'),
            _buildActionTile(
              'Logout',
              'Sign out of your account',
              Icons.logout,
              () => _handleLogout(context),
              isDestructive: true,
            ),

            const SizedBox(height: 30),

            // Version Info
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
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

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
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
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : kOxygenMMPurple,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 16,
        ),
        onTap: onTap,
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
        activeColor: kOxygenMMPurple,
      ),
    );
  }
}

// Content constants for FAQ, Privacy Policy, and Terms of Service
const String _faqContent = '''
Frequently Asked Questions

Q: How do I create an account?
A: You can create an account by downloading the app and following the registration process. You'll need to provide your basic information and verify your email address.

Q: How do I update my profile?
A: Go to Settings > Edit Profile to update your personal information, contact details, and professional information.

Q: How do I register for events?
A: Navigate to the Events section, browse available events, and tap on any event to view details and register.

Q: How do I connect with other members?
A: Use the search functionality to find other members, then send them a connection request.

Q: How do I upload photos to the gallery?
A: Go to the Gallery section and tap the upload button to add photos from your device.

Q: What if I forget my password?
A: Use the "Forgot Password" option on the login screen to reset your password via email.

Q: How do I contact support?
A: You can reach out through the "Send Feedback" option in Settings or contact us directly through the app.

Q: Is my data secure?
A: Yes, we take data security seriously and implement industry-standard security measures to protect your information.

Q: Can I delete my account?
A: Yes, you can delete your account through the Settings menu. This action is permanent and cannot be undone.

Q: How do I receive notifications?
A: You can manage your notification preferences in the Settings section under "App Settings".
''';

const String _privacyPolicyContent = '''
Privacy Policy

Last updated: [Date]

1. Information We Collect
We collect information you provide directly to us, such as when you create an account, update your profile, or contact us for support.

2. How We Use Your Information
We use the information we collect to:
- Provide, maintain, and improve our services
- Process transactions and send related information
- Send technical notices, updates, and support messages
- Respond to your comments and questions

3. Information Sharing
We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.

4. Data Security
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

5. Your Rights
You have the right to:
- Access your personal information
- Correct inaccurate information
- Delete your account and associated data
- Object to certain processing of your information

6. Contact Us
If you have any questions about this Privacy Policy, please contact us through the app or at our support email.

7. Changes to This Policy
We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.
''';

const String _termsOfServiceContent = '''
Terms of Service

Last updated: [Date]

1. Acceptance of Terms
By accessing and using this app, you accept and agree to be bound by the terms and provision of this agreement.

2. Use License
Permission is granted to temporarily download one copy of the app for personal, non-commercial transitory viewing only.

3. User Accounts
You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.

4. Prohibited Uses
You may not use our app:
- For any unlawful purpose or to solicit others to perform unlawful acts
- To violate any international, federal, provincial, or state regulations, rules, laws, or local ordinances
- To infringe upon or violate our intellectual property rights or the intellectual property rights of others

5. Content
Our app allows you to post, link, store, share and otherwise make available certain information, text, graphics, videos, or other material. You are responsible for the content that you post to the app.

6. Privacy Policy
Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the app.

7. Termination
We may terminate or suspend your account and bar access to the app immediately, without prior notice or liability, under our sole discretion, for any reason whatsoever.

8. Disclaimer
The information on this app is provided on an "as is" basis. To the fullest extent permitted by law, this Company excludes all representations, warranties, conditions and terms.

9. Governing Law
These Terms shall be interpreted and governed by the laws of the jurisdiction in which our company is located.

10. Contact Information
If you have any questions about these Terms of Service, please contact us through the app or at our support email.
''';
