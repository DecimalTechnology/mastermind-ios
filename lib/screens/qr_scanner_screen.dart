import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/screens/Search/search_details_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool isScanning = true;
  String? scannedUserId;
  String? scannedProfileId;

  @override
  void initState() {
    super.initState();
  }

  Map<String, String> _parseQRCodeData(String qrData) {
    if (qrData.contains('ProfileID:') && qrData.contains('UserID:')) {
      try {
        List<String> parts = qrData.split('|');
        String? profileId;
        String? userId;

        for (String part in parts) {
          if (part.startsWith('ProfileID:')) {
            profileId = part.substring(10); // after "ProfileID:"
          } else if (part.startsWith('UserID:')) {
            userId = part.substring(7); // after "UserID:"
          }
        }

        return {
          'profileId': profileId ?? 'N/A',
          'userId': userId ?? 'N/A',
        };
      } catch (e) {}
    }

    // Fallback: treat entire string as userId
    return {
      'profileId': 'N/A',
      'userId': qrData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return PlatformWidget.scaffold(
      context: context,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(CupertinoIcons.back, color: Colors.white, size: 28),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kOxygenMMPurple.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.keyboard, color: Colors.white, size: 20),
              ),
              onPressed: () {
                Navigator.pop(context, 'manual');
              },
              tooltip: 'Manual Entry',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;

              for (final barcode in barcodes) {
                if (isScanning && barcode.rawValue != null) {
                  // Parse QR code data to extract user ID and profile ID
                  final parsed = _parseQRCodeData(barcode.rawValue!);

                  setState(() {
                    isScanning = false;
                    scannedUserId = parsed['userId'];
                    scannedProfileId = parsed['profileId'];
                  });

                  controller.stop();
                  _showSuccessDialog();
                  break;
                }
              }
            },
          ),

          // Simple overlay
          CustomPaint(
            painter: SimpleScannerOverlayPainter(
              borderColor: kOxygenMMPurple,
              borderRadius: 15,
              borderLength: 40,
              borderWidth: 4,
              cutOutSize: MediaQuery.of(context).size.width * 0.75,
            ),
            child: const SizedBox.expand(),
          ),

          // Top instruction area
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: kOxygenMMPurple.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: kOxygenMMPurple,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isScanning
                        ? 'Position QR Code in Frame'
                        : 'QR Code Detected!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isScanning
                        ? 'Hold steady for automatic scanning'
                        : 'Processing user information...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Bottom action area
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Scanning indicator
                  if (isScanning)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: kOxygenMMPurple.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kOxygenMMPurple,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: kOxygenMMPurple,
                        size: 30,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Action buttons
                  if (scannedUserId != null)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kOxygenMMPurple.withValues(alpha: 0.9),
                            kOxygenMMPurple.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: kOxygenMMPurple.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'User Found!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'ID: $scannedUserId',
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (scannedProfileId != null &&
                                        scannedProfileId != 'N/A')
                                      Text(
                                        'Profile ID: $scannedProfileId',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SearchResultDetailsScreen(
                                          userId: scannedProfileId ?? '',
                                          profilId: scannedUserId ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.visibility, size: 18),
                                  label: const Text('View Profile'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: kOxygenMMPurple,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      isScanning = true;
                                      scannedUserId = null;
                                    });
                                    controller.start();
                                  },
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Scan Again'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTestQRCode() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Test QR Code'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('This is a test QR code with user ID: 12345'),
              SizedBox(height: 16),
              Text('You can scan this or use the manual entry option.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isScanning = false;
                  scannedUserId = '12345';
                });
                controller.stop();
                _showSuccessDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kOxygenMMPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simulate Scan'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kOxygenMMPurple,
                  kOxygenMMPurple.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kOxygenMMPurple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'QR Code Scanned!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'User ID: $scannedUserId',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchResultDetailsScreen(
                                userId: scannedProfileId!,
                                profilId: scannedUserId!,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 43, 18, 18),
                          foregroundColor: kOxygenMMPurple,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('View Profile'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class SimpleScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  SimpleScannerOverlayPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final cutOutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    // Draw the overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
              cutOutRect, Radius.circular(borderRadius))),
      ),
      paint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final borderRect =
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius));
    canvas.drawRRect(borderRect, borderPaint);

    // Draw corner indicators
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth * 2
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.top + borderLength),
      Offset(cutOutRect.left, cutOutRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.top),
      Offset(cutOutRect.left + borderLength, cutOutRect.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(cutOutRect.right - borderLength, cutOutRect.top),
      Offset(cutOutRect.right, cutOutRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.top),
      Offset(cutOutRect.right, cutOutRect.top + borderLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.bottom - borderLength),
      Offset(cutOutRect.left, cutOutRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.left, cutOutRect.bottom),
      Offset(cutOutRect.left + borderLength, cutOutRect.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(cutOutRect.right - borderLength, cutOutRect.bottom),
      Offset(cutOutRect.right, cutOutRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRect.right, cutOutRect.bottom - borderLength),
      Offset(cutOutRect.right, cutOutRect.bottom),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
