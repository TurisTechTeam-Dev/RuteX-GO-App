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
    final routesUseCase = RoutesUsesCases(RoutesRepositoryImpl());

    switch (settings.name) {
      case citySelection:
        return MaterialPageRoute(
          builder: (_) => CitySelectionScreen(routesUsesCases: routesUseCase),
        );

      case routeSelection:
        final String idCiudad = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => RouteSelectionScreen(
            routesUsesCases: routesUseCase,
            idCiudad: idCiudad,
          ),
        );

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

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case missionQrScanner:
        final routeId = _routeIdFromArguments(settings.arguments);
        final totalPois = _intFromArguments(settings.arguments, 'totalPois');
        return MaterialPageRoute(
          builder: (_) => MisionScannerScreen(
            routeId: routeId,
            totalPois: totalPois,
          ),
        );
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

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no definida: ${settings.name}')),
          ),
        );
    }
  }

  static String? _routeIdFromArguments(Object? arguments) {
    if (arguments is String) return arguments;

    if (arguments is Map) {
      final routeId = arguments['routeId'] ?? arguments['rutaId'];
      return routeId?.toString();
    }

    return null;
  }

  static int? _intFromArguments(Object? arguments, String key) {
    if (arguments is Map) {
      final value = arguments[key];

      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
    }

    return null;
  }
}
