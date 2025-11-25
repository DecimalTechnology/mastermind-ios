import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_mind/providers/vision_board_provider.dart';
import 'package:master_mind/models/vision_board_model.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/widgets/common_styles.dart';
import 'package:master_mind/widgets/base_screen.dart';
import 'package:master_mind/widgets/shimmer_loading.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';

// Custom TextFormField for formatted number input
class FormattedNumberField extends StatefulWidget {
  final String labelText;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final String? helperText;
  final bool enabled;

  const FormattedNumberField({
    super.key,
    required this.labelText,
    required this.initialValue,
    required this.onChanged,
    this.helperText,
    this.enabled = true,
  });

  @override
  State<FormattedNumberField> createState() => _FormattedNumberFieldState();
}

class _FormattedNumberFieldState extends State<FormattedNumberField> {
  late TextEditingController _controller;
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(
      text:
          _currentValue > 0 ? NumberFormatter.formatNumber(_currentValue) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        helperText: widget.helperText,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
      ],
      onChanged: (value) {
        final parsedValue = NumberFormatter.parseNumber(value);
        if (parsedValue != _currentValue) {
          _currentValue = parsedValue;
          widget.onChanged(_currentValue);
        }
      },
      onTap: () {
        // Select all text when tapped for easy editing
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      },
    );
  }
}

class VisionBoardScreen extends BaseScreenWithAppBar {
  const VisionBoardScreen({super.key}) : super(title: "Vision Board");

  @override
  State<VisionBoardScreen> createState() => _VisionBoardScreenState();
}

