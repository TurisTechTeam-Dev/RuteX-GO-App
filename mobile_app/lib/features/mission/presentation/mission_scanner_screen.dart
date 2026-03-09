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

  // Controlador único para manejar Flash y Zoom desde esta pantalla
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
          // Capa 1: El Escáner
          RutexScannerWidget(
            controller: _scannerController,
            onCodeDetected: _onQrCodeDetected,
          ),

          // Capa 2: Interfaz de usuario (Flash, Zoom, Botón atrás)
          _buildOverlayUI(),
        ],
      ),
    );
  }

  Widget _buildOverlayUI() {
    return Stack(
      children: [
        // Top Bar con Flash Funcional
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

        // Slider de Zoom debajo del cuadro (260px del cuadro + margen)
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 300), // Empuja el slider debajo del visor
              _buildZoomSlider(),
            ],
          ),
        ),

        // Cargando
        if (_isProcessing)
          const Center(
            child: CircularProgressIndicator(color: AppColors.verdePrincipal),
          ),

        // Botón inferior
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
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ValueListenableBuilder(
        valueListenable: _scannerController,
        builder: (context, state, child) {
          return Row(
            children: [
              const Icon(Icons.zoom_out, color: Colors.white, size: 18),
              Expanded(
                child: Slider(
                  activeColor: AppColors.verdePrincipal,
                  inactiveColor: Colors.white24,
                  value: state.zoomScale,
                  onChanged: (value) => _scannerController.setZoomScale(value),
                ),
              ),
              const Icon(Icons.zoom_in, color: Colors.white, size: 18),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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