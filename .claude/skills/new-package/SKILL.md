---
name: new-package
description: Scaffold a new local workspace package under packages/ in this Flutter template (pubspec, barrel file, src/, README, test/, and wiring it into the root pubspec workspace). Use when the user asks to add a new shared/local package, e.g. a new design-system module, a networking helper, or any code meant to be shared across features or reused in another project.
---

# New local package scaffold

This repo uses a `pubspec.yaml` `workspace: [packages/*]` layout — see
`docs/PACKAGES.md` at the repo root for what each existing package
(`custom_go_router`, `error_handler_with_result`, `violin_assets`,
`violin_design_system`, `violin_l10n`) is responsible for, so you don't duplicate one
of them by accident.

Ask the user for the package name (snake_case, e.g. `violin_analytics`) and a
one-sentence description of what it's for before scaffolding.

## Steps

1. Create the directory structure:
   ```
   packages/<name>/
     lib/
       <name>.dart          # public barrel file — the ONLY file consumers import
       src/                 # implementation, never imported directly by consumers
     test/
     README.md
     pubspec.yaml
     CHANGELOG.md           # only if the package might ever be published standalone
   ```

2. `pubspec.yaml`:
   ```yaml
   name: <name>
   description: "<one-sentence description>"
   version: 0.0.1
   publish_to: 'none'
   resolution: workspace

   environment:
     sdk: ^3.11.0

   dependencies:
     flutter:
       sdk: flutter
     # add path deps on other local packages the same way the root does, e.g.:
     # violin_assets:
     #   path: ../violin_assets

   dev_dependencies:
     flutter_test:
       sdk: flutter
     flutter_lints: ^6.0.0
   ```
   Match dependency versions to what's already used elsewhere in the workspace
   (check `pubspec.lock` / another package's `pubspec.yaml`) rather than
   picking new ones.

3. `lib/<name>.dart` — export only from `src/`:
   ```dart
   export 'src/some_public_thing.dart';
   ```

4. Implementation goes in `lib/src/...`. Follow the same layering conventions
   as the app if the package has its own domain/external/ui split (most local
   packages here don't — they're single-purpose: design-system atoms, a
   router wrapper, an error type, generated assets, l10n).

5. `README.md` — what the package is for and a minimal usage snippet. Look at
   `packages/error_handler_with_result/README.md` for the level of detail
   expected (it's the most complete one in the repo).

6. `test/` mirroring `lib/src/`. Use `mocktail` for mocks, matching the app's
   testing conventions (`docs/TESTING.md`) — no `mockito`/`build_runner`.

7. Wire it into the root `pubspec.yaml`, under `dependencies:`, alphabetically
   with the other local packages:
   ```yaml
   <name>:
     path: packages/<name>
   ```
   Then run:
   ```bash
   flutter pub get
   ```

8. If the package needs golden tests (visual widgets), add
   `golden_toolkit` and, if it renders network images, `network_image_mock` to
   `dev_dependencies`, matching `packages/violin_design_system/pubspec.yaml`.

## After scaffolding

```bash
flutter pub get
flutter analyze
flutter test
```