class _VisionBoardScreenState
    extends BaseScreenWithAppBarState<VisionBoardScreen> {
  @override
  Future<void> initializeData() async {
    await _loadVisionBoardData();

    // Test Crashlytics logging
    FirebaseCrashlytics.instance.log('Vision Board Screen initialized');
    FirebaseCrashlytics.instance.setCustomKey('screen_name', 'vision_board');
    FirebaseCrashlytics.instance.setCustomKey('user_action', 'screen_load');
  }

  @override
  PreferredSizeWidget? buildAppBar() {
    final currentYear = DateTime.now().year;

    return AppBar(
      title: const Text("Vision Board", style: TextStyle(color: kPrimaryColor)),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: kPrimaryColor,
      actions: [
        IconButton(
          onPressed: () => _showYearSelectorDialog(),
          icon: const Icon(Icons.calendar_today),
        ),
        Consumer<VisionBoardProvider>(
          builder: (context, visionBoardProvider, child) {
            final selectedYear = visionBoardProvider.currentYear;
            final canAddGoals = selectedYear >= currentYear;

            return canAddGoals
                ? IconButton(
                    onPressed: () => _showAddGoalDialog(),
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Goal',
                  )
                : IconButton(
                    onPressed: null,
                    icon: const Icon(Icons.add),
                    tooltip: 'Cannot add goals for previous years',
                  );
          },
        ),
      ],
    );
  }

  Future<void> _loadVisionBoardData() async {
    try {
      // Set custom keys for Crashlytics
      await FirebaseCrashlytics.instance.setCustomKey('screen', 'vision_board');
      await FirebaseCrashlytics.instance
          .setCustomKey('action', 'load_vision_board_data');

      final visionBoardProvider =
          Provider.of<VisionBoardProvider>(context, listen: false);
      await visionBoardProvider.loadVisionBoard();

      // Log successful data load
      FirebaseCrashlytics.instance.log('Vision board data loaded successfully');
    } catch (error, stackTrace) {
      // Log error to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to load vision board data',
        information: ['VisionBoardScreen._loadVisionBoardData'],
      );
      rethrow;
    }
  }

  void _showAddGoalDialog() {
    try {
      // Set custom keys for Crashlytics
      FirebaseCrashlytics.instance
          .setCustomKey('action', 'show_add_goal_dialog');
      FirebaseCrashlytics.instance.log('Add goal dialog opened');

      final visionBoardProvider =
          Provider.of<VisionBoardProvider>(context, listen: false);

      if (!visionBoardProvider.canAddGoal) {
        FirebaseCrashlytics.instance.log('User reached maximum goals limit');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'You have reached the maximum number of goals for this year'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          String goalText = '';
          double target = 0.0;
          double achieved = 0.0;

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Add New Goal'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Goal Description',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        goalText = value;
                      },
                    ),
                    const SizedBox(height: 15),
                    FormattedNumberField(
                      labelText: 'Target Value',
                      initialValue: target,
                      onChanged: (value) {
                        target = value;
                      },
                    ),
                    const SizedBox(height: 15),
                    FormattedNumberField(
                      labelText: 'Achieved Value (Optional)',
                      initialValue: achieved,
                      onChanged: (value) {
                        achieved = value;
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: visionBoardProvider.isLoading
                        ? null
                        : () async {
                            try {
                              if (goalText.isEmpty) {
                                FirebaseCrashlytics.instance
                                    .log('User tried to add empty goal');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please enter a goal description'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              FirebaseCrashlytics.instance
                                  .log('Adding new goal: $goalText');
                              final success = await visionBoardProvider.addGoal(
                                goal: goalText,
                                target: target,
                                achieved: achieved,
                              );

                              if (success) {
                                FirebaseCrashlytics.instance
                                    .log('Goal added successfully');
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Goal added successfully!'),
                                    backgroundColor: kPrimaryColor,
                                  ),
                                );
                              } else {
                                FirebaseCrashlytics.instance.log(
                                    'Failed to add goal: ${visionBoardProvider.error}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(visionBoardProvider.error ??
                                        'Failed to add goal'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (error, stackTrace) {
                              FirebaseCrashlytics.instance.recordError(
                                error,
                                stackTrace,
                                reason: 'Failed to add goal',
                                information: [
                                  'VisionBoardScreen._showAddGoalDialog.addGoal'
                                ],
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'An error occurred while adding the goal'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                    ),
                    child: visionBoardProvider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Add Goal',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to show add goal dialog',
        information: ['VisionBoardScreen._showAddGoalDialog'],
      );
    }
  }

  void _showGoalDetailsDialog(VisionGoal goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Goal Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Goal', goal.goal),
              const SizedBox(height: 10),
              _buildDetailRow(
                  'Target', NumberFormatter.formatNumber(goal.target)),
              const SizedBox(height: 10),
              _buildDetailRow(
                  'Achieved', NumberFormatter.formatNumber(goal.achieved)),
              const SizedBox(height: 10),
              _buildDetailRow('Progress', '${goal.progressPercentage}%'),
              const SizedBox(height: 10),
              _buildDetailRow(
                  'Remaining', NumberFormatter.formatNumber(goal.remaining)),
              const SizedBox(height: 15),
              _buildProgressBar(goal.progress),
              const SizedBox(height: 15),
              _buildStatusIndicator(goal.isCompleted),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditGoalDialog(goal);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
              ),
              child: const Text(
                'Edit Goal',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(goal);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditGoalDialog(VisionGoal goal) {
    final visionBoardProvider =
        Provider.of<VisionBoardProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String goalText = goal.goal;
        double target = goal.target;
        double achieved = goal.achieved;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Goal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: goalText,
                    decoration: const InputDecoration(
                      labelText: 'Goal Description',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      goalText = value;
                    },
                  ),
                  const SizedBox(height: 15),
                  FormattedNumberField(
                    labelText: 'Target Value',
                    initialValue: target,
                    onChanged: (value) {
                      target = value;
                    },
                  ),
                  const SizedBox(height: 15),
                  FormattedNumberField(
                    labelText: 'Achieved Value',
                    initialValue: achieved,
                    onChanged: (value) {
                      achieved = value;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final success = await visionBoardProvider.updateGoal(
                      goalId: goal.id,
                      goal: goalText,
                      target: target,
                      achieved: achieved,
                    );

                    if (success) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Goal updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(visionBoardProvider.error ??
                              'Failed to update goal'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(VisionGoal goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to delete this goal?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goal: ${goal.goal}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Progress: ${goal.progressPercentage}%',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteGoal(goal);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteGoal(VisionGoal goal) async {
    try {
      // Set custom keys for Crashlytics
      await FirebaseCrashlytics.instance.setCustomKey('action', 'delete_goal');
      await FirebaseCrashlytics.instance.setCustomKey('goal_id', goal.id);
      await FirebaseCrashlytics.instance.setCustomKey('goal_name', goal.goal);

      FirebaseCrashlytics.instance
          .log('Attempting to delete goal: ${goal.goal}');

      final visionBoardProvider =
          Provider.of<VisionBoardProvider>(context, listen: false);

      final success = await visionBoardProvider.deleteGoal(goal.id);

      if (success) {
        FirebaseCrashlytics.instance
            .log('Goal deleted successfully: ${goal.goal}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        FirebaseCrashlytics.instance
            .log('Failed to delete goal: ${visionBoardProvider.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(visionBoardProvider.error ?? 'Failed to delete goal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to delete goal',
        information: ['VisionBoardScreen._deleteGoal', 'Goal ID: ${goal.id}'],
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while deleting the goal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateProgressDialog(VisionGoal goal) {
    final visionBoardProvider =
        Provider.of<VisionBoardProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double newAchieved = goal.achieved;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Progress'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goal: ${goal.goal}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Current Progress: ${goal.progressPercentage}%',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  FormattedNumberField(
                    labelText: 'New Achieved Value',
                    initialValue: goal.achieved,
                    onChanged: (value) {
                      newAchieved = value;
                    },
                    helperText: 'Enter the new achieved value',
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Target: ${NumberFormatter.formatNumber(goal.target)} | Remaining: ${NumberFormatter.formatNumber(goal.target - newAchieved)}',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final success =
                        await visionBoardProvider.updateGoalProgress(
                      goalId: goal.id,
                      achieved: newAchieved,
                    );

                    if (success) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Progress updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(visionBoardProvider.error ??
                              'Failed to update progress'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Update Progress',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showYearSelectorDialog() {
    try {
      // Set custom keys for Crashlytics
      FirebaseCrashlytics.instance.setCustomKey('action', 'show_year_selector');
      FirebaseCrashlytics.instance.log('Year selector dialog opened');

      final visionBoardProvider =
          Provider.of<VisionBoardProvider>(context, listen: false);
      final currentYear = DateTime.now().year;
      final selectedYear = visionBoardProvider.currentYear;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Year'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int year = currentYear; year >= currentYear - 5; year--)
                    ListTile(
                      leading: Radio<int>(
                        value: year,
                        groupValue: selectedYear,
                        onChanged: (value) async {
                          if (mounted) {
                            Navigator.of(context).pop();
                            await visionBoardProvider.changeYear(value!);
                          }
                        },
                      ),
                      title: Text(
                        year.toString(),
                        style: TextStyle(
                          fontWeight: year == selectedYear
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: year == selectedYear ? kPrimaryColor : null,
                        ),
                      ),
                      trailing: year == currentYear
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Current',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : year < currentYear
                              ? null
                              : null,
                      onTap: () async {
                        if (mounted) {
                          Navigator.of(context).pop();
                          await visionBoardProvider.changeYear(year);
                        }
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to show year selector dialog',
        information: ['VisionBoardScreen._showYearSelectorDialog'],
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kPrimaryColor,
                          kPrimaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                if (progress > 0)
                  Positioned(
                    left: (constraints.maxWidth * progress) - 8,
                    top: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isCompleted ? 'Completed' : 'In Progress',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGoalCard(VisionGoal goal) {
    // Determine progress color based on completion
    final progressColor = goal.progress > 1.0
        ? Colors.green
        : goal.isCompleted
            ? Colors.green
            : goal.progress > 0.7
                ? kPrimaryColor
                : kPrimaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main goal content
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal.goal,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: goal.progress > 1.0
                                ? [Colors.green, Colors.green.shade700]
                                : goal.isCompleted
                                    ? [kPrimaryColor, kPrimaryColor]
                                    : [kPrimaryColor, kPrimaryColor],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (goal.progress > 1.0
                                      ? Colors.green
                                      : goal.isCompleted
                                          ? kPrimaryColor
                                          : kPrimaryColor)
                                  .withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          goal.isCompleted ? 'Completed' : 'In Progress',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          progressColor.withValues(alpha: 0.1),
                          progressColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: progressColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(
                                'Target',
                                NumberFormatter.formatNumber(goal.target),
                                Icons.flag),
                            _buildStatItem(
                                'Achieved',
                                NumberFormatter.formatNumber(goal.achieved),
                                Icons.check_circle),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildEnhancedProgressBar(goal.progress, progressColor),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                goal.progress > 1.0
                                    ? '${goal.progressPercentage}% Complete (Exceeded!)'
                                    : '${goal.progressPercentage}% Complete',
                                style: TextStyle(
                                  color: goal.progress > 1.0
                                      ? Colors.green
                                      : progressColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                goal.progress > 1.0
                                    ? '${goal.achieved - goal.target} over target'
                                    : '${goal.remaining} remaining',
                                style: TextStyle(
                                  color: goal.progress > 1.0
                                      ? Colors.green
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Quick actions bar
          Consumer<VisionBoardProvider>(
            builder: (context, visionBoardProvider, child) {
              final currentYear = DateTime.now().year;
              final isPreviousYear =
                  visionBoardProvider.currentYear < currentYear;

              if (isPreviousYear) {
                // Show view-only message for previous year goals
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.withValues(alpha: 0.05),
                        Colors.grey.withValues(alpha: 0.02),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility,
                        color: Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'View Only - Previous Year Goal',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show action buttons for current/future year goals
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.withValues(alpha: 0.05),
                      Colors.grey.withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.edit,
                        label: 'Edit',
                        color: kPrimaryColor,
                        onTap: () => _showEditGoalDialog(goal),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.delete,
                        label: 'Delete',
                        color: kPrimaryColor,
                        onTap: () => _showDeleteConfirmationDialog(goal),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: Icons.update,
                        label: 'Update Progress',
                        color: kPrimaryColor,
                        onTap: () => _showUpdateProgressDialog(goal),
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: kPrimaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedProgressBar(double progress, Color progressColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      progressColor,
                      progressColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            if (progress > 0)
              Positioned(
                left: (constraints.maxWidth * progress) - 8,
                top: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: progressColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewCard(VisionBoardProvider provider) {
    final totalProgress = (provider.totalProgress * 100).round();
    final completedGoals = provider.completedGoalsCount;
    final totalGoals = provider.totalGoalsCount;

    // Determine overview color based on progress
    final overviewColor = totalProgress >= 80
        ? kPrimaryColor
        : totalProgress >= 50
            ? kPrimaryColor
            : kPrimaryColor;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            overviewColor,
            overviewColor.withValues(alpha: 0.8),
            overviewColor.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: overviewColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.flag,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Year ${provider.currentYear} Overview',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Your vision board progress',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$totalProgress%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildOverviewProgressBar(provider.totalProgress),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEnhancedOverviewItem('Total Goals', totalGoals.toString(),
                  Icons.flag, Colors.white),
              _buildEnhancedOverviewItem('Completed', completedGoals.toString(),
                  Icons.check_circle, Colors.white),
              _buildEnhancedOverviewItem(
                  'Remaining',
                  (totalGoals - completedGoals).toString(),
                  Icons.schedule,
                  Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewProgressBar(double progress) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            if (progress > 0)
              Positioned(
                left: (constraints.maxWidth * progress) - 8,
                top: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedOverviewItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildContent() {
    try {
      // Set custom keys for Crashlytics
      FirebaseCrashlytics.instance.setCustomKey('screen', 'vision_board');
      FirebaseCrashlytics.instance.setCustomKey('action', 'build_content');

      return Consumer<VisionBoardProvider>(
        builder: (context, visionBoardProvider, child) {
          if (visionBoardProvider.isLoading &&
              !visionBoardProvider.isInitialized) {
            return ShimmerLoading.buildVisionBoardShimmer();
          }

          if (visionBoardProvider.hasError) {
            // Log error to Crashlytics
            FirebaseCrashlytics.instance
                .log('Vision board screen error: ${visionBoardProvider.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(visionBoardProvider.error!,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  CommonStyles.primaryButton(
                    text: 'Retry',
                    onPressed: () => _loadVisionBoardData(),
                    icon: Icons.refresh,
                  ),
                ],
              ),
            );
          }

          if (!visionBoardProvider.hasVisionBoard) {
            final currentYear = DateTime.now().year;
            final selectedYear = visionBoardProvider.currentYear;
            final canAddGoals = selectedYear >= currentYear;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 64,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    canAddGoals
                        ? 'No Vision Board Found'
                        : 'No Vision Board for $selectedYear',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    canAddGoals
                        ? 'Start by adding your first goal for $selectedYear'
                        : 'No goals were set for this year',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (canAddGoals) ...[
                    const SizedBox(height: 20),
                    CommonStyles.primaryButton(
                      text: 'Add First Goal',
                      onPressed: _showAddGoalDialog,
                      icon: Icons.add,
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final provider =
                  Provider.of<VisionBoardProvider>(context, listen: false);
              await provider.refreshVisionBoard();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildOverviewCard(visionBoardProvider),
                  const SizedBox(height: 8),
                  ...visionBoardProvider.goals
                      .map((goal) => _buildGoalCard(goal)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to build vision board content',
        information: ['VisionBoardScreen.buildContent'],
      );
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Please try again later'),
            const SizedBox(height: 20),
            CommonStyles.primaryButton(
              text: 'Retry',
              onPressed: () => _loadVisionBoardData(),
              icon: Icons.refresh,
            ),
          ],
        ),
      );
    }
  }
}
