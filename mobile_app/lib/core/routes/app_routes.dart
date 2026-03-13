import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Pantallas
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/mission/presentation/screens/map_navigation_screen.dart';
import '../../features/mission/presentation/screens/mission_scanner_screen.dart';
import '../../features/mission/presentation/screens/monument_info_screen.dart';
import '../../features/mission/presentation/screens/quiz_screen.dart';
import '../../features/mission/presentation/screens/route_result_screen.dart';
import '../../features/profile/presentation/home_screen.dart';
import '../../features/routes/presentation/city_selection_screen.dart';
import '../../features/routes/presentation/route_selection_screen.dart';
import '../../features/mission/presentation/provider/trip_provider.dart';
import '../../features/mission/domain/usescases/mission_uses_cases.dart';

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

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

      case mapNavigation:
      // Verificamos que los argumentos no sean nulos para evitar pantallazos rojos
        final String routeId = settings.arguments as String? ?? 'default_route';

        return MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            // Le pasamos el UseCase (que viene del main) y el routeId (que viene de la selección)
            create: (context) => TripSimulationProvider(
              missionUseCases: context.read<MissionUseCases>(),
              routeId: routeId,
            ),
            child: MapNavigationScreen(routeId: routeId),
          ),
        );

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case citySelection:
        return MaterialPageRoute(builder: (_) => const CitySelectionScreen());
      case routeSelection:
        return MaterialPageRoute(builder: (_) => const RouteSelectionScreen());
      case missionQrScanner:
        return MaterialPageRoute(builder: (_) => const MisionScannerScreen());
      case monumentInfo:
        return MaterialPageRoute(builder: (_) => const MonumentInfoScreen());
      case quiz:
        return MaterialPageRoute(builder: (_) => const QuizScreen());
      case routeResult:
        return MaterialPageRoute(builder: (_) => const RouteResultScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no definida: ${settings.name}')),
          ),
        );
    }
  }
}