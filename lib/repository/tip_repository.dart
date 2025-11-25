import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:master_mind/models/tip_model.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/services/http_service.dart';

class TipRepository {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final HttpService _httpService = HttpService();

  Future<String?> getAuthToken() async {
    try {
      return await storage.read(key: 'authToken');
    } catch (e) {
      _httpService.trackAuthError('secure_storage', 'READ',
          'Failed to retrieve authentication token: $e');
      throw Exception('Failed to retrieve authentication token: $e');
    }
  }

  Future<List<Tip>> getAllTips() async {
    const endpoint = '/v1/tips';

    final accessToken = await getAuthToken();
    if (accessToken == null) {
      _httpService.trackAuthError(endpoint, 'GET', 'No authentication token');
      throw Exception('No authentication token found.');
    }

    final url = Uri.parse('$baseurl$endpoint');
    final response = await _httpService.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'access-token': accessToken,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final responseObj = TipsResponse.fromJson(data as Map<String, dynamic>);
      return responseObj.data;
    }

    throw Exception('Failed to load tips: ${response.statusCode}');
  }

  Future<Tip> getTipById(String tipId) async {
    final endpoint = '/v1/tips/$tipId';

    final accessToken = await getAuthToken();
    if (accessToken == null) {
      _httpService.trackAuthError(endpoint, 'GET', 'No authentication token');
      throw Exception('No authentication token found.');
    }

    final url = Uri.parse('$baseurl$endpoint');
    final response = await _httpService.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'access-token': accessToken,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final responseObj = TipResponse.fromJson(data as Map<String, dynamic>);
      return responseObj.data;
    }

    throw Exception('Failed to load tip: ${response.statusCode}');
  }

  Future<LikeDislikeResponse> likeTip(String tipId) async {
    final endpoint = '/v1/tips/$tipId/like';

    final accessToken = await getAuthToken();
    if (accessToken == null) {
      _httpService.trackAuthError(endpoint, 'PATCH', 'No authentication token');
      throw Exception('No authentication token found.');
    }

    final url = Uri.parse('$baseurl$endpoint');
    final response = await _httpService.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'access-token': accessToken,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LikeDislikeResponse.fromJson(data as Map<String, dynamic>);
    }

    throw Exception('Failed to like tip: ${response.statusCode}');
  }

  Future<LikeDislikeResponse> dislikeTip(String tipId) async {
    final endpoint = '/v1/tips/$tipId/dislike';

    final accessToken = await getAuthToken();
    if (accessToken == null) {
      _httpService.trackAuthError(endpoint, 'PATCH', 'No authentication token');
      throw Exception('No authentication token found.');
    }

    final url = Uri.parse('$baseurl$endpoint');
    final response = await _httpService.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'access-token': accessToken,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return LikeDislikeResponse.fromJson(data as Map<String, dynamic>);
    }

    throw Exception('Failed to dislike tip: ${response.statusCode}');
  }
}
