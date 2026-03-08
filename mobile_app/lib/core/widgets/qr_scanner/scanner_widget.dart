import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../constants/app_colors.dart';

class RutexScannerWidget extends StatefulWidget {
  final Function(String code) onCodeDetected;

  const RutexScannerWidget({
    super.key,
    required this.onCodeDetected,
  });

  @override
  State<RutexScannerWidget> createState() => _RutexScannerWidgetState();
}

class _RutexScannerWidgetState extends State<RutexScannerWidget> {
  // Inicialización del controlador de la cámara
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void dispose() {
    // Es vital liberar el controlador para cerrar la cámara al salir
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Motor del Escáner (Cámara)
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final String? code = barcodes.first.rawValue;
              if (code != null) {
                widget.onCodeDetected(code);
              }
            }
          },
        ),

        // Marco de Enfoque (Diseño visual)
        _buildScannerOverlay(),

        // Control de Linterna (Flash)
        _buildFlashControl(),
      ],
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.verdeBorde,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildFlashControl() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: CircleAvatar(
          backgroundColor: AppColors.grisSombra.withValues(alpha: 0.6),
          radius: 28,
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              // Accedemos al estado de la linterna de forma segura
              final bool isFlashOn = value.torchState == TorchState.on;

              return IconButton(
                color: AppColors.verdePrincipal,
                iconSize: 28,
                icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
                onPressed: () => controller.toggleTorch(),
              );
            },
          ),
        ),
      ),
    );
  }
}