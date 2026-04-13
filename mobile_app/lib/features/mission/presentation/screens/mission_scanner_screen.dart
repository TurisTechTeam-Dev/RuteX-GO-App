import 'package:flutter/material.dart';
import 'package:mobile_app/core/routes/app_routes.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/qr_scanner/scanner_widget.dart';
import '../../data/repository/mission_repository_impl.dart';
import '../../domain/usescases/mission_uses_cases.dart';

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
    print("QR detectado: $code");
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

          _buildOverlayUI(),
        ],
      ),
    );
  }

  Widget _buildOverlayUI() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.black.withValues(alpha: 0.35),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),

                  IconButton(
                    icon: Icon(
                      _flashOn ? Icons.flash_on : Icons.flash_off,
                      color: _flashOn ? Colors.yellow : Colors.white,
                    ),
                    onPressed: () async {
                      await _scannerController.toggleTorch();
                      setState(() {
                        _flashOn = !_flashOn;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 125,
          left: 0,
          right: 0,
          child: Center(child: _buildZoomSlider()),
        ),

        if (_isProcessing)
          const Center(
            child: CircularProgressIndicator(color: AppColors.verdePrincipal),
          ),
      ],
    );
  }

  Widget _buildZoomSlider() {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ValueListenableBuilder(
        valueListenable: _scannerController,
        builder: (context, state, child) {
          double currentZoom = state.zoomScale;

          return Row(
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_out, color: Colors.white, size: 20),
                onPressed: () => _scannerController.setZoomScale(
                  (currentZoom - 0.1).clamp(0.0, 1.0),
                ),
              ),
              Expanded(
                child: Slider(
                  activeColor: AppColors.verdePrincipal,
                  inactiveColor: Colors.white24,
                  value: currentZoom,
                  onChanged: (value) => _scannerController.setZoomScale(value),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                onPressed: () => _scannerController.setZoomScale(
                  (currentZoom + 0.1).clamp(0.0, 1.0),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
