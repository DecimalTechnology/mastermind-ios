import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:master_mind/models/profile_model.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/core/error_handling/error_handling.dart';
import 'package:master_mind/core/error_handling/exceptions/custom_exceptions.dart';
import 'package:master_mind/services/http_service.dart';

class ProfileRepository {
  final String baseUrl = '$baseurl/v1/profile';
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final HttpService _httpService = HttpService();

  // Used to allow cancelling an in-flight profile image upload.
  http.Client? _activeUploadClient;

  void cancelActiveProfileImageUpload() {
    try {
      _activeUploadClient?.close();
    } catch (_) {
      // ignore
    } finally {
      _activeUploadClient = null;
    }
  }

  String _normalizeImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;

    // Prefer HTTPS to avoid cleartext blocks / flaky behavior on Android networks.
    if (trimmed.startsWith('http://')) {
      return 'https://${trimmed.substring('http://'.length)}';
    }
    return trimmed;
  }

  Future<String?> getAuthToken() async {
    try {
      return await storage.read(key: 'authToken');
    } catch (e) {
      _httpService.trackAuthError('secure_storage', 'READ',
          'Failed to retrieve authentication token: $e');
      throw CacheException('Failed to retrieve authentication token: $e');
    }
  }

  Future<ProfileModel> getProfile() async {
    const endpoint = '/v1/profile';

    try {
      final accessToken = await getAuthToken();

      if (accessToken == null) {
        _httpService.trackAuthError(
            endpoint, 'GET', 'Authentication token not found');
        throw AuthenticationException('Authentication token not found');
      }

      final url = Uri.parse('$baseurl$endpoint');
      final response = await _httpService.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'access-token': accessToken,
        },
      ).timeout(
          const Duration(seconds: 10)); // Reduced timeout for faster response

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          return ProfileModel.fromJson(jsonData);
        } catch (e) {
          _httpService.trackParsingError(
              endpoint,
              'GET',
              'Invalid profile data format received from server',
              response.body);
          throw ValidationException(
              'Invalid profile data format received from server');
        }
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to fetch profile');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to fetch profile: ${e.toString()}');
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    const endpoint = '/v1/profile/profile-picture';

    try {
      final accessToken = await getAuthToken();

      if (accessToken == null) {
        _httpService.trackAuthError(
            endpoint, 'PATCH', 'Authentication token not found');
        throw AuthenticationException('Authentication token not found');
      }

      // Validate file exists and is readable
      if (!await imageFile.exists()) {
        throw ValidationException('Image file does not exist');
      }

      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw ValidationException('Image file is empty');
      }

      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw ValidationException('Image file is too large (max 10MB)');
      }

      print('🚀 Uploading profile image to: $baseurl$endpoint');
      print('📁 File size: ${(fileSize / 1024).toStringAsFixed(2)}KB');

      // IMPORTANT:
      // - Do NOT manually set Content-Type for multipart requests.
      //   The http package sets the correct boundary automatically.
      // - Use the same auth header style as the rest of the app to avoid intermittent 401s.
      final uri = Uri.parse('$baseurl$endpoint');

      Future<http.Response> sendOnce({required String method}) async {
        // Cancel any previous in-flight upload before starting a new one.
        cancelActiveProfileImageUpload();

        final client = http.Client();
        _activeUploadClient = client;

        try {
          final request = http.MultipartRequest(method, uri);

          // Keep auth header consistent with other endpoints in this repo.
          // Some backend endpoints expect `access-token`, some expect `Authorization: Bearer`.
          // Sending both prevents intermittent auth failures across environments.
          request.headers['access-token'] = accessToken;
          request.headers['Authorization'] = 'Bearer $accessToken';
          request.headers['Accept'] = 'application/json';

          // Add image file
          final imageField =
              await http.MultipartFile.fromPath('image', imageFile.path);
          request.files.add(imageField);

          // Extra fields (safe even if backend ignores them)
          request.fields['type'] = 'profile';
          request.fields['category'] = 'profile-picture';

          print('📤 Sending $method multipart request to: $uri');
          final streamedResponse =
              await client.send(request).timeout(const Duration(seconds: 60));
          return await http.Response.fromStream(streamedResponse);
        } finally {
          // Always close the client to avoid socket leaks.
          try {
            client.close();
          } catch (_) {
            // ignore
          }
          if (identical(_activeUploadClient, client)) {
            _activeUploadClient = null;
          }
        }
      }

      // Retry a couple of times on transient failures (timeouts / flaky networks / 5xx).
      http.Response? response;
      const maxAttempts = 3;
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          // Prefer PATCH (your backend uses PATCH), but fall back to POST if the server rejects PATCH.
          response = await sendOnce(method: 'PATCH');
          if (response.statusCode == 405 || response.statusCode == 404) {
            print(
                '⚠️ Server rejected PATCH (HTTP ${response.statusCode}). Retrying once with POST...');
            response = await sendOnce(method: 'POST');
          }

          // Retry on transient HTTP codes
          if (response.statusCode == 408 ||
              response.statusCode == 429 ||
              response.statusCode == 500 ||
              response.statusCode == 502 ||
              response.statusCode == 503 ||
              response.statusCode == 504) {
            if (attempt < maxAttempts) {
              final backoffMs = 400 * attempt * attempt;
              print(
                  '⚠️ Transient upload error (HTTP ${response.statusCode}). Retrying in ${backoffMs}ms... (attempt $attempt/$maxAttempts)');
              await Future.delayed(Duration(milliseconds: backoffMs));
              continue;
            }
          }

          break; // success or non-retryable code
        } on SocketException catch (e) {
          if (attempt >= maxAttempts) rethrow;
          final backoffMs = 400 * attempt * attempt;
          print(
              '⚠️ Upload network error: $e. Retrying in ${backoffMs}ms... (attempt $attempt/$maxAttempts)');
          await Future.delayed(Duration(milliseconds: backoffMs));
        } on TimeoutException catch (e) {
          if (attempt >= maxAttempts) rethrow;
          final backoffMs = 400 * attempt * attempt;
          print(
              '⚠️ Upload timeout: $e. Retrying in ${backoffMs}ms... (attempt $attempt/$maxAttempts)');
          await Future.delayed(Duration(milliseconds: backoffMs));
        }
      }

      if (response == null) {
        throw AppException('Failed to upload profile image (no response)');
      }

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonResponse = jsonDecode(response.body);
          print('🔍 Parsing response JSON...');
          print('🔍 Available keys: ${jsonResponse.keys.toList()}');

          // Try different possible response formats
          String? imageUrl;

          // Check for direct imageUrl field
          if (jsonResponse['imageUrl'] != null) {
            imageUrl = jsonResponse['imageUrl'].toString();
            print('✅ Found imageUrl in direct field: $imageUrl');
          }
          // Check for data.imageUrl format
          else if (jsonResponse['data'] != null &&
              jsonResponse['data']['imageUrl'] != null) {
            imageUrl = jsonResponse['data']['imageUrl'].toString();
            print('✅ Found imageUrl in data.imageUrl: $imageUrl');
          }
          // Check for data.image format
          else if (jsonResponse['data'] != null &&
              jsonResponse['data']['image'] != null) {
            imageUrl = jsonResponse['data']['image'].toString();
            print('✅ Found imageUrl in data.image: $imageUrl');
          }
          // Check for direct image field
          else if (jsonResponse['image'] != null) {
            imageUrl = jsonResponse['image'].toString();
            print('✅ Found imageUrl in image field: $imageUrl');
          }
          // Check for profile.imageUrl format
          else if (jsonResponse['profile'] != null &&
              jsonResponse['profile']['imageUrl'] != null) {
            imageUrl = jsonResponse['profile']['imageUrl'].toString();
            print('✅ Found imageUrl in profile.imageUrl: $imageUrl');
          }
          // Check for profile.image format
          else if (jsonResponse['profile'] != null &&
              jsonResponse['profile']['image'] != null) {
            imageUrl = jsonResponse['profile']['image'].toString();
            print('✅ Found imageUrl in profile.image: $imageUrl');
          }

          if (imageUrl == null || imageUrl.isEmpty) {
            print('❌ No valid image URL found in response');
            print('Available response keys: ${jsonResponse.keys.toList()}');
            throw ValidationException(
                'Image URL not found in response. Available keys: ${jsonResponse.keys.toList()}');
          }

          // Validate URL format
          if (imageUrl.startsWith('http://') ||
              imageUrl.startsWith('https://')) {
            final normalized = _normalizeImageUrl(imageUrl);
            print('✅ Final image URL: $normalized');
            return normalized;
          } else {
            // Try to construct full URL
            if (imageUrl.startsWith('/')) {
              final fullUrl = '$baseurl$imageUrl';
              final normalized = _normalizeImageUrl(fullUrl);
              print('✅ Constructed full URL: $normalized');
              return normalized;
            } else {
              final fullUrl = '$baseurl/$imageUrl';
              final normalized = _normalizeImageUrl(fullUrl);
              print('✅ Constructed full URL: $normalized');
              return normalized;
            }
          }
        } catch (e) {
          print('❌ Error parsing image upload response: $e');
          throw ValidationException(
              'Invalid response format for image upload: $e');
        }
      } else {
        print('❌ Image upload failed with status: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to upload profile image');
      }
    } catch (e) {
      print('❌ Profile image upload failed: $e');
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to upload profile image: ${e.toString()}');
    }
  }

  Future<ProfileModel> updateProfile(ProfileModel updates) async {
    try {
      final accessToken = await getAuthToken();
      if (accessToken == null) {
        throw AuthenticationException('Authentication token not found');
      }

      final response = await http
          .put(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'access-token': accessToken,
            },
            body: jsonEncode(updates.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          return ProfileModel.fromJson(jsonData);
        } catch (e) {
          throw ValidationException(
              'Invalid profile data format received from server');
        }
      } else {
        ErrorHandler.handleHttpResponse(response);
        throw AppException('Failed to update profile');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      ErrorHandler.handleNetworkError(e);
      throw AppException('Failed to update profile: ${e.toString()}');
    }
  }
}
