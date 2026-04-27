import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/domain/entities/auth_user.dart';
import '../features/auth/domain/usecases/auth_use_cases.dart';
import '../features/splash/presentation/splash_screen.dart';
import 'navigation/app_routes.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authUseCases = Provider.of<AuthUseCases>(context, listen: false);

    return StreamBuilder<AuthUser?>(
      stream: authUseCases.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          return FutureBuilder<bool>(
            future: authUseCases.checkAdminStatus(user.uid),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final isAdmin = adminSnapshot.data ?? false;
              if (isAdmin) {
                return const AdminRedirector();
              }

              return const SplashScreen();
            },
          );
        }

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
