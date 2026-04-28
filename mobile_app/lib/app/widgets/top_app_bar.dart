import 'package:flutter/material.dart';

import '../navigation/app_routes.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;

  const TopAppBar({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final logo = theme.brightness == Brightness.dark
        ? 'assets/Logo_Color_Rutexgo.png'
        : 'assets/Logo_Negro_Rutexgo.png';

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
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
      title: Image.asset(logo, height: 28),
      actions: [
        Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: colorScheme.onSurface),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: SizedBox(
          width: double.infinity,
          height: 1,
          child: ColoredBox(
            color: colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2);
}
