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
}

class MissionFields {
  static const puntosInteresId = 'puntos_interes_id';
  static const preguntas = 'preguntas';
  static const titulo = 'titulo';
  static const indiceCorrecto = 'indice_correcto';
  static const respuestas = 'respuestas';
}

class PointInterestFields {
  static const descripcion = 'descripcion';
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
  static const imagenAsset = 'imagen_asset';
  static const isActive = 'isActive';
  static const nombre = 'nombre';
  static const puntosTotales = 'puntos_totales';
}

class UserFields {
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
}

class RankFields {
  static const rangos = 'rangos';
  static const logo = 'logo';
  static const nombre = 'nombre';
  static const puntosNecesarios = 'puntos_necesarios';
}
