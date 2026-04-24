# Nueva estructura del proyecto

Este documento describe la estructura actual de `lib/` despues del refactor. Sirve como mapa rapido para cualquier workspace nuevo de Codex o cualquier companero que necesite entender donde debe vivir cada cosa.

## Criterio general

- `app/` contiene la composicion de la aplicacion: rutas, shell visual y widgets compartidos por pantallas completas.
- `core/` contiene piezas transversales sin dependencia de features: tema, constantes, utilidades y widgets reutilizables.
- `features/` contiene cada modulo funcional separado por capas de Clean Architecture.
- `data/` conoce Firestore, modelos de persistencia y repositorios concretos.
- `domain/` define entidades, contratos y casos de uso. No debe depender de Flutter, Firestore ni presentation.
- `presentation/` contiene pantallas, widgets, providers y modelos de UI.
- La base de datos se mantiene en espanol: colecciones y campos Firestore quedan en espanol para identificar claramente cuando se toca persistencia.

## Estructura principal

```txt
lib/
  main.dart                                      # Punto de entrada Flutter.
  firebase_options.dart                         # Configuracion generada por Firebase.
  injection_container.dart                      # Inyeccion de dependencias de la app.

  app/                                          # Capa de aplicacion: wiring visual y navegacion global.
    auth_wrapper.dart                           # Decide el flujo inicial segun sesion/auth.
    navigation/
      app_routes.dart                           # Nombres y helpers de rutas de navegacion.
    widgets/
      top_app_bar.dart                          # Barra superior compartida por varias pantallas.
      custom_drawer.dart                        # Menu lateral comun.
      app_info_dialog.dart                      # Dialogo global de informacion de la app.
      logout_dialog.dart                        # Dialogo global de cierre de sesion.

  core/                                         # Codigo transversal, sin conocimiento de features concretas.
    constants/
      app_colors.dart                           # Paleta comun de colores.
      firestore_contract.dart                   # Contrato Firestore: colecciones/campos en espanol.
    error/
      failures.dart                             # Tipos de fallo compartidos.
    map/
      routing_service.dart                      # Servicio transversal de rutas/mapa.
    theme/
      app_theme.dart                            # Tema global de Flutter.
    utils/
      text_normalizer.dart                      # Normalizacion de texto reutilizable.
      validators.dart                           # Validadores comunes de formularios.
    widgets/
      backgrounds/
        extremadura_map_background.dart         # Fondo comun con mapa de Extremadura.
      buttons/
        custom_button.dart                      # Boton reutilizable.
      cards/
        custom_cards.dart                       # Cards base reutilizables.
      images/
        storage_aware_image.dart                # Imagen compatible con Storage/URL/assets.
        framed_storage_image.dart               # Imagen enmarcada reutilizable.
      inputs/
        custom_inputs.dart                      # Inputs reutilizables.
      titles/
        stroke_title.dart                       # Titulo visual reutilizable.

  features/                                     # Modulos funcionales aislados por feature.
```

## Patron de feature

Cada feature debe seguir esta forma siempre que tenga logica suficiente:

```txt
features/<feature>/
  data/                                         # Implementacion tecnica y persistencia.
    datasources/                                # Llamadas a Firestore, APIs o almacenamiento local.
    models/                                     # DTOs/modelos que parsean datos externos.
    repositories/                               # Implementaciones de contratos de domain.

  domain/                                       # Regla de negocio y contratos puros.
    entities/                                   # Objetos del negocio usados por la app.
    repositories/                               # Interfaces; definen que necesita la app.
    usecases/                                   # Acciones de negocio orquestadas.

  presentation/                                 # UI y estado de pantalla.
    screens/                                    # Pantallas cuando la feature tiene subflujos.
    widgets/                                    # Widgets especificos de esta feature.
    models/                                     # Modelos solo de UI/navegacion.
    provider/                                   # Estado de UI si aplica.
    utils/                                      # Helpers solo de presentation.
```

Regla practica:

- Si lo usa toda la app, va a `core/` o `app/`.
- Si lo usa solo una feature, va a `features/<feature>/presentation/widgets/`.
- Si habla con Firestore, va a `data/datasources/` o `data/repositories/`.
- Si define lo que la app necesita sin decir como se obtiene, va a `domain/repositories/`.

