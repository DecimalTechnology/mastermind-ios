/// Utility class to help with bulk updates of screen files
/// This provides common patterns for updating screens to be iOS-compatible
class BulkScreenUpdater {
  /// Common import statements to add
  static const String commonImports = '''
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/platform_button.dart';
import 'package:master_mind/utils/platform_text_field.dart';
''';

  /// Pattern replacements for common widgets
  static Map<String, String> get replacements => {
        // Scaffold replacement
        'return Scaffold(':
            'return PlatformWidget.scaffold(\n      context: context,',

        // Button replacements
        'ElevatedButton(': 'PlatformButton(',
        'TextButton(': 'PlatformTextButton(',

        // TextField replacements (basic)
        'TextField(': 'PlatformTextField(',

        // Navigation replacements
        'MaterialPageRoute(builder: (context) =>':
            'PlatformUtils.isIOS ? CupertinoPageRoute(builder: (context) => : MaterialPageRoute(builder: (context) =>',

        // Dialog replacements
        'showDialog(': 'PlatformWidget.showPlatformDialog(',

        // Loading indicator
        'CircularProgressIndicator()': 'PlatformWidget.loadingIndicator()',
      };
}
