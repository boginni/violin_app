# Conventions

## Naming by layer

| Layer | Suffix / shape | Example |
|---|---|---|
| Domain entity | `*Entity` (plain immutable class, `const` constructor) | `ShortenedUrlEntity` |
| Domain params | `*ParamsEntity` | `ShortenUrlParamsEntity` |
| Domain repository | `*Repository`, `abstract interface class` | `ShortenUrlRepository` |
| External model | `*Model extends <matching>Entity` | `ShortenedUrlModel extends ShortenedUrlEntity` |
| External params model | `*ParamsModel` | `ShortenUrlParamsModel` |
| External repository impl | `*RepositoryImpl implements <Domain>Repository` | `ShortenUrlRepositoryImpl` |
| Datasource | `*Datasource` (plain class, not an interface, throws) | `ShortenUrlDatasource` |
| Local/in-memory provider | `*Provider` (singleton factory) | `ShortenUrlHistoryProvider` |
| Dio interceptor | `*Interceptor extends dio.Interceptor` | `DioFailureHandlingInterceptor` |
| App-specific failure | `*Failure` implementing `Failure`/`TimeoutFailure`/`ClientServerFailure` | `DioClientServerFailure` |
| UI controller | `*Controller` (plain class, holds Store(s) + repos) | `HomeController` |
| UI store | `*Store extends ChangeNotifier implements ValueListenable<*StoreState>` | `HomeStore` |
| UI state | `sealed class *State`/`*StoreState`, factory ctor per variant | `HomeStoreState` |
| Page | `*Page` (`StatefulWidget`, holds a `controller`) | `HomePage` |
| Dumb component | `*Component` (`StatelessWidget`, primitives/callbacks only) | `HomeHeaderComponent` |
| Route config | `*RouteConfig extends AppRouteConfig` | `ShellRouteConfig` |
| Route | `*Route extends AppRoute` | `ShellRoute` |

## Folder layout

```
lib/src/domain/
  dto/entities/<name>_entity.dart
  dto/params/<name>_params_entity.dart      (related params can share a file)
  repositories/<name>_repository.dart       (interface only)
  environment.dart

lib/src/external/
  architecture/                              app-specific Failure subtypes
  datasources/<name>_datasource.dart
  dto/models/<name>_model.dart
  dto/params/<name>_params_model.dart
  interceptors/<name>_interceptor.dart
  provider/<name>_provider.dart
  repositories/<name>_repository_impl.dart

lib/src/ui/<feature>/
  controllers/<feature>_controller.dart
  controllers/<feature>_store.dart           (sealed *StoreState lives alongside)
  components/<name>_component.dart           (one file per state-variant if the
                                               component renders a sealed state)
  pages/<feature>_page.dart
  <feature>_routes.dart                      (RouteConfig + Route pair)
  <feature>_dependencies.dart                (only if the feature needs a scoped GetIt)
```

`test/` mirrors `lib/src/` 1:1, with a sibling `goldens/` directory next to any
widget test file that has golden coverage.

## Import style

- **Relative imports within `lib/`** — enforced by `prefer_relative_imports` in
  `analysis_options.yaml`. Only use `package:violin_app/...` from `test/`.
- Local workspace packages (`violin_design_system`, `violin_l10n`, `violin_assets`,
  `custom_go_router`, `error_handler_with_result`) are imported as
  `package:<name>/<name>.dart` (the package's public barrel file) from both
  `lib/` and `test/`.

## Lints of note (`analysis_options.yaml`, extends `flutter_lints/flutter.yaml`)

- `prefer_relative_imports`, `require_trailing_commas`,
  `always_declare_return_types`, `use_super_parameters`,
  `prefer_single_quotes`, `type_annotate_public_apis`,
  `sort_unnamed_constructors_first` — on.
- `sort_constructors_first`, `library_private_types_in_public_api` — off.
- `todo` — not an error; TODOs are allowed.
- `**/*.mocks.dart`, `**/*.freezed.dart`, `**/*.mock.dart` are excluded from
  analysis (the repo doesn't currently generate any of these — mocks are
  hand-written with `mocktail`, not `mockito`/`build_runner` — but the
  exclusion is there in case a fork adds them).

## Serialization

No `json_serializable`/`freezed`. `*Model` classes hand-write
`fromJson`/`toJson`/`fromEntity`/`toEntity`:

```dart
class ShortenedUrlModel extends ShortenedUrlEntity {
  const ShortenedUrlModel({required super.id, required super.url, required super.originalUrl});

  factory ShortenedUrlModel.fromJson(Map<String, dynamic> json) => ShortenedUrlModel(
    id: json['id'] as int,
    url: json['url'] as String,
    originalUrl: json['url_original'] as String,
  );

  Map<String, dynamic> toJson() => {'id': id, 'url': url, 'url_original': originalUrl};

  factory ShortenedUrlModel.fromEntity(ShortenedUrlEntity entity) =>
      ShortenedUrlModel(id: entity.id, url: entity.url, originalUrl: entity.originalUrl);

  ShortenedUrlEntity toEntity() => ShortenedUrlEntity(id: id, url: url, originalUrl: originalUrl);
}
```

Because `Model extends Entity`, a datasource can return a `Model` typed as the
`Entity` and nothing above the datasource ever needs to know `Model` exists.

## Environment / config

`lib/src/domain/environment.dart` reads compile-time constants via
`String.fromEnvironment` / `bool.fromEnvironment`, supplied with
`--dart-define=KEY=value` at build/run time — there is no `flutter_dotenv` or
`.env` file loader wired up. `example.env` documents a superset of keys (some,
like the mock-auth/location ones, aren't consumed by any code yet); treat it as
a template for what a real fork might need, not as active configuration.

## Localization

All strings go through ARB files in `packages/violin_l10n` (`intl_en.arb`,
`intl_pt.arb`) and are consumed via `context.l10n.<key>` — never hardcode
user-facing text in a widget.
