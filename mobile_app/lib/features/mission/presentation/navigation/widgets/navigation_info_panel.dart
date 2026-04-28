import 'package:flutter/material.dart';

class NavigationInfoPanel extends StatelessWidget {
  final String nextStopName;
  final double distanceToNextStop;
  final String? navigationInstruction;
  final double? distanceToInstruction;

  const NavigationInfoPanel({
    super.key,
    required this.nextStopName,
    required this.distanceToNextStop,
    this.navigationInstruction,
    this.distanceToInstruction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.directions_walk, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Siguiente parada: $nextStopName',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  navigationInstruction ?? _formatDistance(distanceToNextStop),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (navigationInstruction != null)
                  Text(
                    _instructionDistanceLabel(),
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double distance) {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }

    return '${distance.toStringAsFixed(0)} m';
  }

  String _instructionDistanceLabel() {
    final distance = distanceToInstruction;
    if (distance == null) {
      return 'Destino a ${_formatDistance(distanceToNextStop)}';
    }

    return 'En ${_formatDistance(distance)} - destino a ${_formatDistance(distanceToNextStop)}';
  }
}
