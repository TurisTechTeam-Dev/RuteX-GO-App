import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:mobile_app/features/splash/presentation/splash_screen.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authUseCases = Provider.of<AuthUseCases>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authUseCases.authStateChanges,
      builder: (context, snapshot) {
        // Mientras se establece la conexión con Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si hay un usuario logueado
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<bool>(
            future: authUseCases.checkAdminStatus(snapshot.data!.uid),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final bool isAdmin = adminSnapshot.data ?? false;

              // REGLA DE ORO: Si es Web y Admin, mantenlo en el panel
              if (kIsWeb && isAdmin) {
                return const AdminRedirector();
              }

              // Si es móvil o no es admin, dejamos que el Splash maneje la entrada
              return const SplashScreen();
            },
          );
        }

        // 3. Si no hay sesión activa, al Splash (que mandará al Login)
        return const SplashScreen();
      },
    );
  }
}

class AdminRedirector extends StatefulWidget {
  const AdminRedirector({super.key});

  @override
  State<AdminRedirector> createState() => _AdminRedirectorState();
}

class _AdminRedirectorState extends State<AdminRedirector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.adminPanel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
