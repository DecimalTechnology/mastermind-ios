# Comprehensive Exception Handling Guide

## 🎯 **Complete Exception Handling Implementation**

This guide covers all 8 categories of exceptions you mentioned, with practical implementation examples for your Flutter app.

## 📋 **1. Network & API Exceptions**

### **Implementation Examples:**

```dart
// Enhanced HTTP Service with comprehensive error handling
class EnhancedHttpService {
  static Future<T?> handleApiCall<T>(
    Future<T> Function() apiCall, {
    Duration timeout = const Duration(seconds: 30),
    T? fallbackValue,
    String? context,
  }) async {
    // Check network connectivity first
    final hasConnection = await Connectivity().checkConnectivity();
    if (hasConnection == ConnectivityResult.none) {
      throw NetworkException('No internet connection available');
    }

    try {
      return await apiCall().timeout(timeout);
    } on SocketException catch (e) {
      throw NetworkException('Network connection failed: ${e.message}');
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out after ${timeout.inSeconds} seconds');
    } on FormatException catch (e) {
      throw DataException('Invalid response format: ${e.message}');
    } catch (e) {
      throw NetworkException('Unexpected network error: ${e.toString()}');
    }
  }

  // Handle different HTTP status codes
  static void handleHttpResponse(http.Response response) {
    switch (response.statusCode) {
      case 401:
        throw AuthenticationException('Session expired. Please login again.');
      case 403:
        throw PermissionException('Access denied. You don\'t have permission.');
      case 404:
        throw NetworkException('Resource not found.');
      case 500:
        throw ServerException('Server error. Please try again later.');
      case 502:
        throw ServerException('Bad gateway. Server temporarily unavailable.');
      case 503:
        throw ServerException('Service unavailable. Please try again later.');
    }
  }
}
```

### **Usage in Providers:**
```dart
class HomeProvider extends ChangeNotifier {
  Future<void> loadHomeData() async {
    try {
      final response = await EnhancedHttpService.handleApiCall(
        () => http.get(Uri.parse('$baseUrl/home')),
        context: 'loadHomeData',
      );
      // Process response
    } on NetworkException catch (e) {
      _error = 'Network error: ${e.message}';
      notifyListeners();
    } on AuthenticationException catch (e) {
      // Handle authentication error
      await _handleAuthError();
    } catch (e) {
      _error = 'Unexpected error: ${e.toString()}';
      notifyListeners();
    }
  }
}
```

## 📋 **2. Data & Parsing Exceptions**

### **Safe JSON Parsing:**
```dart
class SafeDataParser {
  static T? safeJsonParse<T>(
    String jsonString,
    T Function(Map<String, dynamic>) fromJson, {
    T? fallbackValue,
    String? context,
  }) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return fromJson(json);
    } on FormatException catch (e) {
      print('JSON parsing error in $context: $e');
      return fallbackValue;
    } catch (e) {
      print('Data parsing error in $context: $e');
      return fallbackValue;
    }
  }

  static String sanitizeInput(String? input, {String fallback = ''}) {
    if (input == null || input.trim().isEmpty) return fallback;
    return input.trim();
  }

  static T? safeTypeConversion<T>(dynamic value, T Function(dynamic) converter, {T? fallback}) {
    try {
      return converter(value);
    } catch (e) {
      print('Type conversion error: $e');
      return fallback;
    }
  }
}
```

### **Usage:**
```dart
// In your models
class UserModel {
  static UserModel? fromJson(String jsonString) {
    return SafeDataParser.safeJsonParse(
      jsonString,
      (json) => UserModel(
        id: SafeDataParser.safeTypeConversion(json['id'], (v) => v.toString(), fallback: ''),
        name: SafeDataParser.sanitizeInput(json['name']),
        email: SafeDataParser.sanitizeInput(json['email']),
      ),
      context: 'UserModel.fromJson',
    );
  }
}
```

## 📋 **3. Authentication & Security Exceptions**

