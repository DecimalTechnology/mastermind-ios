import 'package:master_mind/models/vision_board_model.dart';
import 'package:master_mind/repository/vision_board_repository.dart';
import 'package:master_mind/repository/Auth_repository.dart';
import 'package:master_mind/providers/base_provider.dart';

class VisionBoardProvider extends BaseProvider {
  final VisionBoardRepository _repository;
  final AuthRepository _authRepository = AuthRepository();

  VisionBoardModel? _visionBoard;
  int _currentYear = DateTime.now().year;

  VisionBoardProvider({required VisionBoardRepository repository})
      : _repository = repository;

  // Getters
  VisionBoardModel? get visionBoard => _visionBoard;
  bool get hasVisionBoard => _visionBoard != null;
  int get currentYear => _currentYear;
  List<VisionGoal> get goals => _visionBoard?.goals ?? [];
  bool get canAddGoal => _visionBoard?.canAddGoal ?? true;
  double get totalProgress => _visionBoard?.totalProgress ?? 0.0;
  int get completedGoalsCount => _visionBoard?.completedGoalsCount ?? 0;
  int get totalGoalsCount => goals.length;

  /// Load vision board for current year
  Future<void> loadVisionBoard({int? year}) async {
    await executeAsync(
      () async {
        final token = await _authRepository.getAuthToken();
        if (token == null) {
          throw Exception('Authentication token not found');
        }

        final targetYear = year ?? _currentYear;
        final visionBoard = await _repository
            .getVisionBoardByYear(
              token: token,
              year: targetYear,
            )
            .timeout(const Duration(seconds: 10)); // Added timeout

        _visionBoard = visionBoard;
        _currentYear = targetYear;

        if (visionBoard != null) {
          setSuccessMessage('Vision board loaded successfully');
        }

        markAsInitialized();
        return visionBoard;
      },
      context: 'loadVisionBoard',
    );
  }

  /// Refresh vision board data
  Future<void> refreshVisionBoard() async {
    await loadVisionBoard(year: _currentYear);
  }

  /// Add a new goal to vision board
  Future<bool> addGoal({
    required String goal,
    required double target,
    double achieved = 0.0,
  }) async {
    return await executeAsyncBool(
      () async {
        final token = await _authRepository.getAuthToken();
        if (token == null) {
          throw Exception('Authentication token not found');
        }

        final updatedVisionBoard = await _repository.addGoal(
          token: token,
          goal: goal,
          target: target,
          achieved: achieved,
        );

        _visionBoard = updatedVisionBoard;
        setSuccessMessage('Goal added successfully');
        return true;
      },
      context: 'addGoal',
    );
  }

  /// Update an existing goal
  Future<bool> updateGoal({
    required String goalId,
    String? goal,
    double? target,
    double? achieved,
  }) async {
    if (_visionBoard == null) {
      throw Exception('No vision board found to update');
    }

    return await executeAsyncBool(
      () async {
        final token = await _authRepository.getAuthToken();
        if (token == null) {
          throw Exception('Authentication token not found');
        }

        final updatedVisionBoard = await _repository.updateGoal(
          token: token,
          goalId: goalId,
          year: _currentYear,
          goal: goal,
          target: target,
          achieved: achieved,
        );

        _visionBoard = updatedVisionBoard;
        setSuccessMessage('Goal updated successfully');
        return true;
      },
      context: 'updateGoal',
    );
  }

  /// Update goal progress (convenience method)
  Future<bool> updateGoalProgress({
    required String goalId,
    required double achieved,
  }) async {
    return await updateGoal(
      goalId: goalId,
      achieved: achieved,
    );
  }

  /// Delete a goal from vision board
  Future<bool> deleteGoal(String goalId) async {
    if (_visionBoard == null) {
      throw Exception('No vision board found');
    }

    return await executeAsyncBool(
      () async {
        final token = await _authRepository.getAuthToken();
        if (token == null) {
          throw Exception('Authentication token not found');
        }

        final updatedVisionBoard = await _repository.deleteGoal(
          token: token,
          goalId: goalId,
          year: _currentYear,
        );

        _visionBoard = updatedVisionBoard;
        setSuccessMessage('Goal deleted successfully');
        return true;
      },
      context: 'deleteGoal',
    );
  }

  /// Get goal by ID
  VisionGoal? getGoalById(String goalId) {
    try {
      return goals.firstWhere((goal) => goal.id == goalId);
    } catch (e) {
      return null;
    }
  }

  /// Check if goal exists
  bool goalExists(String goalText) {
    return goals
        .any((goal) => goal.goal.toLowerCase() == goalText.toLowerCase());
  }

  /// Get goals by completion status
  List<VisionGoal> getGoalsByStatus(bool completed) {
    return goals.where((goal) => goal.isCompleted == completed).toList();
  }

  /// Get goals sorted by progress (highest first)
  List<VisionGoal> getGoalsSortedByProgress() {
    final sortedGoals = List<VisionGoal>.from(goals);
    sortedGoals.sort((a, b) => b.progress.compareTo(a.progress));
    return sortedGoals;
  }

  /// Get goals sorted by completion date (most recent first)
  List<VisionGoal> getGoalsSortedByCompletion() {
    final sortedGoals = List<VisionGoal>.from(goals);
    // Note: This would need completion date field in the model
    // For now, sort by progress
    sortedGoals.sort((a, b) => b.progress.compareTo(a.progress));
    return sortedGoals;
  }

  /// Change year and load vision board for that year
  Future<void> changeYear(int year) async {
    await loadVisionBoard(year: year);
  }

  /// Reset vision board data
  void resetVisionBoard() {
    _visionBoard = null;
    _currentYear = DateTime.now().year;
    clearError();
    clearSuccessMessage();
    notifyListeners();
  }

  /// Clear all data (alias for resetVisionBoard)
  void clearData() {
    resetVisionBoard();
  }

  @override
  void dispose() {
    resetVisionBoard();
    super.dispose();
  }
}
