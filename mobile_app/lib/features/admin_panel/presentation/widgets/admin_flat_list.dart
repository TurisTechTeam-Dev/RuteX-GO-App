import 'package:flutter/material.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/admin_navbar.dart';
import 'package:mobile_app/features/admin_panel/data/admin_remote_datasource.dart';
import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';

class AdminFlatList extends StatelessWidget {
  final AdminNavTab currentTab;
  final Function(dynamic) onItemSelected;

  const AdminFlatList({
    super.key,
    required this.currentTab,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dataSource = AdminRemoteDataSource();

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
            stream: _getStream(dataSource),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6B7249)),
                );
              }

              final items = snapshot.data as List;

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

                  String displayText = "";
                  if (item is AdminMissionModel) {
                    displayText = item.title;
                  } else {
                    displayText = (item as dynamic).name ?? "Sin nombre";
                  }

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
                      onPressed: () => _confirmDelete(context, displayText, () {
                        if (item is AdminCityModel) {
                          dataSource.deleteCity(item.id!);
                        }
                        if (item is AdminRouteModel) {
                          dataSource.deleteRoute(item.id!);
                        }
                        if (item is AdminPoiModel) {
                          dataSource.deletePoi(item.id!);
                        }
                        if (item is AdminMissionModel) {
                          dataSource.deleteMission(item.id!);
                        }
                      }),
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

  Future<void> _confirmDelete(
    BuildContext context,
    String nombre,
    VoidCallback onConfirm,
  ) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar borrado"),
        content: Text("¿Estás seguro de que quieres eliminar '$nombre'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCELAR"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("ELIMINAR"),
          ),
        ],
      ),
    );
    if (result == true) onConfirm();
  }

  Stream _getStream(AdminRemoteDataSource ds) {
    switch (currentTab) {
      case AdminNavTab.cities:
        return ds.watchCities();
      case AdminNavTab.routes:
        return ds.watchRoutes();
      case AdminNavTab.pointsOfInterest:
        return ds.watchPois();
      case AdminNavTab.missions:
        return ds.watchMissions();
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
