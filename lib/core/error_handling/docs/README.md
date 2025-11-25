# Error Handling System - Clean Architecture

## 📁 **Folder Structure**

```
lib/core/error_handling/
├── exceptions/
│   ├── app_exceptions.dart          # Comprehensive exception handler
│   └── custom_exceptions.dart       # Custom exception classes
├── handlers/
│   ├── error_handler.dart           # Centralized error handling utility
│   └── global_error_handler.dart    # Global error handler for the app
├── services/
│   └── enhanced_http_service.dart   # Enhanced HTTP service with error handling
├── widgets/
│   └── error_handler_widget.dart    # Error display widgets
└── docs/
    └── README.md                    # This file
```

## 🎯 **Overview**

This clean folder structure organizes the comprehensive exception handling system into logical components:

### **📂 exceptions/**
- **`app_exceptions.dart`** - Main comprehensive exception handler with all 8 categories
- **`custom_exceptions.dart`** - Custom exception classes extending `AppException`

### **📂 handlers/**
- **`error_handler.dart`** - Centralized error handling utilities and message conversion
- **`global_error_handler.dart`** - Global error handling for unhandled exceptions

### **📂 services/**
- **`enhanced_http_service.dart`** - HTTP service with integrated error handling and Crashlytics

### **📂 widgets/**
- **`error_handler_widget.dart`** - Reusable widgets for error states, loading, and empty states

## 🚀 **Usage Examples**

### **1. Using Comprehensive Exception Handler**
```dart
import 'package:your_app/core/error_handling/exceptions/app_exceptions.dart';

// Check network connectivity
final hasConnection = await ComprehensiveExceptionHandler.checkNetworkConnectivity();

// Safe JSON parsing
final data = ComprehensiveExceptionHandler.safeJsonParse(
  jsonString,
  (json) => YourModel.fromJson(json),
  context: 'loadUserData',
);

// Handle API timeouts
final result = await ComprehensiveExceptionHandler.handleApiTimeout(
  () => apiCall(),
  timeout: Duration(seconds: 30),
  context: 'fetchData',
);
```

### **2. Using Custom Exceptions**
```dart
import 'package:your_app/core/error_handling/exceptions/custom_exceptions.dart';

try {
  // Your code
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on AuthenticationException catch (e) {
  print('Auth error: ${e.message}');
}
```

### **3. Using Error Handler**
```dart
import 'package:your_app/core/error_handling/handlers/error_handler.dart';

// Convert any error to user-friendly message
final message = ErrorHandler.getErrorMessage(error);

// Show error snackbar
ErrorHandler.showErrorSnackBar(context, message);

// Handle HTTP response
ErrorHandler.handleHttpResponse(response);
```

### **4. Using Global Error Handler**
```dart
import 'package:your_app/core/error_handling/handlers/global_error_handler.dart';

// Initialize in main.dart
void main() {
  GlobalErrorHandler.initialize();
  runApp(MyApp());
}

// Wrap app execution
GlobalErrorHandler.runAppWithErrorHandling(() {
  runApp(MyApp());
});
```

### **5. Using Enhanced HTTP Service**
```dart
import 'package:your_app/core/error_handling/services/enhanced_http_service.dart';

final httpService = EnhancedHttpService();

try {
  final response = await httpService.get(
    'https://api.example.com/data',
    context: 'fetchUserData',
  );
  
  final data = httpService.parseJsonResponse(
    response!,
    (json) => UserModel.fromJson(json),
    context: 'parseUserData',
  );
} on NetworkException catch (e) {
  // Handle network errors
}
```

### **6. Using Error Widgets**
```dart
import 'package:your_app/core/error_handling/widgets/error_handler_widget.dart';

// Error state
ErrorHandlerWidget(
  error: 'Something went wrong',
  onRetry: () => retry(),
)

// Loading state
LoadingWidget(
  message: 'Loading data...',
  color: Colors.red,
)

// Empty state
EmptyStateWidget(
  message: 'No data available',
  onAction: () => refresh(),
  actionText: 'Refresh',
)
```

## 🔧 **Integration with Existing Code**

### **Update Provider Imports**
```dart
// Old import
import '../utils/error_handler.dart';

// New import
import '../core/error_handling/handlers/error_handler.dart';
```

### **Update Screen Imports**
```dart
// Old import
import '../widgets/error_handler_widget.dart';

// New import
import '../core/error_handling/widgets/error_handler_widget.dart';
```

### **Update Service Imports**
```dart
// Old import
import '../services/enhanced_http_service.dart';

// New import
import '../core/error_handling/services/enhanced_http_service.dart';
```

## 📊 **Benefits of Clean Structure**

1. **🔍 Easy Navigation** - Clear separation of concerns
2. **🛠️ Maintainability** - Each component has a single responsibility
3. **📦 Reusability** - Components can be easily imported and used
4. **🧪 Testability** - Each component can be tested independently
5. **📈 Scalability** - Easy to add new error handling features
6. **🎯 Focus** - Developers know exactly where to find specific functionality

## 🔄 **Migration Guide**

1. **Update imports** in all files to use the new paths
2. **Test functionality** to ensure everything works correctly
3. **Remove old files** from `lib/utils/` and `lib/services/` (after confirming new structure works)
4. **Update documentation** to reflect the new structure

## ✅ **Verification Checklist**

- [ ] All imports updated to new paths
- [ ] All exception handling functionality working
- [ ] Crashlytics integration working
- [ ] Error widgets displaying correctly
- [ ] HTTP service handling errors properly
- [ ] Global error handler catching unhandled errors
- [ ] No linter errors in the new structure

## 🎉 **Result**

Your app now has a **clean, organized, and maintainable** error handling system that's easy to navigate, extend, and maintain! 🚀
