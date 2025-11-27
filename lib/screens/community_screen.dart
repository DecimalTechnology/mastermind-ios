import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/screens/settings_screen.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/screens/Accountability/accountability_page.dart';
import 'package:master_mind/screens/vision_board_screen.dart';
import 'package:master_mind/widgets/home_drawer.dart';
import 'package:master_mind/screens/tips/tip_session_detail_screen.dart';
import 'dart:math' as math;

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Community',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              if (PlatformUtils.isIOS) {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => SettingsScreen()));
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()));
              }
            },
            icon: const Icon(Icons.settings, color: buttonColor),
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey[50]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Community Building',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get to know your Oxygen Mastermind Members',
                style: TextStyle(
                  fontSize: 18,
                  color: buttonColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: _SunRaysLayout(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SunRaysLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final layoutSize = math.min(screenSize.width, screenSize.height) * 0.8;

    return SizedBox(
      width: layoutSize,
      height: layoutSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Central sun
          Container(
            width: layoutSize * 0.35,
            height: layoutSize * 0.35,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  buttonColor.withValues(alpha: 0.9),
                  buttonColor,
                  buttonColor.withValues(alpha: 0.8),
                ],
                center: Alignment.center,
                radius: 0.8,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: buttonColor.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Container(
              margin: EdgeInsets.all(layoutSize * 0.05),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(layoutSize * 0.03),
                child: Image.asset(
                  'assets/loginScreen/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Ray buttons positioned around the sun
          ..._buildRayButtons(context, layoutSize),
        ],
      ),
    );
  }

  List<Widget> _buildRayButtons(BuildContext context, double layoutSize) {
    final List<_RayButton> rayButtons = [
      _RayButton(
        angle: 0, // Top
        icon: Icons.lightbulb,
        label: 'Tips',
        onTap: () {
          if (PlatformUtils.isIOS) {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => const TipSessionDetailScreen(),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const TipSessionDetailScreen(),
              ),
            );
          }
        },
        layoutSize: layoutSize,
      ),
      _RayButton(
        angle: 60, // Top-right
        icon: Icons.message,
        label: 'Testimonials',
        onTap: () {
          Navigator.of(context).pushNamed('/testimonial-listing');
        },
        layoutSize: layoutSize,
      ),
      _RayButton(
        angle: 120, // Bottom-right
        icon: Icons.assignment,
        label: 'Accountability',
        onTap: () {
          if (PlatformUtils.isIOS) {
            Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => AccountabilityPage()),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AccountabilityPage()),
            );
          }
        },
        layoutSize: layoutSize,
      ),
      _RayButton(
        angle: 180, // Bottom
        icon: Icons.connect_without_contact,
        label: 'Connections',
        onTap: () {
          Navigator.of(context).pushNamed('/connections-listing');
        },
        layoutSize: layoutSize,
      ),
      _RayButton(
        angle: 240, // Bottom-left
        icon: Icons.photo_library,
        label: 'Gallery',
        onTap: () {
          Navigator.of(context).pushNamed('/gallery');
        },
        layoutSize: layoutSize,
        yOffset: -layoutSize * 0.03, // Move up slightly
      ),
      _RayButton(
        angle: 305, // Top-left, moved right
        icon: Icons.visibility,
        label: 'Vision Board',
        onTap: () {
          if (PlatformUtils.isIOS) {
            Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => const VisionBoardScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const VisionBoardScreen()),
            );
          }
        },
        layoutSize: layoutSize,
        yOffset: -layoutSize * 0.05, // Move up slightly
      ),
    ];

    return rayButtons.map((rayButton) => rayButton.build(context)).toList();
  }
}

class _RayButton {
  final double angle;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double layoutSize;
  final double? yOffset;

  _RayButton({
    required this.angle,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.layoutSize,
    this.yOffset,
  });

  Widget build(BuildContext context) {
    final double radius = layoutSize * 0.35;
    final double centerX = layoutSize / 2;
    final double centerY = layoutSize / 2;
    final double buttonSize = layoutSize * 0.2;

    final double radians = angle * (3.14159 / 180);
    final double x = centerX + radius * math.cos(radians);
    final double y = (centerY + (yOffset ?? 0)) + radius * math.sin(radians);

    return Positioned(
      left: x - buttonSize / 2,
      top: y - buttonSize / 2,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    buttonColor.withValues(alpha: 0.9),
                    buttonColor,
                    buttonColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(buttonSize * 0.25),
                boxShadow: [
                  BoxShadow(
                    color: buttonColor.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.8),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: buttonSize * 0.4,
              ),
            ),
          ),
          SizedBox(height: buttonSize * 0.1),
          Text(
            label,
            style: TextStyle(
              color: buttonColor,
              fontWeight: FontWeight.w900,
              fontSize: buttonSize * 0.16,
              shadows: [
                Shadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
