import 'package:flutter/material.dart';
import 'package:mobile_app/core/utils/text_normalizer.dart';
import 'package:mobile_app/core/widgets/nav_web/navegacion_web.dart';
import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';

class SelectorCiudadesJerarquico extends StatefulWidget {
  final List<AdminCityModel> todasLasCiudades;
  final List<AdminRouteModel> todasLasRutas;
  final List<AdminPoiModel> todasLasPois;
  final List<AdminMissionModel> todasLasMisiones;
  final NavTab currentTab;
  final Function(AdminCityModel) onEditarCiudad;
  final Function(AdminRouteModel) onEditarRuta;
  final Function(AdminPoiModel) onEditarPoi;
  final Function(AdminMissionModel) onEditarMision;
  final Function(AdminCityModel) onEliminarCiudad;
  final Function(AdminRouteModel) onEliminarRuta;
  final Function(AdminPoiModel) onEliminarPoi;
  final Function(AdminMissionModel) onEliminarMision;
  final VoidCallback onNuevaCiudad;

  const SelectorCiudadesJerarquico({
    super.key,
    required this.todasLasCiudades,
    required this.todasLasRutas,
    required this.todasLasPois,
    required this.todasLasMisiones,
    required this.currentTab,
    required this.onEditarCiudad,
    required this.onEditarRuta,
    required this.onEditarPoi,
    required this.onEditarMision,
    required this.onEliminarCiudad,
    required this.onEliminarRuta,
    required this.onEliminarPoi,
    required this.onEliminarMision,
    required this.onNuevaCiudad,
  });

  @override
  State<SelectorCiudadesJerarquico> createState() =>
      _SelectorCiudadesJerarquicoState();
}

