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
import '../../../../../core/widgets/audio_guide/audio_guide.dart';
import '../../../../../app/navigation/app_routes.dart';
import '../../../domain/usecases/mission_use_cases.dart';
import '../../mission_flow_result.dart';
import '../../monument_detail/models/monument_info_args.dart';
import '../../quiz/quiz_route_progress.dart';
import '../models/mission_scanner_args.dart';
import '../widgets/mission_scanner_overlay.dart';
import '../widgets/rutex_scanner_widget.dart';

class MissionScannerScreen extends StatefulWidget {
  final MissionUseCases missionUseCases;
  final MissionScannerArgs args;

  const MissionScannerScreen({
    super.key,
    required this.missionUseCases,
    required this.args,
  });

  @override
  State<MissionScannerScreen> createState() => _MissionScannerScreenState();
}

class _MissionScannerScreenState extends State<MissionScannerScreen> {
  static const Duration _scanCooldown = Duration(milliseconds: 2800);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;
  bool _flashOn = false;
  DateTime? _lastScanAt;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onQrCodeDetected(String code) async {
    debugPrint("QR detected: $code");
    final now = DateTime.now();
    if (_isProcessing) return;
    if (_lastScanAt != null && now.difference(_lastScanAt!) < _scanCooldown) {
      return;
    }

    _lastScanAt = now;
    setState(() => _isProcessing = true);

    await _scannerController.stop();

    final result = await widget.missionUseCases.executeScan(code);

    if (result != null && mounted) {
      final pointId = result.point.id;

      if (widget.args.expectedPointId != null &&
          pointId != widget.args.expectedPointId) {
        final expectedName = widget.args.expectedPointName ?? 'este punto';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Este QR no pertenece a $expectedName"),
            backgroundColor: AppColors.error,
          ),
        );

        await _scannerController.start();
        if (!mounted) return;
        setState(() => _isProcessing = false);
        return;
      }

      if (widget.args.routeId != null &&
          QuizRouteProgress.hasVisitedPoint(pointId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Este punto de interés ya está completado"),
            backgroundColor: AppColors.error,
          ),
        );

        await _scannerController.start();
        if (!mounted) return;
        setState(() => _isProcessing = false);
        return;
      }

      final resultFromMission = await Navigator.pushNamed(
        context,
        AppRoutes.monumentInfo,
        arguments: MonumentInfoArgs(
          scanResult: result,
          routeId: widget.args.routeId,
          totalPois: widget.args.totalPois,
        ),
      );

      if (!mounted) return;

      if (resultFromMission == MissionFlowResult.pointCompleted) {
        Navigator.pop(context, MissionFlowResult.pointCompleted);
        return;
      }

      await _scannerController.start();
      if (mounted) {
        setState(() => _isProcessing = false);
      }
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
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final autoRead = MediaQuery.of(context).accessibleNavigation;

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
          Positioned(
            left: 16,
            bottom: bottomPadding + 24,
            child: AudioGuideWidget(
              text:
                  'Escáner QR. Enfoca el código QR del punto de interés correcto dentro del recuadro. Puedes volver atrás o activar la linterna si necesitas más luz.',
              autoRead: autoRead,
              semanticLabel:
                  'Botón de audioguía. Pulsa para escuchar las instrucciones del escáner QR.',
            ),
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
