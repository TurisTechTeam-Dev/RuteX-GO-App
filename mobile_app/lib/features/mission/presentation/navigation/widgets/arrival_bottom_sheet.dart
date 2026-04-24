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
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(30, 30, 30, bottomPadding + 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isFinalTarget ? "META ALCANZADA" : "HAS LLEGADO",
            style: const TextStyle(color: Colors.grey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            poiName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                side: BorderSide(color: isFinalTarget ? Colors.red : Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                isFinalTarget ? "FINALIZAR RUTA" : "SALTAR E IR AL SIGUIENTE",
                style: TextStyle(
                  color: isFinalTarget ? Colors.red : Colors.black54,
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
