# REFACTOR Y CAMBIOS APLICADOS

Este archivo resume solo lo que ya esta hecho en la app movil.
La idea es que cualquier companero pueda abrirlo, entender el estado actual y saber donde tocar sin revisar todo el proyecto desde cero.

## Validacion usada

- En este workspace no se esta usando `dart format` ni `flutter analyze` porque ambos comandos se quedan colgados.
- La comprobacion ligera que se esta usando es `git diff --check` y revision manual de los archivos tocados.

## Estructura refactorizada

### Home / Perfil

Archivos principales:

- `lib/features/profile/presentation/home_screen.dart`
- `lib/features/profile/data/home_data_loader.dart`
- `lib/features/profile/data/home_data.dart`
- `lib/features/profile/data/home_summary.dart`
- `lib/features/profile/presentation/widgets/home_content.dart`
- `lib/features/profile/presentation/widgets/home_cards.dart`
- `lib/features/profile/presentation/widgets/home_route_list.dart`

Que hace ahora:

- `home_screen.dart` actua como contenedor simple.
- `home_data_loader.dart` carga usuario, rangos y rutas completadas.
- `home_summary.dart` calcula el resumen visible del home.
- `home_cards.dart` contiene las cards de usuario, estadisticas y rutas.
- `home_route_list.dart` pinta la lista de rutas completadas.

Comportamiento actual:

- El rango visible y `Puntos totales` salen de `usuarios.puntos`.
- Las rutas completadas siguen leyendo sus datos resumidos desde `usuarios.rutas_completadas`.
- Al pulsar una ruta completada en Home se abre un bottom sheet con el ultimo intento persistido, si existe.

### Auth

Archivos principales:

- `lib/features/auth/presentation/login_screen.dart`
- `lib/features/auth/presentation/register_screen.dart`
- `lib/core/widgets/auth/auth_logo.dart`
- `lib/core/widgets/auth/auth_snack_bar.dart`
- `lib/core/widgets/inputs/custom_inputs.dart`

Que hace ahora:

- Login y registro usan fondo comun con mapa de Extremadura.
- Se ajusto el comportamiento del teclado para evitar saltos raros del layout.
- `CustomInput` tiene `scrollPadding` para mejorar el enfoque de campos.

### Seleccion de ciudad y ruta

Archivos principales:

- `lib/features/routes/presentation/city_selection_screen.dart`
- `lib/features/routes/presentation/widgets/city_selection_content.dart`
- `lib/features/routes/presentation/widgets/city_card.dart`
- `lib/features/routes/presentation/models/city_item.dart`
- `lib/features/routes/presentation/route_selection_screen.dart`
- `lib/features/routes/presentation/widgets/route_selection_content.dart`
- `lib/features/routes/presentation/widgets/route_card.dart`
- `lib/features/routes/presentation/models/route_item.dart`

Que hace ahora:

- Las ciudades se ordenan primero por disponibilidad real de rutas y luego alfabeticamente.
- Una ciudad puede mostrar `Explorar` si tiene rutas, aunque `isActive` no gobierne ese flujo.
- Las rutas muestran `Tiempo estimado` y `Puntos totales`.
- `Comenzar ruta` solo se habilita si todos los puntos de interes de esa ruta tienen mision asociada.
- Si faltan misiones, la card lo explica visualmente y el boton queda como `Ruta no disponible`.

### Quiz, resultados y QR

Archivos principales:

- `lib/features/mission/presentation/quiz/screens/quiz_screen.dart`
- `lib/features/mission/presentation/quiz/screens/route_result_screen.dart`
- `lib/features/mission/presentation/quiz/quiz_route_progress.dart`
- `lib/features/mission/presentation/qr_scanner/screens/mission_scanner_screen.dart`
- `lib/features/mission/presentation/qr_scanner/widgets/mission_scanner_overlay.dart`

Que hace ahora:

- `QuizRouteProgress` centraliza el progreso temporal de ruta.
- La pantalla de resultados se reorganizo visualmente y limpia mejor respuestas con saltos raros.
- La card principal de resultados deja ver el mapa de fondo.
- El QR tiene mas cooldown para evitar disparos demasiado rapidos.

### Fondo e imagenes compartidas

Archivos principales:

- `lib/core/widgets/backgrounds/extremadura_map_background.dart`
- `lib/core/widgets/titles/stroke_title.dart`
- `lib/core/widgets/images/storage_aware_image.dart`

Que hace ahora:

- `ExtremaduraMapBackground` se reutiliza en varias pantallas.
- `StrokeTitle` ya no vive duplicado en distintas vistas.
- `StorageAwareImage` unifica la carga de imagenes desde assets, `https://`, `gs://` o rutas internas tipo `Contenido/...`.

## Firebase y persistencia

### Imagenes en Firebase Storage

Ya soportado en:

- ciudades
- rutas
- punto de interes / detalle de monumento
- logos de rangos

Formato recomendado en Firestore:

- `Contenido/Ciudades/badajoz.jpg`
- `Contenido/Rutas/anfiteatro.jpg`
- `Contenido/PuntosInteres/teatro_romano.jpg`
- `Contenido/Rangos/bronce.png`

No hace falta guardar la URL publica larga si la app puede resolver la ruta interna.

### Resultado de rutas

Estado actual:

- La mejor marca resumida por ruta se sigue guardando en `usuarios.rutas_completadas`.

Archivos implicados:

- `lib/features/mission/presentation/navigation/provider/trip_provider.dart`

Comportamiento actual:

- Si un usuario repite una ruta y mejora su mejor marca, se suma solo la diferencia positiva a `usuarios.puntos`.
- Si hace peor resultado, no suma puntos globales.

## Convenciones importantes

- `usuarios.puntos` es la fuente de verdad para el rango visible y para `Puntos totales` en Home.
- `usuarios.rutas_completadas` se usa como resumen por ruta, no como fuente de verdad para el total global del usuario.
- El listado de rutas de una ciudad depende de `id_ciudad`.
- El inicio de una ruta depende de que todos sus puntos de interes tengan mision.

## Archivos especialmente sensibles

Si se va a tocar comportamiento y no solo UI, revisar primero:

- `lib/features/mission/presentation/navigation/provider/trip_provider.dart`
- `lib/features/profile/data/home_data_loader.dart`
- `lib/features/profile/data/home_summary.dart`
- `lib/features/routes/data/routes_repository_impl.dart`
- `lib/features/routes/domain/usecases/routes_use_cases.dart`
- `lib/core/constants/firestore_contract.dart`
- `docs/base_datos_firestore.md`

## Nota para el equipo

Este archivo se ira actualizando solo con cambios ya aplicados y comprobados dentro del proyecto.
No se esta usando como roadmap de futuro, sino como fotografia del estado real del codigo.
