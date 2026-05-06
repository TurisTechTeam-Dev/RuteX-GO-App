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
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/theme_selector_button.dart';
import '../navigation/app_routes.dart';
import 'app_info_dialog.dart';
import 'logout_dialog.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final themeProvider = context.watch<ThemeProvider>();

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.50,
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.primary
                      : AppColors.verdePrincipal,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Menú',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: isDark
                            ? colorScheme.onPrimary
                            : AppColors.blancoTarjeta,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text('Inicio'),
                        onTap: () => _goToRoot(context, AppRoutes.home),
                      ),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Perfil'),
                        onTap: () => _goToRoot(context, AppRoutes.profile),
                      ),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('Info'),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (_) => const AppInfoDialog(),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.color_lens_outlined),
                        title: const Text('Tema'),
                        subtitle: Text(_themeLabel(themeProvider.themeMode)),
                        onTap: () => showThemeSelector(context),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: colorScheme.error),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const LogoutDialog(),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _goToRoot(BuildContext context, String routeName) {
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }
}
