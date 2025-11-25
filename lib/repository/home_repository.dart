import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:master_mind/models/home_model.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/core/error_handling/error_handling.dart';
import 'package:master_mind/core/error_handling/exceptions/custom_exceptions.dart';

class HomeRepository {
  final String baseUrl =
      '$baseurl/v1/profile/home'; // Use the working profile endpoint
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<String?> getAuthToken() async {
    try {
      return await storage.read(key: 'authToken');
    } catch (e) {
      throw CacheException('Failed to retrieve authentication token: $e');
    }
  }

  Future<HomeResponseModel> getHomeData() async {
    try {
      final accessToken = await getAuthToken();

      if (accessToken == null) {
        throw AuthenticationException('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      ).timeout(
          const Duration(seconds: 10)); // Reduced timeout for faster response

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);

          // Check if data exists
          if (jsonData['data'] != null) {
            if (jsonData['data']['nextMeeting'] != null) {
            } else {}
          } else {}

          return HomeResponseModel.fromJson(jsonData);
        } catch (e) {
          throw ValidationException(
              'Invalid home data format received from server: $e');
        }
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to fetch home data');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to fetch home data: ${e.toString()}');
    }
  }
}
