import 'package:flutter/material.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/mission/presentation/map_navigation_screen.dart';
import '../../features/mission/presentation/mission_scanner_screen.dart';
import '../../features/mission/presentation/monument_info_screen.dart';
import '../../features/mission/presentation/quiz_screen.dart';
import '../../features/mission/presentation/route_result_screen.dart';
import '../../features/profile/presentation/home_screen.dart';
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

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const HomeScreen(),
      citySelection: (context) => const CitySelectionScreen(),
      routeSelection: (context) => const RouteSelectionScreen(),
      mapNavigation: (context) => const MapNavigationScreen(),
      missionQrScanner: (context) => const MisionScannerScreen(),
      monumentInfo: (context) => const MonumentInfoScreen(),
      quiz: (context) => const QuizScreen(),
      routeResult: (context) => const RouteResultScreen(),
    };
  }
}
