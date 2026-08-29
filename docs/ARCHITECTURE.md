# Architecture

Domain-first Clean Architecture, three layers under `lib/src/`, plus a
`packages/` workspace of reusable local packages. State management is a
hand-rolled "BLoC-lite": `ChangeNotifier` + a sealed `State` type, no `bloc`
package, no code generation.

## Layers

```
lib/src/
  domain/      Pure Dart. No Flutter, no dio, no external packages besides
               error_handler_with_result. Entities, params, repository
               interfaces. This is the contract the rest of the app targets.
  external/    Implementations of the domain contracts: models (JSON <->
               entity), datasources (dio/local calls, throw on error),
               repository impls (catch + wrap into Result), interceptors,
               in-memory providers.
  ui/          Flutter. Pages, dumb components, controllers, stores/state,
               routing, DI wiring, theming, extensions.
```

Dependency direction is strictly `ui → domain ← external`. `ui` never imports
`external` directly — it resolves everything through `AppDependencies`
(get_it), typed as the domain interface.

## Data flow, end to end

```
Page (widget)
  → Controller.someAction()
      → Store.state = XState.loading()          // ChangeNotifier.notifyListeners()
      → Repository.method(params)                // domain interface, Future<Result<T>>
          → RepositoryImpl.method(params)         // external, try/catch
              → Datasource.method(params)         // external, throws on failure
                  → Dio (HTTP) and/or a *Provider (in-memory cache)
              ← returns raw Entity/Model or throws
          ← Result.success(value) / Result.failureFromCatch(e, s)
      → Store.state = XState.success(value) / XState.failure(result.failure)
  ← Page rebuilds via ListenableBuilder, `switch (store.state) { ... }`
```

Concrete example already in the repo: `HomePage` → `HomeController.shortenUrl` →
`ShortenUrlRepository` (domain) → `ShortenUrlRepositoryImpl` (external) →
`ShortenUrlDatasource` → `Dio` + `ShortenUrlHistoryProvider`.

### Result / Failure contract (`error_handler_with_result`)

```dart
class Result<T> {
  const Result.success([T? value]);
  const Result.failure(Failure failure);
  factory Result.failureFromCatch(dynamic e, StackTrace s); // wraps unknown errors
  bool get isSuccess;
  bool get isFailure;
  T get success;       // throws if failure
  Failure get failure;
}

abstract class Failure implements Exception {
  bool get isFatal;
  Never throwError();  // rethrows with original stack trace
}
abstract class TimeoutFailure implements Failure {}
abstract class ClientServerFailure implements Failure {}
```

Rules:
- **Datasources throw.** They never construct a `Result` or a `Failure` directly
  (except app-specific `Failure` subtypes raised by an interceptor, e.g. Dio errors).
- **Repository impls are the only place `Result` is constructed**, by wrapping
  the datasource call:
  ```dart
  Future<Result<T>> method(Params p) async {
    try {
      return Result.success(await datasource.method(p));
    } catch (e, s) {
      return Result.failureFromCatch(e, s);
    }
  }
  ```
- **Controllers decide what to do with a failure** — typically set the store's
  failure state and, for genuinely fatal/unexpected failures, call
  `result.failure.throwError()` so it surfaces like an uncaught exception
  (visible in error reporting) while the UI still shows a failure state.
- App-specific failure types (e.g. Dio classification) live in
  `lib/src/external/architecture/data_failures.dart` and implement
  `TimeoutFailure`/`ClientServerFailure` so UI code can `switch`/`is`-check on
  the semantic type rather than on `DioException`.

## State pattern (Store)

```dart
class HomeStore extends ChangeNotifier implements ValueListenable<HomeStoreState> {
  HomeStoreState _state = HomeStoreState.success();
  HomeStoreState get state => _state;
  set state(HomeStoreState value) {
    _state = value;
    notifyListeners();
  }
  @override
  HomeStoreState get value => _state;
}

sealed class HomeStoreState {
  const HomeStoreState();
  factory HomeStoreState.loading() = HomeStoreLoadingState;
  factory HomeStoreState.failure(Failure failure) = HomeStoreFailureState;
  factory HomeStoreState.success() = HomeStoreSuccessState;
}
```

- Only the Store's `state` setter calls `notifyListeners()`. Controllers never
  call `notifyListeners()` directly — they only ever write `store.state = ...`.
- The sealed class + factory-constructor-per-variant pattern is deliberate: it
  makes the widget's `switch (store.state) { ... }` exhaustive and
  compiler-checked whenever a variant is added or removed.
- A page/component that depends on more than one store subscribes with
  `ListenableBuilder(listenable: Listenable.merge([storeA, storeB]), ...)`.

## Controller

A `Controller` is a plain (usually `const`) class, not a `ChangeNotifier`
itself — it holds one or more `Store`s and the domain repositories it needs,
and exposes intent methods (`shortenUrl`, `init`, ...) that the Page calls in
response to user input or lifecycle events:

