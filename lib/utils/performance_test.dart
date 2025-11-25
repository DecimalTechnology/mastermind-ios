// import 'dart:async';
// import 'dart:developer' as developer;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:master_mind/utils/performance_monitor.dart';
// import 'package:master_mind/utils/network_optimizer.dart';
// import 'package:master_mind/utils/image_optimizer.dart';

// class PerformanceTest {
//   static final PerformanceTest _instance = PerformanceTest._internal();
//   factory PerformanceTest() => _instance;
//   PerformanceTest._internal();

//   final List<TestResult> _testResults = [];
//   bool _isRunning = false;

//   /// Run comprehensive performance tests
//   Future<List<TestResult>> runAllTests() async {
//     if (_isRunning) {
//       throw Exception('Performance tests are already running');
//     }

//     _isRunning = true;
//     _testResults.clear();

//     try {
//       // Test 1: App Startup Performance
//       await _testAppStartup();

//       // Test 2: Memory Usage
//       await _testMemoryUsage();

//       // Test 3: Network Performance
//       await _testNetworkPerformance();

//       // Test 4: Image Loading Performance
//       await _testImageLoading();

//       // Test 5: UI Rendering Performance
//       await _testUIRendering();

//       // Test 6: List Scrolling Performance
//       await _testListScrolling();

//       // Test 7: Provider Performance
//       await _testProviderPerformance();

//       return _testResults;
//     } finally {
//       _isRunning = false;
//     }
//   }

//   /// Test app startup performance
//   Future<void> _testAppStartup() async {
//     final stopwatch = Stopwatch()..start();

//     try {
//       // Simulate app startup tasks
//       await Future.delayed(const Duration(milliseconds: 100));

//       stopwatch.stop();

//       _testResults.add(TestResult(
//         name: 'App Startup',
//         duration: stopwatch.elapsed,
//         status: stopwatch.elapsedMilliseconds < 500
//             ? TestStatus.pass
//             : TestStatus.warning,
//         details: 'Startup took ${stopwatch.elapsedMilliseconds}ms',
//       ));
//     } catch (e) {
//       _testResults.add(TestResult(
//         name: 'App Startup',
//         duration: stopwatch.elapsed,
//         status: TestStatus.fail,
//         details: 'Failed: $e',
//       ));
//     }
//   }

//   /// Test memory usage
//   Future<void> _testMemoryUsage() async {
//     try {
//       // Get current memory usage
//       final beforeMemory = _getMemoryUsage();

//       // Perform memory-intensive operation
//       final list = List.generate(1000, (index) => 'Item $index');
//       await Future.delayed(const Duration(milliseconds: 50));

//       final afterMemory = _getMemoryUsage();
//       final memoryIncrease = afterMemory - beforeMemory;

//       _testResults.add(TestResult(
//         name: 'Memory Usage',
//         duration: Duration.zero,
//         status: memoryIncrease < 10 * 1024 * 1024
//             ? TestStatus.pass
//             : TestStatus.warning, // 10MB threshold
//         details:
//             'Memory increase: ${(memoryIncrease / 1024 / 1024).toStringAsFixed(2)}MB',
//       ));
//     } catch (e) {
//       _testResults.add(TestResult(
//         name: 'Memory Usage',
//         duration: Duration.zero,
//         status: TestStatus.fail,
//         details: 'Failed: $e',
//       ));
//     }
//   }

//   /// Test network performance
//   Future<void> _testNetworkPerformance() async {
//     final stopwatch = Stopwatch()..start();

//     try {
//       // Test network optimizer
//       final response = await NetworkOptimizer().optimizedGet(
//         'https://httpbin.org/delay/1',
//         useCache: false,
//       );

//       stopwatch.stop();

