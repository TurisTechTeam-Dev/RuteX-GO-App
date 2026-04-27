# RuteX Go Mobile Context

## Current Priority

The immediate priority is to deliver a functional Codex branch for review. Codex is the mother branch and must remain the most advanced, clean, and readable version of the app.

## Day Plan

1. Finish the mobile readability refactor by removing hard-to-read spreads, compact lambda chains, and dense functional style where it harms class readability.
2. Test the mobile app with login, Google login, register, route selection, route completion, and profile/home refresh.
3. Fix the route completion permission issue for the demo: the client writes route progress directly, and Firestore rules allow normal users to update only their own profile/progress fields.
4. Bring the web branch into this workspace after the mobile route-completion fix.
5. Refactor web code to follow the same readability and naming rules as Codex.
6. Fix web issues and polish admin-facing visual flows.
7. Leave Codex correct as the final integration branch: mobile, backend route completion, and admin web.
8. At final delivery/push to develop/main, remove Codex-only context docs such as `CONTEXT.md`, `NUEVA_ESTRUCTURA.md`, `REFACTOR_CHANGES.md`, and `docs/base_datos_firestore.md` if the team decides they should not ship.

## Refactor Goal

- Use English for Dart classes, methods, variables, folders, and file names where possible.
- Keep Firestore collection names and field keys unchanged unless the database contract is intentionally migrated.
- Keep code readable for the current team level: prefer named helper methods, explicit loops, and clear intermediate variables over dense lambda chains when the logic is important.
- UI/web/admin code must follow Codex style and avoid compact or clever constructs that make review harder.
- Put files in the layer where they belong:
  - `data/datasources` for remote/local data sources.
  - `data/models` for DTO/data models.
  - `data/repositories` for repository implementations.
  - `domain/entities` for domain entities.
  - `domain/repositories` for repository interfaces.
  - `domain/usecases` for use cases.
  - `presentation` for screens, widgets, providers, and UI-facing models.
- Avoid behavior changes during structural refactors unless required to keep the app compiling.

## Security / Backend Rule

Demo implementation:

- Flutter writes completed route progress directly to Firestore from `MissionRepositoryImpl.saveBestRouteProgress`.
- `firestore.rules` allows normal users to update their own `usuario`, `avatar`, `email`, `ultimo_acceso`, `puntos`, and `rutas_completadas`.
- `firestore.rules` still blocks normal users from changing `isAdmin`, `uid`, and `fecha_creacion`.
- `storage.rules` allows users to upload avatar images only under `Avatares/{uid}/...`.

Future professional implementation:

- Move route completion back to backend code with Cloud Functions.
- Then remove `puntos` and `rutas_completadas` from the normal-user update allowlist.

## Known Pain Points

- The `web` branch is not safe to merge wholesale into `codex`: it deletes/refactors large parts of the mobile app and renames architecture away from Codex conventions.
- The admin panel was imported selectively from `web`: `lib/features/admin_panel`, `lib/core/widgets/nav_web`, and the required Firestore field constants.
- Imported admin/web files currently compile and pass `flutter analyze --no-pub`; visual/manual web testing is still pending.

- Some features use `domain/repository` while others use `domain/repositories`.
- Repository implementations currently live directly under `data` in some features and under `data/repository` in others.
- Some method names are Spanish, for example route and point lookup methods.
- Some variables mix Spanish and English in the same scope.
- Firestore constants intentionally expose Spanish database keys such as `usuarios`, `rutas`, `puntos_interes`, `nombre`, and `puntos`; these are external data contracts, not code style targets.

## Refactor Order

1. Normalize feature folder structure.
2. Rename repository interfaces and implementations to English method names.
3. Rename internal variables and parameters to English.
4. Fix imports and usage sites.
5. Run validation with the commands documented below.

## Validation Note

`dart format` and `flutter analyze` work, but Codex must run them outside the filesystem sandbox because Dart/Flutter writes telemetry/cache files under:

```txt
C:\Users\Diego\AppData\Roaming\.dart-tool\
```

If run inside the sandbox, commands can appear to hang and may leave `dart`/`dartvm` processes alive. The observed root error was:

```txt
FileSystemException: Failed to set file modification time, path = 'C:\Users\Diego\AppData\Roaming\.dart-tool\dart-flutter-telemetry-session.json' (OS Error: Acceso denegado, errno = 5)
```

Use these validation commands from Codex with escalated permissions:

```powershell
dart format lib
flutter analyze --no-pub
git diff --check
```

If processes are already stuck, close them first:

```powershell
Stop-Process -Name dart,dartvm -Force
```

Last known successful validation:

```txt
dart format lib\features\mission\data\repositories\mission_repository_impl.dart lib\features\auth\data\repositories\auth_repository_impl.dart
Formatted 2 files.

flutter analyze --no-pub
No issues found.

flutter test --no-pub test\routes_use_cases_test.dart
All tests passed.

```
