import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_app/core/routes/app_routes.dart';
import '../../../core/widgets/Bars/toppAppBarr.dart';
import '../../../core/widgets/qr_scanner/scanner_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/usescases/mission_uses_cases.dart';
import '../data/mission_repository_impl.dart';

class MisionScannerScreen extends StatefulWidget {
  const MisionScannerScreen({super.key});

  @override
  State<MisionScannerScreen> createState() => _MisionScannerScreenState();
}

class _MisionScannerScreenState extends State<MisionScannerScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MissionUseCases _useCases = MissionUseCases(MissionRepositoryImpl());

  // IMPORTANTE: pinchToZoom para que funcionen los dedos
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onQrCodeDetected(String code) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final result = await _useCases.executeScan(code);

    if (result != null && mounted) {
      Navigator.pushNamed(context, AppRoutes.monumentInfo, arguments: result);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Código QR no reconocido"),
          backgroundColor: AppColors.error,
        ),
      );
    }
    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          RutexScannerWidget(
            controller: _scannerController,
            onCodeDetected: _onQrCodeDetected,
          ),
          _buildOverlayUI(),
        ],
      ),
    );
  }

  Widget _buildOverlayUI() {
    return Stack(
      children: [
        // Flash
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: TopAppBar(
            actions: [
              ValueListenableBuilder(
                valueListenable: _scannerController,
                builder: (context, state, child) {
                  final bool isFlashOn = state.torchState == TorchState.on;
                  return IconButton(
                    icon: Icon(
                      isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: isFlashOn ? Colors.yellow : Colors.white,
                    ),
                    onPressed: () => _scannerController.toggleTorch(),
                  );
                },
              ),
            ],
          ),
        ),

        // Slider de Zoom - POSICIONADO MÁS ABAJO
        Positioned(
          bottom: 125, // Ajuste para que quede justo sobre la barra blanca
          left: 0,
          right: 0,
          child: Center(child: _buildZoomSlider()),
        ),

        if (_isProcessing)
          const Center(child: CircularProgressIndicator(color: AppColors.verdePrincipal)),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomBar(),
        ),
      ],
    );
  }

  Widget _buildZoomSlider() {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
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
                onPressed: () => _scannerController.setZoomScale((currentZoom - 0.1).clamp(0.0, 1.0)),
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
                onPressed: () => _scannerController.setZoomScale((currentZoom + 0.1).clamp(0.0, 1.0)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.verdePrincipal, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}