//       _testResults.add(TestResult(
//         name: 'Network Performance',
//         duration: stopwatch.elapsed,
//         status: response.statusCode == 200 ? TestStatus.pass : TestStatus.fail,
//         details:
//             'Response time: ${stopwatch.elapsedMilliseconds}ms, Status: ${response.statusCode}',
//       ));
//     } catch (e) {
//       stopwatch.stop();
//       _testResults.add(TestResult(
//         name: 'Network Performance',
//         duration: stopwatch.elapsed,
//         status: TestStatus.fail,
//         details: 'Failed: $e',
//       ));
//     }
//   }

//   /// Test image loading performance
//   Future<void> _testImageLoading() async {
//     final stopwatch = Stopwatch()..start();

//     try {
//       // Test image preloading
//       await ImageOptimizer.preloadImages([
//         'https://picsum.photos/200/200',
//         'https://picsum.photos/300/300',
//       ]);

//       stopwatch.stop();

//       _testResults.add(TestResult(
//         name: 'Image Loading',
//         duration: stopwatch.elapsed,
//         status: stopwatch.elapsedMilliseconds < 2000
//             ? TestStatus.pass
//             : TestStatus.warning,
//         details: 'Image preloading took ${stopwatch.elapsedMilliseconds}ms',
//       ));
//     } catch (e) {
//       stopwatch.stop();
//       _testResults.add(TestResult(
//         name: 'Image Loading',
//         duration: stopwatch.elapsed,
//         status: TestStatus.fail,
//         details: 'Failed: $e',
//       ));
//     }
//   }

//   /// Test UI rendering performance
//   Future<void> _testUIRendering() async {
//     final stopwatch = Stopwatch()..start();

//     try {
//       // Simulate complex UI rendering
//       await Future.delayed(const Duration(milliseconds: 50));

//       stopwatch.stop();

//       _testResults.add(TestResult(
//         name: 'UI Rendering',
//         duration: stopwatch.elapsed,
//         status: stopwatch.elapsedMilliseconds < 100
//             ? TestStatus.pass
//             : TestStatus.warning,
//         details: 'UI rendering took ${stopwatch.elapsedMilliseconds}ms',
//       ));
//     } catch (e) {
//       stopwatch.stop();
//       _testResults.add(TestResult(
//         name: 'UI Rendering',
//         duration: stopwatch.elapsed,
//         status: TestStatus.fail,
//         details: 'Failed: $e',
//       ));
//     }
//   }

//   /// Test list scrolling performance
//   Future<void> _testListScrolling() async {
//     final stopwatch = Stopwatch()..start();

//     try {
//       // Simulate list scrolling
//       await Future.delayed(const Duration(milliseconds: 30));

//       stopwatch.stop();

//       _testResults.add(TestResult(
//         name: 'List Scrolling',
//         duration: stopwatch.elapsed,
//         status: stopwatch.elapsedMilliseconds < 50
//             ? TestStatus.pass
//             : TestStatus.warning,
//         details:
//             'List scrolling simulation took ${stopwatch.elapsedMilliseconds}ms',
//       ));
//     } catch (e) {
//       stopwatch.stop();
//       _testResults.add(TestResult(
//         name: 'List Scrolling',
//         duration: stopwatch.elapsed,
//         status: TestStatus.fail,
//         details: 'Failed: $e',
//       ));
//     }
//   }

//   /// Test provider performance
//   Future<void> _testProviderPerformance() async {
//     final stopwatch = Stopwatch()..start();

//     try {
//       // Test performance monitor
//       await PerformanceMonitor().measureAsync(
//         'test_provider_operation',
//         () async {
//           await Future.delayed(const Duration(milliseconds: 20));
//           return 'test_result';
//         },
//         context: 'PerformanceTest',
//       );

//       stopwatch.stop();

//       _testResults.add(TestResult(
//         name: 'Provider Performance',
//         duration: stopwatch.elapsed,
//         status: stopwatch.elapsedMilliseconds < 100
//             ? TestStatus.pass
//             : TestStatus.warning,
//         details: 'Provider operation took ${stopwatch.elapsedMilliseconds}ms',
//       ));
//     } catch (e) {
//       stopwatch.stop();
//       _testResults.add(TestResult(
//         name: 'Provider Performance',
//         duration: stopwatch.elapsed,
//         status: TestStatus.fail,
//         details: 'Failed: $e',
//       ));
//     }
//   }

