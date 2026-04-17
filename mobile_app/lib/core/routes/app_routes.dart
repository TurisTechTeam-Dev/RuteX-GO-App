import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Pantallas
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/mission/domain/usecases/mission_use_cases.dart';
import '../../features/mission/presentation/navigation/provider/trip_provider.dart';
import '../../features/mission/presentation/navigation/screens/map_navigation_screen.dart';
import '../../features/mission/presentation/qr_scanner/screens/mission_scanner_screen.dart';
import '../../features/mission/presentation/monument_detail/screens/monument_info_screen.dart';
import '../../features/mission/presentation/quiz/screens/quiz_screen.dart';
import '../../features/mission/presentation/quiz/screens/route_result_screen.dart';
import '../../features/profile/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/routes/data/routes_repository_impl.dart';
import '../../features/routes/domain/usecases/routes_use_cases.dart';
import '../../features/routes/presentation/city_selection_screen.dart';
import '../../features/routes/presentation/route_selection_screen.dart';
import '../../features/admin_panel/presentation/admin_panel_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String mapNavigation = '/map_navigation';
  static const String missionQrScanner = '/mission_scanner';
  static const String monumentInfo = '/monument_info';
  static const String quiz = '/quiz';
  static const String routeResult = '/route_result';
  static const String citySelection = '/city_selection';
  static const String routeSelection = '/route_selection';
  static const String adminPanel = '/admin_panel';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routesUseCases = RoutesUseCases(RoutesRepositoryImpl());

    switch (settings.name) {
      case mapNavigation:
        final String routeId = settings.arguments as String? ?? '';

        return MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => TripSimulationProvider(
              missionUseCases: context.read<MissionUseCases>(),
              routeId: routeId,
            ),
            child: MapNavigationScreen(routeId: routeId),
          ),
        );

      case adminPanel:
        return MaterialPageRoute(builder: (_) => const AdminPanelScreen());

      case citySelection:
        return MaterialPageRoute(
          builder: (_) => CitySelectionScreen(routesUseCases: routesUseCases),
        );

      case routeSelection:
        final String idCiudad = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => RouteSelectionScreen(
            routesUseCases: routesUseCases,
            idCiudad: idCiudad,
          ),
        );

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case missionQrScanner:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MissionScannerScreen(
            routeId: args?['routeId']?.toString(),
            totalPois: _asInt(args?['totalPois']),
            expectedPointId: args?['expectedPointId']?.toString(),
            expectedPointName: args?['expectedPointName']?.toString(),
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

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);

    return null;
  }
}
