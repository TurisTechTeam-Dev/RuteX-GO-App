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
import 'package:mobile_app/features/explorer_diary/domain/repositories/diary_repository.dart';

class DiaryUseCases {

  final DiaryRepository diaryRepository;

  DiaryUseCases({required this.diaryRepository});

  Future<List<DiaryEntry>> executeGetCompletedRoutes(String userId) async {
    return await diaryRepository.getCompletedRoutes(userId);
  }

}
