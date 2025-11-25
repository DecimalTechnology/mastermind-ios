import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'api_monitoring_service.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  final ApiMonitoringService _monitoringService = ApiMonitoringService();

  /// Public getter for monitoring service
  ApiMonitoringService get monitoringService => _monitoringService;

  /// GET request with Crashlytics monitoring
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    final startTime = DateTime.now();
    final endpoint = _getEndpointFromUrl(url);

    try {
      // Track API call start
      _monitoringService.trackApiCallStart(
        endpoint: endpoint,
        method: 'GET',
        queryParams: queryParams,
      );

      // Make the request
      final response = await http.get(url, headers: headers);

      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      // Track success or error
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _monitoringService.trackApiCallSuccess(
          endpoint: endpoint,
          method: 'GET',
          statusCode: response.statusCode,
          responseTimeMs: responseTime,
          responseBody: _parseResponseBody(response.body),
        );
      } else {
        _monitoringService.trackApiCallError(
          endpoint: endpoint,
          method: 'GET',
          statusCode: response.statusCode,
          errorMessage: response.body,
          responseTimeMs: responseTime,
          responseBody: _parseResponseBody(response.body),
          stackTrace: StackTrace.current,
        );
      }

      return response;
    } catch (e, stackTrace) {
      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      if (e is TimeoutException) {
        _monitoringService.trackTimeoutError(
          endpoint: endpoint,
          method: 'GET',
          timeout: const Duration(seconds: 30),
        );
      } else {
        _monitoringService.trackNetworkError(
          endpoint: endpoint,
          method: 'GET',
          errorMessage: e.toString(),
          responseTimeMs: responseTime,
          stackTrace: stackTrace,
        );
      }

      rethrow;
    }
  }

  /// POST request with Crashlytics monitoring
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? queryParams,
  }) async {
    final startTime = DateTime.now();
    final endpoint = _getEndpointFromUrl(url);
    Map<String, dynamic>? requestBody;

    try {
      // Parse request body for monitoring
      if (body != null) {
        if (body is String) {
          try {
            requestBody = jsonDecode(body);
          } catch (e) {
            requestBody = {'raw_body': body};
          }
        } else if (body is Map) {
          requestBody = Map<String, dynamic>.from(body);
        }
      }

      // Track API call start
      _monitoringService.trackApiCallStart(
        endpoint: endpoint,
        method: 'POST',
        requestBody: requestBody,
        queryParams: queryParams,
      );

      // Make the request
      final response = await http.post(url, headers: headers, body: body);

      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      // Track success or error
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _monitoringService.trackApiCallSuccess(
          endpoint: endpoint,
          method: 'POST',
          statusCode: response.statusCode,
          responseTimeMs: responseTime,
          responseBody: _parseResponseBody(response.body),
        );
      } else {
        _monitoringService.trackApiCallError(
          endpoint: endpoint,
          method: 'POST',
          statusCode: response.statusCode,
          errorMessage: response.body,
          responseTimeMs: responseTime,
          requestBody: requestBody,
          responseBody: _parseResponseBody(response.body),
          stackTrace: StackTrace.current,
        );
      }

      return response;
    } catch (e, stackTrace) {
      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      if (e is TimeoutException) {
        _monitoringService.trackTimeoutError(
          endpoint: endpoint,
          method: 'POST',
          timeout: const Duration(seconds: 30),
          requestBody: requestBody,
        );
      } else {
        _monitoringService.trackNetworkError(
          endpoint: endpoint,
          method: 'POST',
          errorMessage: e.toString(),
          responseTimeMs: responseTime,
          requestBody: requestBody,
          stackTrace: stackTrace,
        );
      }

      rethrow;
    }
  }

  /// PUT request with Crashlytics monitoring
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? queryParams,
  }) async {
    final startTime = DateTime.now();
    final endpoint = _getEndpointFromUrl(url);
    Map<String, dynamic>? requestBody;

    try {
      // Parse request body for monitoring
      if (body != null) {
        if (body is String) {
          try {
            requestBody = jsonDecode(body);
          } catch (e) {
            requestBody = {'raw_body': body};
          }
        } else if (body is Map) {
          requestBody = Map<String, dynamic>.from(body);
        }
      }

      // Track API call start
      _monitoringService.trackApiCallStart(
        endpoint: endpoint,
        method: 'PUT',
        requestBody: requestBody,
        queryParams: queryParams,
      );

      // Make the request
      final response = await http.put(url, headers: headers, body: body);

      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      // Track success or error
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _monitoringService.trackApiCallSuccess(
          endpoint: endpoint,
          method: 'PUT',
          statusCode: response.statusCode,
          responseTimeMs: responseTime,
          responseBody: _parseResponseBody(response.body),
        );
      } else {
        _monitoringService.trackApiCallError(
          endpoint: endpoint,
          method: 'PUT',
          statusCode: response.statusCode,
          errorMessage: response.body,
          responseTimeMs: responseTime,
          requestBody: requestBody,
          responseBody: _parseResponseBody(response.body),
          stackTrace: StackTrace.current,
        );
      }

      return response;
    } catch (e, stackTrace) {
      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      if (e is TimeoutException) {
        _monitoringService.trackTimeoutError(
          endpoint: endpoint,
          method: 'PUT',
          timeout: const Duration(seconds: 30),
          requestBody: requestBody,
        );
      } else {
        _monitoringService.trackNetworkError(
          endpoint: endpoint,
          method: 'PUT',
          errorMessage: e.toString(),
          responseTimeMs: responseTime,
          requestBody: requestBody,
          stackTrace: stackTrace,
        );
      }

      rethrow;
    }
  }

  /// PATCH request with Crashlytics monitoring
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? queryParams,
  }) async {
    final startTime = DateTime.now();
    final endpoint = _getEndpointFromUrl(url);
    Map<String, dynamic>? requestBody;

    try {
      // Parse request body for monitoring
      if (body != null) {
        if (body is String) {
          try {
            requestBody = jsonDecode(body);
          } catch (e) {
            requestBody = {'raw_body': body};
          }
        } else if (body is Map) {
          requestBody = Map<String, dynamic>.from(body);
        }
      }

      // Track API call start
      _monitoringService.trackApiCallStart(
        endpoint: endpoint,
        method: 'PATCH',
        requestBody: requestBody,
        queryParams: queryParams,
      );

      // Make the request
      final response = await http.patch(url, headers: headers, body: body);

      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      // Track success or error
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _monitoringService.trackApiCallSuccess(
          endpoint: endpoint,
          method: 'PATCH',
          statusCode: response.statusCode,
          responseTimeMs: responseTime,
          responseBody: _parseResponseBody(response.body),
        );
      } else {
        _monitoringService.trackApiCallError(
          endpoint: endpoint,
          method: 'PATCH',
          statusCode: response.statusCode,
          errorMessage: response.body,
          responseTimeMs: responseTime,
          requestBody: requestBody,
          responseBody: _parseResponseBody(response.body),
          stackTrace: StackTrace.current,
        );
      }

      return response;
    } catch (e, stackTrace) {
      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      if (e is TimeoutException) {
        _monitoringService.trackTimeoutError(
          endpoint: endpoint,
          method: 'PATCH',
          timeout: const Duration(seconds: 30),
          requestBody: requestBody,
        );
      } else {
        _monitoringService.trackNetworkError(
          endpoint: endpoint,
          method: 'PATCH',
          errorMessage: e.toString(),
          responseTimeMs: responseTime,
          requestBody: requestBody,
          stackTrace: stackTrace,
        );
      }

      rethrow;
    }
  }

  /// DELETE request with Crashlytics monitoring
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? queryParams,
  }) async {
    final startTime = DateTime.now();
    final endpoint = _getEndpointFromUrl(url);
    Map<String, dynamic>? requestBody;

    try {
      // Parse request body for monitoring
      if (body != null) {
        if (body is String) {
          try {
            requestBody = jsonDecode(body);
          } catch (e) {
            requestBody = {'raw_body': body};
          }
        } else if (body is Map) {
          requestBody = Map<String, dynamic>.from(body);
        }
      }

      // Track API call start
      _monitoringService.trackApiCallStart(
        endpoint: endpoint,
        method: 'DELETE',
        requestBody: requestBody,
        queryParams: queryParams,
      );

      // Make the request
      final response = await http.delete(url, headers: headers, body: body);

      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      // Track success or error
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _monitoringService.trackApiCallSuccess(
          endpoint: endpoint,
          method: 'DELETE',
          statusCode: response.statusCode,
          responseTimeMs: responseTime,
          responseBody: _parseResponseBody(response.body),
        );
      } else {
        _monitoringService.trackApiCallError(
          endpoint: endpoint,
          method: 'DELETE',
          statusCode: response.statusCode,
          errorMessage: response.body,
          responseTimeMs: responseTime,
          requestBody: requestBody,
          responseBody: _parseResponseBody(response.body),
          stackTrace: StackTrace.current,
        );
      }

      return response;
    } catch (e, stackTrace) {
      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      if (e is TimeoutException) {
        _monitoringService.trackTimeoutError(
          endpoint: endpoint,
          method: 'DELETE',
          timeout: const Duration(seconds: 30),
          requestBody: requestBody,
        );
      } else {
        _monitoringService.trackNetworkError(
          endpoint: endpoint,
          method: 'DELETE',
          errorMessage: e.toString(),
          responseTimeMs: responseTime,
          requestBody: requestBody,
          stackTrace: stackTrace,
        );
      }

      rethrow;
    }
  }

  /// Helper method to extract endpoint from URL
  String _getEndpointFromUrl(Uri url) {
    return '${url.path}${url.query.isNotEmpty ? '?${url.query}' : ''}';
  }

  /// Helper method to parse response body
  Map<String, dynamic>? _parseResponseBody(String body) {
    if (body.isEmpty) return null;

    try {
      return jsonDecode(body);
    } catch (e) {
      return {'raw_response': body};
    }
  }

  /// Track parsing errors separately
  void trackParsingError(String endpoint, String method, String errorMessage,
      String responseBody) {
    _monitoringService.trackParsingError(
      endpoint: endpoint,
      method: method,
      errorMessage: errorMessage,
      responseBody: responseBody,
      stackTrace: StackTrace.current,
    );
  }

  /// Track validation errors
  void trackValidationError(String endpoint, String method, String fieldName,
      String errorMessage, Map<String, dynamic>? requestBody) {
    _monitoringService.trackValidationError(
      endpoint: endpoint,
      method: method,
      fieldName: fieldName,
      errorMessage: errorMessage,
      requestBody: requestBody,
    );
  }

  /// Track authentication errors
  void trackAuthError(String endpoint, String method, String errorMessage) {
    _monitoringService.trackAuthError(
      endpoint: endpoint,
      method: method,
      errorMessage: errorMessage,
      stackTrace: StackTrace.current,
    );
  }
}
