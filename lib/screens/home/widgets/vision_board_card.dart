import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/vision_board_provider.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/screens/vision_board_screen.dart';
import 'add_goal_dialog.dart';

class VisionBoardCard extends StatelessWidget {
  final VoidCallback onNavigateToVisionBoard;

  const VisionBoardCard({
    super.key,
    required this.onNavigateToVisionBoard,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VisionBoardProvider>(
      builder: (context, visionBoardProvider, child) {
        final totalProgress = (visionBoardProvider.totalProgress * 100).round();
        final completedGoals = visionBoardProvider.completedGoalsCount;
        final totalGoals = visionBoardProvider.totalGoalsCount;

        return GestureDetector(
          onTap: onNavigateToVisionBoard,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: kPaddingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildVisionBoardHeader(visionBoardProvider),
                _buildVisionBoardContent(totalProgress, completedGoals,
                    totalGoals, visionBoardProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisionBoardHeader(VisionBoardProvider visionBoardProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryColor, kGradientEndColor],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.visibility_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Vision Board",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisionBoardContent(int totalProgress, int completedGoals,
      int totalGoals, VisionBoardProvider visionBoardProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgressOverview(
              totalProgress, completedGoals, totalGoals, visionBoardProvider),
          const SizedBox(height: 16),
          _buildProgressBar(visionBoardProvider),
          const SizedBox(height: 16),
          _buildStatsGrid(totalProgress, completedGoals, totalGoals),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(int totalProgress, int completedGoals,
      int totalGoals, VisionBoardProvider visionBoardProvider) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: kPrimaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: kPrimaryColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$totalProgress%',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor),
              ),
              Text(
                'Progress',
                style: TextStyle(
                    fontSize: 10,
                    color: kPrimaryColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${completedGoals}/${totalGoals} Goals',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor),
              ),
              const SizedBox(height: 4),
              Text(
                'Year ${visionBoardProvider.currentYear}',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(VisionBoardProvider visionBoardProvider) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width:
                      constraints.maxWidth * visionBoardProvider.totalProgress,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [kPrimaryColor, kGradientEndColor],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(
      int totalProgress, int completedGoals, int totalGoals) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: kPrimaryColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
              child: _buildStatItem('Progress', '$totalProgress%',
                  Icons.trending_up, kPrimaryColor)),
          Container(
              width: 1,
              height: 40,
              color: kPrimaryColor.withValues(alpha: 0.2)),
          Expanded(
              child: _buildStatItem(
                  'Remaining',
                  '${totalGoals - completedGoals}',
                  Icons.schedule,
                  kPrimaryColor)),
          Container(
              width: 1,
              height: 40,
              color: kPrimaryColor.withValues(alpha: 0.2)),
          Expanded(
              child: _buildStatItem('Completed', '$completedGoals',
                  Icons.check_circle, kPrimaryColor)),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showAddGoalDialog(VisionBoardProvider visionBoardProvider) {
    if (!visionBoardProvider.canAddGoal) {
      // Show error message
      return;
    }

    // Show the add goal dialog
    // This will be handled by the parent widget
  }
}
