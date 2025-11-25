import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/services/navigation_service.dart';
import 'package:master_mind/core/error_handling/error_handling.dart';
import 'package:master_mind/utils/platform_utils.dart';

/// Base screen widget that provides common functionality for all screens
abstract class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});
}

/// Base state class for screens with common error handling and loading states
abstract class BaseScreenState<T extends BaseScreen> extends State<T> {
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Initialize the screen - override this in subclasses
  Future<void> _initializeScreen() async {
    try {
      await initializeData();
    } catch (e) {
      if (!_isDisposed) {
        setError(e);
      }
    }
  }

  /// Initialize data for the screen - override this in subclasses
  Future<void> initializeData() async {
    // Override in subclasses
  }

  /// Set loading state
  void setLoading(bool loading) {
    if (!_isDisposed) {
      setState(() {
        _isLoading = loading;
        if (loading) {
          _error = null;
        }
      });
    }
  }

  /// Set error state
  void setError(dynamic error) {
    if (!_isDisposed) {
      setState(() {
        _error = ErrorHandler.getErrorMessage(error);
        _isLoading = false;
      });
      ErrorHandler.logError(error, StackTrace.current,
          context: runtimeType.toString());
    }
  }

  /// Clear error state
  void clearError() {
    if (!_isDisposed) {
      setState(() {
        _error = null;
      });
    }
  }

  /// Execute async operation with loading and error handling
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    String? context,
    bool showErrorSnackBar = false,
  }) async {
    if (_isDisposed) return null;

    try {
      setLoading(true);
      final result = await operation();
      setLoading(false);
      return result;
    } catch (e) {
      setError(e);
      if (showErrorSnackBar && mounted) {
        ErrorHandler.showErrorSnackBar(
            this.context, ErrorHandler.getErrorMessage(e));
      }
      return null;
    }
  }

  /// Execute async operation that returns a boolean
  Future<bool> executeAsyncBool(
    Future<bool> Function() operation, {
    String? context,
    bool showErrorSnackBar = false,
  }) async {
    final result = await executeAsync(
      operation,
      context: context,
      showErrorSnackBar: showErrorSnackBar,
    );
    return result ?? false;
  }

  /// Show error dialog
  Future<bool> showErrorDialog(String title, String message,
      {VoidCallback? onRetry}) async {
    if (PlatformUtils.isIOS) {
      return await showCupertinoDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                  if (onRetry != null)
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  CupertinoDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      if (onRetry != null) {
                        onRetry();
                      }
                    },
                    child: Text(onRetry != null ? 'Retry' : 'OK'),
                  ),
                ],
              );
            },
          ) ??
          false;
    }
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                if (onRetry != null)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    if (onRetry != null) {
                      onRetry();
                    }
                  },
                  child: Text(onRetry != null ? 'Retry' : 'OK'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Show confirmation dialog
  Future<bool> showConfirmationDialog(String title, String message) async {
    if (PlatformUtils.isIOS) {
      return await showCupertinoDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Confirm'),
                  ),
                ],
              );
            },
          ) ??
          false;
    }
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Navigate to a screen with error handling
  Future<T?> navigateToScreen<T>(Widget screen) async {
    try {
      return await NavigationService().navigateToScreen<T>(screen);
    } catch (e) {
      setError(e);
      return null;
    }
  }

  /// Navigate to a screen and replace current screen
  Future<T?> navigateToScreenReplacement<T>(Widget screen) async {
    try {
      return await NavigationService().navigateToScreenReplacement<T>(screen);
    } catch (e) {
      setError(e);
      return null;
    }
  }

  /// Navigate to a screen and clear all previous routes
  Future<T?> navigateToScreenAndClear<T>(Widget screen) async {
    try {
      return await NavigationService().navigateToScreenAndClear<T>(screen);
    } catch (e) {
      setError(e);
      return null;
    }
  }

  /// Go back with error handling
  void goBack<T>([T? result]) {
    try {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop<T>(result);
      }
    } catch (e) {
      setError(e);
    }
  }

  /// Build the main content of the screen - override this in subclasses
  Widget buildContent();

  /// Build the app bar - override this in subclasses if needed
  PreferredSizeWidget? buildAppBar() {
    return null;
  }

  /// Build the drawer - override this in subclasses if needed
  Widget? buildDrawer() {
    return null;
  }

  /// Build the floating action button - override this in subclasses if needed
  Widget? buildFloatingActionButton() {
    return null;
  }

  /// Build the bottom navigation bar - override this in subclasses if needed
  Widget? buildBottomNavigationBar() {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      appBar: buildAppBar(),
      drawer: buildDrawer(),
      floatingActionButton: buildFloatingActionButton(),
      bottomNavigationBar: buildBottomNavigationBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    if (_error != null) {
      return ErrorHandlerWidget(
        error: _error!,
        onRetry: () {
          clearError();
          _initializeScreen();
        },
      );
    }

    return buildContent();
  }
}

/// Base screen with app bar
abstract class BaseScreenWithAppBar extends BaseScreen {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  const BaseScreenWithAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
  });
}

/// Base state for screens with app bar
abstract class BaseScreenWithAppBarState<T extends BaseScreenWithAppBar>
    extends BaseScreenState<T> {
  @override
  PreferredSizeWidget? buildAppBar() {
    if (PlatformUtils.isIOS) {
      return CupertinoNavigationBar(
        middle: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: widget.automaticallyImplyLeading
            ? CupertinoNavigationBarBackButton(
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        trailing: widget.actions != null && widget.actions!.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.actions!,
              )
            : null,
      );
    }
    return AppBar(
      title: Text(widget.title),
      centerTitle: widget.centerTitle,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      actions: widget.actions,
    );
  }
}

/// Base screen with drawer
abstract class BaseScreenWithDrawer extends BaseScreen {
  const BaseScreenWithDrawer({super.key});
}

/// Base state for screens with drawer
abstract class BaseScreenWithDrawerState<T extends BaseScreenWithDrawer>
    extends BaseScreenState<T> {
  @override
  Widget? buildDrawer() {
    // Import and return your drawer widget here
    // return const MyDrawer();
    return null;
  }
}