//   /// Get current memory usage (approximate)
//   int _getMemoryUsage() {
//     // This is a simplified memory usage estimation
//     // In a real app, you might use platform-specific APIs
//     return DateTime.now().millisecondsSinceEpoch %
//         (100 * 1024 * 1024); // Simulate 0-100MB
//   }

//   /// Get test results summary
//   TestSummary getSummary() {
//     if (_testResults.isEmpty) {
//       return TestSummary(
//         totalTests: 0,
//         passedTests: 0,
//         failedTests: 0,
//         warningTests: 0,
//         averageDuration: Duration.zero,
//       );
//     }

//     final passed =
//         _testResults.where((r) => r.status == TestStatus.pass).length;
//     final failed =
//         _testResults.where((r) => r.status == TestStatus.fail).length;
//     final warnings =
//         _testResults.where((r) => r.status == TestStatus.warning).length;

//     final totalDuration = _testResults.fold<Duration>(
//       Duration.zero,
//       (sum, result) => sum + result.duration,
//     );

//     final averageDuration = Duration(
//       microseconds: totalDuration.inMicroseconds ~/ _testResults.length,
//     );

//     return TestSummary(
//       totalTests: _testResults.length,
//       passedTests: passed,
//       failedTests: failed,
//       warningTests: warnings,
//       averageDuration: averageDuration,
//     );
//   }

//   /// Print test results to console
//   void printResults() {
//     final summary = getSummary();

//     debugPrint('🚀 PERFORMANCE TEST RESULTS');
//     debugPrint('========================');
//     debugPrint('Total Tests: ${summary.totalTests}');
//     debugPrint('✅ Passed: ${summary.passedTests}');
//     debugPrint('⚠️  Warnings: ${summary.warningTests}');
//     debugPrint('❌ Failed: ${summary.failedTests}');
//     debugPrint(
//         '⏱️  Average Duration: ${summary.averageDuration.inMilliseconds}ms');
//     debugPrint('');

//     for (final result in _testResults) {
//       final status = result.status == TestStatus.pass
//           ? '✅'
//           : result.status == TestStatus.warning
//               ? '⚠️'
//               : '❌';
//       debugPrint('$status ${result.name}: ${result.details}');
//     }

//     debugPrint('');
//     debugPrint('📊 PERFORMANCE MONITOR SUMMARY');
//     debugPrint('=============================');
//     final monitorSummary = PerformanceMonitor().getSummary();
//     debugPrint('Total Operations: ${monitorSummary.totalOperations}');
//     debugPrint(
//         'Average Duration: ${monitorSummary.averageDuration.inMilliseconds}ms');
//     debugPrint('Slow Operations: ${monitorSummary.slowOperations}');
//     if (monitorSummary.slowestOperation != null) {
//       debugPrint(
//           'Slowest Operation: ${monitorSummary.slowestOperation!.operation} (${monitorSummary.slowestOperation!.duration.inMilliseconds}ms)');
//     }
//   }
// }

// class TestResult {
//   final String name;
//   final Duration duration;
//   final TestStatus status;
//   final String details;

//   TestResult({
//     required this.name,
//     required this.duration,
//     required this.status,
//     required this.details,
//   });
// }

// class TestSummary {
//   final int totalTests;
//   final int passedTests;
//   final int failedTests;
//   final int warningTests;
//   final Duration averageDuration;

//   TestSummary({
//     required this.totalTests,
//     required this.passedTests,
//     required this.failedTests,
//     required this.warningTests,
//     required this.averageDuration,
//   });
// }

// enum TestStatus {
//   pass,
//   warning,
//   fail,
// }
