import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final bool showDrawer;
  final List<Widget>? actions;

  const TopAppBar({
    super.key,
    this.showBack = false,
    this.showDrawer = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,

      // BACK ARROW
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.negroTexto),
              onPressed: () => Navigator.pop(context),
            )
          : null,

      // LOGO
      title: Image.asset("assets/Logo_Negro_Rutexgo.png", height: 28),

      // DRAWER DERECHA
      actions: [
        if (showDrawer)
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.negroTexto),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),

        if (actions != null) ...actions!,
      ],

      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(2),
        child: Divider(height: 1, thickness: 1, color: AppColors.negroTexto),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header del Menú
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.verdePrincipal),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Menú RutexGo',
                    style: TextStyle(
                      color: AppColors.blancoTarjeta,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Opciones del Menú
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const Spacer(),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              _showLogoutDialog(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cerrar sesión"),
          content: const Text("¿Estás seguro de que quieres salir?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              child: const Text("Salir", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
