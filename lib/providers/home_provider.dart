import 'package:flutter/foundation.dart';
import 'package:master_mind/models/home_model.dart';
import 'package:master_mind/repository/home_repository.dart';
import 'package:master_mind/core/error_handling/error_handling.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository _homeRepository;

  HomeResponseModel? _homeData;
  bool _isLoading = false;
  String? _error;

  HomeProvider({required HomeRepository homeRepository})
      : _homeRepository = homeRepository;

  HomeResponseModel? get homeData => _homeData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  UserInfo? get userInfo => _homeData?.data.userInfo;
  NextMeeting? get nextMeeting => _homeData?.data.nextMeeting;
  List<NextMeeting> get weeklyMeetings => _homeData?.data.weeklyMeetings ?? [];
  int get connections => _homeData?.data.connections ?? 0;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _homeData = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<HomeResponseModel?> loadHomeData() async {
    // If already loading, don't start another load
    if (_isLoading) {
      return _homeData;
    }

    // Always fetch fresh data when explicitly called
    // This ensures we get the latest data after login
    _homeData = null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final homeData = await _homeRepository
          .getHomeData()
          .timeout(const Duration(seconds: 10)); // Added timeout
      _homeData = homeData;
      _isLoading = false;
      notifyListeners();
      return homeData;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();

      // Log error for debugging
      ErrorHandler.logError(e, StackTrace.current,
          context: 'HomeProvider.loadHomeData');

      return null;
    }
  }

  Future<void> refreshHomeData() async {
    // Force refresh by clearing cached data
    _homeData = null;
    await loadHomeData();
  }
}
