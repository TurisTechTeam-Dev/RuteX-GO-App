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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.35 : 0.12,
            ),
            blurRadius: 10,
          ),
        ],
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
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  navigationInstruction ?? _formatDistance(distanceToNextStop),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (navigationInstruction != null)
                  Text(
                    _instructionDistanceLabel(),
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.68,
                      ),
                    ),
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
