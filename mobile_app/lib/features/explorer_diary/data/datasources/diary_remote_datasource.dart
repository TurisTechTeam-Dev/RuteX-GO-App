/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class DiaryRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  DiaryRemoteDataSource({required this.firestore, required this.storage});

  /// Carga las rutas completadas y las enriquece con los datos necesarios
  /// para generar el diario del explorador.
  Future<List<Map<String, dynamic>>> getAllDiaryData(String userId) async {
    final userDoc = await firestore.collection('usuarios').doc(userId).get();

    if (!userDoc.exists) return [];

    final List<dynamic> rutasRaw = userDoc.data()?['rutas_completadas'] ?? [];
    final List<Map<String, dynamic>> finalRoutes = [];

    for (var item in rutasRaw) {
      if (item is Map) {
        final String? routeId = item['rutaId']?.toString();

        if (routeId != null && routeId.isNotEmpty) {
          try {
            final routeSnapshot = await firestore
                .collection('rutas')
                .doc(routeId)
                .get();

            if (routeSnapshot.exists) {
              final routeData = routeSnapshot.data()!;

              String sealUrl = "";
              try {
                sealUrl = await storage
                    .ref('sellos/$routeId.png')
                    .getDownloadURL();
              } catch (e) {
                // El diario puede generarse aunque aún no exista sello para la ruta.
                debugPrint(
                  "Aviso: No se pudo cargar el sello para $routeId: $e",
                );
              }

              final List<dynamic> poiIds = routeData['id_puntos_interes'] ?? [];
              List<String> poiNames = [];
              for (var id in poiIds) {
                final poiDoc = await firestore
                    .collection('puntos_interes')
                    .doc(id.toString())
                    .get();
                if (poiDoc.exists) poiNames.add(poiDoc.data()?['nombre'] ?? "");
              }

              finalRoutes.add({
                'id': routeId,
                'nombre': routeData['nombre'] ?? 'Ruta',
                'puntos_interes_nombres': poiNames,
                'seal_url': sealUrl,
                'fecha': DateTime.now(),
              });
            }
          } catch (e) {
            debugPrint("Error procesando ruta $routeId: $e");
          }
        }
      }
    }
    return finalRoutes;
  }
}