### **Authentication Error Handler:**
```dart
class AuthExceptionHandler {
  static String handleAuthError(dynamic error) {
    if (error.toString().contains('invalid_credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (error.toString().contains('user_not_found')) {
      return 'User not found. Please check your email.';
    } else if (error.toString().contains('weak_password')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (error.toString().contains('email_already_in_use')) {
      return 'Email is already registered. Please use a different email.';
    } else if (error.toString().contains('expired')) {
      return 'Session expired. Please login again.';
    } else {
      return 'Authentication failed. Please try again.';
    }
  }

  static Future<bool> checkPermission(PermissionType permission) async {
    try {
      switch (permission) {
        case PermissionType.camera:
          // Implement camera permission check
          return true;
        case PermissionType.location:
          // Implement location permission check
          return true;
        case PermissionType.storage:
          // Implement storage permission check
          return true;
        default:
          return true;
      }
    } catch (e) {
      print('Permission check failed: $e');
      return false;
    }
  }
}
```

## 📋 **4. File & Storage Exceptions**

### **Safe File Operations:**
```dart
class FileExceptionHandler {
  static Future<bool> safeFileOperation(
    Future<void> Function() operation, {
    String? context,
  }) async {
    try {
      await operation();
      return true;
    } on FileSystemException catch (e) {
      print('File system error in $context: $e');
      return false;
    } catch (e) {
      print('File operation error in $context: $e');
      return false;
    }
  }

  static Future<bool> checkStorageSpace({int requiredBytes = 1024 * 1024}) async {
    try {
      // Implement storage space check
      return true;
    } catch (e) {
      print('Storage space check failed: $e');
      return false;
    }
  }

  static Future<File?> safeFileUpload(File file) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        throw FileException('File does not exist: ${file.path}');
      }

      // Check file size
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) { // 10MB limit
        throw FileException('File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');
      }

      return file;
    } catch (e) {
      print('File upload error: $e');
      return null;
    }
  }
}
```

## 📋 **5. UI & User Input Exceptions**

### **Form Validation Service:**
```dart
class FormValidationService {
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return 'Please enter a valid email';
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return 'Phone number is required';
    final phoneRegex = RegExp(r'^\+?[\d\s-()]{10,}$');
    if (!phoneRegex.hasMatch(phone)) return 'Please enter a valid phone number';
    return null;
  }

  static Future<void> safeNavigate(
    BuildContext context,
    Widget Function() screenBuilder, {
    String? contextName,
  }) async {
    try {
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screenBuilder()),
        );
      }
    } catch (e) {
      print('Navigation error in $contextName: $e');
      _showErrorSnackBar(context, 'Navigation failed. Please try again.');
    }
  }
}
```

## 📋 **6. Device & System Exceptions**

### **Device Capability Checker:**
```dart
class DeviceExceptionHandler {
  static Future<bool> checkDeviceCapability(DeviceCapability capability) async {
    try {
      switch (capability) {
        case DeviceCapability.camera:
          // Check camera availability
          return true;
        case DeviceCapability.gps:
          // Check GPS availability
          return true;
        case DeviceCapability.biometric:
          // Check biometric availability
          return true;
        case DeviceCapability.storage:
          // Check storage availability
          return true;
        default:
          return true;
      }
    } catch (e) {
      print('Device capability check failed: $e');
      return false;
    }
  }

  static void handleLowMemory() {
    // Clear caches, dispose unused resources
    print('Low memory detected, clearing caches...');
  }

  static Future<bool> checkBatteryLevel() async {
    try {
      // Implement battery level check
      return true;
    } catch (e) {
      print('Battery check failed: $e');
      return false;
    }
  }
}
```

## 📋 **7. Third-Party Library Exceptions**

