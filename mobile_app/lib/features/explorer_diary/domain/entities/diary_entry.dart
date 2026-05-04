/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'dart:io';

class DiaryEntry {
  final String routeId;
  final String routeName;
  final DateTime completionDate;
  final List<String> monuments;
  final String sealUrl;
  final List<File> photos;

  DiaryEntry({
    required this.routeId,
    required this.routeName,
    required this.completionDate,
    required this.monuments,
    required this.sealUrl,
    this.photos = const [],
  });

  DiaryEntry copyWith({
    String? routeId,
    String? routeName,
    DateTime? completionDate,
    List<String>? monuments,
    String? sealUrl,
    List<File>? photos,
  }) {
    return DiaryEntry(
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      completionDate: completionDate ?? this.completionDate,
      monuments: monuments ?? this.monuments,
      sealUrl: sealUrl ?? this.sealUrl,
      photos: photos ?? this.photos,
    );
  }
}
