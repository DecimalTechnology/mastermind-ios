class VisionBoardModel {
  final String id;
  final String userId;
  final int year;
  final int goalLimit;
  final List<VisionGoal> goals;
  final DateTime createdAt;
  final DateTime updatedAt;

  VisionBoardModel({
    required this.id,
    required this.userId,
    required this.year,
    required this.goalLimit,
    required this.goals,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor for creating from JSON
  factory VisionBoardModel.fromJson(Map<String, dynamic> json) {
    return VisionBoardModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      goalLimit: json['goalLimit'] ?? 8,
      goals: (json['goals'] as List<dynamic>?)
              ?.map((goal) => VisionGoal.fromJson(goal))
              .toList() ??
          [],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'year': year,
      'goalLimit': goalLimit,
      'goals': goals.map((goal) => goal.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated values
  VisionBoardModel copyWith({
    String? id,
    String? userId,
    int? year,
    int? goalLimit,
    List<VisionGoal>? goals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VisionBoardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      year: year ?? this.year,
      goalLimit: goalLimit ?? this.goalLimit,
      goals: goals ?? this.goals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if can add more goals
  bool get canAddGoal => goals.length < goalLimit;

  // Get total progress across all goals (capped at 100% per goal for overview)
  double get totalProgress {
    if (goals.isEmpty) return 0.0;
    double totalProgress = 0.0;
    for (var goal in goals) {
      // Cap individual goal progress at 100% for overview calculation
      double cappedProgress = goal.progress > 1.0 ? 1.0 : goal.progress;
      totalProgress += cappedProgress;
    }
    return totalProgress / goals.length;
  }

  // Get completed goals count
  int get completedGoalsCount => goals.where((goal) => goal.isCompleted).length;

  @override
  String toString() {
    return 'VisionBoardModel(id: $id, year: $year, goals: ${goals.length}, progress: ${(totalProgress * 100).round()}%)';
  }
}

class VisionGoal {
  final String id;
  final String goal;
  final double target;
  final double achieved;

  VisionGoal({
    required this.id,
    required this.goal,
    required this.target,
    required this.achieved,
  });

  // Computed properties
  double get progress => target > 0 ? achieved / target : 0.0;
  double get remaining => target - achieved;
  int get progressPercentage => (progress * 100).round();
  bool get isCompleted => achieved >= target;

  // Factory constructor for creating from JSON
  factory VisionGoal.fromJson(Map<String, dynamic> json) {
    return VisionGoal(
      id: json['_id'] ?? json['id'] ?? '',
      goal: json['goal'] ?? '',
      target: (json['target'] ?? 0).toDouble(),
      achieved: (json['achieved'] ?? 0).toDouble(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'target': target,
      'achieved': achieved,
    };
  }

  // Create a copy with updated values
  VisionGoal copyWith({
    String? id,
    String? goal,
    double? target,
    double? achieved,
  }) {
    return VisionGoal(
      id: id ?? this.id,
      goal: goal ?? this.goal,
      target: target ?? this.target,
      achieved: achieved ?? this.achieved,
    );
  }

  @override
  String toString() {
    return 'VisionGoal(id: $id, goal: $goal, target: $target, achieved: $achieved, progress: $progressPercentage%)';
  }
}
