import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    // 1. Evitamos peticiones absurdas (si los puntos son iguales)
    if (start.latitude == end.latitude && start.longitude == end.longitude) {
      return [start, end];
    }

    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/walking/' // Caminando es mejor para Mérida
            '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
            '?overview=full&geometries=polyline'
    );

    try {
      // 2. Añadimos Headers para que OSRM no nos bloquee
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'User-Agent': 'RutexGo_App_Demo',
      }).timeout(const Duration(seconds: 12)); // Un poco más de margen

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && data['routes'].isNotEmpty) {
          final String encodedPolyline = data['routes'][0]['geometry'];
          final points = _decodePolyline(encodedPolyline);
          debugPrint("✅ Ruta calculada por calles: ${points.length} puntos");
          return points;
        }
      } else {
        debugPrint("❌ OSRM respondió error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("⚠️ Fallo de conexión/Timeout en OSRM: $e");
    }

    // 3. Solo si todo lo anterior falla, devolvemos la línea recta
    debugPrint("🚀 Plan B: Línea recta (Servidor no disponible)");
    return [start, end];
  }

  // Tu función _decodePolyline que ya tienes está perfecta, mantenla igual.
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
      shift = 0; result = 0;
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