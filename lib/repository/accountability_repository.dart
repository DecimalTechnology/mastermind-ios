import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/accountability_slip.dart';
import 'package:master_mind/utils/const.dart';

class AccountabilityRepository {
  static final String baseUrl = '${baseurl}/v1/accountability';

  String _formatDateTimeForServer(DateTime dt) {
    // Convert local DateTime to UTC first, then format
    // This ensures the server always receives UTC time regardless of server timezone
    final utcDate = dt.isUtc ? dt : dt.toUtc();

    final y = utcDate.year.toString().padLeft(4, '0');
    final m = utcDate.month.toString().padLeft(2, '0');
    final d = utcDate.day.toString().padLeft(2, '0');
    final hh = utcDate.hour.toString().padLeft(2, '0');
    final mm = utcDate.minute.toString().padLeft(2, '0');
    final ss = utcDate.second.toString().padLeft(2, '0');

    // Format as ISO 8601 with 'Z' suffix to explicitly indicate UTC
    // Format: yyyy-MM-ddTHH:mm:ssZ
    return '$y-$m-$d' 'T' '$hh:$mm:$ss' 'Z';
  }

  Future<Map<String, dynamic>> createSlip({
    required String token,
    required AccountabilitySlip slip,
  }) async {
    // Log the date being sent
    final localDate = slip.date.toLocal();
    final utcDate = slip.date.toUtc();
    final formattedDate = _formatDateTimeForServer(slip.date);

    print("\n" + "=" * 80);
    print("📤 CREATING ACCOUNTABILITY SLIP");
    print("=" * 80);
    print("Local DateTime (user input): ${localDate.toString()}");
    print("UTC DateTime (converted): ${utcDate.toString()}");
    print("Formatted for server: $formattedDate");
    print("=" * 80 + "\n");

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'place': slip.place,
        // Convert local time to UTC and format as ISO 8601 with 'Z' suffix
        // This ensures consistent behavior across local and hosted servers
        'date': formattedDate,
        'members': slip.members.map((e) => e.id).toList(),
      }),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("\n✅ ACCOUNTABILITY SLIP CREATED SUCCESSFULLY");
      print("Response: ${const JsonEncoder.withIndent('  ').convert(data)}\n");
      return data;
    } else {
      print("\n❌ FAILED TO CREATE ACCOUNTABILITY SLIP");
      print("Status Code: ${response.statusCode}");
      print("Response: ${response.body}\n");
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
      // Pretty print the full API response
      print("\n" + "=" * 80);
      print("📋 ACCOUNTABILITY SLIPS API RESPONSE (FULL)");
      print("=" * 80);
      print(const JsonEncoder.withIndent('  ').convert(data));
      print("=" * 80 + "\n");

      final List<dynamic> list = data['data'] ?? [];

      print("📋 PARSING ${list.length} ACCOUNTABILITY SLIPS:");
      final slips = list.asMap().entries.map((entry) {
        final index = entry.key;
        final json = entry.value;
        try {
          print("\n--- Accountability Slip #${index + 1} Raw JSON ---");
          print(
              "  date field: ${json['date']} (type: ${json['date'].runtimeType})");
          final slip = AccountabilitySlip.fromJson(json);
          print(
              "  Parsed date: ${slip.date} (UTC: ${slip.date.toUtc()}, Local: ${slip.date.toLocal()})");
          return slip;
        } catch (e) {
          print("❌ Error parsing slip #${index + 1}: $e");
          print(
              "   Raw JSON: ${const JsonEncoder.withIndent('  ').convert(json)}");
          rethrow;
        }
      }).toList();

      return slips;
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
        // Convert local time to UTC and format as ISO 8601 with 'Z' suffix
        // This ensures consistent behavior across local and hosted servers
        'date': _formatDateTimeForServer(slip.date),
        'members': slip.members.map((e) => e.id).toList(),
      }),
    );
    // handle response if needed
  }
}
