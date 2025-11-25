# Crashlytics Integration for API Monitoring

This document explains how Crashlytics has been integrated into the Oxygen Mastermind app for comprehensive API monitoring and error tracking.

## Overview

The app now includes automatic Crashlytics monitoring for all API calls, providing:
- **Performance tracking** (response times, success rates)
- **Error tracking** (network errors, parsing errors, validation errors)
- **User context** (user ID, email, role)
- **Request/response logging** (for debugging)
- **Breadcrumb tracking** (for analytics)

## Architecture

### 1. ApiMonitoringService
Located at: `lib/services/api_monitoring_service.dart`

**Features:**
- Tracks API call start/end times
- Records success and error metrics
- Manages user context
- Provides detailed error categorization

**Key Methods:**
```dart
// Track API call start
trackApiCallStart(endpoint, method, requestBody, queryParams)

// Track successful API calls
trackApiCallSuccess(endpoint, method, statusCode, responseTimeMs, responseBody)

// Track API errors
trackApiCallError(endpoint, method, statusCode, errorMessage, responseTimeMs, requestBody, responseBody, stackTrace)

// Track network errors
trackNetworkError(endpoint, method, errorMessage, responseTimeMs, requestBody, stackTrace)

// Track authentication errors
trackAuthError(endpoint, method, errorMessage, stackTrace)

// Track timeout errors
trackTimeoutError(endpoint, method, timeout, requestBody)

// Track validation errors
trackValidationError(endpoint, method, fieldName, errorMessage, requestBody)

// Track parsing errors
trackParsingError(endpoint, method, errorMessage, responseBody, stackTrace)
```

### 2. HttpService
Located at: `lib/services/http_service.dart`

**Features:**
- Wraps all HTTP methods (GET, POST, PUT, PATCH, DELETE)
- Automatically tracks all API calls
- Provides consistent error handling
- Integrates with ApiMonitoringService

**Usage:**
```dart
final httpService = HttpService();

// GET request with automatic monitoring
final response = await httpService.get(
  Uri.parse('$baseUrl/api/endpoint'),
  headers: {'Authorization': 'Bearer $token'},
);

// POST request with automatic monitoring
final response = await httpService.post(
  Uri.parse('$baseUrl/api/endpoint'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(requestData),
);
```

## Implementation in Repositories

### Example: AuthRepository
```dart
class AuthRepository {
  final HttpService _httpService = HttpService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    const endpoint = '/v1/auth/signin';
    
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        _httpService.trackValidationError(endpoint, 'POST', 'email/password', 'Email and password are required', null);
        throw ValidationException('Email and password are required');
      }

      final url = Uri.parse('$baseurl$endpoint');
      final requestBody = {'email': email, 'password': password};

      final response = await _httpService.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          
          if (data['data'] == null || data['data']['accessToken'] == null) {
            _httpService.trackParsingError(endpoint, 'POST', 'Invalid response format: access token not found', response.body);
            throw ValidationException('Invalid response format: access token not found');
          }

          // Set user context for Crashlytics
          _httpService.monitoringService.setUserContext(
            userEmail: email,
            userRole: data['data']['role'] ?? 'user',
          );
          
          return data;
        } catch (e) {
          _httpService.trackParsingError(endpoint, 'POST', 'Invalid response format from server', response.body);
          throw ValidationException('Invalid response format from server');
        }
      } else {
        throw AppException('Login failed');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AppException('Login failed: ${e.toString()}');
    }
  }
}
```

## Error Categories Tracked

### 1. API Errors (HTTP Status Codes)
- **4xx Errors**: Client errors (validation, authentication, etc.)
- **5xx Errors**: Server errors
- **Custom Error Messages**: Parsed from response body

### 2. Network Errors
- **Connection Timeout**: Request takes too long
- **No Internet**: Network connectivity issues
- **DNS Resolution**: Domain name resolution failures
- **SSL/TLS Errors**: Certificate or protocol issues

### 3. Authentication Errors
- **Missing Token**: No authentication token found
- **Invalid Token**: Token is expired or malformed
- **Token Storage Errors**: Issues with secure storage

### 4. Validation Errors
- **Required Fields**: Missing required input fields
- **Format Validation**: Invalid email, phone, etc.
- **Business Logic**: Custom validation rules

### 5. Parsing Errors
- **JSON Parsing**: Invalid JSON response
- **Model Parsing**: Failed to parse response into model
- **Type Conversion**: Wrong data types in response

