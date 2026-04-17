import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../routes/app_routes.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;

  const TopAppBar({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.blancoPuro,
      elevation: 0,
      centerTitle: true,

      // Flecha izquierda
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.negroTexto),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                }
              },
            )
          : null,

      // Logo centro
      title: Image.asset("assets/Logo_Negro_Rutexgo.png", height: 28),

      // Drawer derecha
      actions: [
        Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: AppColors.negroTexto),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            );
          },
        ),
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
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.50,
      child: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              const DrawerHeader(
                decoration: BoxDecoration(color: AppColors.verdePrincipal),
                child: SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Menú',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.blancoTarjeta,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Inicio
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Inicio'),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Perfil'),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.profile,
                    (route) => false,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Info'),
                onTap: () {
                  Navigator.pop(context);
                  _showInfoDialog(context);
                },
              ),

              const Spacer(),

              const Divider(),

              // Logout
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cerrar sesión"),
          content: const Text("¿Estás seguro de que quieres salir?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
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

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Como funciona RuteXGo"),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Elige una ciudad, selecciona una ruta y sigue el mapa hasta cada punto de interes.",
                ),
                SizedBox(height: 10),
                Text(
                  "Al llegar, escanea el QR del punto correcto. Se abrira una descripcion y despues la mision.",
                ),
                SizedBox(height: 10),
                Text(
                  "Cada pregunta acertada suma 10 puntos. Cada punto puede dar hasta 30 puntos.",
                ),
                SizedBox(height: 10),
                Text(
                  "Si completas las misiones de todos los puntos de la ruta, recibes 10 puntos extra.",
                ),
                SizedBox(height: 10),
                Text(
                  "Puedes saltar un punto, pero esa mision quedara como no realizada y no contara para la bonificacion.",
                ),
                SizedBox(height: 10),
                Text("Si repites una ruta, se conserva tu mejor puntuacion."),
                SizedBox(height: 10),
                Text(
                  "Tu rango se calcula con los puntos reales obtenidos en tus rutas completadas.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Entendido"),
            ),
          ],
        );
      },
    );
  }
}
