/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/import 'package:flutter/material.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/admin_navbar.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/components/hierarchical_city_selector.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/admin_flat_list.dart';
import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';
import 'package:mobile_app/features/admin_panel/domain/usecases/admin_use_cases.dart';
import 'package:mobile_app/features/admin_panel/presentation/models/admin_editable_item.dart';

class AdminSidebar extends StatelessWidget {
  final AdminNavTab currentTab;
  final AdminUseCases adminUseCases;
  final ValueChanged<AdminEditableItem?> onItemSelected;

  const AdminSidebar({
    super.key,
    required this.currentTab,
    required this.adminUseCases,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: const Color(0xFF6B7249),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF6B7249),
            tabs: [
              Tab(text: "Explorar".toUpperCase()),
              Tab(text: "Todas".toUpperCase()),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                StreamBuilder<List<AdminCityModel>>(
                  stream: adminUseCases.watchCities(),
                  builder: (context, citySnapshot) {
                    if (citySnapshot.hasError) {
                      return Center(
                        child: Text("Error cities: ${citySnapshot.error}"),
                      );
                    }
                    return StreamBuilder<List<AdminRouteModel>>(
                      stream: adminUseCases.watchRoutes(),
                      builder: (context, routeSnapshot) {
                        if (routeSnapshot.hasError) {
                          return Center(
                            child: Text("Error routes: ${routeSnapshot.error}"),
                          );
                        }
                        return StreamBuilder<List<AdminPoiModel>>(
                          stream: adminUseCases.watchPois(),
                          builder: (context, pointSnapshot) {
                            if (pointSnapshot.hasError) {
                              return Center(
                                child: Text(
                                  "Error puntos: ${pointSnapshot.error}",
                                ),
                              );
                            }

                            return StreamBuilder<List<AdminMissionModel>>(
                              stream: adminUseCases.watchMissions(),
                              builder: (context, missionSnapshot) {
                                if (missionSnapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      "Error misiones: ${missionSnapshot.error}",
                                    ),
                                  );
                                }

                                if (!citySnapshot.hasData ||
                                    !routeSnapshot.hasData ||
                                    !pointSnapshot.hasData ||
                                    !missionSnapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return HierarchicalCitySelector(
                                  allCities: citySnapshot.data!,
                                  allRoutes: routeSnapshot.data!,
                                  allPois: pointSnapshot.data!,
                                  allMissions: missionSnapshot.data!,
                                  currentTab: currentTab,
                                  onEditCity: (city) =>
                                      onItemSelected(AdminCityItem(city)),
                                  onEditRoute: (route) =>
                                      onItemSelected(AdminRouteItem(route)),
                                  onEditPoi: (point) =>
                                      onItemSelected(AdminPoiItem(point)),
                                  onEditMission: (mission) =>
                                      onItemSelected(AdminMissionItem(mission)),
                                  onDeleteCity: (item) =>
                                      adminUseCases.deleteCity(item.id!),
                                  onDeleteRoute: (item) =>
                                      adminUseCases.deleteRoute(item.id!),
                                  onDeletePoi: (item) =>
                                      adminUseCases.deletePoi(item.id!),
                                  onDeleteMission: (item) =>
                                      adminUseCases.deleteMission(item.id!),
                                  onNewCity: () => onItemSelected(null),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                AdminFlatList(
                  currentTab: currentTab,
                  adminUseCases: adminUseCases,
                  onItemSelected: onItemSelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
