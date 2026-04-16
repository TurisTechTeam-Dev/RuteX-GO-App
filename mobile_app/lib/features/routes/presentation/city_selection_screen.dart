import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/bars/top_app_bar.dart';
import '../domain/usescases/routes_uses_cases.dart';
import 'widgets/city_selection_content.dart';

class CitySelectionScreen extends StatelessWidget {
  final RoutesUsesCases routesUsesCases;

  const CitySelectionScreen({super.key, required this.routesUsesCases});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(showBack: true),
      endDrawer: const CustomDrawer(),
      body: CitySelectionContent(routesUsesCases: routesUsesCases),
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
