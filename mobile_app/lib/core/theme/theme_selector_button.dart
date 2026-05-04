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

import 'theme_provider.dart';

class ThemeSelectorButton extends StatelessWidget {
  const ThemeSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: 'Cambiar tema',
      icon: Icon(Icons.color_lens_outlined, color: colorScheme.onSurface),
      onPressed: () => showThemeSelector(context),
    );
  }
}

Future<void> showThemeSelector(BuildContext context) {
  final themeProvider = context.read<ThemeProvider>();

  return showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeModeTile(
              title: 'Claro',
              icon: Icons.light_mode_outlined,
              value: ThemeMode.light,
              selectedValue: themeProvider.themeMode,
            ),
            _ThemeModeTile(
              title: 'Oscuro',
              icon: Icons.dark_mode_outlined,
              value: ThemeMode.dark,
              selectedValue: themeProvider.themeMode,
            ),
            _ThemeModeTile(
              title: 'Sistema',
              icon: Icons.brightness_auto_outlined,
              value: ThemeMode.system,
              selectedValue: themeProvider.themeMode,
            ),
          ],
        ),
      );
    },
  );
}

class _ThemeModeTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode selectedValue;

  const _ThemeModeTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: selectedValue == value ? const Icon(Icons.check) : null,
      onTap: () {
        context.read<ThemeProvider>().setThemeMode(value);
        Navigator.pop(context);
      },
    );
  }
}
