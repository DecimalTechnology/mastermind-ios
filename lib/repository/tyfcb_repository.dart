import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:master_mind/models/tyfcb_model.dart';
import 'package:master_mind/utils/const.dart';

class TYFCBRepository {
  Future<bool> submitTYFCB(TYFCBModel model, String token) async {
    final String apiUrl = '$baseurl/v1/tycb/${model.id}';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': model.message,
          'amount': model.amount,
          'businessType': model.businessType.toLowerCase(),
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Simulate POST /api/tycb/:id
  Future<TYFCBModel> createTYCB({
    required String id,
    required String thankYouTo,
    required String amount,
    required String businessType,
    required String comments,
  }) async {
    // TODO: Replace with actual HTTP POST call
    await Future.delayed(const Duration(seconds: 2));
    // Simulated response
    final response = {
      '_id': id,
      'message': comments,
      'amount': int.tryParse(amount) ?? 0,
      'createdAt': DateTime.now().toIso8601String(),
      'image': '',
      'name': thankYouTo,
      'email': '',
    };
    return TYFCBModel.fromJson(response);
  }

  Future<List<TYFCBModel>> getTYFCBs(String token,
      {required String type}) async {
    final String apiUrl = '$baseurl/v1/tycb/$type';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        return list.map((e) => TYFCBModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Deprecated: Use getTYFCBs(token, type: 'received') instead
  Future<List<TYFCBModel>> getReceivedTYFCBs(String token) async {
    return getTYFCBs(token, type: 'received');
  }

  // Deprecated: Use getTYFCBs(token, type: 'sent') instead
  Future<List<TYFCBModel>> getSentTYFCBs(String token) async {
    return getTYFCBs(token, type: 'sent');
  }

  Future<double> fetchTotalTYFCBAmount(String token) async {
    final String apiUrl =
        '$baseurl/v1/tycb/total-amount'; // <-- Adjust endpoint as per your backend
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming API returns: { "totalAmount": 75000 }
        return (data['totalAmount'] as num).toDouble();
      } else {
        return 0.0;
      }
    } catch (e) {
      return 0.0;
    }
  }
}
