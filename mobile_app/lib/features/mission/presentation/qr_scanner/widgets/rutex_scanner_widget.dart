/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../core/constants/app_colors.dart';

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
  double _baseZoom = 0.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onScaleStart: (_) {
            _baseZoom = widget.controller.value.zoomScale;
          },
          onScaleUpdate: (details) {
            final newZoom = (_baseZoom * details.scale).clamp(0.0, 1.0);
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
