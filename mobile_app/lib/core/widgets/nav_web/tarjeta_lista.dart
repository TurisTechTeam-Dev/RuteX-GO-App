import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/nav_web/navegacion_web.dart';
import 'package:mobile_app/features/admin_panel/data/admin_remote_datasource.dart';
import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';

class AdminFlatList extends StatelessWidget {
  final NavTab currentTab;
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
        // Botón superior para añadir nuevo (envía null para abrir formulario vacío)
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

        // Lista dinámica de elementos
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

                  // LÓGICA DE CORRECCIÓN DE NOMBRE/TÍTULO
                  String textoAMostrar = "";
                  if (item is AdminMissionModel) {
                    textoAMostrar = item.title; // Usamos titulo para misiones
                  } else {
                    // Usamos dynamic para acceder a 'nombre' en Ciudades, Rutas y Puntos
                    textoAMostrar = (item as dynamic).name ?? "Sin nombre";
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    title: Text(
                      textoAMostrar,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () =>
                          _confirmDelete(context, textoAMostrar, () {
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

  // Helper para seleccionar el Stream correcto según la pestaña
  Stream _getStream(AdminRemoteDataSource ds) {
    switch (currentTab) {
      case NavTab.cities:
        return ds.watchCities();
      case NavTab.routes:
        return ds.watchRoutes();
      case NavTab.pointsOfInterest:
        return ds.watchPois();
      case NavTab.missions:
        return ds.watchMissions();
    }
  }

  // Helper para el texto del botón
  String _getSingularName() {
    switch (currentTab) {
      case NavTab.cities:
        return "Ciudad";
      case NavTab.routes:
        return "Ruta";
      case NavTab.pointsOfInterest:
        return "Punto de Interés";
      case NavTab.missions:
        return "Misión";
    }
  }
}
