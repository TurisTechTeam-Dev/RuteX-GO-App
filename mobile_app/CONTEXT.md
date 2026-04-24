# RuteX Go Mobile Context

## Current Priority

The immediate priority is a large refactor of the Flutter codebase. The project has mixed architecture and mixed Spanish/English naming, especially around repositories, domain interfaces, data implementations, models, and data sources.

## Refactor Goal

- Use English for Dart classes, methods, variables, folders, and file names where possible.
- Keep Firestore collection names and field keys unchanged unless the database contract is intentionally migrated.
- Put files in the layer where they belong:
  - `data/datasources` for remote/local data sources.
  - `data/models` for DTO/data models.
  - `data/repositories` for repository implementations.
  - `domain/entities` for domain entities.
  - `domain/repositories` for repository interfaces.
  - `domain/usecases` for use cases.
  - `presentation` for screens, widgets, providers, and UI-facing models.
- Avoid behavior changes during structural refactors unless required to keep the app compiling.

## Known Pain Points

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
dart format lib
Formatted 77 files (42 changed) in 0.45 seconds.

flutter analyze --no-pub
No issues found.
```
