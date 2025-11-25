# State Management & Error Handling System

This document outlines the comprehensive state management and error handling system implemented for the Oxygen Mastermind Flutter application.

## 🏗️ Architecture Overview

The system consists of several key components:

1. **Base Provider Class** - Common state management functionality
2. **Custom Exception Classes** - Type-safe error handling
3. **Error Handler Utility** - Centralized error processing
4. **Global Error Handler** - App-wide error catching
5. **Reusable Widgets** - Consistent UI for different states

## 📁 File Structure

```
lib/
├── utils/
│   ├── exceptions.dart           # Custom exception classes
│   ├── error_handler.dart        # Error handling utilities
│   ├── global_error_handler.dart # Global error handling
│   └── README.md                 # This documentation
├── providers/
│   ├── base_provider.dart        # Base provider class
│   ├── connection_Provider.dart  # Refactored connection provider
│   └── ...                       # Other providers
└── widgets/
    └── error_handler_widget.dart # Reusable error/loading widgets
```

## 🔧 Components

### 1. Base Provider Class (`base_provider.dart`)

The `BaseProvider` class provides common state management functionality that all providers can extend.

**Features:**
- Loading state management
- Error handling with context
- Success message handling
- Async operation execution with error handling
- Automatic error logging

**Usage:**
```dart
class MyProvider extends BaseProvider {
  Future<void> loadData() async {
    await executeAsync(
      () async {
        // Your async operation here
        return await repository.getData();
      },
      context: 'loadData',
    );
  }
}
```

### 2. Custom Exception Classes (`exceptions.dart`)

Type-safe exception classes for different error scenarios:

- `AppException` - Base exception class
- `NetworkException` - Network-related errors
- `AuthenticationException` - Auth-related errors
- `ValidationException` - Input validation errors
- `ServerException` - Server-side errors
- `CacheException` - Local storage errors
- `PermissionException` - Access control errors
- `TimeoutException` - Request timeout errors

### 3. Error Handler Utility (`error_handler.dart`)

Centralized error handling with user-friendly messages.

**Features:**
- Convert any error to user-friendly message
- HTTP response error parsing
- Network error handling
- Error logging
- Snackbar utilities for error/success messages

**Usage:**
```dart
// Convert error to user message
String message = ErrorHandler.getErrorMessage(error);

// Show error snackbar
ErrorHandler.showErrorSnackBar(context, message);

// Handle HTTP response
ErrorHandler.handleHttpResponse(response);
```

### 4. Global Error Handler (`global_error_handler.dart`)

App-wide error catching and handling.

**Features:**
- Flutter framework error handling
- Platform error handling
- Unhandled async error catching
- Error boundary widget
- Critical error handling

**Usage:**
```dart
// Initialize in main()
GlobalErrorHandler.initialize();

// Wrap widgets with error boundary
ErrorBoundary(
  child: YourWidget(),
)
```

### 5. Reusable Widgets (`error_handler_widget.dart`)

Consistent UI components for different states:

- `ErrorHandlerWidget` - Error display with retry
- `LoadingWidget` - Loading indicator with message
- `EmptyStateWidget` - Empty state display
- `StateAwareWidget` - Combined state handling

**Usage:**
```dart
StateAwareWidget<List<Data>>(
  isLoading: provider.isLoading,
  error: provider.error,
  data: provider.data,
  isEmpty: provider.data?.isEmpty ?? true,
  onData: (data) => ListView.builder(...),
  onRetry: () => provider.loadData(),
)
```

## 🚀 Implementation Guide

### Step 1: Update Existing Providers

Refactor existing providers to extend `BaseProvider`:

```dart
// Before
class MyProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  Future<void> loadData() async {
    _isLoading = true;
    try {
      // operation
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
    }
  }
}

// After
class MyProvider extends BaseProvider {
  Future<void> loadData() async {
    await executeAsync(
      () async {
        // operation
      },
      context: 'loadData',
    );
  }
}
```

### Step 2: Update Repository Error Handling

Use the error handler in repositories:

```dart
Future<Data> getData() async {
  try {
    final response = await http.get(url);
    ErrorHandler.handleHttpResponse(response);
    return Data.fromJson(jsonDecode(response.body));
  } catch (e) {
    ErrorHandler.handleNetworkError(e);
    rethrow;
  }
}
```

### Step 3: Update UI Components

Use the state-aware widgets:

```dart
Consumer<MyProvider>(
  builder: (context, provider, _) {
    return StateAwareWidget<List<Data>>(
      isLoading: provider.isLoading,
      error: provider.error,
      data: provider.data,
      isEmpty: provider.data?.isEmpty ?? true,
      onData: (data) => ListView.builder(...),
      onRetry: () => provider.loadData(),
      loadingMessage: 'Loading data...',
      emptyTitle: 'No data available',
      emptySubtitle: 'Try refreshing to load new data',
    );
  },
)
```

## 📋 Best Practices

### 1. Error Handling
- Always use `executeAsync` or `executeAsyncBool` for async operations
- Provide context for better error tracking
- Use custom exceptions for specific error types
- Log errors with appropriate context

### 2. State Management
- Extend `BaseProvider` for all providers
- Use `StateAwareWidget` for consistent UI states
- Clear messages when leaving screens
- Handle loading states properly

### 3. User Experience
- Show user-friendly error messages
- Provide retry functionality
- Use appropriate loading indicators
- Handle empty states gracefully

### 4. Code Organization
- Keep providers focused on single responsibility
- Use consistent naming conventions
- Document complex error handling logic
- Test error scenarios

## 🔍 Error Tracking

The system includes comprehensive error tracking:

1. **Console Logging** - All errors are logged to console with context
2. **Error Context** - Each error includes operation context
3. **Stack Traces** - Full stack traces for debugging
4. **User Messages** - User-friendly error messages
5. **Retry Mechanisms** - Automatic retry capabilities

## 🛠️ Configuration

### Production Setup

For production, configure logging services:

```dart
// In global_error_handler.dart
static void _sendToLoggingService(dynamic error, StackTrace? stack, String? context) {
  // Firebase Crashlytics
  FirebaseCrashlytics.instance.recordError(error, stack, reason: context);
  
  // Or Sentry
  Sentry.captureException(error, stackTrace: stack);
}
```

### Custom Error Messages

Customize error messages in `error_handler.dart`:

```dart
static const String _customErrorMessage = 'Your custom message';
```

## 📱 Example Implementation

See `lib/screens/connection/my_connections.dart` for a complete example of the new state management system in action.

## 🔄 Migration Checklist

- [ ] Update all providers to extend `BaseProvider`
- [ ] Replace manual error handling with `executeAsync`
- [ ] Update UI components to use `StateAwareWidget`
- [ ] Add error boundaries to critical screens
- [ ] Test error scenarios
- [ ] Configure production logging
- [ ] Update documentation

This system provides a robust, scalable foundation for state management and error handling throughout the application. 