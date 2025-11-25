// repository/search_repo.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Removed unused import
import 'package:master_mind/models/search_model.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/services/http_service.dart';

class SearchRepository {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final HttpService _httpService = HttpService();

  Future<String?> getAuthToken() async {
    try {
      final token = await storage.read(key: 'authToken');
      return token;
    } catch (e) {
      _httpService.trackAuthError('secure_storage', 'READ',
          'Failed to retrieve authentication token: $e');
      throw Exception('Failed to retrieve authentication token: $e');
    }
  }

  Future<List<SearchResult>> search(String query, String type, int page,
      String? location, String? company) async {
    const endpoint = '/v1/profile/search';

    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        _httpService.trackAuthError(
            endpoint, 'POST', 'No authentication token found');
        throw Exception('No authentication token found.');
      }

      final url =
          Uri.parse('$baseurl$endpoint?search=$query&type=$type&page=$page');
      final requestBody = {
        'googleMapLocation': location,
        'company': company,
      };

      final response = await _httpService.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        try {
          print(response.body);
          final decodedBody = json.decode(response.body);

          if (decodedBody is List) {
            return decodedBody
                .map((json) => SearchResult.fromJson(json))
                .toList();
          } else if (decodedBody is Map<String, dynamic> &&
              decodedBody.containsKey('data')) {
            final List<dynamic> data = decodedBody['data'];
            return data.map((json) => SearchResult.fromJson(json)).toList();
          } else {
            _httpService.trackParsingError(endpoint, 'POST',
                'Unexpected API response format', response.body);
            throw Exception('Unexpected API response format.');
          }
        } catch (e) {
          _httpService.trackParsingError(endpoint, 'POST',
              'Failed to parse search response: $e', response.body);
          throw Exception('Failed to parse search response: $e');
        }
      } else {
        throw Exception('Load failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during search: $e');
    }
  }
}
