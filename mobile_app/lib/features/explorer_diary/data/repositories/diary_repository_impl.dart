/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:mobile_app/features/explorer_diary/data/datasources/diary_remote_datasource.dart';
import 'package:mobile_app/features/explorer_diary/domain/entities/diary_entry.dart';
import 'package:mobile_app/features/explorer_diary/domain/repositories/diary_repository.dart';

class DiaryRepositoryImpl implements DiaryRepository{

  final DiaryRemoteDatasource remoteDataSource;

  DiaryRepositoryImpl({
    required this.remoteDataSource,
  });



  @override
  Future<List<DiaryEntry>> getCompletedRoutes(String userId) async {
    // Llamamos al DataSource para obtener los mapas de datos
    final List<Map<String, dynamic>> rawDataList =
    await remoteDataSource.getAllDiaryData(userId);

    // Convertimos cada mapa en una entidad DiaryEntry
    return rawDataList.map((data) {
      return DiaryEntry(
        routeId: data['id'].toString(),
        routeName: data['nombre'],
        completionDate: data['fecha'],
        monuments: List<String>.from(data['puntos_interes_nombres']),
        sealUrl: data['seal_url'],
        // IMPORTANTE: Aquí se inicializa la lista de archivos vacía.
        // Las fotos se añadirán en la capa de presentación (UI).
        photos: [],
      );
    }).toList();
  }
}
