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
            ? Container(
                padding: const EdgeInsets.only(top: 15, bottom: 0),
                child: CupertinoTabBar(
                  currentIndex: selectedIndex,
                  onTap: (index) => bottomNavProvider.setIndex(index),
                  backgroundColor: CupertinoColors.systemBackground,
                  activeColor: buttonColor,
                  inactiveColor: CupertinoColors.systemGrey,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: Icon(CupertinoIcons.home),
                      ),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: Icon(CupertinoIcons.search),
                      ),
                      label: "Search",
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: Icon(CupertinoIcons.calendar),
                      ),
                      label: "Events",
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: Icon(CupertinoIcons.group),
                      ),
                      label: "Community",
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: Icon(CupertinoIcons.person),
                      ),
                      label: "Profile",
                    ),
                  ],
                ),
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
                    icon: Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      child: Icon(Icons.home_outlined),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      child: Icon(Icons.home),
                    ),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      child: Icon(Icons.search_outlined),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      child: Icon(Icons.search),
                    ),
                    label: "Search",
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      child: Icon(Icons.event_outlined),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      child: Icon(Icons.event),
                    ),
                    label: "Events",
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      child: Icon(Icons.groups_outlined),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      child: Icon(Icons.groups),
                    ),
                    label: "Community",
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      child: Icon(Icons.person_outline),
                    ),
                    activeIcon: Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 4),
                      child: Icon(Icons.person),
                    ),
                    label: "Profile",
                  ),
                ],
              ),
      ),
    );
  }
}
