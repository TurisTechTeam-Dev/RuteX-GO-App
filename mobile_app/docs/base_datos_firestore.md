# Base de datos Firestore

Este documento fija el contrato actual entre la app movil RuteXGo y Firestore.
Se ha creado a partir de las capturas de Firebase Console y de las lecturas/escrituras que hace el codigo Flutter.

No usar como referencia la parte web/admin para este flujo: queda fuera de este documento.

## Colecciones

La base de datos usa estas colecciones principales:

- `ciudades`
- `config_rangos`
- `misiones`
- `puntos_interes`
- `resultado`
- `rutas`
- `usuarios`

## `ciudades`

Documento ejemplo observado:

```text
ciudades/{ciudadId}
imagen: string
isActive: bool
nombre: string
provincia: string
```

Uso en app:

- `RoutesRepositoryImpl.getCiudades()` lee toda la coleccion.
- `CitySelectionContent` ordena primero las ciudades con `isActive == true`.
- `CityItem` usa:
  - `nombre`
  - `imagen`
  - `isActive`
- Si `imagen` esta vacia, la UI intenta usar `assets/images_selection/{ciudadId}.jpg`.

Notas:

- `provincia` existe en Firebase, pero ahora mismo no se usa en la UI movil.

## `config_rangos`

Documento actual usado por codigo:

```text
config_rangos/3CpvEa6pk5fvifbr73jW
rangos: array<map>
```

Cada elemento de `rangos`:

```text
logo: string
nombre: string
puntos_necesarios: number
```

Uso en app:

- `HomeDataLoader` lee de forma fija el documento `3CpvEa6pk5fvifbr73jW`.
- `HomeSummary` usa:
  - `nombre`
  - `puntos_necesarios`
- `logo` esta disponible en base de datos, pero todavia no se usa en Home.

Notas:

- Si se cambia el ID del documento de rangos, hay que actualizar `HomeDataLoader`.
- La logica actual calcula el rango con la suma de `usuarios.rutas_completadas[].puntos_obtenidos`.

## `misiones`

Documento ejemplo observado:

```text
misiones/{misionId}
puntos_interes_id: string
preguntas: array<map>
titulo: string
```

Cada pregunta:

```text
indice_correcto: number
pregunta_1 / pregunta_2 / pregunta_3: string
respuestas: array<string>
```

Uso en app:

- `MissionRepositoryImpl.getMissionByPointId(pointId)` busca:
  - coleccion `misiones`
  - campo `puntos_interes_id == pointId`
  - `limit(1)`
- `QuizMission` espera `preguntas`.
- `QuizQuestion` extrae la pregunta buscando la primera clave que empiece por `pregunta_`.
- Cada acierto suma 10 puntos.

Notas:

- El nombre del campo `puntos_interes_id` debe coincidir exactamente.
- Si un punto de interes tiene mas de una mision, ahora mismo la app solo usara la primera que devuelva Firestore.

## `puntos_interes`

Documento ejemplo observado:

```text
puntos_interes/{puntoInteresId}
descripcion: string
imagen: string
localizacion: GeoPoint
nombre: string
qr_code: string
radio_activacion: number
```

Uso en app:

- `MissionRepositoryImpl.getPuntoByQr(qrCode)` busca:
  - coleccion `puntos_interes`
  - campo `qr_code == qrCode`
  - `limit(1)`
- `MissionRepositoryImpl.getPointsByIds(ids)` busca documentos por ID.
- La carga por IDs se divide en lotes para evitar el limite de `whereIn`.
- `PointOfInterest.fromFirestore` usa:
  - `nombre`
  - `descripcion`
  - `localizacion`
  - `qr_code`
  - `radio_activacion`
- `MonumentInfoScreen` usa:
  - `nombre`
  - `descripcion`
  - `imagen`

Notas:

- `localizacion` debe ser `GeoPoint`.
- `radio_activacion` controla la llegada al punto en el mapa.
- El codigo tambien tolera una clave antigua/corrupta de descripcion con tilde, pero la clave correcta es `descripcion`.

## `rutas`

Documento ejemplo observado:

```text
rutas/{rutaId}
dificultad: string
duracion: string
id_ciudad: string
id_puntos_interes: array<string>
isActive: bool
nombre: string
puntos_totales: number
```

Uso en app:

- `RoutesRepositoryImpl.getRutasByCiudad(idCiudad)` busca:
  - coleccion `rutas`
  - campo `id_ciudad == idCiudad`
- `RouteItem` usa:
  - `nombre`
  - `descripcion` si existe
  - `dificultad`
  - `duracion`
  - `imagen_asset` si existe
  - `id_puntos_interes`
- `TripSimulationProvider` carga los puntos por `id_puntos_interes`.
- `HomeDataLoader` usa:
  - `id_puntos_interes`
  - `puntos_totales`
  - `nombre`

