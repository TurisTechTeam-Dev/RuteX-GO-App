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

  DiaryRemoteDataSource({
    required this.firestore,
    required this.storage,
  });

  /// Obtiene los datos de las rutas completadas del usuario.
  Future<List<Map<String, dynamic>>> getAllDiaryData(String userId) async {
    // 1. Acceder al documento del usuario usando el UID real
    final userDoc = await firestore.collection('usuarios').doc(userId).get();

    if (!userDoc.exists) return [];

    // 2. Obtener la lista de mapas "rutas_completadas"
    final List<dynamic> rutasRaw = userDoc.data()?['rutas_completadas'] ?? [];
    final List<Map<String, dynamic>> finalRoutes = [];

    for (var item in rutasRaw) {
      if (item is Map) {
        // Extraemos el ID que está dentro del campo 'rutaId'
        final String? routeId = item['rutaId']?.toString();

        if (routeId != null && routeId.isNotEmpty) {
          try {
            // Buscamos los detalles de la ruta en la colección 'rutas'
            final routeSnapshot = await firestore.collection('rutas').doc(routeId).get();

            if (routeSnapshot.exists) {
              final routeData = routeSnapshot.data()!;

              // Intentamos obtener la URL del sello
              String sealUrl = "";
              try {
                sealUrl = await storage.ref('sellos/$routeId.png').getDownloadURL();
              } catch (e) {
                // Si da error 403 o no existe, imprimimos en consola y seguimos
                debugPrint("Aviso: No se pudo cargar el sello para $routeId: $e");
                // sealUrl se queda como "" y la UI mostrará el icono por defecto (Icons.qr_code)
              }

              // Obtenemos nombres de monumentos
              final List<dynamic> poiIds = routeData['id_puntos_interes'] ?? [];
              List<String> poiNames = [];
              for (var id in poiIds) {
                final poiDoc = await firestore.collection('puntos_interes').doc(id.toString()).get();
                if (poiDoc.exists) poiNames.add(poiDoc.data()?['nombre'] ?? "");
              }

              finalRoutes.add({
                'id': routeId,
                'nombre': routeData['nombre'] ?? 'Ruta',
                'puntos_interes_nombres': poiNames,
                'seal_url': sealUrl,
                'fecha': DateTime.now(), // O la fecha que prefieras del mapa 'item'
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
