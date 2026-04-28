import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';
import 'package:mobile_app/features/admin_panel/data/admin_remote_datasource.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/admin_navbar.dart';

import 'package:mobile_app/features/admin_panel/presentation/widgets/route_form.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/forms/city_form.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/forms/mission_form.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/forms/point_interest_form.dart';
import 'package:mobile_app/features/admin_panel/presentation/models/admin_editable_item.dart';

class AdminFormRouter extends StatelessWidget {
  final AdminNavTab tab;
  final AdminEditableItem? itemToEdit;
  final AdminRemoteDataSource dataSource;
  final Future<void> Function(Future<void> Function()) onSave;
  final VoidCallback onResetSelection;

  const AdminFormRouter({
    super.key,
    required this.tab,
    required this.itemToEdit,
    required this.dataSource,
    required this.onSave,
    required this.onResetSelection,
  });

  @override
  Widget build(BuildContext context) {
    final uniqueKey = ValueKey('${tab.index}_${itemToEdit?.id ?? 'nuevo'}');

    // Always show the form for the active tab.
    switch (tab) {
      case AdminNavTab.cities:
        return CityForm(
          key: uniqueKey,
          city: itemToEdit is AdminCityItem
              ? (itemToEdit as AdminCityItem).city
              : null,
          onSave: (city) => onSave(() => dataSource.saveCity(city)),
          onCancel: onResetSelection,
          onUploadImage: (Uint8List bytes, String name) =>
              dataSource.uploadFile(bytes, 'Contenido/Ciudades', name),
        );
      case AdminNavTab.routes:
        return _buildRouteFormWithData(uniqueKey);
      case AdminNavTab.pointsOfInterest:
        return _buildPointFormWithData(uniqueKey);
      case AdminNavTab.missions:
        return _buildMissionFormWithData(uniqueKey);
    }
  }

  // Routes form
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
                  route: itemToEdit is AdminRouteItem
                      ? (itemToEdit as AdminRouteItem).route
                      : null,
                  availableCities: citySnapshot.data!,
                  availablePoints: pointSnapshot.data!,
                  availableMissions: missionSnapshot.data!,
                  onSave: (route) => onSave(() => dataSource.saveRoute(route)),
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
          point: itemToEdit is AdminPoiItem
              ? (itemToEdit as AdminPoiItem).point
              : null,
          cities: snapshot.data!,
          onSave: (point) => onSave(() => dataSource.savePoi(point)),
          onUploadImage: (Uint8List bytes, String name) =>
              dataSource.uploadFile(bytes, 'Contenido/Puntos de Interes', name),
        );
      },
    );
  }

  // Missions form
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
                      mission: itemToEdit is AdminMissionItem
                          ? (itemToEdit as AdminMissionItem).mission
                          : null,
                      availablePoints: pointSnapshot.data!,
                      existingMissions: missionSnapshot.data!,
                      cities: citySnapshot.data!,
                      routes: routeSnapshot.data!,
                      onSave: (mission) =>
                          onSave(() => dataSource.saveMission(mission)),
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
