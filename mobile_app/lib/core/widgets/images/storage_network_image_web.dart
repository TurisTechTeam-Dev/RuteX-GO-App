/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripcion: Esta aplicacion y su codigo fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribucion o uso no autorizado.
  Anio: 2026
  -----------------------------------------------------------------------------
*/
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

Widget buildResolvedStorageNetworkImage({
  required String imageUrl,
  required BoxFit fit,
  required Widget fallback,
  Widget? placeholder,
  double? width,
  double? height,
}) {
  return _WebStorageNetworkImage(
    imageUrl: imageUrl,
    fit: fit,
    width: width,
    height: height,
  );
}

class _WebStorageNetworkImage extends StatelessWidget {
  static final Set<String> _registeredViewTypes = {};

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const _WebStorageNetworkImage({
    required this.imageUrl,
    required this.fit,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final viewType = 'storage-aware-image-${Object.hash(imageUrl, fit)}';

    if (_registeredViewTypes.add(viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(viewType, (viewId) {
        return web.HTMLImageElement()
          ..src = imageUrl
          ..alt = ''
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = _objectFitCss(fit)
          ..style.display = 'block'
          ..style.border = '0';
      });
    }

    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: viewType),
    );
  }

  static String _objectFitCss(BoxFit fit) {
    return switch (fit) {
      BoxFit.contain => 'contain',
      BoxFit.fill => 'fill',
      BoxFit.fitHeight => 'contain',
      BoxFit.fitWidth => 'contain',
      BoxFit.none => 'none',
      BoxFit.scaleDown => 'scale-down',
      BoxFit.cover => 'cover',
    };
  }
}
