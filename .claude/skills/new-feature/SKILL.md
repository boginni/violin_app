---
name: new-feature
description: Scaffold a new feature end-to-end in this Flutter Clean Architecture template — domain entity/params/repository, external model/datasource/repository impl, DI registration, UI store/controller/page/components, routing, and tests at every layer. Use when the user asks to add a new feature, screen, endpoint, or repository to this app.
---

# New feature scaffold

This repo is a domain-first Clean Architecture Flutter template (see
`/CLAUDE.md`, `docs/ARCHITECTURE.md`, `docs/CONVENTIONS.md`, `docs/TESTING.md`
at the repo root). This skill turns "add feature X" into the exact sequence of
files this template expects, in the naming/style already used by the
`ShortenUrl` feature (`lib/src/domain/...`, `lib/src/external/...`,
`lib/src/ui/home/...`) — read one or two of those files first if anything
below is ambiguous, they are the canonical example.

Before writing anything, ask the user (or infer from their request) for:
- The feature name (used to derive `FeatureName`, `feature_name` file prefixes).
- What data it needs (fields on the entity) and what params it takes.
- Whether it needs a network call, local storage, or both.
- Whether it's a new screen (needs a route) or is embedded in an existing one.

Do not scaffold layers the feature doesn't need (e.g. skip params if a method
takes no arguments; skip a `*Provider` if there's no local cache), but keep the
suffixes and file locations below exactly — that consistency is the point of
the template.

## Step-by-step

### 1. Domain layer (`lib/src/domain/`)

1. `dto/entities/<feature>_entity.dart` — immutable `class` (or several,
   colocated, if closely related), `const` constructor, only `final` fields.
2. `dto/params/<feature>_params_entity.dart` — one class per repository method
   that needs input; multiple related params classes can share one file (see
   `shorten_url_params_entity.dart`).
3. `repositories/<feature>_repository.dart` — `abstract interface class
   <Feature>Repository`, one method per use case, every method returns
   `Future<Result<T>>` (`Result` from `package:error_handler_with_result/error_handler_with_result.dart`).

### 2. External layer (`lib/src/external/`)

4. `dto/models/<feature>_model.dart` — `class <Feature>Model extends
   <Feature>Entity` with `fromJson`, `toJson`, `fromEntity`, `toEntity`
   (hand-written, no `json_serializable`/`freezed`).
5. `dto/params/<feature>_params_model.dart` if a params entity needs to become
   a JSON body — same `fromEntity`/`toJson` shape.
6. (Only if the feature needs local caching/in-memory storage)
   `provider/<feature>_provider.dart` — private-constructor singleton
   (`factory X() => _instance`), plain get/save/remove methods.
7. `datasources/<feature>_datasource.dart` — plain `class` (not an interface),
   constructor takes `Dio` and/or the provider. Methods **throw** on failure,
   return the raw `Entity`/`Model` (typed as the `Model`, since it extends the
   `Entity`, but callers above only ever see the `Entity` type). Do not catch
   exceptions here.
8. `repositories/<feature>_repository_impl.dart` — `class
   <Feature>RepositoryImpl implements <Feature>Repository`, one datasource
   dependency, every method wraps the datasource call:
   ```dart
   Future<Result<T>> method(Params p) async {
     try {
       return Result.success(await datasource.method(p));
     } catch (e, s) {
       return Result.failureFromCatch(e, s);
     }
   }
   ```
   Never call `.throwError()` here.
9. If the feature needs a new failure classification beyond the generic Dio
   timeout/client-server ones, add it to
   `lib/src/external/architecture/data_failures.dart` implementing
   `TimeoutFailure` or `ClientServerFailure`.

### 3. Register in DI

10. Edit `lib/src/ui/app/app_dependencies.dart`, inside `_init`, **above the
    `// --` marker**:
    ```dart
    i.registerFactory(() => const FeatureDatasource(...));
    i.registerFactory<FeatureRepository>(() => FeatureRepositoryImpl(i.get()));
    ```
    Repositories are always registered against their **interface** type.
    Providers go through `registerFactory` too (see `ShortenUrlHistoryProvider.new`).

### 4. UI layer (`lib/src/ui/<feature>/`)

11. `controllers/<feature>_store.dart` — `<Feature>Store extends
    ChangeNotifier implements ValueListenable<<Feature>StoreState>` plus a
    `sealed class <Feature>StoreState` with named factory constructors for
    each variant the UI needs to render (typically `initial`/`loading`,
    `failure(Failure)`, `success(<data>)`, and `empty()` if an empty-list state
    needs distinct UI).
