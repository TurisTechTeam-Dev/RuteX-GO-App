/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripcion: Esta aplicacion y su codigo fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribucion o uso no autorizado.
  Anio: 2026
  -----------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';

Widget buildResolvedStorageNetworkImage({
  required String imageUrl,
  required BoxFit fit,
  required Widget fallback,
  Widget? placeholder,
  double? width,
  double? height,
}) {
  return Image.network(
    imageUrl,
    width: width,
    height: height,
    fit: fit,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return placeholder ?? const SizedBox.shrink();
    },
    errorBuilder: (context, error, stackTrace) {
      return fallback;
    },
  );
}
