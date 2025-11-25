import 'package:flutter/material.dart';
import 'package:master_mind/utils/const.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onActivityFeedPressed;
  final VoidCallback onSettingsPressed;

  const HomeAppBar({
    super.key,
    required this.onActivityFeedPressed,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 2,
      backgroundColor: Colors.white,
      foregroundColor: kPrimaryColor,
      title: _buildAppBarTitle(),
      centerTitle: false,
      actions: _buildAppBarActions(),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.home_rounded,
            color: kPrimaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "Dashboard",
          style: TextStyle(
            color: kPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      _buildActionButton(
        icon: Icons.notifications_outlined,
        tooltip: 'Activity Feed',
        onPressed: onActivityFeedPressed,
      ),
      _buildActionButton(
        icon: Icons.settings_outlined,
        tooltip: 'Settings',
        onPressed: onSettingsPressed,
      ),
    ];
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: tooltip,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