## Features actuales

```txt
features/
  auth/                                        # Login, registro, sesion y cambios de credenciales.
    data/
      models/
        auth_user_model.dart                   # Modelo tecnico para mapear usuario autenticado.
      repositories/
        auth_repository_impl.dart              # Implementacion con Firebase Auth/Firestore.
    domain/
      entities/
        auth_user.dart                         # Usuario de dominio, independiente de Firebase.
      repositories/
        auth_repository.dart                   # Contrato de autenticacion.
      usecases/
        auth_use_cases.dart                    # Casos de uso de login, registro y perfil auth.
    presentation/
      login_screen.dart                        # Pantalla de login.
      register_screen.dart                     # Pantalla de registro.
      widgets/
        auth_card.dart                         # Card especifica de pantallas auth.
        auth_logo.dart                         # Logo especifico de auth.
        auth_snack_bar.dart                    # Feedback especifico de auth.
        login_content.dart                     # Contenido del formulario de login.
        register_content.dart                  # Contenido del formulario de registro.

  routes/                                      # Seleccion de ciudad y seleccion de ruta.
    data/
      datasources/
        routes_remote_datasource.dart          # Queries a ciudades, rutas y misiones.
      models/
        city_model.dart                        # Parseo Firestore -> City.
        route_model.dart                       # Parseo Firestore -> TouristRoute.
      repositories/
        routes_repository_impl.dart            # Implementacion del contrato de rutas.
    domain/
      entities/
        city.dart                              # Ciudad usada por la app.
        tourist_route.dart                     # Ruta turistica usada por la app.
      repositories/
        routes_repository.dart                 # Contrato de rutas.
      usecases/
        routes_use_cases.dart                  # Casos de uso de seleccion de rutas.
    presentation/
      city_selection_screen.dart               # Pantalla de ciudades.
      route_selection_screen.dart              # Pantalla de rutas por ciudad.
      models/
        route_selection_args.dart              # Argumentos de navegacion de seleccion.
      widgets/
        city_card.dart                         # Card de ciudad.
        city_selection_content.dart            # Layout de seleccion de ciudad.
        route_card.dart                        # Card de ruta.
        route_selection_content.dart           # Layout de seleccion de ruta.

  mission/                                     # Navegacion, QR, quiz y resultado de ruta.
    data/
      datasources/
        mission_remote_datasource.dart         # Queries de puntos de interes, rutas y misiones.
      models/
        mission_model.dart                     # Parseo de misiones/preguntas.
        poi_model.dart                         # Parseo de puntos de interes.
        completed_route_progress_model.dart    # Modelo de progreso guardado en usuario.
      repositories/
        mission_repository_impl.dart           # Implementacion de flujo de mision/ruta.
    domain/
      entities/
        mission.dart                           # Mision de dominio.
        mission_scan_result.dart               # Resultado del escaneo QR.
        poi_entity.dart                        # Punto de interes de dominio.
        route_progress_save_result.dart        # Resultado al guardar progreso.
      repositories/
        mission_repository.dart                # Contrato de misiones.
      usecases/
        mission_use_cases.dart                 # Casos de uso de mision, quiz y progreso.
    presentation/
      mission_flow_result.dart                 # Resultado de flujo usado por UI.
      monument_detail/
        models/
          monument_info_args.dart              # Argumentos para detalle de monumento.
        screens/
          monument_info_screen.dart            # Pantalla de detalle de monumento.
      navigation/
        models/
          route_completion_summary.dart        # Resumen de finalizacion para UI.
        provider/
          trip_provider.dart                   # Estado del viaje/navegacion.
        screens/
          map_navigation_screen.dart           # Pantalla de navegacion de ruta.
        utils/
          navigation_distance_utils.dart       # Calculos de distancia de UI.
          route_duration_formatter.dart        # Formateo de duracion.
          route_target_selector.dart           # Seleccion del siguiente destino.
        widgets/
          arrival_bottom_sheet.dart            # Sheet al llegar a un punto.
          map_view.dart                        # Vista de mapa de la feature.
          navigation_info_panel.dart           # Panel informativo de navegacion.
      qr_scanner/
        models/
          mission_scanner_args.dart            # Argumentos del scanner.
        screens/
          mission_scanner_screen.dart          # Pantalla de escaneo QR.
        widgets/
          mission_scanner_overlay.dart         # Overlay visual del scanner.
          rutex_scanner_widget.dart            # Widget tecnico del scanner.
      quiz/
        quiz_route_progress.dart               # Estado/progreso del quiz dentro de ruta.
        models/
          quiz_mission.dart                    # Modelo de UI para mision del quiz.
          quiz_question.dart                   # Modelo de UI para pregunta.
          route_result_args.dart               # Argumentos de resultado.
          route_result_data.dart               # Datos visibles en resultado.
        screens/
          quiz_screen.dart                     # Pantalla del quiz.
          route_result_screen.dart             # Pantalla final de resultado.
        widgets/
          quiz_answer_option.dart              # Opcion de respuesta.
          quiz_content.dart                    # Layout del quiz.
          question_results_sheet.dart          # Detalle de respuestas.
          route_result_panel.dart              # Panel de resultado final.

  profile/                                     # Home, perfil de usuario, ranking y progreso.
    data/
      datasources/
        profile_remote_datasource.dart         # Lectura/escritura Firestore de perfil y progreso.
      repositories/
        profile_repository_impl.dart           # Implementacion del contrato de perfil.
      home_data_loader.dart                    # Orquestador de datos del Home.
    domain/
      entities/
        home_data.dart                         # Datos completos del Home.
        home_route.dart                        # Ruta resumida para Home.
        profile_rank.dart                      # Rango del usuario.
        user_profile.dart                      # Perfil de usuario.
      repositories/
        profile_repository.dart                # Contrato de perfil.
      usecases/
        profile_use_cases.dart                 # Casos de uso de perfil/home.
    presentation/
      home_screen.dart                         # Pantalla principal tras login.
      profile_screen.dart                      # Pantalla de perfil editable.
      models/
        home_summary.dart                      # Resumen calculado solo para UI.
      widgets/
        home_cards.dart                        # Cards del Home.
        home_content.dart                      # Layout del Home.
        home_route_list.dart                   # Lista de rutas completadas.
        profile_content.dart                   # Layout de perfil.
        profile_forms.dart                     # Formularios de perfil.
        profile_header.dart                    # Cabecera del perfil.

  admin_panel/
    presentation/
      admin_panel_screen.dart                  # Pantalla de administracion actual.

  splash/
    presentation/
      splash_screen.dart                       # Pantalla inicial/carga.
```

