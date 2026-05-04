/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  static const _valhallaRouteUrl = 'https://valhalla1.openstreetmap.de/route';
  static const _osrmWalkingProfiles = ['foot'];

  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final route = await getNavigationRoute(start, end);
    return route.points;
  }

  Future<NavigationRoute> getNavigationRoute(LatLng start, LatLng end) async {
    if (start.latitude == end.latitude && start.longitude == end.longitude) {
      return NavigationRoute(points: [start, end]);
    }

    final pedestrianRoute = await _getValhallaPedestrianRoute(start, end);
    if (pedestrianRoute.points.isNotEmpty) return pedestrianRoute;

    final osrmRoute = await _getOsrmFallbackRoute(start, end);
    if (osrmRoute.points.isNotEmpty) return osrmRoute;

    debugPrint('Plan B: linea recta al no poder calcular ruta peatonal');
    return NavigationRoute(points: [start, end]);
  }

  Future<NavigationRoute> _getValhallaPedestrianRoute(
    LatLng start,
    LatLng end,
  ) async {
    final url = Uri.parse(_valhallaRouteUrl);
    final body = jsonEncode({
      'locations': [
        {'lat': start.latitude, 'lon': start.longitude},
        {'lat': end.latitude, 'lon': end.longitude},
      ],
      'costing': 'pedestrian',
      'directions_options': {'units': 'kilometers', 'language': 'es-ES'},
    });

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'User-Agent': 'RutexGo_App_Demo',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        debugPrint('Valhalla devolvio ${response.statusCode}');
        return const NavigationRoute(points: []);
      }

      final data = json.decode(response.body);
      final trip = data['trip'];
      if (trip is! Map) return const NavigationRoute(points: []);

      final rawLegs = trip['legs'];
      if (rawLegs is! List || rawLegs.isEmpty) {
        return const NavigationRoute(points: []);
      }

      final points = <LatLng>[];
      final steps = <NavigationStep>[];

      for (final rawLeg in rawLegs) {
        if (rawLeg is! Map) continue;

        final shape = rawLeg['shape']?.toString();
        if (shape == null || shape.isEmpty) continue;

        final legPoints = _decodePolyline(shape, precision: 6);
        points.addAll(legPoints);
        steps.addAll(_valhallaStepsFromLeg(rawLeg, legPoints));
      }

      debugPrint(
        'Ruta peatonal calculada con Valhalla: '
        '${points.length} puntos, ${steps.length} pasos',
      );
      return NavigationRoute(points: points, steps: steps);
    } catch (e) {
      debugPrint('Fallo calculando ruta peatonal con Valhalla: $e');
      return const NavigationRoute(points: []);
    }
  }

  List<NavigationStep> _valhallaStepsFromLeg(
    Map rawLeg,
    List<LatLng> legPoints,
  ) {
    final rawManeuvers = rawLeg['maneuvers'];
    if (rawManeuvers is! List || legPoints.isEmpty) return [];

    final steps = <NavigationStep>[];
    for (final rawManeuver in rawManeuvers) {
      if (rawManeuver is! Map) continue;

      final beginIndex =
          (rawManeuver['begin_shape_index'] as num?)?.toInt() ?? 0;
      final safeIndex = beginIndex.clamp(0, legPoints.length - 1);
      final streetNames = rawManeuver['street_names'];
      final roadName = streetNames is List && streetNames.isNotEmpty
          ? streetNames.first.toString()
          : '';
      final instruction =
          rawManeuver['instruction']?.toString() ??
          _instructionFor(type: '', modifier: null, roadName: roadName);
      final lengthKm = (rawManeuver['length'] as num?)?.toDouble() ?? 0;
      final duration = (rawManeuver['time'] as num?)?.toDouble() ?? 0;
      final type = rawManeuver['type']?.toString() ?? '';

      steps.add(
        NavigationStep(
          instruction: instruction,
          maneuverLocation: legPoints[safeIndex],
          distance: lengthKm * 1000,
          duration: duration,
          maneuverType: type,
          modifier: null,
          roadName: roadName,
        ),
      );
    }

    return steps;
  }

  Future<NavigationRoute> _getOsrmFallbackRoute(
    LatLng start,
    LatLng end,
  ) async {
    for (final profile in _osrmWalkingProfiles) {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/$profile/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=polyline&steps=true',
      );

      try {
        final response = await http
            .get(
              url,
              headers: {
                'Accept': 'application/json',
                'User-Agent': 'RutexGo_App_Demo',
              },
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
            final route = data['routes'][0] as Map<String, dynamic>;
            final encodedPolyline = route['geometry'] as String;
            final points = _decodePolyline(encodedPolyline);
            final steps = _osrmStepsFromRoute(route);
            debugPrint(
              'Ruta fallback OSRM con perfil $profile: '
              '${points.length} puntos, ${steps.length} pasos',
            );
            return NavigationRoute(points: points, steps: steps);
          }
        } else {
          debugPrint(
            'OSRM devolvio ${response.statusCode} con perfil $profile',
          );
        }
      } catch (e) {
        debugPrint('Fallo con fallback OSRM $profile: $e');
      }
    }

    return const NavigationRoute(points: []);
  }

  List<NavigationStep> _osrmStepsFromRoute(Map<String, dynamic> route) {
    final rawLegs = route['legs'];
    if (rawLegs is! List) return [];

    final steps = <NavigationStep>[];
    for (final rawLeg in rawLegs) {
      if (rawLeg is! Map) continue;

      final rawSteps = rawLeg['steps'];
      if (rawSteps is! List) continue;

      for (final rawStep in rawSteps) {
        if (rawStep is! Map) continue;

        final maneuver = rawStep['maneuver'];
        if (maneuver is! Map) continue;

        final location = maneuver['location'];
        if (location is! List || location.length < 2) continue;

        final longitude = (location[0] as num?)?.toDouble();
        final latitude = (location[1] as num?)?.toDouble();
        if (latitude == null || longitude == null) continue;

        final type = maneuver['type']?.toString() ?? '';
        final modifier = maneuver['modifier']?.toString();
        final roadName = rawStep['name']?.toString() ?? '';
        final distance = (rawStep['distance'] as num?)?.toDouble() ?? 0;
        final duration = (rawStep['duration'] as num?)?.toDouble() ?? 0;

        steps.add(
          NavigationStep(
            instruction: _instructionFor(
              type: type,
              modifier: modifier,
              roadName: roadName,
            ),
            maneuverLocation: LatLng(latitude, longitude),
            distance: distance,
            duration: duration,
            maneuverType: type,
            modifier: modifier,
            roadName: roadName,
          ),
        );
      }
    }

    return steps;
  }

  String _instructionFor({
    required String type,
    required String? modifier,
    required String roadName,
  }) {
    final direction = _directionLabel(modifier);
    final roadSuffix = roadName.isEmpty ? '' : ' por $roadName';

    switch (type) {
      case 'depart':
        return 'Comienza$roadSuffix';
      case 'arrive':
        return 'Has llegado al destino';
      case 'turn':
        return 'Gira $direction$roadSuffix';
      case 'new name':
        return 'Continúa $direction$roadSuffix';
      case 'continue':
        return 'Continúa$roadSuffix';
      case 'merge':
        return 'Incorpórate $direction$roadSuffix';
      case 'on ramp':
        return 'Toma la entrada $direction$roadSuffix';
      case 'off ramp':
        return 'Toma la salida $direction$roadSuffix';
      case 'fork':
        return 'Mantente $direction$roadSuffix';
      case 'roundabout':
      case 'rotary':
        return 'En la rotonda, continúa $direction$roadSuffix';
      case 'end of road':
        return 'Al final de la vía, gira $direction$roadSuffix';
      default:
        return 'Continúa$roadSuffix';
    }
  }

  String _directionLabel(String? modifier) {
    switch (modifier) {
      case 'left':
        return 'a la izquierda';
      case 'slight left':
        return 'ligeramente a la izquierda';
      case 'sharp left':
        return 'pronunciadamente a la izquierda';
      case 'right':
        return 'a la derecha';
      case 'slight right':
        return 'ligeramente a la derecha';
      case 'sharp right':
        return 'pronunciadamente a la derecha';
      case 'straight':
        return 'recto';
      case 'uturn':
        return 'y da la vuelta';
      default:
        return 'recto';
    }
  }

  List<LatLng> _decodePolyline(String encoded, {int precision = 5}) {
    final poly = <LatLng>[];
    var index = 0;
    final len = encoded.length;
    var lat = 0;
    var lng = 0;
    final factor = precision == 6 ? 1E6 : 1E5;

    while (index < len) {
      var shift = 0;
      var result = 0;
      int b;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;
      poly.add(LatLng(lat / factor, lng / factor));
    }

    return poly;
  }
}

class NavigationRoute {
  const NavigationRoute({required this.points, this.steps = const []});

  final List<LatLng> points;
  final List<NavigationStep> steps;
}

class NavigationStep {
  const NavigationStep({
    required this.instruction,
    required this.maneuverLocation,
    required this.distance,
    required this.duration,
    required this.maneuverType,
    required this.modifier,
    required this.roadName,
  });

  final String instruction;
  final LatLng maneuverLocation;
  final double distance;
  final double duration;
  final String maneuverType;
  final String? modifier;
  final String roadName;
}
