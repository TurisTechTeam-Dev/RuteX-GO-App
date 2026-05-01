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

import '../../constants/app_colors.dart';

class StrokeTitle extends StatelessWidget {
  final String text;

  const StrokeTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5
                ..color = AppColors.verdePrincipal,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
