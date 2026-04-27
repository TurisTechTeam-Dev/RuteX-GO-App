import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/nav_web/navegacion_web.dart';
import 'package:mobile_app/core/widgets/nav_web/componentes_extras/selector_ciudades_jerarquico.dart';
import 'package:mobile_app/core/widgets/nav_web/tarjeta_lista.dart';
import 'package:mobile_app/features/admin_panel/data/admin_remote_datasource.dart';
import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';

class AdminSidebar extends StatelessWidget {
  final NavTab currentTab;
  final Function(dynamic) onItemSelected;

  const AdminSidebar({
    super.key,
    required this.currentTab,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dataSource = AdminRemoteDataSource();

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
                // TAB 1: EXPLORADOR JERÁRQUICO
                StreamBuilder<List<AdminCityModel>>(
                  stream: dataSource.watchCities(),
                  builder: (context, citySnapshot) {
                    if (citySnapshot.hasError) {
                      return Center(
                        child: Text("Error cities: ${citySnapshot.error}"),
                      );
                    }
                    return StreamBuilder<List<AdminRouteModel>>(
                      stream: dataSource.watchRoutes(),
                      builder: (context, routeSnapshot) {
                        if (routeSnapshot.hasError) {
                          return Center(
                            child: Text("Error routes: ${routeSnapshot.error}"),
                          );
                        }
                        return StreamBuilder<List<AdminPoiModel>>(
                          stream: dataSource.watchPois(),
                          builder: (context, pointSnapshot) {
                            if (pointSnapshot.hasError) {
                              return Center(
                                child: Text(
                                  "Error puntos: ${pointSnapshot.error}",
                                ),
                              );
                            }

                            return StreamBuilder<List<AdminMissionModel>>(
                              stream: dataSource.watchMissions(),
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
                                return SelectorCiudadesJerarquico(
                                  todasLasCiudades: citySnapshot.data!,
                                  todasLasRutas: routeSnapshot.data!,
                                  todasLasPois: pointSnapshot.data!,
                                  todasLasMisiones: missionSnapshot.data!,
                                  currentTab: currentTab,
                                  onEditarCiudad: onItemSelected,
                                  onEditarRuta: onItemSelected,
                                  onEditarPoi: onItemSelected,
                                  onEditarMision: onItemSelected,
                                  onEliminarCiudad: (item) =>
                                      dataSource.deleteCity(item.id!),
                                  onEliminarRuta: (item) =>
                                      dataSource.deleteRoute(item.id!),
                                  onEliminarPoi: (item) =>
                                      dataSource.deletePoi(item.id!),
                                  onEliminarMision: (item) =>
                                      dataSource.deleteMission(item.id!),
                                  onNuevaCiudad: () => onItemSelected(null),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                // TAB 2: LISTA PLANA
                AdminFlatList(
                  currentTab: currentTab,
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
