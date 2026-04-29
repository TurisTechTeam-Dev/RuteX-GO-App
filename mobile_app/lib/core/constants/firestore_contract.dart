class FirestoreCollections {
  static const ciudades = 'ciudades';
  static const configRangos = 'config_rangos';
  static const misiones = 'misiones';
  static const puntosInteres = 'puntos_interes';
  static const resultado = 'resultado';
  static const rutas = 'rutas';
  static const usuarios = 'usuarios';
}

class FirestoreDocs {
  static const rangosConfig = '3CpvEa6pk5fvifbr73jW';
}

class CityFields {
  static const imagen = 'imagen';
  static const isActive = 'isActive';
  static const nombre = 'nombre';
  static const provincia = 'provincia';
}

class MissionFields {
  static const puntosInteresId = 'puntos_interes_id';
  static const puntoInteresId = 'punto_interes_id';
  static const preguntas = 'preguntas';
  static const titulo = 'titulo';
  static const indiceCorrecto = 'indice_correcto';
  static const respuestas = 'respuestas';
}

class PointInterestFields {
  static const descripcion = 'descripcion';
  static const idCiudad = 'id_ciudad';
  static const imagen = 'imagen';
  static const localizacion = 'localizacion';
  static const nombre = 'nombre';
  static const qrCode = 'qr_code';
  static const radioActivacion = 'radio_activacion';
}

class RouteFields {
  static const descripcion = 'descripcion';
  static const dificultad = 'dificultad';
  static const duracion = 'duracion';
  static const idCiudad = 'id_ciudad';
  static const idPuntosInteres = 'id_puntos_interes';
  static const imagen = 'imagen';
  static const imagenAsset = 'imagen_asset';
  static const isActive = 'isActive';
  static const nombre = 'nombre';
  static const puntosTotales = 'puntos_totales';
}

class UserFields {
  static const avatar = 'avatar';
  static const email = 'email';
  static const fechaCreacion = 'fecha_creacion';
  static const isAdmin = 'isAdmin';
  static const nombre = 'nombre';
  static const puntos = 'puntos';
  static const rango = 'rango';
  static const rutasCompletadas = 'rutas_completadas';
  static const uid = 'uid';
  static const ultimoAcceso = 'ultimo_acceso';
  static const usuario = 'usuario';
}

class CompletedRouteFields {
  static const rutaId = 'rutaId';
  static const idRuta = 'id_ruta';
  static const routeId = 'routeId';
  static const puntosObtenidos = 'puntos_obtenidos';
  static const puntos = 'puntos';
  static const monumentosVisitados = 'monumentos_visitados';
  static const misionesCompletadas = 'misiones_completadas';
  static const puntosInteresSaltados = 'puntos_interes_saltados';
}

class ResultFields {
  static const idUsuario = 'id_usuario';
  static const idRuta = 'id_ruta';
  static const nombreRuta = 'nombre_ruta';
  static const mejorPuntuacionAnterior = 'mejor_puntuacion_anterior';
  static const mejorPuntuacionGuardada = 'mejor_puntuacion_guardada';
  static const puntuacionIntento = 'puntuacion_intento';
  static const puntosInteresVisitados = 'puntos_interes_visitados';
  static const misionesCompletadas = 'misiones_completadas';
  static const totalPuntosInteres = 'total_puntos_interes';
  static const puntosTotalesPosibles = 'puntos_totales_posibles';
  static const tiempoIntento = 'tiempo_intento';
  static const respuestasCorrectas = 'respuestas_correctas';
  static const totalRespuestas = 'total_respuestas';
  static const respuestas = 'respuestas';
  static const puntosInteresSaltados = 'puntos_interes_saltados';
  static const fechaCreacion = 'fecha_creacion';
}

class ResultAnswerFields {
  static const nombreMonumento = 'nombre_monumento';
  static const pregunta = 'pregunta';
  static const respuestaSeleccionada = 'respuesta_seleccionada';
  static const respuestaCorrecta = 'respuesta_correcta';
  static const esCorrecta = 'es_correcta';
}

class ResultDocIds {
  const ResultDocIds._();

  static String routeResult({required String uid, required String routeId}) {
    return '${_safeSegment(uid)}_${_safeSegment(routeId)}';
  }

  static String _safeSegment(String value) {
    return value.replaceAll('/', '_').trim();
  }
}

class RankFields {
  static const rangos = 'rangos';
  static const logo = 'logo';
  static const nombre = 'nombre';
  static const puntosNecesarios = 'puntos_necesarios';
}
