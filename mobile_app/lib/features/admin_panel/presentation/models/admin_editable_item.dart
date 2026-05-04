import '../../data/models/admin_models.dart';
import '../widgets/admin_navbar.dart';

sealed class AdminEditableItem {
  const AdminEditableItem();

  String? get id;
  String get displayName;
  AdminNavTab get tab;

  static AdminEditableItem? fromModel(Object? model) {
    if (model == null) return null;
    if (model is AdminCityModel) return AdminCityItem(model);
    if (model is AdminRouteModel) return AdminRouteItem(model);
    if (model is AdminPoiModel) return AdminPoiItem(model);
    if (model is AdminMissionModel) return AdminMissionItem(model);

    throw ArgumentError.value(model, 'model', 'Unsupported admin item type');
  }
}

class AdminCityItem extends AdminEditableItem {
  final AdminCityModel city;

  const AdminCityItem(this.city);

  @override
  String? get id => city.id;

  @override
  String get displayName => city.name;

  @override
  AdminNavTab get tab => AdminNavTab.cities;
}

class AdminRouteItem extends AdminEditableItem {
  final AdminRouteModel route;

  const AdminRouteItem(this.route);

  @override
  String? get id => route.id;

  @override
  String get displayName => route.name;

  @override
  AdminNavTab get tab => AdminNavTab.routes;
}

class AdminPoiItem extends AdminEditableItem {
  final AdminPoiModel point;

  const AdminPoiItem(this.point);

  @override
  String? get id => point.id;

  @override
  String get displayName => point.name;

  @override
  AdminNavTab get tab => AdminNavTab.pointsOfInterest;
}

class AdminMissionItem extends AdminEditableItem {
  final AdminMissionModel mission;

  const AdminMissionItem(this.mission);

  @override
  String? get id => mission.id;

  @override
  String get displayName => mission.title;

  @override
  AdminNavTab get tab => AdminNavTab.missions;
}
