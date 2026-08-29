# violin_app

A Flutter template: domain-first Clean Architecture with a ChangeNotifier-based
"BLoC-lite" state pattern, a local `packages/*` workspace, and a working
example feature (URL shortener) demonstrating every layer end to end.

Meant to be forked as the starting point for new Flutter apps or technical
tests — copy the repo, rename the package, and start scaffolding features with
the conventions already in place.

## Getting started

```bash
flutter pub get
flutter run --dart-define=BASE_URL=<api-base-url> --dart-define=IS_PRODUCTION=false
flutter test
```

## Documentation

- [CLAUDE.md](CLAUDE.md) — start here: architecture summary, conventions, commands
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — layers, data flow, DI, routing
- [docs/CONVENTIONS.md](docs/CONVENTIONS.md) — naming, folder layout, style rules
- [docs/TESTING.md](docs/TESTING.md) — test conventions, mocking, goldens
- [docs/PACKAGES.md](docs/PACKAGES.md) — what each package under `packages/` is for

Two Claude Code skills (`.claude/skills/new-feature`, `.claude/skills/new-package`)
automate scaffolding a new feature or local package in the established style.
