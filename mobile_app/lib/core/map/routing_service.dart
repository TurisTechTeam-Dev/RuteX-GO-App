import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  static const _walkingProfiles = ['walking', 'foot'];

  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    if (start.latitude == end.latitude && start.longitude == end.longitude) {
      return [start, end];
    }

    for (final profile in _walkingProfiles) {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/$profile/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=polyline',
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
            final encodedPolyline = data['routes'][0]['geometry'] as String;
            final points = _decodePolyline(encodedPolyline);
            debugPrint(
              "Ruta peatonal calculada con perfil $profile: ${points.length} puntos",
            );
            return points;
          }
        } else {
          debugPrint(
            "OSRM devolvió ${response.statusCode} con perfil $profile",
          );
        }
      } catch (e) {
        debugPrint("Fallo con perfil peatonal $profile: $e");
      }
    }

    debugPrint("Plan B: línea recta al no poder calcular ruta peatonal");
    return [start, end];
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }
}