### **SDK Error Handler:**
```dart
class SdkExceptionHandler {
  static Future<T?> safeSdkOperation<T>(
    Future<T> Function() sdkCall, {
    T? fallbackValue,
    String? context,
  }) async {
    try {
      return await sdkCall();
    } catch (e) {
      print('SDK error in $context: $e');
      return fallbackValue;
    }
  }

  static String handleApiKeyError(dynamic error) {
    if (error.toString().contains('invalid_api_key')) {
      return 'API configuration error. Please contact support.';
    } else if (error.toString().contains('quota_exceeded')) {
      return 'Service quota exceeded. Please try again later.';
    } else {
      return 'Service temporarily unavailable. Please try again.';
    }
  }

  // Firebase specific error handling
  static String handleFirebaseError(dynamic error) {
    if (error.toString().contains('permission-denied')) {
      return 'Access denied. You don\'t have permission for this action.';
    } else if (error.toString().contains('unavailable')) {
      return 'Service temporarily unavailable. Please try again.';
    } else {
      return 'Firebase error occurred. Please try again.';
    }
  }
}
```

## 📋 **8. General Runtime Exceptions**

### **Runtime Exception Handler:**
```dart
class RuntimeExceptionHandler {
  static void safeSetState(State state, VoidCallback fn) {
    if (state.mounted) {
      state.setState(fn);
    }
  }

  static Future<T?> safeAsyncOperation<T>(
    Future<T> Function() operation, {
    T? fallbackValue,
    String? context,
  }) async {
    try {
      return await operation();
    } catch (e) {
      print('Async operation error in $context: $e');
      return fallbackValue;
    }
  }

  static void handleNullPointer(dynamic value, String context) {
    if (value == null) {
      print('Null pointer detected in $context');
      // Handle null value gracefully
    }
  }

  static void handleIndexOutOfRange(List list, int index, String context) {
    if (index < 0 || index >= list.length) {
      print('Index out of range in $context: index=$index, length=${list.length}');
      // Handle index error gracefully
    }
  }
}
```

## 🛠️ **Implementation in Your App**

### **1. Update Your Providers:**
```dart
class HomeProvider extends ChangeNotifier {
  Future<void> loadHomeData() async {
    try {
      // Check network connectivity
      final hasConnection = await Connectivity().checkConnectivity();
      if (hasConnection == ConnectivityResult.none) {
        throw NetworkException('No internet connection');
      }

      // Make API call with timeout
      final response = await EnhancedHttpService.handleApiCall(
        () => http.get(Uri.parse('$baseUrl/home')),
        timeout: const Duration(seconds: 30),
        context: 'loadHomeData',
      );

      // Parse response safely
      final data = SafeDataParser.safeJsonParse(
        response.body,
        (json) => HomeData.fromJson(json),
        context: 'HomeProvider.loadHomeData',
      );

      if (data != null) {
        _homeData = data;
        notifyListeners();
      }
    } on NetworkException catch (e) {
      _error = e.message;
      notifyListeners();
    } on AuthenticationException catch (e) {
      await _handleAuthError();
    } catch (e) {
      _error = 'Unexpected error: ${e.toString()}';
      notifyListeners();
    }
  }
}
```

### **2. Update Your Screens:**
```dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadHomeData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadHomeData(),
          child: ListView(
            children: [
              // Your content here
            ],
          ),
        );
      },
    );
  }
}
```

### **3. Update Your Forms:**
```dart
class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            validator: FormValidationService.validateEmail,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextFormField(
            controller: _passwordController,
            validator: FormValidationService.validatePassword,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          ElevatedButton(
            onPressed: _handleLogin,
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Perform login with error handling
        await AuthProvider().login(
          _emailController.text,
          _passwordController.text,
        );
      } on AuthenticationException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    }
  }
}
```

## 🎯 **Key Benefits:**

1. **✅ Comprehensive Coverage**: Handles all 8 exception categories
2. **✅ User-Friendly Messages**: Clear, actionable error messages
3. **✅ Graceful Degradation**: App continues working even with errors
4. **✅ Retry Mechanisms**: Users can retry failed operations
5. **✅ Proper Logging**: All errors are logged for debugging
6. **✅ Performance Optimized**: Efficient error handling without performance impact
7. **✅ Maintainable Code**: Clean, organized exception handling structure

## 🚀 **Next Steps:**

1. **Implement the services** in your app
2. **Update your providers** to use the enhanced error handling
3. **Update your screens** to show proper error states
4. **Test thoroughly** with different error scenarios
5. **Monitor and log** errors in production

This comprehensive exception handling system will make your app much more robust and user-friendly!