- `puntos_totales` para una ruta de 3 puntos de interes es `100`: hasta 30 por punto y 10 de bonus solo si se completan las misiones de todos los puntos.
- Si falta `puntos_totales`, el codigo calcula por defecto `(numero de puntos de interes * 30) + 10`.
- El listado movil muestra las rutas asociadas a la ciudad aunque `isActive` falte o este a `false`.

## `usuarios`

Documento ejemplo observado:

```text
usuarios/{uid}
email: string
fecha_creacion: timestamp
isAdmin: bool
nombre: string
puntos: number
rango: string
rutas_completadas: array<map>
ultimo_acceso: timestamp
```

Cada elemento de `rutas_completadas`:

```text
misiones_completadas: number
monumentos_visitados: number
puntos_obtenidos: number
rutaId: string
```

Uso en app:

- `AuthRepositoryImpl.register()` crea:
  - `nombre`
  - `usuario`
  - `email`
  - `fecha_creacion`
  - `puntos: 0`
  - `rutas_completadas: []`
  - `isAdmin: false`
- `AuthRepositoryImpl.isAdmin(uid)` lee `isAdmin`.
- `HomeDataLoader` lee `rutas_completadas` y carga las rutas por IDs en lotes.
- `QuizScreen` escribe progreso en `rutas_completadas` con:
  - `rutaId`
  - `puntos_obtenidos`
  - `monumentos_visitados`
  - `misiones_completadas`
- `TripSimulationProvider.finishRoute()` guarda el progreso final en `rutas_completadas`, tambien cuando algunos puntos se han saltado.
- El bonus de 10 puntos solo se aplica si `misiones_completadas` coincide con el numero total de puntos de la ruta.
- Al finalizar ruta se incrementa `usuarios.puntos` solo por la diferencia positiva frente a la mejor puntuacion anterior.
- Si la ruta ya estaba completada, se conserva la mejor puntuacion: una repeticion peor no sobrescribe el resultado anterior; una mejor si lo actualiza.

Notas:

- El codigo soporta variantes legacy para el ID de ruta: `rutaId`, `id_ruta` y `routeId`.
- El Home muestra puntos globales calculados desde `rutas_completadas`, no desde `usuarios.puntos`.
- `usuarios.puntos` puede quedar desincronizado si se editan rutas completadas a mano. Para la UI movil, la fuente fiable es `rutas_completadas`.

## `resultado`

Documento ejemplo observado:

```text
resultado/{resultadoId}
fecha_ruta_completada: timestamp
id_ruta: string
id_usuario: string
puntos_interes_visitados: number
puntos_partida: number
tiempo_empleado: string
```

Uso en app:

- La pantalla Home actual no usa esta coleccion.
- `ProfileRemoteDataSource.getCompletedRoutes()` intenta leer `resultado` filtrando por `id_usuario`.

Riesgo detectado:

- Existia una funcion legacy que escribia `usuario_id` y `mision_id`; se ha retirado para no crear documentos incompatibles.
- Como el flujo actual guarda progreso real en `usuarios.rutas_completadas`, no conviene volver a escribir en `resultado` hasta decidir si se va a usar para historico formal.

## Flujo actual de ruta

1. El usuario elige ciudad.
2. La app carga `rutas` por `id_ciudad`.
3. Al comenzar ruta, el mapa carga los IDs de `rutas.id_puntos_interes`.
4. Se descargan los documentos de `puntos_interes`.
5. El mapa elige el punto pendiente mas cercano al usuario.
6. Al llegar, el usuario escanea `puntos_interes.qr_code`.
7. La app busca la mision por `misiones.puntos_interes_id`.
8. El quiz suma 10 puntos por respuesta correcta.
9. Al completar cada punto de interes, el mapa marca ese punto como completado y recalcula el siguiente mas cercano.
10. Al completar todos los puntos de la ruta, aunque algunos se hayan saltado, el mapa guarda en `usuarios.rutas_completadas` y actualiza `usuarios.puntos` como dato auxiliar.
11. El bonus final se suma solo si se han completado los quiz de todos los puntos de interes.

## Checklist para nuevos workspaces

- No renombrar campos de Firestore sin migracion.
- Mantener `id_puntos_interes` como array de IDs de documentos de `puntos_interes`.
- Mantener `qr_code` unico por punto de interes.
- Mantener `puntos_interes_id` en `misiones`.
- Revisar si `resultado` se va a usar o queda legacy.
- Home usa la suma de `rutas_completadas[].puntos_obtenidos`; si se borra una ruta completada, sus puntos desaparecen del Home.
- El listado de rutas depende de `id_ciudad`, no de `isActive`.
- El documento de rangos usado por Home esta hardcodeado: `3CpvEa6pk5fvifbr73jW`.