class _SelectorCiudadesJerarquicoState
    extends State<SelectorCiudadesJerarquico> {
  AdminCityModel? _selectedCity;
  AdminPoiModel? _selectedPoint;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos las provincias de la base de datos
    final provinciasDb = widget.todasLasCiudades
        .where(
          (c) =>
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.province.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .map((c) => c.province)
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();

    final provincias = provinciasDb.isEmpty && _searchQuery.isEmpty
        ? ['Cáceres', 'Badajoz']
        : provinciasDb;

    return Column(
      children: [
        _buildSearchField(),
        if (_selectedCity != null || _selectedPoint != null) ...[
          _buildBreadcrumb(),
          const Divider(height: 1),
        ],
        Expanded(child: _buildExplorerBody(provincias)),
      ],
    );
  }

  Widget _buildExplorerBody(List<String> provincias) {
    // NUEVO: Si hay búsqueda, mostrar resultados planos globales
    if (_searchQuery.isNotEmpty) {
      return _buildSearchResults();
    }

    if (_selectedCity != null) {
      switch (widget.currentTab) {
        case NavTab.cities:
          return _buildSelectedCityMessage(_selectedCity!);
        case NavTab.routes:
          return _buildRouteList(_selectedCity!);
        case NavTab.pointsOfInterest:
          return _buildCityPointList(_selectedCity!);
        case NavTab.missions:
          if (_selectedPoint != null) {
            return _buildPointMissionList(_selectedPoint!);
          }
          return _buildCityPointList(_selectedCity!);
      }
    }

    // SI ESTAMOS EN LA VISTA INICIAL, MOSTRAR ACORDEÓN DE PROVINCIAS
    return ListView.builder(
      itemCount: provincias.length,
      itemBuilder: (context, index) {
        final prov = provincias[index];
        final ciudadesDeProv = widget.todasLasCiudades
            .where(
              (c) =>
                  TextNormalizer.toAsciiSlug(c.province) ==
                  TextNormalizer.toAsciiSlug(prov),
            )
            .toList();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: ExpansionTile(
            key: PageStorageKey(prov),
            leading: const Icon(Icons.map, color: Color(0xFF6B7249)),
            title: Text(
              prov.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.1,
              ),
            ),
            children: ciudadesDeProv.isEmpty
                ? [const ListTile(title: Text("No hay ciudades registrados"))]
                : ciudadesDeProv
                      .where(
                        (c) => c.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .map((ciudad) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(ciudad.name),
                          leading: const Icon(
                            Icons.location_city,
                            size: 20,
                            color: Colors.blueGrey,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () => widget.onEditarCiudad(ciudad),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _confirmDelete(
                                  context,
                                  ciudad.name,
                                  () => widget.onEliminarCiudad(ciudad),
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _selectCity(ciudad),
                        );
                      })
                      .toList(),
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: "Buscar...",
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7249)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6B7249), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
      color: Colors.grey.shade100,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () {
              setState(() {
                if (_selectedPoint != null) {
                  _selectedPoint = null;
                } else {
                  _selectedCity = null;
                }
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (_selectedCity != null)
                    _buildBreadcrumbItem(_selectedCity!.name, () {
                      setState(() => _selectedPoint = null);
                    }),
                  if (_selectedPoint != null) ...[
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.grey,
                    ),
                    _buildBreadcrumbItem(_selectedPoint!.name, () {}),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbItem(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF6B7249),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteList(AdminCityModel ciudad) {
    final rutasFiltradas = widget.todasLasRutas
        .where(
          (r) =>
              _belongsToCity(r.cityId, ciudad) &&
              r.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    if (rutasFiltradas.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No hay rutas registradas en esta ciudad",
            style: TextStyle(color: Colors.grey),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedCity = null),
            child: const Text("Volver"),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: rutasFiltradas.length,
      itemBuilder: (context, index) {
        final ruta = rutasFiltradas[index];
        return ListTile(
          leading: const Icon(Icons.directions_run, color: Colors.orange),
          title: Text(ruta.name),
          subtitle: Text('${ruta.duration} - ${ruta.difficulty}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => widget.onEditarRuta(ruta),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 18,
                  color: Colors.redAccent,
                ),
                onPressed: () => _confirmDelete(
                  context,
                  ruta.name,
                  () => widget.onEliminarRuta(ruta),
                ),
              ),
            ],
          ),
          onTap: () => widget.onEditarRuta(ruta),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildPointList(AdminRouteModel ruta) {
    final poisIds = ruta.pointIds.toSet();
    final poisFiltradas = widget.todasLasPois
        .where(
          (p) =>
              poisIds.contains(p.id) &&
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    if (poisFiltradas.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "Esta ruta no tiene puntos de interés asociados",
            style: TextStyle(color: Colors.grey),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedCity = null),
            child: const Text("Volver"),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: poisFiltradas.length,
      itemBuilder: (context, index) {
        final poi = poisFiltradas[index];
        return ListTile(
          leading: const Icon(Icons.location_on, color: Colors.redAccent),
          title: Text(poi.name),
          subtitle: Text(
            poi.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => widget.onEditarPoi(poi),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final query = _searchQuery.toLowerCase();

    switch (widget.currentTab) {
      case NavTab.cities:
        final resultados = widget.todasLasCiudades
            .where((c) => c.name.toLowerCase().contains(query))
            .toList();
        return _buildSearchList(
          resultados,
          (item) => item.name,
          (item) => item.province,
          Icons.location_city,
          (item) => widget.onEditarCiudad(item),
          (item) {
            setState(() {
              _selectedCity = item;
              _searchQuery = '';
              _searchCtrl.clear();
            });
          },
        );

      case NavTab.routes:
        final resultados = widget.todasLasRutas
            .where((r) => r.name.toLowerCase().contains(query))
            .toList();
        return _buildSearchList(
          resultados,
          (item) => item.name,
          (item) => item.duration,
          Icons.directions_run,
          (item) => widget.onEditarRuta(item),
          (item) => widget.onEditarRuta(item),
        );

      case NavTab.pointsOfInterest:
        final resultados = widget.todasLasPois
            .where((p) => p.name.toLowerCase().contains(query))
            .toList();
        return _buildSearchList(
          resultados,
          (item) => item.name,
          (item) => item.description,
          Icons.location_on,
          (item) => widget.onEditarPoi(item),
          (item) {}, // No drill-down para POIs
        );

      case NavTab.missions:
        final resultados = widget.todasLasMisiones
            .where((mission) => mission.title.toLowerCase().contains(query))
            .toList();
        return _buildSearchList(
          resultados,
          (item) => item.title,
          (item) => _pointNameForMission(item),
          Icons.assignment,
          (item) => widget.onEditarMision(item),
          (item) => widget.onEditarMision(item),
        );
    }
  }

  Widget _buildSearchList<T>(
    List<T> items,
    String Function(T) title,
    String Function(T) subtitle,
    IconData icon,
    Function(T) onEdit,
    Function(T) onTap,
  ) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "No se encontraron resultados",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Icon(icon, color: const Color(0xFF6B7249)),
          title: Text(
            title(item),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            subtitle(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => onEdit(item),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 18,
                  color: Colors.redAccent,
                ),
                onPressed: () => _confirmDelete(context, title(item), () {
                  if (item is AdminCityModel) widget.onEliminarCiudad(item);
                  if (item is AdminRouteModel) widget.onEliminarRuta(item);
                  if (item is AdminPoiModel) widget.onEliminarPoi(item);
                  if (item is AdminMissionModel) widget.onEliminarMision(item);
                }),
              ),
            ],
          ),
          onTap: () => onTap(item),
        );
      },
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
        content: Text(
          "¿Estás seguro de que quieres eliminar '$nombre'? Esta acción no se puede deshacer.",
        ),
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

  Widget _buildCityPointList(AdminCityModel ciudad) {
    final routePoiIds = widget.todasLasRutas
        .where((route) => _belongsToCity(route.cityId, ciudad))
        .expand((route) => route.pointIds)
        .toSet();

    final poisFiltradas = widget.todasLasPois
        .where(
          (p) =>
              (_belongsToCity(p.cityId, ciudad) ||
                  (p.id != null && routePoiIds.contains(p.id))) &&
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    if (poisFiltradas.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No hay puntos de interés registrados en esta ciudad",
            style: TextStyle(color: Colors.grey),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedCity = null),
            child: const Text("Volver"),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: poisFiltradas.length,
      itemBuilder: (context, index) {
        final poi = poisFiltradas[index];
        final isMissionTab = widget.currentTab == NavTab.missions;
        return ListTile(
          leading: const Icon(Icons.location_on, color: Colors.redAccent),
          title: Text(poi.name),
          subtitle: Text(
            poi.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => widget.onEditarPoi(poi),
          ),
          onTap: isMissionTab
              ? () => setState(() => _selectedPoint = poi)
              : () => widget.onEditarPoi(poi),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildCityMissionList(AdminCityModel ciudad) {
    final poiIds = _pointIdsForCity(ciudad);
    final missions = widget.todasLasMisiones
        .where((mission) => poiIds.contains(mission.pointId))
        .toList();

    if (missions.isEmpty) {
      return _buildEmptyListMessage(
        "No hay misiones registradas en esta ciudad",
        () => setState(() => _selectedCity = null),
      );
    }

    return ListView.builder(
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          leading: const Icon(Icons.assignment, color: Color(0xFF6B7249)),
          title: Text(mission.title),
          subtitle: Text(_pointNameForMission(mission)),
          trailing: IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => widget.onEditarMision(mission),
          ),
          onTap: () => widget.onEditarMision(mission),
        );
      },
    );
  }

  Widget _buildPointMissionList(AdminPoiModel point) {
    final pointId = point.id ?? '';
    final missions = widget.todasLasMisiones
        .where((mission) => mission.pointId == pointId)
        .toList();

    if (missions.isEmpty) {
      return _buildEmptyListMessage(
        "No hay misiones registradas en este punto",
        () => setState(() => _selectedPoint = null),
      );
    }

    return ListView.builder(
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          leading: const Icon(Icons.assignment, color: Color(0xFF6B7249)),
          title: Text(mission.title),
          subtitle: Text(point.name),
          trailing: IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => widget.onEditarMision(mission),
          ),
          onTap: () => widget.onEditarMision(mission),
        );
      },
    );
  }

  Widget _buildSelectedCityMessage(AdminCityModel city) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Pulsa el icono de editar de ${city.name} para modificar la ciudad.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildEmptyListMessage(String text, VoidCallback onBack) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.info_outline, size: 42, color: Colors.grey),
        const SizedBox(height: 12),
        Text(text, style: const TextStyle(color: Colors.grey)),
        TextButton(onPressed: onBack, child: const Text("Volver")),
      ],
    );
  }

  void _selectCity(AdminCityModel city) {
    if (widget.currentTab == NavTab.cities) {
      widget.onEditarCiudad(city);
      return;
    }

    setState(() {
      _selectedCity = city;
      _selectedPoint = null;
      _searchQuery = '';
      _searchCtrl.clear();
    });
  }

  Set<String> _pointIdsForCity(AdminCityModel city) {
    final routePoiIds = widget.todasLasRutas
        .where((route) => _belongsToCity(route.cityId, city))
        .expand((route) => route.pointIds);

    final directPoiIds = widget.todasLasPois
        .where((poi) => _belongsToCity(poi.cityId, city))
        .map((poi) => poi.id ?? '')
        .where((id) => id.isNotEmpty);

    return {...routePoiIds, ...directPoiIds};
  }

  String _pointNameForMission(AdminMissionModel mission) {
    for (final poi in widget.todasLasPois) {
      if (poi.id == mission.pointId) {
        return poi.name;
      }
    }

    return mission.pointId;
  }

  bool _belongsToCity(String rawCityValue, AdminCityModel city) {
    final normalizedValue = TextNormalizer.toAsciiSlug(rawCityValue);
    final cityId = TextNormalizer.toAsciiSlug(city.id ?? '');
    final cityName = TextNormalizer.toAsciiSlug(city.name);

    return normalizedValue.isNotEmpty &&
        (normalizedValue == cityId || normalizedValue == cityName);
  }
}
