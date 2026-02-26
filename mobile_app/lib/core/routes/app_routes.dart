import 'package:flutter/material.dart';

// Import de la Feature Splash (Asegúrate de que este archivo existe)
import '../../features/splash/presentation/SplashScreen.dart';
import '../../features/auth/presentation/LoginScreen.dart';
import '../../features/auth/presentation/RegisterScreen.dart';
import '../../features/profile/presentation/HomeScreen.dart';
import '../../features/mission/presentation/MapNavigationScreen.dart';
import '../../features/mission/presentation/MonumentInfoScreen.dart';
import '../../features/mission/presentation/QuizScreen.dart';
import '../../features/mission/presentation/RouteResultScreen.dart';
import '../../features/routes/presentation/CitySelectionScreen.dart';
import '../../features/routes/presentation/RouteSelectionScreen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String mapNavigation = '/map_navigation';
  static const String monumentInfo = '/monument_info';
  static const String quiz = '/quiz';
  static const String routeResult = '/route_result';
  static const String citySelection = '/city_selection';
  static const String routeSelection = '/route_selection';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const HomeScreen(),
      citySelection: (context) => const CitySelectionScreen(),
      routeSelection: (context) => const RouteSelectionScreen(),
      mapNavigation: (context) => const MapNavigationScreen(),
      monumentInfo: (context) => const MonumentInfoScreen(),
      quiz: (context) => const QuizScreen(),
      routeResult: (context) => const RouteResultScreen(),
    };
  }
}