```dart
class HomeController {
  const HomeController(this.repository, this.runtimeRepository, {
    required this.store,
    required this.shortenHistoryStore,
  });
  final HomeStore store;
  final ShortenHistoryStore shortenHistoryStore;
  final ShortenUrlRepository repository;
  final DeviceRuntimeRepository runtimeRepository;

  Future<void> shortenUrl(String url) async {
    store.state = HomeStoreState.loading();
    final result = await repository.shortenUrl(ShortenUrlParamsEntity(url: url));
    if (result.isFailure) {
      store.state = HomeStoreState.failure(result.failure);
      result.failure.throwError();
    }
    store.state = HomeStoreState.success();
  }
}
```

Pages are `StatefulWidget`s that call `controller.init()` from
`addPostFrameCallback` in `initState` (never synchronously in `build`/`initState`
itself, to avoid notifying listeners before the first frame is built).

## Dependency injection (`get_it`)

All app-wide bindings live in one place, `lib/src/ui/app/app_dependencies.dart`:

```dart
class AppDependencies {
  static final GetIt _app = GetIt.asNewInstance();
  static void init() => _init(_app);

  static void _init(GetIt i) {
    final dio = Dio();
    dio.interceptors.add(DioFailureHandlingInterceptor());

    i.registerSingleton(dio);            // shared, long-lived
    i.registerSingleton(AppStore());

    i.registerFactory(ShortenUrlHistoryProvider.new);
    i.registerFactory(() => ShortenUrlDatasource(dio, i.get()));
    i.registerFactory<ShortenUrlRepository>(         // bind to the INTERFACE
      () => ShortenUrlRepositoryImpl(i.get()),
    );

    // --   <- new registrations go above this marker
  }

  static void restart() => _app.reset();
  static T get<T extends Object>({...}) => _app.get();
  static void registerSingleton<T extends Object>(T instance) => _app.registerSingleton(instance);
}
```

Rules of thumb:
- `registerSingleton` for things that must be shared/stateful across the app
  (`Dio`, top-level app `Store`s).
- `registerFactory` for everything else, including repositories — always typed
  to the **domain interface** (`registerFactory<ShortenUrlRepository>(...)`),
  never the concrete impl, so call sites can only ever depend on the interface.
- A feature that needs its own isolated DI scope (rare) can declare a second
  `GetIt.asNewInstance()`, as sketched in `lib/src/ui/shell/shell_dependencies.dart`.
  Most features don't need this — `AppDependencies.get()` is enough.
- `AppController` is a special case: it's registered as a singleton from
  `AppWidget.initState()`, not from `_init`, because it needs the widget's
  own controller instance.

## Routing (`custom_go_router` + `go_router`)

Each screen is a matched **config/route pair**:

```dart
class ShellRouteConfig extends AppRouteConfig {
  static const basePath = 'shell';
  @override final fullPath = '/$basePath';
  @override bool hasValidParams(Map<String, String> params, {Object? extra}) => true;
  @override AppRoute getRouteFromParams(Map<String, String> params) => ShellRoute();
}

class ShellRoute extends AppRoute {
  late final store = ShellStore();
  late final shellController = ShellController(
    appController: AppDependencies.get(),
    store: store,
    homeController: HomeController(AppDependencies.get(), AppDependencies.get(),
      store: HomeStore(), shortenHistoryStore: ShortenHistoryStore()),
  );
  @override String toPath() => Uri(path: '/${ShellRouteConfig.basePath}').toString();
  @override Widget toScreen({Object? extra}) => ShellPage(controller: shellController);
}
```

- `*RouteConfig` owns path/param validation and constructs the `*Route` from
  raw path/query params (`hasValidParams`, `getRouteFromParams`).
- `*Route` owns building the screen's controller/store graph (`late final`
  fields, pulling shared deps from `AppDependencies.get()`) and exposes
  `toPath()` / `toScreen({extra})`.
- Register the pair once, in `lib/src/ui/app/app_routes.dart`:
  ```dart
  GoRouter(
    initialLocation: SplashRoute().toPath(),
    routes: [
      CustomGoRoute(config: SplashRouteConfig()),
      CustomGoRoute(config: ShellRouteConfig()),
      // add new CustomGoRoute(config: YourRouteConfig()) here
    ],
  )
  ```
- Navigate via the `BuildContext` extensions in `custom_go_router`, not raw
  `go_router` calls: `context.goToRoute(SomeRoute())`, `context.pushRoute(...)`,
  `context.maybePop()`.

## Cross-cutting UI helpers

- `lib/src/ui/app/extensions/context_extensions.dart` — use `context.theme`,
  `context.textTheme`, `context.colorScheme`, `context.width/height`,
  `context.isDarkMode`, etc. instead of `Theme.of(context)` directly.
- `context.l10n` (from `violin_l10n`) for all user-facing strings — never hardcode
  strings in widgets.
- `lib/src/domain/environment.dart` — compile-time config via
  `String.fromEnvironment`/`bool.fromEnvironment` (`--dart-define`), not a
  `.env` loader.
