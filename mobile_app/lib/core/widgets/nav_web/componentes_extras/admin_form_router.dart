import 'package:flutter/material.dart';
import 'dart:typed_data';

// Infraestructura y Modelos
import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';
import 'package:mobile_app/features/admin_panel/data/admin_remote_datasource.dart';
import 'package:mobile_app/core/widgets/nav_web/navegacion_web.dart';

// Componentes de navegación y selectores

// Formularios (Ajusta estas rutas si tus archivos se llaman distinto)
import 'package:mobile_app/core/widgets/nav_web/formulario_ruta.dart';
import 'package:mobile_app/core/widgets/nav_web/formularios/formulario_ciudades.dart';
import 'package:mobile_app/core/widgets/nav_web/formularios/formulario_mision.dart'; // Verifica si es formulario_mision.dart
import 'package:mobile_app/core/widgets/nav_web/formularios/formulario_punto_interes.dart';

class AdminFormRouter extends StatelessWidget {
  final NavTab tab;
  final dynamic itemToEdit;
  final AdminRemoteDataSource dataSource;
  final Function(dynamic, Future<void> Function(dynamic)) onSave;
  final VoidCallback onResetSelection;
  final Function(dynamic) onItemSelected;

  const AdminFormRouter({
    super.key,
    required this.tab,
    required this.itemToEdit,
    required this.dataSource,
    required this.onSave,
    required this.onResetSelection,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    // La key única asegura que el formulario se resetee al cambiar de item
    final uniqueKey = ValueKey('${tab.index}_${itemToEdit?.id ?? 'nuevo'}');

    // SIEMPRE MOSTRAR EL FORMULARIO CORRESPONDIENTE AL TAB ACTUAL
    switch (tab) {
      case NavTab.cities:
        return CityForm(
          key: uniqueKey,
          city: itemToEdit is AdminCityModel ? itemToEdit : null,
          onSave: (data) =>
              onSave(data, (val) => dataSource.saveCity(val as AdminCityModel)),
          onCancel: onResetSelection,
          onUploadImage: (Uint8List bytes, String name) =>
              dataSource.uploadFile(bytes, 'Contenido/Ciudades', name),
        );
      case NavTab.routes:
        return _buildRouteFormWithData(uniqueKey);
      case NavTab.pointsOfInterest:
        return _buildPointFormWithData(uniqueKey);
      case NavTab.missions:
        return _buildMissionFormWithData(uniqueKey);
    }
  }

  // --- 2. FORMULARIO DE RUTAS ---
  Widget _buildRouteFormWithData(Key key) {
    return StreamBuilder<List<AdminCityModel>>(
      stream: dataSource.watchCities(),
      builder: (context, citySnapshot) {
        return StreamBuilder<List<AdminPoiModel>>(
          stream: dataSource.watchPois(),
          builder: (context, pointSnapshot) {
            return StreamBuilder<List<AdminMissionModel>>(
              stream: dataSource.watchMissions(),
              builder: (context, missionSnapshot) {
                if (!citySnapshot.hasData ||
                    !pointSnapshot.hasData ||
                    !missionSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return RouteForm(
                  key: key,
                  route: itemToEdit is AdminRouteModel
                      ? itemToEdit as AdminRouteModel
                      : null,
                  availableCities: citySnapshot.data!,
                  availablePoints: pointSnapshot.data!,
                  availableMissions: missionSnapshot.data!,
                  onSave: (data) => onSave(
                    data,
                    (val) => dataSource.saveRoute(val as AdminRouteModel),
                  ),
                  onUploadImage: (Uint8List bytes, String name) =>
                      dataSource.uploadFile(bytes, 'Contenido/Rutas', name),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- 3. FORMULARIO DE PUNTOS DE INTERÉS ---
  Widget _buildPointFormWithData(Key key) {
    return StreamBuilder<List<AdminCityModel>>(
      stream: dataSource.watchCities(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return PointInterestForm(
          key: key,
          point: itemToEdit is AdminPoiModel
              ? itemToEdit as AdminPoiModel
              : null,
          cities: snapshot.data!,
          onSave: (data) =>
              onSave(data, (val) => dataSource.savePoi(val as AdminPoiModel)),
          onUploadImage: (Uint8List bytes, String name) =>
              dataSource.uploadFile(bytes, 'Contenido/Puntos de Interes', name),
        );
      },
    );
  }

  // --- 4. FORMULARIO DE MISIONES ---
  Widget _buildMissionFormWithData(Key key) {
    return StreamBuilder<List<AdminCityModel>>(
      stream: dataSource.watchCities(),
      builder: (context, citySnapshot) {
        return StreamBuilder<List<AdminPoiModel>>(
          stream: dataSource.watchPois(),
          builder: (context, pointSnapshot) {
            return StreamBuilder<List<AdminRouteModel>>(
              stream: dataSource.watchRoutes(),
              builder: (context, routeSnapshot) {
                return StreamBuilder<List<AdminMissionModel>>(
                  stream: dataSource.watchMissions(),
                  builder: (context, missionSnapshot) {
                    if (!citySnapshot.hasData ||
                        !pointSnapshot.hasData ||
                        !routeSnapshot.hasData ||
                        !missionSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return MissionForm(
                      key: key,
                      mission: itemToEdit is AdminMissionModel
                          ? itemToEdit as AdminMissionModel
                          : null,
                      availablePoints: pointSnapshot.data!,
                      existingMissions: missionSnapshot.data!,
                      cities: citySnapshot.data!,
                      routes: routeSnapshot.data!,
                      onSave: (data) => onSave(
                        data,
                        (val) =>
                            dataSource.saveMission(val as AdminMissionModel),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