### 6. Timeout Errors
- **Request Timeout**: API call takes longer than expected
- **Connection Timeout**: Network connection issues

## Crashlytics Dashboard Information

### Custom Keys Available
- `api_endpoint`: The API endpoint being called
- `api_method`: HTTP method (GET, POST, etc.)
- `api_status_code`: HTTP status code
- `api_response_time_ms`: Response time in milliseconds
- `api_response_size_bytes`: Size of response in bytes
- `api_error_status_code`: Error status code
- `api_error_message`: Error message
- `network_error_message`: Network error details
- `auth_error_message`: Authentication error details
- `validation_field`: Field that failed validation
- `validation_message`: Validation error message
- `parsing_error_message`: Parsing error details
- `timeout_duration_seconds`: Timeout duration
- `user_email`: User's email address
- `user_role`: User's role in the system

### Breadcrumbs Available
- API Request: `API Request: METHOD /endpoint`
- API Success: `API Success: METHOD /endpoint (statusCode ms)`
- API Error: `API Error: METHOD /endpoint (statusCode)`
- Network Error: `Network Error: METHOD /endpoint`
- Auth Error: `Auth Error: METHOD /endpoint`
- Timeout Error: `Timeout Error: METHOD /endpoint (duration)`
- Validation Error: `Validation Error: METHOD /endpoint`
- Parsing Error: `Parsing Error: METHOD /endpoint`

## Best Practices

### 1. Always Use HttpService
Replace direct `http` package usage with `HttpService`:
```dart
// ❌ Don't do this
final response = await http.get(url, headers: headers);

// ✅ Do this
final response = await _httpService.get(url, headers: headers);
```

### 2. Track Specific Errors
Use appropriate tracking methods for different error types:
```dart
// For validation errors
_httpService.trackValidationError(endpoint, method, fieldName, errorMessage, requestBody);

// For parsing errors
_httpService.trackParsingError(endpoint, method, errorMessage, responseBody);

// For auth errors
_httpService.trackAuthError(endpoint, method, errorMessage);
```

### 3. Set User Context
Set user context after successful authentication:
```dart
_httpService.monitoringService.setUserContext(
  userEmail: email,
  userRole: role,
);
```

### 4. Clear User Context
Clear user context on logout:
```dart
_httpService.monitoringService.clearUserContext();
```

### 5. Handle Sensitive Data
Avoid logging sensitive information:
```dart
// ❌ Don't log passwords
_httpService.trackApiCallStart(endpoint: '/login', requestBody: {'password': 'secret'});

// ✅ Do this
_httpService.trackApiCallStart(endpoint: '/login', requestBody: {'email': 'user@example.com'});
```

## Monitoring and Alerts

### Firebase Console Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Crashlytics**
4. Set up alerts for:
   - High error rates
   - Slow response times
   - Authentication failures
   - Network connectivity issues

### Key Metrics to Monitor
- **API Success Rate**: Should be > 95%
- **Average Response Time**: Should be < 2000ms
- **Error Rate by Endpoint**: Identify problematic APIs
- **User Impact**: Number of users affected by errors
- **Geographic Distribution**: Error patterns by location

## Troubleshooting

### Common Issues

1. **No Crashlytics Data**
   - Check if Firebase is properly initialized
   - Verify Crashlytics is enabled
   - Check network connectivity

2. **Missing User Context**
   - Ensure `setUserContext()` is called after login
   - Verify user data is available

3. **High Error Rates**
   - Check API endpoint health
   - Review error messages in Crashlytics
   - Monitor server logs

4. **Slow Response Times**
   - Check network connectivity
   - Review API performance
   - Consider caching strategies

### Debug Mode
Enable debug logging by adding to your code:
```dart
FirebaseCrashlytics.instance.log('Debug: API call to $endpoint');
```

## Migration Guide

### For Existing Repositories
1. Import `HttpService`:
   ```dart
   import 'package:master_mind/services/http_service.dart';
   ```

2. Add HttpService instance:
   ```dart
   final HttpService _httpService = HttpService();
   ```

3. Replace `http` calls with `_httpService` calls:
   ```dart
   // Before
   final response = await http.get(url, headers: headers);
   
   // After
   final response = await _httpService.get(url, headers: headers);
   ```

4. Add error tracking where appropriate:
   ```dart
   try {
     // API call
   } catch (e) {
     _httpService.trackParsingError(endpoint, method, e.toString(), responseBody);
     rethrow;
   }
   ```

This integration provides comprehensive monitoring and debugging capabilities for all API interactions in the Oxygen Mastermind app.
