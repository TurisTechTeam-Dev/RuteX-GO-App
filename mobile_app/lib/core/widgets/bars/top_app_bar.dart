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
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.negroTexto),
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
      title: Image.asset("assets/Logo_Negro_Rutexgo.png", height: 28),
      actions: [
        Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: AppColors.negroTexto),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
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
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _showLogoutDialog(context),
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
          title: const Text("Cómo funciona RuteXGo"),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _InfoBullet(
                  bold: "Ruta: ",
                  text:
                      "elige una ciudad, selecciona una ruta y sigue el mapa hasta cada punto de interés.",
                ),
                SizedBox(height: 10),
                _InfoBullet(
                  bold: "QR y misión: ",
                  text:
                      "al llegar, escanea el QR del punto correcto. Verás una descripción del monumento y después una misión con preguntas.",
                ),
                SizedBox(height: 10),
                _InfoBullet(
                  bold: "Puntos: ",
                  text:
                      "cada pregunta acertada suma 10 puntos. Cada punto de interés puede dar hasta 30 puntos.",
                ),
                SizedBox(height: 10),
                _InfoBullet(
                  bold: "Bonificación: ",
                  text:
                      "si completas las misiones de todos los puntos de la ruta, recibes 10 puntos extra.",
                ),
                SizedBox(height: 10),
                _InfoBullet(
                  bold: "Saltos: ",
                  text:
                      "puedes saltar un punto, pero esa misión quedará como no realizada y no contará para la bonificación.",
                ),
                SizedBox(height: 10),
                _InfoBullet(
                  bold: "Mejor marca: ",
                  text:
                      "si repites una ruta, se conserva tu mejor puntuación.",
                ),
                SizedBox(height: 10),
                _InfoBullet(
                  bold: "Rango: ",
                  text:
                      "tu rango se calcula con los puntos reales obtenidos en tus rutas completadas.",
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

class _InfoBullet extends StatelessWidget {
  final String bold;
  final String text;

  const _InfoBullet({required this.bold, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.verdePrincipal,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.negroTexto,
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: bold,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
