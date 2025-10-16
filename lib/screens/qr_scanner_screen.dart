import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanned = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        _showCameraError('카메라 권한이 필요합니다.');
      }
    }
  }

  void _showCameraError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('카메라 오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // 권한 없으면 화면 닫기
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) {
      if (!scanned) {
        scanned = true;
        controller.pauseCamera();

        final scannedCode = scanData.code ?? '';

        Navigator.of(context).pop(scannedCode);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR 코드 인식')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        onPermissionSet: (ctrl, permission) {
          if (!permission) {
            _showCameraError('카메라 권한이 거부되었습니다.');
          }
        },
      ),
    );
  }
}
