import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  final Function(String) onQRCodeScanned;

  const QRScannerPage({
    super.key,
    required this.onQRCodeScanned,
  });

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController controller = MobileScannerController();
  bool isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller: controller,
            onDetect: (BarcodeCapture barcodeCapture) {
              if (!isScanning) return;
              
              final String? code = barcodeCapture.barcodes.first.rawValue;
              if (code != null) {
                setState(() {
                  isScanning = false;
                });
                widget.onQRCodeScanned(code);
              }
            },
          ),
          
          // Overlay with scanning frame
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Point camera at QR code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom overlay shape
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path();
    
    // Add the outer rectangle
    path.addRect(rect);

    // Calculate the cut-out rectangle (centered)
    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );

    // Subtract the cut-out rectangle
    path.addRRect(
      RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
    );
    
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final cutOutSize = this.cutOutSize;
    final cutOutHeight = cutOutSize;
    final cutOutWidth = cutOutSize;

    final cutOutBottomRightY = height / 2 + cutOutHeight / 2;
    final cutOutBottomRightX = width / 2 + cutOutWidth / 2;
    final cutOutTopLeftY = height / 2 - cutOutHeight / 2;
    final cutOutTopLeftX = width / 2 - cutOutWidth / 2;

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw corner borders
    final borderLength = this.borderLength;

    // Top left
    canvas.drawPath(
      Path()
        ..moveTo(cutOutTopLeftX - borderOffset, cutOutTopLeftY + borderLength)
        ..quadraticBezierTo(cutOutTopLeftX - borderOffset,
            cutOutTopLeftY - borderOffset, cutOutTopLeftX + borderLength, cutOutTopLeftY - borderOffset),
      borderPaint,
    );

    // Top right
    canvas.drawPath(
      Path()
        ..moveTo(cutOutBottomRightX - borderLength, cutOutTopLeftY - borderOffset)
        ..quadraticBezierTo(cutOutBottomRightX + borderOffset,
            cutOutTopLeftY - borderOffset, cutOutBottomRightX + borderOffset, cutOutTopLeftY + borderLength),
      borderPaint,
    );

    // Bottom right
    canvas.drawPath(
      Path()
        ..moveTo(cutOutBottomRightX + borderOffset, cutOutBottomRightY - borderLength)
        ..quadraticBezierTo(cutOutBottomRightX + borderOffset,
            cutOutBottomRightY + borderOffset, cutOutBottomRightX - borderLength, cutOutBottomRightY + borderOffset),
      borderPaint,
    );

    // Bottom left
    canvas.drawPath(
      Path()
        ..moveTo(cutOutTopLeftX + borderLength, cutOutBottomRightY + borderOffset)
        ..quadraticBezierTo(cutOutTopLeftX - borderOffset,
            cutOutBottomRightY + borderOffset, cutOutTopLeftX - borderOffset, cutOutBottomRightY - borderLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
