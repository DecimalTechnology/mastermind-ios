import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/screens/auth/Login_form.dart';
import 'package:master_mind/screens/home/Landing_screen.dart';
import 'package:master_mind/screens/splash_screen.dart';
import 'package:master_mind/screens/discount_coupon/discount_coupon_screen.dart';
import 'package:master_mind/core/error_handling/error_handling.dart';
import 'package:master_mind/utils/platform_utils.dart';

/// Centralized navigation service for the app
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get the current context
  BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to a named route with error handling
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) async {
    try {
      if (context == null) {
        throw Exception('Navigation context is not available');
      }
      return await Navigator.of(context!)
          .pushNamed<T>(routeName, arguments: arguments);
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current,
          context: 'NavigationService.navigateTo');
      return null;
    }
  }

  /// Navigate to a named route and replace current screen
  Future<T?> navigateToReplacement<T>(String routeName,
      {Object? arguments}) async {
    try {
      if (context == null) {
        throw Exception('Navigation context is not available');
      }
      return await Navigator.of(context!)
          .pushReplacementNamed<T, void>(routeName, arguments: arguments);
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current,
          context: 'NavigationService.navigateToReplacement');
      return null;
    }
  }

  /// Navigate to a named route and clear all previous routes
  Future<T?> navigateToAndClear<T>(String routeName,
      {Object? arguments}) async {
    try {
      if (context == null) {
        throw Exception('Navigation context is not available');
      }
      return await Navigator.of(context!).pushNamedAndRemoveUntil<T>(
        routeName,
        (route) => false,
        arguments: arguments,
      );
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current,
          context: 'NavigationService.navigateToAndClear');
      return null;
    }
  }

  /// Navigate to a new screen with platform-aware route
  Future<T?> navigateToScreen<T>(Widget screen) async {
    try {
      if (context == null) {
        throw Exception('Navigation context is not available');
      }
      if (PlatformUtils.isIOS) {
        return await Navigator.of(context!).push<T>(
          CupertinoPageRoute<T>(builder: (context) => screen),
        );
      }
      return await Navigator.of(context!).push<T>(
        MaterialPageRoute<T>(builder: (context) => screen),
      );
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current,
          context: 'NavigationService.navigateToScreen');
      return null;
    }
  }

  /// Navigate to a new screen and replace current screen
  Future<T?> navigateToScreenReplacement<T>(Widget screen) async {
    try {
      if (context == null) {
        throw Exception('Navigation context is not available');
      }
      if (PlatformUtils.isIOS) {
        return await Navigator.of(context!).pushReplacement<T, void>(
          CupertinoPageRoute<T>(builder: (context) => screen),
        );
      }
      return await Navigator.of(context!).pushReplacement<T, void>(
        MaterialPageRoute<T>(builder: (context) => screen),
      );
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current,
          context: 'NavigationService.navigateToScreenReplacement');
      return null;
    }
  }

  /// Navigate to a new screen and clear all previous routes
  Future<T?> navigateToScreenAndClear<T>(Widget screen) async {
    try {
      if (context == null) {
        throw Exception('Navigation context is not available');
      }
      if (PlatformUtils.isIOS) {
        return await Navigator.of(context!).pushAndRemoveUntil<T>(
          CupertinoPageRoute<T>(builder: (context) => screen),
          (route) => false,
        );
      }
      return await Navigator.of(context!).pushAndRemoveUntil<T>(
        MaterialPageRoute<T>(builder: (context) => screen),
        (route) => false,
      );
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current,
          context: 'NavigationService.navigateToScreenAndClear');
      return null;
    }
  }

  /// Go back to previous screen
  void goBack<T>([T? result]) {
    try {
      if (context == null) {
        throw Exception('Navigation context is not available');
      }
      if (Navigator.of(context!).canPop()) {
        Navigator.of(context!).pop<T>(result);
      }
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current,
          context: 'NavigationService.goBack');
    }
  }

  /// Check if can go back
  bool canGoBack() {
    try {
      if (context == null) return false;
      return Navigator.of(context!).canPop();
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current,
          context: 'NavigationService.canGoBack');
      return false;
    }
  }

  /// Navigate to login screen
  Future<void> navigateToLogin() async {
    try {
      await navigateToScreenAndClear(const LoginForm());
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current,
          context: 'NavigationService.navigateToLogin');
    }
  }

  /// Navigate to home screen
  Future<void> navigateToHome() async {
    try {
      await navigateToScreenAndClear(const BottomNavbar());
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current,
          context: 'NavigationService.navigateToHome');
    }
  }

  /// Navigate to splash screen
  Future<void> navigateToSplash() async {
    try {
      await navigateToScreenAndClear(const SplashScreen());
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current,
          context: 'NavigationService.navigateToSplash');
    }
  }

  /// Show error dialog and navigate based on error type
  Future<void> handleNavigationError(BuildContext context, dynamic error,
      {String? fallbackRoute}) async {
    try {
      String message = ErrorHandler.getErrorMessage(error);

      // Show error dialog
      bool shouldRetry = await PlatformWidget.showPlatformDialog<bool>(
            context: context,
            title: 'Navigation Error',
            content: message,
            actions: PlatformUtils.isIOS
                ? [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Retry'),
                    ),
                  ]
                : [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Retry'),
                    ),
                  ],
          ) ??
          false;

      if (shouldRetry) {
        // Retry navigation logic here
        if (fallbackRoute != null) {
          await navigateTo(fallbackRoute);
        }
      }
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current,
          context: 'NavigationService.handleNavigationError');
    }
  }
}

/// Route generator for named routes
class AppRouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    try {
      switch (settings.name) {
        case '/':
          return _buildRoute(const SplashScreen());
        case '/home':
          return _buildRoute(const BottomNavbar());
        case '/login':
          return _buildRoute(const LoginForm());
        case '/discount-coupons':
          return _buildRoute(const DiscountCouponScreen());
        default:
          return _errorRoute();
      }
    } catch (e) {
      ErrorHandler.logError(e, StackTrace.current,
          context: 'AppRouteGenerator.generateRoute');
      return _errorRoute();
    }
  }

  static Route<dynamic> _buildRoute(Widget screen) {
    if (PlatformUtils.isIOS) {
      return CupertinoPageRoute(builder: (_) => screen);
    }
    return MaterialPageRoute(builder: (_) => screen);
  }

  static Route<dynamic> _errorRoute() {
    if (PlatformUtils.isIOS) {
      return CupertinoPageRoute(builder: (_) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Error'),
          ),
          child: const Center(
            child: Text('Route not found'),
          ),
        );
      });
    }
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Route not found'),
        ),
      );
    });
  }
}