## Regla especial: Firestore en espanol

`lib/core/constants/firestore_contract.dart` es una frontera con la base de datos. Sus constantes mantienen nombres en espanol porque representan colecciones y campos reales:

```txt
FirestoreCollections.usuarios                  # Coleccion usuarios.
FirestoreCollections.rutas                     # Coleccion rutas.
FirestoreCollections.puntosInteres             # Coleccion puntos_interes.
UserFields.nombre                              # Campo nombre.
UserFields.usuario                             # Campo usuario.
RouteFields.idPuntosInteres                    # Campo id_puntos_interes.
CompletedRouteFields.puntosObtenidos           # Campo puntos_obtenidos.
```

Esto es intencional. El objetivo es que al leer una clase de `data/` se identifique rapido cuando se esta llamando a la BD. No convertir estos nombres a ingles salvo que tambien se migre la base de datos.

## Validacion recomendada

Desde Codex, usar estos comandos:

```powershell
flutter analyze --no-pub
git diff --check
```

Si Dart/Flutter se queda colgado por cache o telemetria:

```powershell
Stop-Process -Name dart,dartvm -Force
```

`dart format lib` funciona, pero en este proyecto conviene ejecutarlo solo cuando el cambio lo justifique porque toca muchos archivos.

## Estado actual

- La estructura principal ya esta separada en `app`, `core` y `features`.
- Las features principales siguen `data/domain/presentation`.
- Los repositorios tienen interfaz en `domain/repositories` e implementacion en `data/repositories`.
- Los widgets transversales viven en `core/widgets` o `app/widgets`.
- Los widgets especificos viven dentro de su feature en `presentation/widgets`.
- El flujo de rutas, quiz y resultado fue probado manualmente despues del refactor.
- Ultima validacion tecnica conocida: `flutter analyze --no-pub` sin issues.
