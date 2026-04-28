import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/admin_panel/presentation/admin_panel_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/mission/domain/usecases/mission_use_cases.dart';
import '../../features/mission/presentation/monument_detail/models/monument_info_args.dart';
import '../../features/mission/presentation/monument_detail/screens/monument_info_screen.dart';
import '../../features/mission/presentation/navigation/provider/trip_provider.dart';
import '../../features/mission/presentation/navigation/screens/map_navigation_screen.dart';
import '../../features/mission/presentation/qr_scanner/models/mission_scanner_args.dart';
import '../../features/mission/presentation/qr_scanner/screens/mission_scanner_screen.dart';
import '../../features/mission/presentation/quiz/models/quiz_mission.dart';
import '../../features/mission/presentation/quiz/screens/quiz_screen.dart';
import '../../features/mission/presentation/quiz/screens/route_result_screen.dart';
import '../../features/profile/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/routes/domain/usecases/routes_use_cases.dart';
import '../../features/routes/presentation/city_selection_screen.dart';
import '../../features/routes/presentation/models/route_selection_args.dart';
import '../../features/routes/presentation/route_selection_screen.dart';

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
  static const String showInfoOnHomeStartArg = 'showInfoOnStart';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mapNavigation:
        final routeId = settings.arguments as String? ?? '';

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
          builder: (context) => CitySelectionScreen(
            routesUseCases: context.read<RoutesUseCases>(),
          ),
        );

      case routeSelection:
        final args = settings.arguments as RouteSelectionArgs?;
        return MaterialPageRoute(
          builder: (context) => RouteSelectionScreen(
            routesUseCases: context.read<RoutesUseCases>(),
            cityKeys: args?.cityKeys ?? const <String>{},
          ),
        );

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case home:
        final showInfoOnStart = _showInfoOnStart(settings.arguments);
        return MaterialPageRoute(
          builder: (_) => HomeScreen(showInfoOnStart: showInfoOnStart),
        );

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case missionQrScanner:
        final args = settings.arguments as MissionScannerArgs?;
        return MaterialPageRoute(
          builder: (context) => MissionScannerScreen(
            missionUseCases: context.read<MissionUseCases>(),
            args: args ?? const MissionScannerArgs(),
          ),
        );

      case monumentInfo:
        final data = settings.arguments as MonumentInfoArgs;
        return MaterialPageRoute(builder: (_) => MonumentInfoScreen(args: data));

      case quiz:
        final data = settings.arguments as QuizMission;
        return MaterialPageRoute(builder: (_) => QuizScreen(mission: data));

      case routeResult:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RouteResultScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no definida: ${settings.name}')),
          ),
        );
    }
  }

  static bool _showInfoOnStart(Object? arguments) {
    if (arguments is Map) {
      return arguments[showInfoOnHomeStartArg] == true;
    }

    return false;
  }
}
