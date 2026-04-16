import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/widgets/qr_scanner/scanner_widget.dart';
import '../../../data/repository/mission_repository_impl.dart';
import '../../../domain/usescases/mission_uses_cases.dart';
import '../widgets/mission_scanner_overlay.dart';

class MisionScannerScreen extends StatefulWidget {
  final String? routeId;
  final int? totalPois;

  const MisionScannerScreen({super.key, this.routeId, this.totalPois});

  @override
  State<MisionScannerScreen> createState() => _MisionScannerScreenState();
}

class _MisionScannerScreenState extends State<MisionScannerScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MissionUseCases _useCases = MissionUseCases(MissionRepositoryImpl());

  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;
  bool _flashOn = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onQrCodeDetected(String code) async {
    debugPrint("QR detectado: $code");
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    await _scannerController.stop();

    final result = await _useCases.executeScan(code);

    if (result != null && mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.monumentInfo,
        arguments: {
          ...result,
          if (widget.routeId != null) 'routeId': widget.routeId,
          if (widget.totalPois != null) 'totalPois': widget.totalPois,
        },
      ).then((_) async {
        await _scannerController.start();
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Código QR no reconocido"),
            backgroundColor: AppColors.error,
          ),
        );
      }

      await _scannerController.start();
      if (!mounted) return;
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          IgnorePointer(
            ignoring: false,
            child: RutexScannerWidget(
              controller: _scannerController,
              onCodeDetected: _onQrCodeDetected,
            ),
          ),

          MissionScannerOverlay(
            controller: _scannerController,
            isProcessing: _isProcessing,
            flashOn: _flashOn,
            onBack: () => Navigator.pop(context),
            onToggleTorch: _toggleTorch,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTorch() async {
    await _scannerController.toggleTorch();
    if (!mounted) return;
    setState(() => _flashOn = !_flashOn);
  }
}
