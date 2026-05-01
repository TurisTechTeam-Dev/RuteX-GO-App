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

import '../../../../core/constants/app_colors.dart';

class AuthCard extends StatelessWidget {
  final List<Widget> children;

  const AuthCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.negroTarjeta.withValues(alpha: 0.78)
            : AppColors.tarjetaTransparente,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(
            alpha: isDark ? 0.30 : 0.08,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 4,
            offset: const Offset(0, 4),
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
