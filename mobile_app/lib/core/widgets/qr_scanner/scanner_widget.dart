import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../constants/app_colors.dart';

class RutexScannerWidget extends StatefulWidget {
  final Function(String code) onCodeDetected;
  final MobileScannerController controller;

  const RutexScannerWidget({
    super.key,
    required this.onCodeDetected,
    required this.controller,
  });

  @override
  State<RutexScannerWidget> createState() => _RutexScannerWidgetState();
}

class _RutexScannerWidgetState extends State<RutexScannerWidget> {
  double _baseZoom = 0.0; // Zoom al iniciar el gesto

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Envolvemos el scanner en un GestureDetector para capturar el pinch
        GestureDetector(
          onScaleStart: (details) {
            // Guardamos el zoom actual cuando el usuario pone los dos dedos
            _baseZoom = widget.controller.value.zoomScale;
          },
          onScaleUpdate: (details) {
            // Calculamos el nuevo zoom basado en el movimiento de los dedos
            // details.scale nos dice cuánto se han alejado o acercado los dedos
            final double newZoom = (_baseZoom * details.scale).clamp(0.0, 1.0);
            widget.controller.setZoomScale(newZoom);
          },
          child: MobileScanner(
            controller: widget.controller,
            fit: BoxFit.cover,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                widget.onCodeDetected(barcodes.first.rawValue!);
              }
            },
          ),
        ),

        // Marco de diseño (Ignora los toques para no romper el GestureDetector)
        IgnorePointer(
          child: Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.verdeBorde, width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
