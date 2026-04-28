import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/navigation/app_routes.dart';
import 'app/auth_wrapper.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'firebase_options.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(providers: buildAppProviders(), child: const RutexApp()),
  );
}

class RutexApp extends StatelessWidget {
  const RutexApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RutexGo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const AuthWrapper(),
    );
  }
}
