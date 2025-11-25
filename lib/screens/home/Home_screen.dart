import 'package:flutter/material.dart';
import 'package:master_mind/providers/profile_provider.dart';
import 'package:master_mind/providers/Auth_provider.dart';
import 'package:master_mind/providers/vision_board_provider.dart';
import 'package:master_mind/providers/home_provider.dart';
import 'package:master_mind/screens/Activity_feed.dart';
import 'package:master_mind/screens/settings_screen.dart';
import 'package:master_mind/screens/vision_board_screen.dart';
import 'package:master_mind/widgets/home_drawer.dart';
import 'package:master_mind/widgets/base_screen.dart';
import 'package:master_mind/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/models/profile_model.dart';
import 'package:master_mind/widgets/shimmer_loading.dart';
import 'widgets/index.dart';

class HomeScreen extends BaseScreenWithAppBar {
  const HomeScreen({super.key}) : super(title: "Home");

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseScreenWithAppBarState<HomeScreen>
    with WidgetsBindingObserver {
  String? _error;
  bool _needsRelogin = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      // Refresh data when app is resumed
      _handleAppResumed();
    }
  }

  void _handleAppResumed() {
    // Check if user is authenticated and refresh data if needed
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      _clearAllData();
      _loadAllData();
    }
  }

  @override
  Future<void> initializeData() async {
    // Clear any existing data first
    _clearAllData();

    await _loadAllData();
    _startAuthCheck();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is called when the widget's dependencies change
    // Useful for refreshing data when navigating back to this screen
    if (mounted) {
      _handleScreenFocus();
    }
  }

  void _handleScreenFocus() {
    // Check if we need to refresh data when the screen comes into focus
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated && !_needsRelogin) {
      // Only refresh if we're authenticated and not in relogin state
      // This prevents unnecessary API calls
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      if (homeProvider.homeData == null) {
        // Only refresh if we don't have data
        _loadAllData();
      }
    }
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadProfileData(),
      _loadHomeData(),
      _loadVisionBoardData(),
    ], eagerError: false)
        .timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        return [];
      },
    );
  }

  Future<void> _loadProfileData() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.loadProfile();
  }

  Future<void> _loadHomeData() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.loadHomeData();
  }

  Future<void> _loadVisionBoardData() async {
    final visionBoardProvider =
        Provider.of<VisionBoardProvider>(context, listen: false);
    if (!visionBoardProvider.hasVisionBoard) {
      await visionBoardProvider.loadVisionBoard();
      print('Vision board loaded: ${visionBoardProvider.hasVisionBoard}');
    } else {
      print('Vision board already loaded, skipping');
    }
  }

  @override
  PreferredSizeWidget? buildAppBar() {
    return HomeAppBar(
      onActivityFeedPressed: () => _navigateToActivityFeed(),
      onSettingsPressed: () => _navigateToSettings(),
    );
  }

  @override
  Widget? buildDrawer() {
    return const MyDrawer();
  }

  void _navigateToActivityFeed() {
    navigateToScreen(const ActivityFeed());
  }

  void _navigateToSettings() {
    navigateToScreen(SettingsScreen());
  }

  void _navigateToVisionBoard() {
    navigateToScreen(const VisionBoardScreen());
  }

  void _startAuthCheck() {
    Future.delayed(const Duration(hours: 24), () {
      if (mounted && !_isDisposed) {
        _checkAuthStatus();
        _startAuthCheck();
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (!authProvider.isAuthenticated) {
        setState(() => _needsRelogin = true);
        throw Exception('Session expired. Please login again.');
      }

      final token = await authProvider.authRepository.getAuthToken();
      if (token == null) {
        setState(() => _needsRelogin = true);
        throw Exception('Authentication token expired. Please login again.');
      }

      // If we were previously logged out and now we're authenticated, refresh data
      if (_needsRelogin) {
        setState(() => _needsRelogin = false);
        // Clear old data and reload fresh data
        _clearAllData();
        await _loadAllData();
      }
    } catch (e) {
      // Don't rethrow, let the UI handle the error state
    }
  }

  void _handleRelogin() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      await NavigationService().navigateToLogin();
    } catch (e) {
      // Handle error appropriately
    }
  }

  void _handleSuccessfulLogin() async {
    // Clear all old data and reload fresh data
    _clearAllData();
    await _loadAllData();
  }

  void _handleRetry() async {
    _clearAllErrors();
    await _loadAllData();
  }

  void _clearAllErrors() {
    clearError();
    setState(() {
      _needsRelogin = false;
      _error = null;
    });

    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final visionBoardProvider =
        Provider.of<VisionBoardProvider>(context, listen: false);

    profileProvider.clearError();
    homeProvider.clearError();
    visionBoardProvider.clearError();
  }

  void _clearAllData() {
    clearError();
    setState(() {
      _needsRelogin = false;
      _error = null;
    });

    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final visionBoardProvider =
        Provider.of<VisionBoardProvider>(context, listen: false);

    // Clear all cached data
    profileProvider.clearData();
    homeProvider.clearData();
    visionBoardProvider.clearData();
  }

  Future<void> _handleRefresh() async {
    // Clear data without triggering UI updates
    _clearAllDataSilently();

    // Load data with optimized timeout and error handling
    await _loadAllDataOptimized();
  }

  void _clearAllDataSilently() {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final visionBoardProvider =
        Provider.of<VisionBoardProvider>(context, listen: false);

    // Clear data without notifying listeners to avoid UI flicker
    profileProvider.clearData();
    homeProvider.clearData();
    visionBoardProvider.clearData();
  }

  Future<void> _loadAllDataOptimized() async {
    try {
      // Run operations in parallel with shorter timeout
      await Future.wait([
        _loadProfileDataOptimized(),
        _loadHomeDataOptimized(),
        _loadVisionBoardDataOptimized(),
      ], eagerError: false)
          .timeout(
        const Duration(seconds: 15), // Reduced timeout
        onTimeout: () {
          return [];
        },
      );
    } catch (e) {
      // Don't set error here, let individual providers handle their errors
    }
  }

  Future<void> _loadProfileDataOptimized() async {
    try {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      await profileProvider.loadProfile();
    } catch (e) {
      // Don't throw to allow other operations to complete
    }
  }

  Future<void> _loadHomeDataOptimized() async {
    try {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      await homeProvider.loadHomeData();
    } catch (e) {
      // Don't throw to allow other operations to complete
    }
  }

  Future<void> _loadVisionBoardDataOptimized() async {
    try {
      final visionBoardProvider =
          Provider.of<VisionBoardProvider>(context, listen: false);
      if (!visionBoardProvider.hasVisionBoard) {
        await visionBoardProvider.loadVisionBoard();
      } else {}
    } catch (e) {
      // Don't throw to allow other operations to complete
    }
  }

  @override
  Widget buildContent() {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = profileProvider.profile;

    _logDebugInfo(profileProvider, homeProvider, profile);

    // Listen for authentication changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authProvider.isAuthenticated && _needsRelogin) {
        _handleSuccessfulLogin();
      }

      // If user is authenticated but we don't have data, load it
      if (authProvider.isAuthenticated &&
          !_needsRelogin &&
          profile == null &&
          homeProvider.homeData == null) {
        _loadAllData();
      }
    });

    if (_needsRelogin) {
      return _buildReloginMessage();
    }

    // Check if any provider is still loading and not initialized
    final isAnyProviderLoading =
        profileProvider.isLoading || homeProvider.isLoading;

    if (isAnyProviderLoading &&
        profile == null &&
        homeProvider.homeData == null) {
      return ShimmerLoading.buildHomeScreenShimmer();
    }

    final hasNetworkError = profileProvider.hasError || homeProvider.hasError;
    if (hasNetworkError) {
      return _buildNetworkErrorState(
          _getNetworkErrorMessage(profileProvider, homeProvider));
    }

    if (profile != null) {
      return _buildMainContent();
    }

    if (error != null) {
      return _buildLocalErrorState();
    }

    // Show loading if we're still waiting for data
    return ShimmerLoading.buildSimpleShimmer(
      message: 'Preparing your dashboard...',
    );
  }

  void _logDebugInfo(ProfileProvider profileProvider, HomeProvider homeProvider,
      ProfileModel? profile) {}

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildProfileSection(),
            _buildMeetingCard(),
            const SizedBox(height: 10),
            _buildVisionBoard(),
            const SizedBox(height: 10),
            _buildSlipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildReloginMessage() {
    return ErrorStates.buildReloginMessage(
      error: _error,
      onRelogin: _handleRelogin,
      onRetry: _handleRetry,
    );
  }

  Widget _buildLocalErrorState() {
    return ErrorStates.buildLocalErrorState(
      error: error!,
      onRetry: _handleRetry,
    );
  }

  Widget _buildNetworkErrorState(String errorMessage) {
    return ErrorStates.buildNetworkErrorState(
      errorMessage: errorMessage,
      onRetry: _handleRetry,
    );
  }

  String _getNetworkErrorMessage(
      ProfileProvider profileProvider, HomeProvider homeProvider) {
    if (homeProvider.hasError) {
      return homeProvider.error ?? 'Failed to load dashboard data';
    }
    if (profileProvider.hasError) {
      return profileProvider.error ?? 'Failed to load profile data';
    }
    return 'Network connection failed. Please check your internet connection.';
  }

  Widget _buildProfileSection() {
    return const ProfileSection();
  }

  Widget _buildVisionBoard() {
    return VisionBoardCard(
      onNavigateToVisionBoard: () => _navigateToVisionBoard(),
    );
  }

  Widget _buildMeetingCard() {
    return const MeetingCard();
  }

  Widget _buildSlipsCard() {
    return const ActivitiesCard();
  }
}
