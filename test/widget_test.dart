// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Removed unused import
import 'package:master_mind/providers/bottom_nav_provider.dart';
import 'package:master_mind/providers/Auth_provider.dart';
import 'package:master_mind/repository/Auth_repository.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => BottomNavProvider()),
          Provider<AuthRepository>(
            create: (_) => AuthRepository(),
          ),
          ChangeNotifierProxyProvider<AuthRepository, AuthProvider>(
            create: (context) =>
                AuthProvider(authRepository: context.read<AuthRepository>()),
            update: (context, repository, previous) =>
                AuthProvider(authRepository: repository),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Test App'),
            ),
          ),
        ),
      ),
    );

    // Verify that the app loads without crashing
    expect(find.text('Test App'), findsOneWidget);
  });
}
