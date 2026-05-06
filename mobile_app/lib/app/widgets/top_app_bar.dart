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

import '../../core/constants/app_colors.dart';
import '../navigation/app_routes.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;

  const TopAppBar({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? theme.colorScheme.surface
        : AppColors.blancoPuro;
    final foregroundColor = isDark
        ? theme.colorScheme.onSurface
        : AppColors.negroTexto;
    final logo = isDark
        ? 'assets/logos finales rutexgo blanco1.1.png'
        : 'assets/Logo_Negro_Rutexgo.png';

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: foregroundColor),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                  return;
                }

                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
              },
            )
          : null,
      title: LayoutBuilder(
        builder: (context, constraints) {
          return Image.asset(
            logo,
            height: 28,
            width: constraints.maxWidth,
            fit: BoxFit.contain,
          );
        },
      ),
      actions: [
        Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: foregroundColor),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: SizedBox(
          width: double.infinity,
          height: 2,
          child: ColoredBox(
            color: isDark
                ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
                : AppColors.negroTexto,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2);
}
