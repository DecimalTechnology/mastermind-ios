import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/providers/accountability_provider.dart';
import 'package:master_mind/providers/connection_Provider.dart';
import 'package:master_mind/providers/tyfcb_provider.dart';
import 'package:master_mind/repository/connection/connectionsRepository.dart';
import 'package:master_mind/repository/tyfcb_repository.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/Auth_provider.dart';
import 'package:master_mind/repository/Auth_repository.dart';
import 'package:master_mind/screens/splash_screen.dart';
import 'package:master_mind/providers/bottom_nav_provider.dart';
import 'package:master_mind/providers/profile_provider.dart';
import 'package:master_mind/repository/profileRepo/profile_repo.dart';
import 'package:master_mind/providers/event_provider.dart';
import 'package:master_mind/repository/event_repository.dart';
import 'package:master_mind/providers/search_provider.dart';
import 'package:master_mind/repository/Search_repository/search_repository.dart';
import 'package:master_mind/providers/testimonial_provider.dart';
import 'package:master_mind/core/error_handling/handlers/global_error_handler.dart';
import 'package:master_mind/services/navigation_service.dart';
import 'package:master_mind/screens/testimonial/testimonial_listing_screen.dart';
import 'package:master_mind/screens/testimonial/testimonial_screen.dart';
import 'package:master_mind/screens/testimonial/ask_testimonial_screen.dart';
import 'package:master_mind/screens/community_screen.dart';
import 'package:master_mind/screens/connection/connectionDetails.dart';
import 'package:master_mind/screens/tyfcb_screen.dart';
import 'package:master_mind/screens/Activity_feed.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/screens/gallery_screen.dart';
import 'package:master_mind/screens/settings_screen.dart';
import 'package:master_mind/providers/gallery_provider.dart'; // Import GalleryProvider
import 'package:master_mind/repository/gallery/gallery_repository.dart'; // Import GalleryRepository
import 'package:master_mind/providers/vision_board_provider.dart'; // Import VisionBoardProvider
import 'package:master_mind/repository/vision_board_repository.dart'; // Import VisionBoardRepository
import 'package:master_mind/providers/home_provider.dart'; // Import HomeProvider
import 'package:master_mind/repository/home_repository.dart'; // Import HomeRepository
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:master_mind/firebase_options.dart';
import 'package:master_mind/services/api_monitoring_service.dart';
import 'dart:ui';
import 'package:master_mind/providers/tip_provider.dart';
import 'package:master_mind/repository/tip_repository.dart';
import 'package:master_mind/providers/discount_coupon_provider.dart';
import 'package:master_mind/repository/discount_coupon_repository.dart';
import 'package:master_mind/screens/discount_coupon/discount_coupon_screen.dart';

void main() async {
  // Ensure Flutter is initialized before setting up error handling
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // Initialize Firebase Analytics for breadcrumb logs
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  // Initialize API Monitoring Service
  ApiMonitoringService();

  // Set up error handling for Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Handle errors that occur during zone execution
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize global error handling
  GlobalErrorHandler.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                ConnectionProvider(repository: ConnectionRepository())),
        ChangeNotifierProvider(create: (context) => BottomNavProvider()),
        Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        ChangeNotifierProxyProvider<AuthRepository, AuthProvider>(
          create: (context) =>
              AuthProvider(authRepository: context.read<AuthRepository>()),
          update: (context, repository, previous) =>
              AuthProvider(authRepository: repository),
        ),
        ChangeNotifierProvider(
            create: (_) => ProfileProvider(repository: ProfileRepository())),
        ChangeNotifierProvider(
            create: (_) => EventProvider(repository: EventRepository())),
        ChangeNotifierProvider(
            create: (_) => SearchProvider(SearchRepository())),
        ChangeNotifierProvider(create: (_) => TestimonialProvider()),
        ChangeNotifierProvider(
            create: (_) => TYFCBProvider(repository: TYFCBRepository())),
        ChangeNotifierProvider(
          create: (_) => AccountabilityProvider(),
        ),
        ChangeNotifierProvider(
          // Add GalleryProvider here
          create: (context) => GalleryProvider(
            repository: GalleryRepository(),
          )..loadGalleryImages(), // Load images when provider is created
        ),
        ChangeNotifierProvider(
          // Add VisionBoardProvider here
          create: (_) => VisionBoardProvider(
            repository: VisionBoardRepository(),
          ),
        ),
        ChangeNotifierProvider(
          // Add HomeProvider here
          create: (_) => HomeProvider(
            homeRepository: HomeRepository(),
          ),
        ),
        ChangeNotifierProvider(
          // Add TipProvider here
          create: (_) => TipProvider(repository: TipRepository()),
        ),
        ChangeNotifierProvider(
          // Add DiscountCouponProvider here
          create: (_) => DiscountCouponProvider(
            repository: DiscountCouponRepository(),
          ),
        ),
      ],
      child: ErrorBoundary(
        child: PlatformUtils.isIOS ? _buildCupertinoApp() : _buildMaterialApp(),
      ),
    ),
  );
}

