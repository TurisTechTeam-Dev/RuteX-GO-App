import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../constants/app_colors.dart';

class RutexScannerWidget extends StatelessWidget {
  final Function(String code) onCodeDetected;
  final MobileScannerController controller;

  const RutexScannerWidget({
    super.key,
    required this.onCodeDetected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cámara
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final String? code = barcodes.first.rawValue;
              if (code != null) {
                onCodeDetected(code);
              }
            }
          },
        ),

        // Marco de diseño (Cuadro verde)
        Center(
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
        ),
      ],
    );
  }
}