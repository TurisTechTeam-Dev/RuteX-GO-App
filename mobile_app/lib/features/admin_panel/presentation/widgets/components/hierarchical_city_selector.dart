import 'package:flutter/material.dart';
import 'package:mobile_app/core/utils/text_normalizer.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/admin_navbar.dart';
import 'package:mobile_app/features/admin_panel/data/models/admin_models.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/components/admin_delete_confirmation.dart';
import 'package:mobile_app/features/admin_panel/presentation/widgets/components/admin_empty_state.dart';

class HierarchicalCitySelector extends StatefulWidget {
  final List<AdminCityModel> allCities;
  final List<AdminRouteModel> allRoutes;
  final List<AdminPoiModel> allPois;
  final List<AdminMissionModel> allMissions;
  final AdminNavTab currentTab;
  final Function(AdminCityModel) onEditCity;
  final Function(AdminRouteModel) onEditRoute;
  final Function(AdminPoiModel) onEditPoi;
  final Function(AdminMissionModel) onEditMission;
  final Function(AdminCityModel) onDeleteCity;
  final Function(AdminRouteModel) onDeleteRoute;
  final Function(AdminPoiModel) onDeletePoi;
  final Function(AdminMissionModel) onDeleteMission;
  final VoidCallback onNewCity;

  const HierarchicalCitySelector({
    super.key,
    required this.allCities,
    required this.allRoutes,
    required this.allPois,
    required this.allMissions,
    required this.currentTab,
    required this.onEditCity,
    required this.onEditRoute,
    required this.onEditPoi,
    required this.onEditMission,
    required this.onDeleteCity,
    required this.onDeleteRoute,
    required this.onDeletePoi,
    required this.onDeleteMission,
    required this.onNewCity,
  });

  @override
  State<HierarchicalCitySelector> createState() =>
      _HierarchicalCitySelectorState();
}

class _HierarchicalCitySelectorState extends State<HierarchicalCitySelector> {
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
    // Build the province list from Firestore data
    final provinceNamesFromDb = widget.allCities
        .where(
          (c) =>
              c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.province.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .map((c) => c.province)
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();

    final provinceNames = provinceNamesFromDb.isEmpty && _searchQuery.isEmpty
        ? ['Cáceres', 'Badajoz']
        : provinceNamesFromDb;

    return Column(
      children: [
        _buildSearchField(),
        if (_selectedCity != null || _selectedPoint != null) ...[
          _buildBreadcrumb(),
          const Divider(height: 1),
        ],
        Expanded(child: _buildExplorerBody(provinceNames)),
      ],
    );
  }

