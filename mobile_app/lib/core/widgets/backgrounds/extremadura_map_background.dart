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

class ExtremaduraMapBackground extends StatelessWidget {
  final double opacity;

  const ExtremaduraMapBackground({super.key, this.opacity = 0.4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.negroFondo : AppColors.blancoPuro,
        image: DecorationImage(
          image: const AssetImage('assets/Mapa_fondo_Extremadura.png'),
          opacity: opacity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
