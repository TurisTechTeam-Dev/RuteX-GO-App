import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Pantallas
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/mission/domain/usescases/mission_uses_cases.dart';
import '../../features/mission/presentation/provider/trip_provider.dart';
import '../../features/mission/presentation/screens/map_navigation_screen.dart';
import '../../features/mission/presentation/screens/mission_scanner_screen.dart';
import '../../features/mission/presentation/screens/monument_info_screen.dart';
import '../../features/mission/presentation/screens/quiz_screen.dart';
import '../../features/mission/presentation/screens/route_result_screen.dart';
import '../../features/profile/presentation/home_screen.dart';
import '../../features/routes/data/routes_repository_impl.dart';
import '../../features/routes/domain/usescases/routes_uses_cases.dart';
import '../../features/routes/presentation/city_selection_screen.dart';
import '../../features/routes/presentation/route_selection_screen.dart';

// IMPORTACIÓN DE LA NUEVA PANTALLA
import '../../features/admin_panel/presentation/admin_panel_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String mapNavigation = '/map_navigation';
  static const String missionQrScanner = '/mission_scanner';
  static const String monumentInfo = '/monument_info';
  static const String quiz = '/quiz';
  static const String routeResult = '/route_result';
  static const String citySelection = '/city_selection';
  static const String routeSelection = '/route_selection';
  static const String adminPanel = '/admin_panel';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Instancia del caso de uso de rutas para las pantallas que lo requieren
    final routesUseCase = RoutesUsesCases(RoutesRepositoryImpl());

    switch (settings.name) {

    // 1. RUTA DEL PANEL DE ADMINISTRACIÓN (WEB)
      case adminPanel:
        return MaterialPageRoute(
          builder: (_) => const AdminPanelScreen(),
        );

    // 2. SELECCIÓN DE CIUDAD
      case citySelection:
        return MaterialPageRoute(
          builder: (_) => CitySelectionScreen(routesUsesCases: routesUseCase),
        );

    // 3. SELECCIÓN DE RUTA
      case routeSelection:
        final String idCiudad = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => RouteSelectionScreen(
            routesUsesCases: routesUseCase,
            idCiudad: idCiudad,
          ),
        );

    // 4. NAVEGACIÓN POR MAPA (CON PROVIDER ESPECÍFICO)
      case mapNavigation:
        final String routeId = settings.arguments as String? ?? 'default_route';
        return MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => TripSimulationProvider(
              missionUseCases: context.read<MissionUseCases>(),
              routeId: routeId,
            ),
            child: MapNavigationScreen(routeId: routeId),
          ),
        );

    // 5. RUTAS DE AUTENTICACIÓN
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

    // 6. PERFIL Y HOME
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

    // 7. MISIONES Y GAMIFICACIÓN
      case missionQrScanner:
        return MaterialPageRoute(builder: (_) => const MisionScannerScreen());

      case monumentInfo:
        final data = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MonumentInfoScreen(data: data),
        );

      case quiz:
        final data = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => QuizScreen(data: data));

      case routeResult:
        return MaterialPageRoute(builder: (_) => const RouteResultScreen());

    // RUTA POR DEFECTO (ERROR)
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'Ruta no definida: ${settings.name}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
    }
  }
}