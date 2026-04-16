import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_data.dart';

class HomeDataLoader {
  const HomeDataLoader();

  Future<HomeData> load() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .get();

    final userData = userDoc.data() ?? {};

    final rangosDoc = await FirebaseFirestore.instance
        .collection("config_rangos")
        .doc("3CpvEa6pk5fvifbr73jW")
        .get();

    final rangos = rangosDoc.data()?["rangos"] ?? [];

    final rutasProgreso = List<dynamic>.from(
      userData["rutas_completadas"] ?? [],
    );

    var rutasIds = rutasProgreso
        .map(_routeIdFromProgress)
        .whereType<String>()
        .toList();

    rutasIds = rutasIds.toSet().toList();

    final rutas = <HomeRouteData>[];

    if (rutasIds.isNotEmpty) {
      final rutasQuery = await FirebaseFirestore.instance
          .collection("rutas")
          .where(FieldPath.documentId, whereIn: rutasIds)
          .get();

      for (final doc in rutasQuery.docs) {
        final data = doc.data();
        final puntosInteres = List<dynamic>.from(
          data["id_puntos_interes"] ?? [],
        );
        final misionesTotales = puntosInteres.length;
        final puntosTotales = _asInt(
          data["puntos_totales"],
          defaultValue: misionesTotales * 30,
        );

        final progreso = _progressMapForRoute(rutasProgreso, doc.id);
        final hasDetailedProgress = progreso.isNotEmpty;

        final puntosObtenidos = _asInt(
          progreso["puntos_obtenidos"] ?? progreso["puntos"],
          defaultValue: hasDetailedProgress ? 0 : puntosTotales,
        );
        final misionesCompletadas = _asInt(
          progreso["monumentos_visitados"] ?? progreso["misiones_completadas"],
          defaultValue: misionesTotales,
        );

        rutas.add(
          HomeRouteData(
            id: doc.id,
            name: data["nombre"]?.toString() ?? "Ruta",
            totalPoints: puntosTotales,
            pointsOfInterest: puntosInteres,
            totalMissions: misionesTotales,
            obtainedPoints: puntosObtenidos,
            completedMissions: misionesCompletadas,
          ),
        );
      }
    }

    return HomeData(user: userData, routes: rutas, rangos: rangos);
  }

  static String? _routeIdFromProgress(dynamic progress) {
    if (progress is String) return progress;

    if (progress is Map) {
      final routeId =
          progress["rutaId"] ?? progress["id_ruta"] ?? progress["routeId"];
      return routeId?.toString();
    }

    return null;
  }

  static Map<String, dynamic> _progressMapForRoute(
    List<dynamic> routesProgress,
    String routeId,
  ) {
    for (final progress in routesProgress) {
      if (progress is Map && _routeIdFromProgress(progress) == routeId) {
        return Map<String, dynamic>.from(progress);
      }
    }

    return {};
  }

  static int _asInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;

    return defaultValue;
  }
}
