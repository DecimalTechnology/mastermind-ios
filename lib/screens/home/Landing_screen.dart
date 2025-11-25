import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/providers/bottom_nav_provider.dart';
// Removed unused import
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/screens/event/Event_screen.dart';
import 'package:master_mind/screens/home/Home_screen.dart';
import 'package:master_mind/screens/profile/myProfile_screen.dart';
import 'package:master_mind/screens/Search/search_screen.dart';
import 'package:master_mind/screens/community_screen.dart';
import 'package:master_mind/utils/const.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomNavProvider = Provider.of<BottomNavProvider>(context);
    final int selectedIndex = bottomNavProvider.selectedIndex;

    final List<Widget> screens = [
      HomeScreen(),
      SearchScreen(),
      EventPage(),
      CommunityScreen(),
      ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (selectedIndex == 0) {
          // If on Home tab, exit the app
          SystemNavigator.pop();
        } else {
          // If on other tabs, navigate back to Home tab
          bottomNavProvider.setIndex(0);
        }
      },
      child: PlatformWidget.scaffold(
        context: context,
        body: IndexedStack(
          index: selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: PlatformUtils.isIOS
            ? CupertinoTabBar(
                currentIndex: selectedIndex,
                onTap: (index) => bottomNavProvider.setIndex(index),
                backgroundColor: CupertinoColors.systemBackground,
                activeColor: buttonColor,
                inactiveColor: CupertinoColors.systemGrey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.search),
                    label: "Search",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.calendar),
                    label: "Events",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.group),
                    label: "Community",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.person),
                    label: "Profile",
                  ),
                ],
              )
            : BottomNavigationBar(
                currentIndex: selectedIndex,
                onTap: (index) => bottomNavProvider.setIndex(index),
                backgroundColor: Colors.white,
                selectedItemColor: buttonColor,
                unselectedItemColor: Colors.grey,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search_outlined),
                    activeIcon: Icon(Icons.search),
                    label: "Search",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.event_outlined),
                    activeIcon: Icon(Icons.event),
                    label: "Events",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.groups_outlined),
                    activeIcon: Icon(Icons.groups),
                    label: "Community",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: "Profile",
                  ),
                ],
              ),
      ),
    );
  }
}