12. `controllers/<feature>_controller.dart` — plain (`const` if possible)
    class holding the store(s) and the repository interface(s) it needs.
    Intent methods set `store.state = ...` before and after the repository
    call; on failure, set the failure state and decide whether to
    `result.failure.throwError()` (do this for genuinely unexpected/fatal
    failures the user can't act on; don't for expected, recoverable ones the
    failure state already communicates).
13. `pages/<feature>_page.dart` — `StatefulWidget` holding a `controller`;
    `initState` schedules `controller.init()` via
    `WidgetsBinding.instance.addPostFrameCallback`; `build` renders via
    `ListenableBuilder(listenable: store /* or Listenable.merge([...]) */)`
    with an exhaustive `switch (store.state) { ... }`.
14. `components/<name>_component.dart` — dumb `StatelessWidget`s, one per
    state variant if the page renders a sealed state
    (`<feature>_empty_component.dart`, `..._failure_component.dart`,
    `..._loading_component.dart`, `..._success_component.dart`), taking only
    primitives/callbacks, no controller/store access.
15. Use `context.l10n.<key>` for every user-facing string — add the key to
    **both** `packages/violin_l10n/lib/src/l10n/intl_en.arb` and `intl_pt.arb`
    first.

### 5. Routing (only if this feature is a new screen)

16. `lib/src/ui/<feature>/<feature>_routes.dart`:
    ```dart
    class FeatureRouteConfig extends AppRouteConfig {
      static const basePath = 'feature';
      @override final fullPath = '/$basePath';
      @override bool hasValidParams(Map<String, String> params, {Object? extra}) => true;
      @override AppRoute getRouteFromParams(Map<String, String> params) => FeatureRoute();
    }

    class FeatureRoute extends AppRoute {
      late final store = FeatureStore();
      late final controller = FeatureController(AppDependencies.get(), store: store);
      @override String toPath() => Uri(path: '/${FeatureRouteConfig.basePath}').toString();
      @override Widget toScreen({Object? extra}) => FeaturePage(controller: controller);
    }
    ```
17. Register it in `lib/src/ui/app/app_routes.dart`, inside the `routes:` list:
    `CustomGoRoute(config: FeatureRouteConfig())`.
18. Navigate to it from elsewhere with `context.goToRoute(FeatureRoute())` or
    `context.pushRoute(FeatureRoute())` (from `custom_go_router`'s
    `route_extensions.dart`) — never raw `go_router` calls.

### 6. Tests (`test/src/...`, mirroring the paths above)

Write these even if the closest existing example in the repo is missing one —
see `docs/TESTING.md`'s "Gap to be aware of" note; don't skip the controller
test just because `home_controller_test.dart` doesn't exist yet.

19. `test/src/domain/repositoires/<feature>_repository_test.dart` — mock the
    interface (`MockFeatureRepository extends Mock implements
    FeatureRepository`), `Fake` classes for every params/entity type used with
    `any()`, `given/when/then`-style test names, `verify(...).called(1)`.
20. `test/src/external/repositories/<feature>_repository_impl_test.dart` —
    mock the datasource, assert `Result.isSuccess`/`isFailure` mapping,
    `verifyNoMoreInteractions(datasource)`; failure path uses
    `thenThrow(const TestFailure())` (import `flutter_test` with `hide
    TestFailure`).
21. `test/src/external/datasources/<feature>_datasource_test.dart` — mock
    `Dio` (and provider, if any), assert the exact request made and that
    failures propagate by throwing.
22. `test/src/ui/<feature>/controllers/<feature>_controller_test.dart` — mock
    the repository, assert the store transitions through the right sequence
    of states (`loading` → `success`/`failure`) and that failure states carry
    the right `Failure`.
23. `test/src/ui/<feature>/components/` and `pages/` — widget tests pumped
    inside `MaterialAppTesting` (see `test/material_app_testing.dart`), plus
    golden tests (`golden_toolkit` + `mockNetworkImagesFor`) if the feature has
    meaningful visual states. Run `flutter test --update-goldens` once to
    generate the initial golden files, then review the generated PNGs.

## After scaffolding

Run:
```bash
flutter analyze
flutter test
```
and fix anything flagged before considering the feature done.
