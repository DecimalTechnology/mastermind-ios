import 'dart:io';
import 'dart:async';
// Removed unused import
import 'package:http/http.dart' as http;
import '../exceptions/custom_exceptions.dart';
import '../exceptions/app_exceptions.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Timeout constants
const Duration kDefaultApiTimeout = Duration(seconds: 30);
const Duration kFileUploadTimeout = Duration(seconds: 120);

/// Enhanced HTTP service with comprehensive exception handling
class EnhancedHttpService {
  static final EnhancedHttpService _instance = EnhancedHttpService._internal();
  factory EnhancedHttpService() => _instance;
  EnhancedHttpService._internal();

  final http.Client _client = http.Client();

  // ===== NETWORK & API EXCEPTION HANDLING =====

  /// Enhanced GET request with comprehensive error handling
  Future<http.Response?> get(
    String url, {
    Map<String, String>? headers,
    Duration timeout = kDefaultApiTimeout,
    String? context,
  }) async {
    // Check network connectivity first
    final hasConnection =
        await ComprehensiveExceptionHandler.checkNetworkConnectivity();
    if (!hasConnection) {
      throw NetworkException('No internet connection available');
    }

    return await ComprehensiveExceptionHandler.handleApiTimeout(
      () async {
        try {
          final response = await _client
              .get(
                Uri.parse(url),
                headers: headers,
              )
              .timeout(timeout);

          return _handleResponse(response, context: context);
        } on SocketException catch (e) {
          _logHttpError(e, context, url);
          throw NetworkException('Network connection failed: ${e.message}');
        } on TimeoutException catch (e) {
          _logHttpError(e, context, url);
          throw NetworkException(
              'Request timed out after ${timeout.inSeconds} seconds');
        } on FormatException catch (e) {
          _logHttpError(e, context, url);
          throw DataException('Invalid URL format: ${e.message}');
        } catch (e) {
          _logHttpError(e, context, url);
          throw NetworkException('Unexpected network error: ${e.toString()}');
        }
      },
      timeout: timeout,
      context: context,
    );
  }

