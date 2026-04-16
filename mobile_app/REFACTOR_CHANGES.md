# Registro de cambios de refactor

Este documento resume los cambios realizados en la rama `codex` para que otro workspace pueda revisar o replicar la misma reorganizacion.

## Estado de referencia

- Rama de trabajo: `codex`.
- Commit ya creado: `d14badd Corrige problems en lib`.
- Cambios posteriores al commit: refactor de `home`, refactor parcial de `auth` y refactor de seleccion de ciudad.
- Validacion disponible: `git diff --check`.
- No se pudo ejecutar `flutter analyze` ni `dart analyze` porque los comandos no estan disponibles en esta terminal.

## Cambios ya incluidos en el commit `d14badd`

### Archivos renombrados

- `lib/core/widgets/Bars/toppAppBarr.dart` -> `lib/core/widgets/bars/top_app_bar.dart`
  - Motivo: normalizar nombre de carpeta/archivo y eliminar el typo del nombre.
- `lib/features/auth/presentation/auht_wrapper.dart` -> `lib/features/auth/presentation/auth_wrapper.dart`
  - Motivo: corregir typo en `auth`.
- `lib/features/FirebaseTestScreen.dart` -> `lib/features/firebase_test_screen.dart`
  - Motivo: cumplir convencion `snake_case` en nombres de archivos Dart.
- `lib/features/mission/presentation/quiz/screens/result_view_ screen.dart` -> `lib/features/mission/presentation/quiz/screens/result_view_screen.dart`
  - Motivo: quitar espacio y formato incorrecto del nombre.

### Archivos modificados

- `lib/main.dart`
  - Actualizado el import de `auth_wrapper.dart`.
- `lib/core/map/map_view.dart`
  - Migrado `withOpacity` a `withValues(alpha: ...)`.
- `lib/features/mission/presentation/navigation/screens/map_navigation_screen.dart`
  - Migrado `withOpacity` a `withValues(alpha: ...)`.
- `lib/features/mission/data/repository/mission_repository_impl.dart`
  - Reemplazado `print` por `debugPrint`.
  - Eliminadas comprobaciones nulas innecesarias tras `doc.data()`.
- `lib/features/mission/domain/entity/poi_entity.dart`
  - Reemplazado `print` por `debugPrint`.
- `lib/features/mission/data/model/poi_model.dart`
  - Reemplazado import de `cupertino.dart` por `foundation.dart`.
- `lib/features/mission/presentation/qr_scanner/screens/mission_scanner_screen.dart`
  - Reemplazado `print` por `debugPrint`.
  - Anadidos guards de `mounted` en callbacks async.
- `lib/features/mission/presentation/quiz/screens/quiz_screen.dart`
  - Quitado `.toList()` innecesario en un spread.
- `lib/features/mission/presentation/monument_detail/screens/monument_info_screen.dart`
  - Aplicados elementos null-aware en el map de argumentos: `'routeId': ?routeId`, `'totalPois': ?totalPois`.
- `lib/features/routes/presentation/city_selection_screen.dart`
  - Sustituidos parametros `_`, `__`, `___` en `errorBuilder`.
- `lib/features/splash/presentation/splash_screen.dart`
  - Anadido guard `mounted` tras `await` antes de navegar.
- `lib/core/widgets/inputs/custom_inputs.dart`
  - Renombrado `custom_input` a `CustomInput`.
- `lib/features/auth/presentation/login_screen.dart`
  - Actualizado uso de `CustomInput`.
  - Eliminado campo `_errorMessage` no usado.
  - Reemplazado `print` por `debugPrint`.
- `lib/features/auth/presentation/register_screen.dart`
  - Actualizado uso de `CustomInput`.
  - Eliminado cast innecesario a `AuthRepository`.
- `lib/features/admin_panel/presentation/admin_panel_screen.dart`
  - Eliminados imports no usados.
- `lib/features/profile/presentation/profile_screen.dart`
  - Eliminados imports no usados y aplicado `const` donde procedia.

## Refactor actual: Home

### Archivos creados

- `lib/features/profile/data/home_data_loader.dart`
  - Extrae la carga de datos de Firestore/Auth que antes vivia en `home_screen.dart`.
