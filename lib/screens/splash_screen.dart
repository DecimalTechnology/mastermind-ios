import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/Auth_provider.dart';
import 'package:master_mind/screens/home/Landing_screen.dart';
import 'package:master_mind/screens/auth/Login_form.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';
// Removed unused import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String _loadingMessage = "Loading...";

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Start animation
    _animationController.forward();

    // Check authentication status after animation
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // First check if user data exists in shared preferences
      final hasStoredData = await authProvider.hasStoredUserData();

      if (hasStoredData) {
        setState(() {
          _loadingMessage = "Checking credentials...";
        });
      } else {
        setState(() {
          _loadingMessage = "Welcome to Oxygen Mastermind...";
        });
      }

      // Check if user is already authenticated
      await authProvider.checkAuthStatus();

      if (!mounted) return;

      // Navigate based on authentication status
      if (authProvider.isAuthenticated) {
        setState(() {
          _loadingMessage = "Welcome back!";
        });

        // Small delay to show the welcome message
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Check for app updates before navigating
        // await MockAppUpdateService.checkAndShowUpdateDialog(context);

        if (PlatformUtils.isIOS) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (context) => const BottomNavbar()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const BottomNavbar()),
          );
        }
      } else {
        setState(() {
          _loadingMessage = "Please sign in...";
        });

        // Small delay to show the sign in message
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        if (PlatformUtils.isIOS) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (context) => const LoginForm()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginForm()),
          );
        }
      }
    } catch (e) {
      // If there's an error, navigate to login form
      if (mounted) {
        setState(() {
          _loadingMessage = "Please sign in...";
        });

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        if (PlatformUtils.isIOS) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (context) => const LoginForm()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginForm()),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: kBackgroundColor,
        child: SafeArea(
          child: _buildContent(context),
        ),
      );
    }
    return PlatformWidget.scaffold(
      context: context,
      backgroundColor: kBackgroundColor,
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo with animations
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // App Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            'assets/loginScreen/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // App Name
                      Text(
                        "Oxygen Mastermind",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tagline
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Text(
                          "Creating Extraordinary Results by Igniting the Power of People",
                          style: TextStyle(
                            fontSize: 16,
                            color: kGreyTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 60),

          // Loading indicator
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    PlatformWidget.loadingIndicator(
                      color: kPrimaryColor,
                      size: 40,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _loadingMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: kGreyTextColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
