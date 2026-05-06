/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:flutter/services.dart';

class NativeApiKeys {
  static const MethodChannel _channel = MethodChannel('rutexgo/api_keys');

  static String? _googleDirectionsApiKey;

  static Future<String> googleDirectionsApiKey() async {
    final cachedKey = _googleDirectionsApiKey;
    if (cachedKey != null) return cachedKey;

    try {
      final key = await _channel.invokeMethod<String>('googleDirectionsApiKey');
      _googleDirectionsApiKey = key?.trim() ?? '';
      return _googleDirectionsApiKey!;
    } catch (_) {
      _googleDirectionsApiKey = '';
      return '';
    }
  }
}