  Widget _buildExplorerBody(List<String> provinceNames) {
    // When searching, show flat global results
    if (_searchQuery.isNotEmpty) {
      return _buildSearchResults();
    }

    if (_selectedCity != null) {
      switch (widget.currentTab) {
        case AdminNavTab.cities:
          return _buildSelectedCityMessage(_selectedCity!);
        case AdminNavTab.routes:
          return _buildRouteList(_selectedCity!);
        case AdminNavTab.pointsOfInterest:
          return _buildCityPointList(_selectedCity!);
        case AdminNavTab.missions:
          if (_selectedPoint != null) {
            return _buildPointMissionList(_selectedPoint!);
          }
          return _buildCityPointList(_selectedCity!);
      }
    }

    // Initial view: show province accordion
    return ListView.builder(
      itemCount: provinceNames.length,
      itemBuilder: (context, index) {
        final provinceName = provinceNames[index];
        final provinceCities = widget.allCities
            .where(
              (c) =>
                  TextNormalizer.toAsciiSlug(c.province) ==
                  TextNormalizer.toAsciiSlug(provinceName),
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
            key: PageStorageKey(provinceName),
            leading: const Icon(Icons.map, color: Color(0xFF6B7249)),
            title: Text(
              provinceName.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 1.1,
              ),
            ),
            children: provinceCities.isEmpty
                ? [const ListTile(title: Text("No hay ciudades registrados"))]
                : provinceCities
                      .where(
                        (c) => c.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .map((city) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(city.name),
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
                                onPressed: () => widget.onEditCity(city),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => showAdminDeleteConfirmation(
                                  context: context,
                                  itemName: city.name,
                                  warnCannotUndo: true,
                                  onConfirm: () => widget.onDeleteCity(city),
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _selectCity(city),
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

  Widget _buildRouteList(AdminCityModel city) {
    final filteredRoutes = widget.allRoutes
        .where(
          (r) =>
              _belongsToCity(r.cityId, city) &&
              r.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    if (filteredRoutes.isEmpty) {
      return AdminEmptyState(
        message: "No hay rutas registradas en esta ciudad",
        iconSize: 48,
        onBack: () => setState(() => _selectedCity = null),
      );
    }

    return ListView.builder(
      itemCount: filteredRoutes.length,
      itemBuilder: (context, index) {
        final route = filteredRoutes[index];
        return ListTile(
          leading: const Icon(Icons.directions_run, color: Colors.orange),
          title: Text(route.name),
          subtitle: Text('${route.duration} - ${route.difficulty}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => widget.onEditRoute(route),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 18,
                  color: Colors.redAccent,
                ),
                onPressed: () => showAdminDeleteConfirmation(
                  context: context,
                  itemName: route.name,
                  warnCannotUndo: true,
                  onConfirm: () => widget.onDeleteRoute(route),
                ),
              ),
            ],
          ),
          onTap: () => widget.onEditRoute(route),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildPointList(AdminRouteModel route) {
    final poiIds = route.pointIds.toSet();
    final filteredPois = widget.allPois
        .where(
          (p) =>
              poiIds.contains(p.id) &&
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    if (filteredPois.isEmpty) {
      return AdminEmptyState(
        message: "Esta ruta no tiene puntos de interés asociados",
        iconSize: 48,
        onBack: () => setState(() => _selectedCity = null),
      );
    }

    return ListView.builder(
      itemCount: filteredPois.length,
      itemBuilder: (context, index) {
        final poi = filteredPois[index];
        return ListTile(
          leading: const Icon(Icons.location_on, color: Colors.redAccent),
          title: Text(poi.name),
          subtitle: Text(
            poi.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => widget.onEditPoi(poi),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 18,
                  color: Colors.redAccent,
                ),
                onPressed: () => showAdminDeleteConfirmation(
                  context: context,
                  itemName: poi.name,
                  warnCannotUndo: true,
                  onConfirm: () => widget.onDeletePoi(poi),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final query = _searchQuery.toLowerCase();

    switch (widget.currentTab) {
      case AdminNavTab.cities:
        final results = widget.allCities
            .where((c) => c.name.toLowerCase().contains(query))
            .toList();
        return _buildSearchList(
          results,
          (item) => item.name,
          (item) => item.province,
          Icons.location_city,
          (item) => widget.onEditCity(item),
          (item) {
            setState(() {
              _selectedCity = item;
              _searchQuery = '';
              _searchCtrl.clear();
            });
          },
        );

      case AdminNavTab.routes:
        final results = widget.allRoutes
            .where((r) => r.name.toLowerCase().contains(query))
            .toList();
        return _buildSearchList(
          results,
          (item) => item.name,
          (item) => item.duration,
          Icons.directions_run,
          (item) => widget.onEditRoute(item),
          (item) => widget.onEditRoute(item),
        );

      case AdminNavTab.pointsOfInterest:
        final results = widget.allPois
            .where((p) => p.name.toLowerCase().contains(query))
            .toList();
        return _buildSearchList(
          results,
          (item) => item.name,
          (item) => item.description,
          Icons.location_on,
          (item) => widget.onEditPoi(item),
          (item) {}, // No drill-down for POIs
        );

      case AdminNavTab.missions:
        final results = widget.allMissions
            .where((mission) => mission.title.toLowerCase().contains(query))
            .toList();
        return _buildSearchList(
          results,
          (item) => item.title,
          (item) => _pointNameForMission(item),
          Icons.assignment,
          (item) => widget.onEditMission(item),
          (item) => widget.onEditMission(item),
        );
    }
  }

  Widget _buildSearchList<T extends Object>(
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
                onPressed: () => showAdminDeleteConfirmation(
                  context: context,
                  itemName: title(item),
                  warnCannotUndo: true,
                  onConfirm: () => _deleteSearchResult(item),
                ),
              ),
            ],
          ),
          onTap: () => onTap(item),
        );
      },
    );
  }

  void _deleteSearchResult(Object item) {
    if (item is AdminCityModel) widget.onDeleteCity(item);
    if (item is AdminRouteModel) widget.onDeleteRoute(item);
    if (item is AdminPoiModel) widget.onDeletePoi(item);
    if (item is AdminMissionModel) widget.onDeleteMission(item);
  }

  Widget _buildCityPointList(AdminCityModel city) {
    final routePoiIds = widget.allRoutes
        .where((route) => _belongsToCity(route.cityId, city))
        .expand((route) => route.pointIds)
        .toSet();

    final filteredPois = widget.allPois
        .where(
          (p) =>
              (_belongsToCity(p.cityId, city) ||
                  (p.id != null && routePoiIds.contains(p.id))) &&
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    if (filteredPois.isEmpty) {
      return AdminEmptyState(
        message: "No hay puntos de interés registrados en esta ciudad",
        iconSize: 48,
        onBack: () => setState(() => _selectedCity = null),
      );
    }

    return ListView.builder(
      itemCount: filteredPois.length,
      itemBuilder: (context, index) {
        final poi = filteredPois[index];
        final isMissionTab = widget.currentTab == AdminNavTab.missions;
        return ListTile(
          leading: const Icon(Icons.location_on, color: Colors.redAccent),
          title: Text(poi.name),
          subtitle: Text(
            poi.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => widget.onEditPoi(poi),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 18,
                  color: Colors.redAccent,
                ),
                onPressed: () => showAdminDeleteConfirmation(
                  context: context,
                  itemName: poi.name,
                  warnCannotUndo: true,
                  onConfirm: () => widget.onDeletePoi(poi),
                ),
              ),
            ],
          ),
          onTap: isMissionTab
              ? () => setState(() => _selectedPoint = poi)
              : () => widget.onEditPoi(poi),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildCityMissionList(AdminCityModel city) {
    final poiIds = _pointIdsForCity(city);
    final missions = widget.allMissions
        .where((mission) => poiIds.contains(mission.pointId))
        .toList();

    if (missions.isEmpty) {
      return AdminEmptyState(
        message: "No hay misiones registradas en esta ciudad",
        onBack: () => setState(() => _selectedCity = null),
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => widget.onEditMission(mission),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.delete,
                  size: 18,
                  color: Colors.redAccent,
                ),
                onPressed: () => showAdminDeleteConfirmation(
                  context: context,
                  itemName: mission.title,
                  warnCannotUndo: true,
                  onConfirm: () => widget.onDeleteMission(mission),
                ),
              ),
            ],
          ),
          onTap: () => widget.onEditMission(mission),
        );
      },
    );
  }

  Widget _buildPointMissionList(AdminPoiModel point) {
    final pointId = point.id ?? '';
    final missions = widget.allMissions
        .where((mission) => mission.pointId == pointId)
        .toList();

    if (missions.isEmpty) {
      return AdminEmptyState(
        message: "No hay misiones registradas en este punto",
        onBack: () => setState(() => _selectedPoint = null),
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => widget.onEditMission(mission),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.delete,
                  size: 18,
                  color: Colors.redAccent,
                ),
                onPressed: () => showAdminDeleteConfirmation(
                  context: context,
                  itemName: mission.title,
                  warnCannotUndo: true,
                  onConfirm: () => widget.onDeleteMission(mission),
                ),
              ),
            ],
          ),
          onTap: () => widget.onEditMission(mission),
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

  void _selectCity(AdminCityModel city) {
    if (widget.currentTab == AdminNavTab.cities) {
      widget.onEditCity(city);
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
    final routePoiIds = widget.allRoutes
        .where((route) => _belongsToCity(route.cityId, city))
        .expand((route) => route.pointIds);

    final directPoiIds = widget.allPois
        .where((poi) => _belongsToCity(poi.cityId, city))
        .map((poi) => poi.id ?? '')
        .where((id) => id.isNotEmpty);

    return {...routePoiIds, ...directPoiIds};
  }

  String _pointNameForMission(AdminMissionModel mission) {
    for (final poi in widget.allPois) {
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
