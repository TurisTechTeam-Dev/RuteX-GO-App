import 'package:flutter/material.dart';

class ArrivalBottomSheet extends StatelessWidget {
  final String poiName;
  final bool isFinalTarget;
  final VoidCallback onScanMission;
  final VoidCallback onSkipPoint;

  const ArrivalBottomSheet({
    super.key,
    required this.poiName,
    required this.isFinalTarget,
    required this.onScanMission,
    required this.onSkipPoint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final subtleText = theme.colorScheme.onSurface.withValues(alpha: 0.68);

    return Container(
      padding: EdgeInsets.fromLTRB(30, 30, 30, bottomPadding + 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isFinalTarget ? "META ALCANZADA" : "HAS LLEGADO",
            style: TextStyle(color: subtleText, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            poiName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onScanMission,
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text(
                "ESCANEAR PARA JUGAR",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSkipPoint,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isFinalTarget ? Colors.red : Colors.grey,
                ),
                foregroundColor: isFinalTarget ? Colors.red : subtleText,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                isFinalTarget ? "FINALIZAR RUTA" : "SALTAR E IR AL SIGUIENTE",
                style: TextStyle(
                  color: isFinalTarget ? Colors.red : subtleText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