- `lib/features/profile/data/home_summary.dart`
  - Extrae los calculos de rango, puntos y misiones.
- `lib/features/profile/presentation/widgets/home_cards.dart`
  - Extrae las cards visuales del home: usuario, estadisticas y ruta.
- `lib/features/profile/presentation/widgets/home_content.dart`
  - Extrae la composicion principal del cuerpo del home.
- `lib/features/profile/presentation/widgets/home_route_list.dart`
  - Extrae la lista de rutas completadas.
- `lib/core/widgets/titles/stroke_title.dart`
  - Mueve `StrokeTitle` a un widget compartido, usado por home y pantallas de rutas.

### Archivos modificados

- `lib/features/profile/presentation/home_screen.dart`
  - Queda como contenedor de estado: `Scaffold`, FAB, `FutureBuilder` y `HomeContent`.
  - Baja de unas 500 lineas a unas 47 lineas.
- `lib/features/profile/data/home_data.dart`
  - Mantiene `HomeData`.
  - Anade `HomeRouteData` para que la UI no consuma mapas crudos de rutas.
- `lib/features/routes/presentation/city_selection_screen.dart`
  - Importa `StrokeTitle` desde el nuevo widget compartido.
- `lib/features/routes/presentation/route_selection_screen.dart`
  - Importa `StrokeTitle` desde el nuevo widget compartido.

## Refactor actual: Login y Registro

### Archivos creados

- `lib/features/auth/presentation/auth_use_cases_factory.dart`
  - Centraliza la creacion de `AuthUsesCases` con `FirebaseAuth`, `FirebaseFirestore` y `AuthRepositoryImpl`.
- `lib/core/widgets/auth/auth_logo.dart`
  - Extrae el logo con `Hero(tag: 'logo')`; cada pantalla sigue pasando su misma altura.
- `lib/core/widgets/auth/auth_snack_bar.dart`
  - Helper simple para mostrar SnackBars de auth.

### Archivos modificados

- `lib/features/auth/presentation/login_screen.dart`
  - Usa `createAuthUseCases()`.
  - Usa `AuthLogo`.
  - Usa `showAuthSnackBar` para el error de login.
  - No se cambiaron rutas, validaciones, textos visibles ni layout.
- `lib/features/auth/presentation/register_screen.dart`
  - Usa `createAuthUseCases()`.
  - Usa `AuthLogo`.
  - Usa `showAuthSnackBar` para el error de registro.
  - No se cambiaron rutas, validaciones, textos visibles ni layout.

## Refactor actual: Seleccion de ciudad

### Archivos creados

- `lib/features/routes/presentation/widgets/city_card.dart`
  - Extrae la card de ciudad desde `city_selection_screen.dart`.
  - Contiene imagen, fallback icon, contador de rutas, boton explorar y titulo con stroke local.

### Archivos modificados

- `lib/features/routes/presentation/city_selection_screen.dart`
  - Usa `CityCard`.
  - Mantiene el `StreamBuilder` y ordenacion de ciudades.
  - El fondo ahora incluye `color: AppColors.blancoPuro`, igual que home y seleccion de ruta.
  - Se eliminaron imports y codigo de card que ya no pertenecen a la pantalla.

## Notas para el siguiente workspace

- Los cambios actuales posteriores a `d14badd` todavia no estan commiteados.
- Si el siguiente workspace aplica estos cambios manualmente, conviene hacerlo en este orden:
  1. Crear widgets compartidos (`StrokeTitle`, `AuthLogo`, `auth_snack_bar`).
  2. Crear loaders/modelos de home (`HomeDataLoader`, `HomeSummary`, `HomeRouteData`).
  3. Extraer widgets de home (`HomeContent`, `HomeRouteList`, `home_cards`).
  4. Actualizar imports de rutas para usar `StrokeTitle`.
  5. Extraer `CityCard` y actualizar el fondo de `CitySelectionScreen`.
  6. Actualizar login/registro para usar `createAuthUseCases` y `AuthLogo`.
- Antes de mergear, ejecutar `flutter analyze` y una prueba visual de login, registro, home, seleccion de ciudad y seleccion de ruta cuando el entorno lo permita.
