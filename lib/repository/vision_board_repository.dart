import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:master_mind/models/vision_board_model.dart';
import 'package:master_mind/utils/const.dart';

class VisionBoardRepository {
  /// Add a goal to vision board (creates board if doesn't exist)
  Future<VisionBoardModel> addGoal({
    required String token,
    required String goal,
    required double target,
    required double achieved,
  }) async {
    final String apiUrl = '$baseurl/v1/visionboard';

    try {
      final requestBody = {
        'goal': goal,
        'target': target.toString(),
        'achieved': achieved.toString(),
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return VisionBoardModel.fromJson(data['data']);
        } else {
          throw Exception(
              'Failed to add goal: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to add goal: ${errorData['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('Error adding goal to vision board: $e');
    }
  }

  /// Get vision board by year
  Future<VisionBoardModel?> getVisionBoardByYear({
    required String token,
    required int year,
  }) async {
    final String apiUrl = '$baseurl/v1/visionboard/$year';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
          const Duration(seconds: 10)); // Added timeout for faster response

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return VisionBoardModel.fromJson(data['data']);
        }
      } else if (response.statusCode == 404) {
        // No vision board found for this year
        return null;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to get vision board: ${errorData['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('Error getting vision board by year: $e');
    }

    return null;
  }

  /// Update a goal in vision board
  Future<VisionBoardModel> updateGoal({
    required String token,
    required String goalId,
    required int year,
    String? goal,
    double? target,
    double? achieved,
  }) async {
    final String apiUrl = '$baseurl/v1/visionboard?goalId=$goalId&year=$year';

    try {
      final requestBody = <String, dynamic>{};
      if (goal != null) requestBody['goal'] = goal;
      if (target != null) requestBody['target'] = target.toString();
      if (achieved != null) requestBody['achieved'] = achieved.toString();

      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return VisionBoardModel.fromJson(data['data']);
        } else {
          throw Exception(
              'Failed to update goal: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to update goal: ${errorData['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('Error updating goal in vision board: $e');
    }
  }

  /// Delete a goal from vision board
  Future<VisionBoardModel> deleteGoal({
    required String token,
    required String goalId,
    required int year,
  }) async {
    final String apiUrl = '$baseurl/v1/visionboard?goalId=$goalId&year=$year';

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return VisionBoardModel.fromJson(data['data']);
        } else {
          throw Exception(
              'Failed to delete goal: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to delete goal: ${errorData['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting goal from vision board: $e');
    }
  }

  /// Get current year's vision board (convenience method)
  Future<VisionBoardModel?> getCurrentYearVisionBoard(String token) async {
    final currentYear = DateTime.now().year;
    return getVisionBoardByYear(token: token, year: currentYear);
  }

  /// Update goal progress (convenience method)
  Future<VisionBoardModel> updateGoalProgress({
    required String token,
    required String goalId,
    required int year,
    required double achieved,
  }) async {
    return updateGoal(
      token: token,
      goalId: goalId,
      year: year,
      achieved: achieved,
    );
  }
}