// Build Material App for Android/Web
Widget _buildMaterialApp() {
  return MaterialApp(
    title: 'Oxygen Mastermind',
    navigatorKey: NavigationService().navigatorKey,
    theme: ThemeData(
      primaryColor: kOxygenMMPurple,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kOxygenMMPurple,
        primary: kOxygenMMPurple,
        secondary: kAccentPurple,
        background: kWhite,
        surface: kGrey,
        error: kRed,
        onPrimary: kWhite,
        onSecondary: kWhite,
        onBackground: kBlack,
        onSurface: kBlack,
        onError: kWhite,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: kWhite,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: kWhite,
        foregroundColor: kPrimaryColor,
        elevation: 0,
      ),
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kOxygenMMPurple,
          foregroundColor: Colors.white,
          iconColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: kPrimaryColor,
          iconColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: kPrimaryColor.withAlpha((0.3 * 255).toInt())),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: kPrimaryColor.withAlpha((0.3 * 255).toInt())),
        ),
        filled: true,
        fillColor: kBackgroundColor,
      ),
      cardTheme: CardThemeData(
        color: kCardColor,
        elevation: 4,
        shadowColor: kShadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: kPrimaryColor.withValues(alpha: 0.2),
        thickness: 1,
      ),
    ),
    home: const SplashScreen(),
    onGenerateRoute: AppRouteGenerator.generateRoute,
    routes: {
      '/testimonial-listing': (context) => const TestimonialListingScreen(),
      '/testimonial': (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return TestimonialScreen(
          userid: args['userid'],
          userName: args['userName'],
        );
      },
      '/ask-testimonial': (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return AskTestimonialScreen(
          userid: args['userid'],
          userName: args['userName'],
        );
      },
      '/community': (context) => const CommunityScreen(),
      '/connections-listing': (context) => const Connectiondetails(),
      '/tyfcb': (context) => const TYFCBScreen(),
      '/activity-feed': (context) => const ActivityFeed(),
      '/gallery': (context) => GalleryPage(),
      '/settings': (context) => const SettingsScreen(),
      '/discount-coupons': (context) => const DiscountCouponScreen(),
      'splash': (context) => const SplashScreen(),
      'home': (context) => const SplashScreen(),
      'login': (context) => const SplashScreen(),
      'register': (context) => const SplashScreen(),
    },
    builder: (context, child) {
      return ErrorBoundary(
        child: child!,
      );
    },
  );
}

// Build Cupertino App for iOS
Widget _buildCupertinoApp() {
  return CupertinoApp(
    title: 'Oxygen Mastermind',
    navigatorKey: NavigationService().navigatorKey,
    theme: CupertinoThemeData(
      primaryColor: kOxygenMMPurple,
      scaffoldBackgroundColor: CupertinoColors.systemBackground,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        textStyle: const TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          color: CupertinoColors.label,
        ),
        navTitleTextStyle: const TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: kPrimaryColor,
        ),
        navLargeTitleTextStyle: const TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: kPrimaryColor,
        ),
        actionTextStyle: const TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          color: kOxygenMMPurple,
        ),
      ),
    ),
    home: const SplashScreen(),
    onGenerateRoute: (settings) {
      // Convert Material routes to Cupertino-compatible routes
      switch (settings.name) {
        case '/testimonial-listing':
          return CupertinoPageRoute(
            builder: (_) => const TestimonialListingScreen(),
          );
        case '/testimonial':
          final args = settings.arguments as Map<String, dynamic>;
          return CupertinoPageRoute(
            builder: (_) => TestimonialScreen(
              userid: args['userid'],
              userName: args['userName'],
            ),
          );
        case '/ask-testimonial':
          final args = settings.arguments as Map<String, dynamic>;
          return CupertinoPageRoute(
            builder: (_) => AskTestimonialScreen(
              userid: args['userid'],
              userName: args['userName'],
            ),
          );
        case '/community':
          return CupertinoPageRoute(
            builder: (_) => const CommunityScreen(),
          );
        case '/connections-listing':
          return CupertinoPageRoute(
            builder: (_) => const Connectiondetails(),
          );
        case '/tyfcb':
          return CupertinoPageRoute(
            builder: (_) => const TYFCBScreen(),
          );
        case '/activity-feed':
          return CupertinoPageRoute(
            builder: (_) => const ActivityFeed(),
          );
        case '/gallery':
          return CupertinoPageRoute(
            builder: (_) => GalleryPage(),
          );
        case '/settings':
          return CupertinoPageRoute(
            builder: (_) => const SettingsScreen(),
          );
        case '/discount-coupons':
          return CupertinoPageRoute(
            builder: (_) => const DiscountCouponScreen(),
          );
        default:
          return CupertinoPageRoute(
            builder: (_) => const SplashScreen(),
          );
      }
    },
    builder: (context, child) {
      return ErrorBoundary(
        child: child!,
      );
    },
  );
}
