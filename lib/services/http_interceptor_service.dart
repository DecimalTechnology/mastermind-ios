import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:master_mind/core/error_handling/exceptions/custom_exceptions.dart';
import 'package:master_mind/core/error_handling/handlers/error_handler.dart';
import 'package:master_mind/services/auth_token_service.dart';

/// HTTP interceptor service that handles authentication and token refresh
class HttpInterceptorService {
  static final HttpInterceptorService _instance =
      HttpInterceptorService._internal();
  factory HttpInterceptorService() => _instance;
  HttpInterceptorService._internal();

  final AuthTokenService _authTokenService = AuthTokenService();
  final http.Client _client = http.Client();

  // Track failed requests to prevent infinite loops
  final Set<String> _failedRequests = <String>{};
  final Set<String> _authErrorRequests = <String>{};

  /// Enhanced GET request with automatic auth handling
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
    String? context,
    bool retryOnAuthError = true,
  }) async {
    final authHeaders = await _addAuthHeaders(headers);
    return await _makeRequest(
      () => _client
          .get(
            Uri.parse(url),
            headers: authHeaders,
          )
          .timeout(timeout),
      url: url,
      context: context,
      retryOnAuthError: retryOnAuthError,
    );
  }

  /// Enhanced POST request with automatic auth handling
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    String? context,
    bool retryOnAuthError = true,
  }) async {
    final authHeaders = await _addAuthHeaders(headers);
    return await _makeRequest(
      () => _client
          .post(
            Uri.parse(url),
            headers: authHeaders,
            body: body,
          )
          .timeout(timeout),
      url: url,
      context: context,
      retryOnAuthError: retryOnAuthError,
    );
  }

  /// Enhanced PUT request with automatic auth handling
  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    String? context,
    bool retryOnAuthError = true,
  }) async {
    final authHeaders = await _addAuthHeaders(headers);
    return await _makeRequest(
      () => _client
          .put(
            Uri.parse(url),
            headers: authHeaders,
            body: body,
          )
          .timeout(timeout),
      url: url,
      context: context,
      retryOnAuthError: retryOnAuthError,
    );
  }

  /// Enhanced DELETE request with automatic auth handling
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 30),
    String? context,
    bool retryOnAuthError = true,
  }) async {
    final authHeaders = await _addAuthHeaders(headers);
    return await _makeRequest(
      () => _client
          .delete(
            Uri.parse(url),
            headers: authHeaders,
            body: body,
          )
          .timeout(timeout),
      url: url,
      context: context,
      retryOnAuthError: retryOnAuthError,
    );
  }

  /// Make HTTP request with automatic auth error handling
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() request, {
    required String url,
    String? context,
    bool retryOnAuthError = true,
  }) async {
    try {
      final response = await request();

      // Handle successful response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Clear any previous failures for this URL
        _failedRequests.remove(url);
        _authErrorRequests.remove(url);
        return response;
      }

      // Handle 401 Unauthorized
      if (response.statusCode == 401) {
        return await _handleAuthError(request, url, context, retryOnAuthError);
      }

      // Handle other error responses
      return _handleErrorResponse(response, context);
    } catch (e) {
      if (e is AuthenticationException) {
        rethrow;
      }

      // Handle network errors
      ErrorHandler.logError(e, null, context: context);
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  /// Handle authentication errors (401)
  Future<http.Response> _handleAuthError(
    Future<http.Response> Function() originalRequest,
    String url,
    String? context,
    bool retryOnAuthError,
  ) async {
    if (kDebugMode) {}

    // Clear auth tokens
    await _authTokenService.handleAuthError();

    // Add to auth error requests to prevent loops
    _authErrorRequests.add(url);

    if (!retryOnAuthError || _authErrorRequests.contains(url)) {
      // Don't retry or already tried - throw auth exception
      throw AuthenticationException('Session expired. Please login again.');
    }

    // For now, just throw the auth exception
    // In the future, you could implement token refresh here
    throw AuthenticationException('Session expired. Please login again.');
  }

  /// Handle non-401 error responses
  http.Response _handleErrorResponse(http.Response response, String? context) {
    switch (response.statusCode) {
      case 400:
        throw ValidationException('Bad request: ${response.body}');
      case 403:
        throw PermissionException('Access denied: ${response.body}');
      case 404:
        throw AppException('Resource not found: ${response.body}');
      case 408:
        throw NetworkException('Request timeout: Please try again');
      case 429:
        throw NetworkException(
            'Too many requests: Please wait before trying again');
      case 500:
        throw ServerException('Internal server error: Please try again later');
      case 502:
        throw ServerException('Bad gateway: Server is temporarily unavailable');
      case 503:
        throw ServerException('Service unavailable: Please try again later');
      case 504:
        throw NetworkException('Gateway timeout: Please try again');
      default:
        throw AppException('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// Add authentication headers to request
  Future<Map<String, String>> _addAuthHeaders(
      Map<String, String>? headers) async {
    final authHeaders = headers ?? <String, String>{};

    // Add auth token if available
    final token = await _authTokenService.getAuthToken();
    if (token != null && token.isNotEmpty) {
      authHeaders['access-token'] = token;
    }

    // Add content type if not present
    if (!authHeaders.containsKey('Content-Type')) {
      authHeaders['Content-Type'] = 'application/json';
    }

    return authHeaders;
  }

  /// Clear failed request tracking
  void clearFailedRequests() {
    _failedRequests.clear();
    _authErrorRequests.clear();
  }

  /// Check if URL has had auth errors
  bool hasAuthError(String url) => _authErrorRequests.contains(url);

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
