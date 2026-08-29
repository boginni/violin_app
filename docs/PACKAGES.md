# Local packages (`packages/*`)

The root `pubspec.yaml` declares `workspace: [packages/*]` and depends on each
via a `path:` dependency. All are `publish_to: 'none'` and use
`resolution: workspace`, except `error_handler_with_result`, which is written
to be publishable standalone. Use the `new-package` skill to scaffold a new one
with the same shape.

## `error_handler_with_result`

The `Result<T>` / `Failure` contract every repository speaks. See
[docs/ARCHITECTURE.md](ARCHITECTURE.md#result--failure-contract-error_handler_with_result)
for the full contract and usage rules. Exports `src/result.dart` and
`src/failure.dart` via its barrel file. Has the most complete README of any
local package — read it before changing error-handling behavior.

## `custom_go_router`

Wraps `go_router` with two abstract types (`AppRouteConfig`, `AppRoute`) and a
`CustomGoRoute` that bridges them into a real `GoRoute`, plus `BuildContext`
navigation extensions (`goToRoute`, `pushRoute`, `maybePop`, ...). See
[docs/ARCHITECTURE.md](ARCHITECTURE.md#routing-custom_go_router--go_router).
Depends on `go_router: ^14.8.1`.

## `violin_design_system`

Design-system atoms: `CustomFontBuilder`, `InverseBrightnessBuilder` (+
`ThemeRegistry`, an `InheritedWidget` exposing the light/dark theme pair down
the tree — used by `AppWidget`), `RainbowThemeBuilder`, `PlaceHolderImage`,
`FaviconImage` (network favicon fetch through a proxy, with graceful fallback
to `PlaceHolderImage`). Depends on `violin_assets` (path dep); dev-depends on
`network_image_mock` for its own golden tests
(`test/src/atoms/*_golden_test.dart`). This is where new shared, reusable
visual atoms belong — feature-specific widgets stay in
`lib/src/ui/<feature>/components/`.

## `violin_assets`

Generated asset accessor. `lib/src/violin_assets_resources.dart` is marked
"GENERATED CODE - DO NOT MODIFY BY HAND" and is produced by
`scripts/generate_sources.dart` from `assets/resources/`. To add a new asset:
drop the file into `assets/resources/`, re-run the generator script, then
reference it as `ViolinAssetsResources.<generatedName>` — never hand-edit the
generated file.

## `violin_l10n`

Localization facade over Flutter's `intl`/ARB codegen. `l10n.yaml` points at
`lib/src/l10n`, template `intl_en.arb`; `intl_pt.arb` provides pt-BR. Generates
`lib/src/gen/app_localizations.g.dart`, which app code never imports directly
— instead use the `context.l10n` extension and the `ViolinL10n` facade
(`localizationsDelegates`, `supportedLocales`) that this package exports. Add a
new string to **both** ARB files before using it.

## Adding a new local package

Use the `new-package` skill, or by hand:

1. `packages/<name>/pubspec.yaml` with `publish_to: 'none'`, `resolution: workspace`.
2. `packages/<name>/lib/<name>.dart` as the public barrel file (only export
   from `src/`, never let consumers import `package:<name>/src/...`).
3. `packages/<name>/lib/src/...` for implementation.
4. `packages/<name>/README.md` describing what the package is for.
5. `packages/<name>/test/` mirroring `lib/src/`.
6. Add `<name>:\n    path: packages/<name>` under `dependencies:` in the root
   `pubspec.yaml`, then `flutter pub get`.
