import 'package:flutter/material.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/admin_navbar.dart';
import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';
import 'package:mobile_app/features/admin_panel/domain/usecases/admin_use_cases.dart';
import 'package:mobile_app/features/admin_panel/presentation/models/admin_editable_item.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/components/admin_delete_confirmation.dart';

class AdminFlatList extends StatelessWidget {
  final AdminNavTab currentTab;
  final AdminUseCases adminUseCases;
  final ValueChanged<AdminEditableItem?> onItemSelected;

  const AdminFlatList({
    super.key,
    required this.currentTab,
    required this.adminUseCases,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B7249),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => onItemSelected(null),
            icon: const Icon(Icons.add),
            label: Text("Añadir ${_getSingularName()}"),
          ),
        ),
        const Divider(height: 1),

        Expanded(
          child: StreamBuilder(
            stream: _getStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6B7249)),
                );
              }

              final items = _editableItemsFrom(snapshot.data);

              if (items.isEmpty) {
                return Center(
                  child: Text(
                    "No hay ${_getSingularName().toLowerCase()}s aún",
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 15, endIndent: 15),
                itemBuilder: (context, i) {
                  final item = items[i];
                  final displayText = item.displayName.isEmpty
                      ? "Sin nombre"
                      : item.displayName;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    title: Text(
                      displayText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => showAdminDeleteConfirmation(
                        context: context,
                        itemName: displayText,
                        onConfirm: () => _deleteItem(item),
                      ),
                    ),
                    onTap: () => onItemSelected(item),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<List<Object>> _getStream() {
    switch (currentTab) {
      case AdminNavTab.cities:
        return adminUseCases.watchCities();
      case AdminNavTab.routes:
        return adminUseCases.watchRoutes();
      case AdminNavTab.pointsOfInterest:
        return adminUseCases.watchPois();
      case AdminNavTab.missions:
        return adminUseCases.watchMissions();
    }
  }

  List<AdminEditableItem> _editableItemsFrom(Object? data) {
    if (data is List<AdminCityModel>) {
      return data.map(AdminCityItem.new).toList();
    }
    if (data is List<AdminRouteModel>) {
      return data.map(AdminRouteItem.new).toList();
    }
    if (data is List<AdminPoiModel>) {
      return data.map(AdminPoiItem.new).toList();
    }
    if (data is List<AdminMissionModel>) {
      return data.map(AdminMissionItem.new).toList();
    }
    return const <AdminEditableItem>[];
  }

  void _deleteItem(AdminEditableItem item) {
    switch (item) {
      case AdminCityItem(:final city):
        adminUseCases.deleteCity(city.id!);
      case AdminRouteItem(:final route):
        adminUseCases.deleteRoute(route.id!);
      case AdminPoiItem(:final point):
        adminUseCases.deletePoi(point.id!);
      case AdminMissionItem(:final mission):
        adminUseCases.deleteMission(mission.id!);
    }
  }

  String _getSingularName() {
    switch (currentTab) {
      case AdminNavTab.cities:
        return "Ciudad";
      case AdminNavTab.routes:
        return "Ruta";
      case AdminNavTab.pointsOfInterest:
        return "Punto de Interés";
      case AdminNavTab.missions:
        return "Misión";
    }
  }
}
