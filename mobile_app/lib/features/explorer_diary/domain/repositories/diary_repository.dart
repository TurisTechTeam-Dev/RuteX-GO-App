/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:mobile_app/features/explorer_diary/domain/entities/diary_entry.dart';

abstract class DiaryRepository {
  /// Obtiene la lista de rutas completadas por el usuario desde Firestore
  /// para transformarlas en entradas del diario.
  Future<List<DiaryEntry>> getCompletedRoutes(String userId);
}
