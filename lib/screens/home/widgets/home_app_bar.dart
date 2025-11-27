import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';

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
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leading: PlatformUtils.isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Icon(
                CupertinoIcons.bars,
                color: kPrimaryColor,
                size: 28,
              ),
            )
          : IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu, color: buttonColor),
              tooltip: 'Menu',
            ),
      title: const Text(
        "Dashboard",
        style: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: onActivityFeedPressed,
          icon: const Icon(Icons.notifications_outlined, color: buttonColor),
          tooltip: 'Activity Feed',
        ),
        IconButton(
          onPressed: onSettingsPressed,
          icon: const Icon(Icons.settings_outlined, color: buttonColor),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