  /// Enhanced POST request with comprehensive error handling
  Future<http.Response?> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = kDefaultApiTimeout,
    String? context,
  }) async {
    // Check network connectivity first
    final hasConnection =
        await ComprehensiveExceptionHandler.checkNetworkConnectivity();
    if (!hasConnection) {
      throw NetworkException('No internet connection available');
    }

    return await ComprehensiveExceptionHandler.handleApiTimeout(
      () async {
        try {
          final response = await _client
              .post(
                Uri.parse(url),
                headers: headers,
                body: body,
              )
              .timeout(timeout);

          return _handleResponse(response, context: context);
        } on SocketException catch (e) {
          throw NetworkException('Network connection failed: ${e.message}');
        } on TimeoutException catch (e) {
          throw NetworkException(
              'Request timed out after ${timeout.inSeconds} seconds');
        } on FormatException catch (e) {
          throw DataException('Invalid request format: ${e.message}');
        } catch (e) {
          throw NetworkException('Unexpected network error: ${e.toString()}');
        }
      },
      timeout: timeout,
      context: context,
    );
  }

  /// Enhanced PUT request with comprehensive error handling
  Future<http.Response?> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = kDefaultApiTimeout,
    String? context,
  }) async {
    // Check network connectivity first
    final hasConnection =
        await ComprehensiveExceptionHandler.checkNetworkConnectivity();
    if (!hasConnection) {
      throw NetworkException('No internet connection available');
    }

    return await ComprehensiveExceptionHandler.handleApiTimeout(
      () async {
        try {
          final response = await _client
              .put(
                Uri.parse(url),
                headers: headers,
                body: body,
              )
              .timeout(timeout);

          return _handleResponse(response, context: context);
        } on SocketException catch (e) {
          throw NetworkException('Network connection failed: ${e.message}');
        } on TimeoutException catch (e) {
          throw NetworkException(
              'Request timed out after ${timeout.inSeconds} seconds');
        } on FormatException catch (e) {
          throw DataException('Invalid request format: ${e.message}');
        } catch (e) {
          throw NetworkException('Unexpected network error: ${e.toString()}');
        }
      },
      timeout: timeout,
      context: context,
    );
  }

  /// Enhanced DELETE request with comprehensive error handling
  Future<http.Response?> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = kDefaultApiTimeout,
    String? context,
  }) async {
    // Check network connectivity first
    final hasConnection =
        await ComprehensiveExceptionHandler.checkNetworkConnectivity();
    if (!hasConnection) {
      throw NetworkException('No internet connection available');
    }

    return await ComprehensiveExceptionHandler.handleApiTimeout(
      () async {
        try {
          final response = await _client
              .delete(
                Uri.parse(url),
                headers: headers,
                body: body,
              )
              .timeout(timeout);

          return _handleResponse(response, context: context);
        } on SocketException catch (e) {
          throw NetworkException('Network connection failed: ${e.message}');
        } on TimeoutException catch (e) {
          throw NetworkException(
              'Request timed out after ${timeout.inSeconds} seconds');
        } on FormatException catch (e) {
          throw DataException('Invalid request format: ${e.message}');
        } catch (e) {
          throw NetworkException('Unexpected network error: ${e.toString()}');
        }
      },
      timeout: timeout,
      context: context,
    );
  }

  /// Enhanced multipart request for file uploads
  Future<http.Response?> multipartPost(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    Duration timeout = kFileUploadTimeout,
    String? context,
  }) async {
    // Check network connectivity first
    final hasConnection =
        await ComprehensiveExceptionHandler.checkNetworkConnectivity();
    if (!hasConnection) {
      throw NetworkException('No internet connection available');
    }

    // Check storage space for file uploads
    final hasStorage = await ComprehensiveExceptionHandler.checkStorageSpace();
    if (!hasStorage) {
      throw StorageException('Insufficient storage space for file upload');
    }

    return await ComprehensiveExceptionHandler.handleApiTimeout(
      () async {
        try {
          final request = http.MultipartRequest('POST', Uri.parse(url));

          // Add headers
          if (headers != null) {
            request.headers.addAll(headers);
          }

          // Add fields
          if (fields != null) {
            request.fields.addAll(fields);
          }

          // Add files
          if (files != null) {
            request.files.addAll(files);
          }

          final streamedResponse = await request.send().timeout(timeout);
          final response = await http.Response.fromStream(streamedResponse);

          return _handleResponse(response, context: context);
        } on SocketException catch (e) {
          throw NetworkException('Network connection failed: ${e.message}');
        } on TimeoutException catch (e) {
          throw NetworkException(
              'File upload timed out after ${timeout.inSeconds} seconds');
        } on FileSystemException catch (e) {
          throw StorageException('File system error: ${e.message}');
        } catch (e) {
          throw NetworkException('Unexpected upload error: ${e.toString()}');
        }
      },
      timeout: timeout,
      context: context,
    );
  }

  // ===== RESPONSE HANDLING =====

  /// Handle HTTP response with comprehensive error checking
  http.Response _handleResponse(http.Response response, {String? context}) {
    // Handle different HTTP status codes
    switch (response.statusCode) {
      case 200:
      case 201:
        return response;
      case 400:
        throw ValidationException('Bad request: ${response.body}');
      case 401:
        throw AuthenticationException('Unauthorized: Please login again');
      case 403:
        throw PermissionException(
            'Access denied: You don\'t have permission for this action');
      case 404:
        throw NetworkException('Resource not found: ${response.body}');
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
        throw NetworkException('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // ===== JSON PARSING WITH ERROR HANDLING =====

  /// Safe JSON parsing for API responses
  T? parseJsonResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson, {
    T? fallbackValue,
    String? context,
  }) {
    try {
      // Validate response body
      if (response.body.isEmpty) {
        throw DataException('Empty response body');
      }

      // Parse JSON safely
      final jsonData = ComprehensiveExceptionHandler.safeJsonParse(
        response.body,
        fromJson,
        fallbackValue: fallbackValue,
        context: context,
      );

      if (jsonData == null) {
        throw DataException('Failed to parse JSON response');
      }

      return jsonData;
    } on FormatException catch (e) {
      throw DataException('Invalid JSON format: ${e.message}');
    } catch (e) {
      throw DataException('JSON parsing error: ${e.toString()}');
    }
  }

  // ===== UTILITY METHODS =====

  /// Create multipart file with error handling
  Future<http.MultipartFile?> createMultipartFile(
    String field,
    File file, {
    String? context,
  }) async {
    return await ComprehensiveExceptionHandler.safeAsyncOperation(
      () async {
        // Check if file exists
        if (!await file.exists()) {
          throw FileException('File does not exist: ${file.path}');
        }

        // Check file size
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          // 10MB limit
          throw FileException(
              'File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');
        }

        return await http.MultipartFile.fromPath(field, file.path);
      },
      context: context,
    );
  }

  /// Add authentication headers
  Map<String, String> addAuthHeaders(
    Map<String, String>? headers,
    String? token,
  ) {
    final authHeaders = headers ?? <String, String>{};
    if (token != null && token.isNotEmpty) {
      authHeaders['Authorization'] = 'Bearer $token';
    }
    return authHeaders;
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }

  /// Log HTTP errors to Crashlytics
  static void _logHttpError(dynamic error, String? context, String url) {
    try {
      FirebaseCrashlytics.instance.setCustomKey('error_type', 'http_error');
      FirebaseCrashlytics.instance
          .setCustomKey('http_context', context ?? 'unknown');
      FirebaseCrashlytics.instance.setCustomKey('http_url', url);
      FirebaseCrashlytics.instance
          .setCustomKey('http_method', 'GET'); // You can make this dynamic

      FirebaseCrashlytics.instance.recordError(
        error,
        StackTrace.current,
        reason: 'HTTP error in $context for $url',
      );
    } catch (e) {
      print('Failed to log HTTP error to Crashlytics: $e');
    }
  }
}
