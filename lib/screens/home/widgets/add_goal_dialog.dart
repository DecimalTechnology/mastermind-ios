import 'package:flutter/material.dart';
import 'package:master_mind/providers/vision_board_provider.dart';
import 'package:master_mind/utils/const.dart';

class AddGoalDialog extends StatefulWidget {
  final VisionBoardProvider visionBoardProvider;

  const AddGoalDialog({super.key, required this.visionBoardProvider});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  String goalText = '';
  double target = 0.0;
  double achieved = 0.0;

  @override
  Widget build(BuildContext context) {
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
            onChanged: (value) => goalText = value,
          ),
          const SizedBox(height: 15),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Target Value',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => target = double.tryParse(value) ?? 0.0,
          ),
          const SizedBox(height: 15),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Achieved Value (Optional)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => achieved = double.tryParse(value) ?? 0.0,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              widget.visionBoardProvider.isLoading ? null : _handleAddGoal,
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          child: widget.visionBoardProvider.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add Goal', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _handleAddGoal() async {
    if (goalText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a goal description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await widget.visionBoardProvider.addGoal(
      goal: goalText,
      target: target,
      achieved: achieved,
    );

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(widget.visionBoardProvider.error ?? 'Failed to add goal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
