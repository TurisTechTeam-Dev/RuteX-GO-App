import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/bars/top_app_bar.dart';
import '../domain/usecases/routes_use_cases.dart';
import 'widgets/route_selection_content.dart';

class RouteSelectionScreen extends StatelessWidget {
  final RoutesUseCases routesUseCases;
  final Set<String> cityKeys;

  const RouteSelectionScreen({
    super.key,
    required this.routesUseCases,
    required this.cityKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(showBack: true),
      endDrawer: const CustomDrawer(),
      body: RouteSelectionContent(
        routesUseCases: routesUseCases,
        cityKeys: cityKeys,
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.negroTexto, width: 2),
          ),
        ),
        child: const SafeArea(child: SizedBox()),
      ),
    );
  }
}
