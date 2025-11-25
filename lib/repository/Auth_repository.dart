// auth_repository.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:master_mind/models/User_model.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/core/error_handling/error_handling.dart';
import 'package:master_mind/core/error_handling/exceptions/custom_exceptions.dart';
import 'package:master_mind/services/http_service.dart';

class AuthRepository {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final HttpService _httpService = HttpService();

  AuthRepository();

  Future<String?> getAuthToken() async {
    try {
      return await storage.read(key: 'authToken');
    } catch (e) {
      _httpService.trackAuthError('secure_storage', 'READ',
          'Failed to retrieve authentication token: $e');
      throw CacheException('Failed to retrieve authentication token: $e');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    // Removed unused variable
    const endpoint = '/v1/auth/signin';

    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        _httpService.trackValidationError(endpoint, 'POST', 'email/password',
            'Email and password are required', null);
        throw ValidationException('Email and password are required');
      }

      final url = Uri.parse('$baseurl$endpoint');
      final requestBody = {'email': email, 'password': password};

      final response = await _httpService
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          if (data['data'] == null || data['data']['accessToken'] == null) {
            _httpService.trackParsingError(
                endpoint,
                'POST',
                'Invalid response format: access token not found',
                response.body);
            throw ValidationException(
                'Invalid response format: access token not found');
          }

          final authToken = data['data']['accessToken'];
          await storage.write(key: 'authToken', value: authToken);

          // Set user context for Crashlytics
          _httpService.monitoringService.setUserContext(
            userEmail: email,
            userRole: data['data']['role'] ?? 'user',
          );

          return data;
        } catch (e) {
          _httpService.trackParsingError(endpoint, 'POST',
              'Invalid response format from server', response.body);
          throw ValidationException('Invalid response format from server');
        }
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Login failed');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Login failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String company,
    required String position,
    required String industry,
    required String region,
    required String chapter,
  }) async {
    const endpoint = '/v1/auth/signup';

    try {
      // Validate required fields
      final requiredFields = {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'company': company,
        'position': position,
        'industry': industry,
        'region': region,
        'chapter': chapter,
      };

      for (final entry in requiredFields.entries) {
        if (entry.value.isEmpty) {
          _httpService.trackValidationError(
              endpoint, 'POST', entry.key, '${entry.key} is required', null);
          throw ValidationException('${entry.key} is required');
        }
      }

      final url = Uri.parse('$baseurl$endpoint');
      final requestBody = {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'company': company,
        'position': position,
        'industry': industry,
        'region': region,
        'chapter': chapter,
      };

      final response = await _httpService
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          return data;
        } catch (e) {
          _httpService.trackParsingError(endpoint, 'POST',
              'Invalid response format from server', response.body);
          throw ValidationException('Invalid response format from server');
        }
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Registration failed');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Registration failed: ${e.toString()}');
    }
  }

  Future<bool> resetPassword(String oldPassword, String newPassword) async {
    try {
      final String? accessToken = await getAuthToken();

      if (accessToken == null) {
        throw AuthenticationException('Access token not found');
      }

      // Validate passwords
      if (oldPassword.isEmpty || newPassword.isEmpty) {
        throw ValidationException('Old and new passwords are required');
      }

      if (newPassword.length < 6) {
        throw ValidationException(
            'New password must be at least 6 characters long');
      }

      final url = Uri.parse('$baseurl/v1/auth/password/reset');

      final response = await http
          .patch(
            url,
            headers: {
              'Content-Type': 'application/json',
              'access-token': accessToken,
            },
            body: json.encode({
              'oldPassword': oldPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Password reset failed');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Password reset failed: ${e.toString()}');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final String? accessToken = await getAuthToken();

      if (accessToken == null) {
        throw AuthenticationException('No authentication token found');
      }

      final url = Uri.parse('$baseurl/v1/auth/me');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          if (data['user'] == null) {
            throw ValidationException(
                'Invalid response format: user data not found');
          }

          return User.fromJson(data['user']);
        } catch (e) {
          throw ValidationException('Invalid response format from server');
        }
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to get current user');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to get current user: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      // Clear user context from Crashlytics
      _httpService.monitoringService.clearUserContext();

      // Clear stored token
      await storage.delete(key: 'authToken');
    } catch (e) {
      _httpService.trackAuthError('secure_storage', 'DELETE',
          'Failed to clear authentication token: $e');
      throw CacheException('Failed to clear authentication token: $e');
    }
  }

  Future<bool> verifyEmail(String token) async {
    try {
      if (token.isEmpty) {
        throw ValidationException('Verification token is required');
      }

      final url = Uri.parse('$baseurl/v1/auth/verify-email');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'token': token,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Email verification failed');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Email verification failed: ${e.toString()}');
    }
  }

  Future<bool> resendVerificationEmail() async {
    try {
      final String? accessToken = await getAuthToken();

      if (accessToken == null) {
        throw AuthenticationException('No authentication token found');
      }

      final url = Uri.parse('$baseurl/v1/auth/resend-verification');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to resend verification email');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException(
          'Failed to resend verification email: ${e.toString()}');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
