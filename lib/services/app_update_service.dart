// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:convert';

// class AppUpdateService {
//   // Replace with your actual API endpoint that returns app version info
//   static const String _updateCheckUrl =
//       'https://your-api-endpoint.com/app-version';

//   // Play Store URLs (replace with your actual app URLs)
//   static const String _androidPlayStoreUrl =
//       'https://play.google.com/store/apps/details?id=com.example.master_mind';
//   static const String _iosAppStoreUrl =
//       'https://apps.apple.com/app/your-app-id';

//   // Check for app updates
//   static Future<UpdateInfo?> checkForUpdates() async {
//     try {
//       // Get current app version
//       PackageInfo packageInfo = await PackageInfo.fromPlatform();
//       String currentVersion = packageInfo.version;
//       int currentBuildNumber = int.parse(packageInfo.buildNumber);

//       // Get latest version from your server
//       final response = await http.get(Uri.parse(_updateCheckUrl));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final latestVersion = data['version'];
//         final latestBuildNumber = data['buildNumber'];
//         final isForceUpdate = data['forceUpdate'] ?? false;
//         final updateMessage = data['message'] ??
//             'A new version is available with bug fixes and improvements';
//         final whatsNew =
//             data['whatsNew'] ?? 'Bug fixes and performance improvements';

//         // Compare versions
//         if (latestBuildNumber > currentBuildNumber) {
//           return UpdateInfo(
//             currentVersion: currentVersion,
//             latestVersion: latestVersion,
//             isForceUpdate: isForceUpdate,
//             updateMessage: updateMessage,
//             whatsNew: whatsNew,
//           );
//         }
//       }
//     } catch (e) {
//       debugPrint('Error checking for updates: $e');
//     }

//     return null;
//   }

//   // Show update dialog
//   static Future<void> showUpdateDialog(
//       BuildContext context, UpdateInfo updateInfo) async {
//     return showDialog(
//       context: context,
//       barrierDismissible: !updateInfo.isForceUpdate,
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async => !updateInfo.isForceUpdate,
//           child: AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     Icons.system_update,
//                     color: Colors.blue,
//                     size: 24,
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     'Update Available',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'A new version of Oxygen Mastermind is available!',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 SizedBox(height: 16),

//                 // Version comparison
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey[200]!),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Current Version:',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           Text(
//                             updateInfo.currentVersion,
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Latest Version:',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: Colors.green,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               updateInfo.latestVersion,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: 16),

//                 // Update message
//                 Text(
//                   updateInfo.updateMessage,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[700],
//                   ),
//                 ),

//                 SizedBox(height: 12),

//                 // What's new section
//                 Container(
//                   padding: EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.blue.withOpacity(0.2)),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.new_releases,
//                             color: Colors.blue,
//                             size: 16,
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             'What\'s New:',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.blue[700],
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         updateInfo.whatsNew,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.blue[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Force update warning
//                 if (updateInfo.isForceUpdate) ...[
//                   SizedBox(height: 16),
//                   Container(
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.orange.withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.warning,
//                           color: Colors.orange,
//                           size: 20,
//                         ),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             'This is a required update to continue using the app.',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.orange[800],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//             actions: [
//               if (!updateInfo.isForceUpdate)
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text(
//                     'Later',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ElevatedButton(
//                 onPressed: () async {
//                   Navigator.of(context).pop();
//                   await _openStore();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.store, size: 18),
//                     SizedBox(width: 8),
//                     Text(
//                       'Update Now',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Open the appropriate store
//   static Future<void> _openStore() async {
//     try {
//       String storeUrl;

//       if (Platform.isAndroid) {
//         storeUrl = _androidPlayStoreUrl;
//       } else if (Platform.isIOS) {
//         storeUrl = _iosAppStoreUrl;
//       } else {
//         // For web or other platforms
//         storeUrl = _androidPlayStoreUrl;
//       }

//       final Uri url = Uri.parse(storeUrl);

//       if (await canLaunchUrl(url)) {
//         await launchUrl(
//           url,
//           mode: LaunchMode.externalApplication,
//         );
//       } else {
//         debugPrint('Could not launch store URL: $storeUrl');
//       }
//     } catch (e) {
//       debugPrint('Error opening store: $e');
//     }
//   }

//   // Check for updates and show dialog if needed
//   static Future<void> checkAndShowUpdateDialog(BuildContext context) async {
//     try {
//       final updateInfo = await checkForUpdates();
//       if (updateInfo != null) {
//         await showUpdateDialog(context, updateInfo);
//       }
//     } catch (e) {
//       debugPrint('Error in checkAndShowUpdateDialog: $e');
//     }
//   }
// }

// // Data class for update information
// class UpdateInfo {
//   final String currentVersion;
//   final String latestVersion;
//   final bool isForceUpdate;
//   final String updateMessage;
//   final String whatsNew;

//   UpdateInfo({
//     required this.currentVersion,
//     required this.latestVersion,
//     required this.isForceUpdate,
//     required this.updateMessage,
//     required this.whatsNew,
//   });
// }
