import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  /// Obtiene la ruta entre dos monumentos de Mérida usando OSRM
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
          '?overview=full&geometries=polyline',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final String encodedPolyline = data['routes'][0]['geometry'];
          return _decodePolyline(encodedPolyline);
        }
      }
    } catch (e) {
      debugPrint("Error en OSRM: $e");
    }
    return [];
  }

  /// Algoritmo para decodificar la geometría de OSRM a puntos LatLng
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