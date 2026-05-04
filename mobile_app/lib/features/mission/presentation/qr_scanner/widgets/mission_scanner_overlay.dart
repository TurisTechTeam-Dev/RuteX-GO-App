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

class MissionScannerOverlay extends StatelessWidget {
  final MobileScannerController controller;
  final bool isProcessing;
  final bool flashOn;
  final VoidCallback onBack;
  final Future<void> Function() onToggleTorch;

  const MissionScannerOverlay({
    super.key,
    required this.controller,
    required this.isProcessing,
    required this.flashOn,
    required this.onBack,
    required this.onToggleTorch,
  });

  @override
  Widget build(BuildContext context) {
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
                    onPressed: onBack,
                  ),
                  IconButton(
                    icon: Icon(
                      flashOn ? Icons.flash_on : Icons.flash_off,
                      color: flashOn ? Colors.yellow : Colors.white,
                    ),
                    onPressed: onToggleTorch,
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
          child: Center(child: _ScannerZoomSlider(controller: controller)),
        ),
        if (isProcessing)
          const Center(
            child: CircularProgressIndicator(color: AppColors.verdePrincipal),
          ),
      ],
    );
  }
}

class _ScannerZoomSlider extends StatelessWidget {
  final MobileScannerController controller;

  const _ScannerZoomSlider({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, state, child) {
          final currentZoom = state.zoomScale;

          return Row(
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_out, color: Colors.white, size: 20),
                onPressed: () => controller.setZoomScale(
                  (currentZoom - 0.1).clamp(0.0, 1.0),
                ),
              ),
              Expanded(
                child: Slider(
                  activeColor: AppColors.verdePrincipal,
                  inactiveColor: Colors.white24,
                  value: currentZoom,
                  onChanged: controller.setZoomScale,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                onPressed: () => controller.setZoomScale(
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
