import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/accountability_slip.dart';
import 'package:master_mind/utils/const.dart';

class AccountabilityRepository {
  static final String baseUrl = '${baseurl}/v1/accountability';

  String _formatLocalDateTime(DateTime dt) {
    // Format the local time directly without UTC conversion
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d' 'T' '$hh:$mm';
  }

  Future<Map<String, dynamic>> createSlip({
    required String token,
    required AccountabilitySlip slip,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'place': slip.place,
        // format local time as yyyy-MM-dd'T'HH:mm without Z
        'date': _formatLocalDateTime(slip.date),
        'members': slip.members.map((e) => e.id).toList(),
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to create slip');
    }
  }

  Future<List<AccountabilitySlip>> getSlips({required String token}) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> list = data['data'] ?? [];
      return list.map((e) => AccountabilitySlip.fromJson(e)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch slips');
    }
  }

  Future<void> deleteSlip({
    required String token,
    required String slipId,
  }) async {
    await http.delete(
      Uri.parse('$baseUrl/$slipId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    // handle response if needed
  }

  Future<void> editSlip({
    required String token,
    required String slipId,
    required AccountabilitySlip slip,
  }) async {
    await http.put(
      Uri.parse('$baseUrl/$slipId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'place': slip.place,
        // format local time as yyyy-MM-dd'T'HH:mm without Z
        'date': _formatLocalDateTime(slip.date),
        'members': slip.members.map((e) => e.id).toList(),
      }),
    );
    // handle response if needed
  }
}
