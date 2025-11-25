import 'package:flutter/material.dart';
import 'package:master_mind/providers/Auth_provider.dart';
import 'package:master_mind/providers/profile_provider.dart';
import 'package:master_mind/screens/auth/Login_form.dart';
import 'package:master_mind/screens/connection/connectionDetails.dart';
import 'package:master_mind/screens/testimonial/testimonial_listing_screen.dart';
import 'package:master_mind/screens/Accountability/accountability_page.dart';

// Removed unused import
import 'package:master_mind/screens/gallery_screen.dart';
import 'package:master_mind/screens/settings_screen.dart';
import 'package:master_mind/utils/const.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginForm()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Removed unused variables

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              buttonColor.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 5),
          children: [
            // Quick Actions Section
            _buildSectionHeader('Quick Actions'),

            _buildMenuItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              subtitle: 'Overview & Analytics',
              onTap: () => Navigator.pop(context),
              isActive: true,
            ),

            _buildMenuItem(
              icon: Icons.people,
              title: 'Connections',
              subtitle: 'Manage your network',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Connectiondetails(),
                    ));
              },
            ),

            _buildMenuItem(
              icon: Icons.star,
              title: 'Testimonials',
              subtitle: 'View & manage testimonials',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TestimonialListingScreen(),
                    ));
              },
            ),

            // Business Tools Section
            _buildSectionHeader('Business Tools'),

            _buildMenuItem(
              icon: Icons.assignment,
              title: 'Accountability',
              subtitle: 'Set & track goals',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountabilityPage(),
                    ));
              },
            ),

            // _buildMenuItem(
            //   icon: Icons.share,
            //   title: 'Referrals',
            //   subtitle: 'Share & earn rewards',
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => const RefferalScreen(),
            //         ));
            //   },
            // ),

            // Community Section
            _buildSectionHeader('Community'),

            _buildMenuItem(
              icon: Icons.groups,
              title: 'Community',
              subtitle: 'Connect with members',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/community');
              },
            ),

            _buildMenuItem(
              icon: Icons.photo_library,
              title: 'Gallery',
              subtitle: 'Browse photos & events',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GalleryPage(),
                    ));
              },
            ),

            // Offers Section
            _buildSectionHeader('Offers'),

            _buildMenuItem(
              icon: Icons.local_offer,
              title: 'Discount Coupons',
              subtitle: 'Exclusive restaurant offers',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/discount-coupons');
              },
            ),

            // Settings Section
            _buildSectionHeader('Settings'),

            _buildMenuItem(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'App preferences',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(),
                    ));
              },
            ),

            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get assistance',
              onTap: () {
                Navigator.pop(context);
                _showHelpDialog(context);
              },
            ),

            const SizedBox(height: 20),

            // Logout Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      decoration: BoxDecoration(
        color: isActive
            ? kPrimaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: kPrimaryColor.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isActive ? kPrimaryColor : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isActive ? kWhite : Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? kPrimaryColor : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
                Icons.email, 'Email Support', 'support@mastermind.com'),
            const SizedBox(height: 12),
            _buildHelpItem(Icons.phone, 'Phone Support', '+1 (555) 123-4567'),
            const SizedBox(height: 12),
            _buildHelpItem(Icons.chat, 'Live Chat', 'Available 24/7'),
            const SizedBox(height: 12),
            _buildHelpItem(Icons.article, 'FAQ', 'Common questions & answers'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: buttonColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
