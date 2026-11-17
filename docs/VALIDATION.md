# Verified results — 17 November 2026

Current toolchain: **Flutter 3.50.0 / Dart 3.14.0**, official tag `3.50.0` at `ab2912035e160d9cad6306df307576da6128ebdb`, using a separate SDK for this project. Host: macOS 27.2.1 Apple Silicon, Chrome 157, Xcode 27.2, CocoaPods 1.16.2. The shared/global Flutter 3.41.9 installation was not upgraded.

These checks were rerun after the final two patch overrides were applied. The Web edit dialog was opened and cancelled without changing existing records, and the rebuilt macOS app was quit and relaunched to verify the current binary.

## Current checks

- Formatting on `lib` and `test`: clean with the current Dart formatter.
- `flutter analyze --no-pub`: no issues.
- `flutter test --coverage --no-pub`: **20 passed**. Includes real SQLite v1→v2 migration, reopen/undo/ID reuse/retry, input boundaries, filters/search/order, controller failures, widget CRUD/priority/retry/accessibility, narrow layout at 150% text size, and a new regression verifying that the current Material dropdown is disabled during save.
- Measured line coverage: **397/404 (98.3%)**. This covers imported application files, not every platform bootstrap path; it is not branch or mutation coverage. CI uploads its own LCOV report.
- Dependency refresh: all direct registry dependencies and transitive dependencies updated, including exact project-local overrides for `material_color_utilities` **0.13.1** and `test_api` **0.7.15**. No outdated entries remain with overrides enabled. See [DEPENDENCIES.md](DEPENDENCIES.md) and [the machine-readable audit](dependency-audit.json).
- SQLite Web worker and WASM regenerated together using `dart run sqflite_common_ffi_web:setup --force`.
- `flutter build web --release --no-wasm-dry-run --no-pub`: passed. This is the JavaScript Flutter target using SQLite's WASM binary, not a production Flutter Wasm-runtime test.
- `flutter build macos --release --no-pub`: passed. `file` confirms **arm64 + x86_64** slices in the universal binary. The app was opened on Apple Silicon and showed the three native tasks from the earlier version. Intel runtime execution was not performed.
- `flutter build ios --release --no-codesign --no-pub`: passed (18.4 MB). This is an unsigned device build, not a phone/simulator execution or a signed distribution artifact.
- Android: SDK/JDK are installed, but the existing license warning remains unresolved; no terms accepted and no Android build/device validation claimed.

The first upgraded Apple builds found stale precompiled headers. Clearing only this project's generated macOS/ iOS build artifacts and the verified iOS workspace's intermediates fixed the issue. The Flutter 3.41/Xcode 27 universal `lipo` limitation recorded in the initial log is superseded by the successful current universal build. The old single-architecture workaround is no longer required with the verified SDK.

Flutter generated its supported Swift Package integration. The project's custom CocoaPods configuration is retained; the tool suggests optional manual removal for build-time improvement, but both builds complete with the current integration. No global Flutter feature flags or shared caches were modified.

## Actual runtime and data compatibility

The compiled current Web release was opened at `http://127.0.0.1:8765`, on the same origin used by the previous package versions. It reopened **all four existing tasks** with their titles, descriptions, priorities and completion counts (two pending, two completed). The accessible tree retains independent completion/edit/delete controls, the rendered app was visually checked, and its captured console reported no warnings/errors. No app state was injected.

The current macOS release was launched from its built app bundle. It opened the independent native SQLite database and retained its **three existing example tasks**, including completion status. The schema remains version 2 and the filename remains `todo_list.db`; no storage-format migration was added merely to upgrade packages.

The initial modernization also exercised real create, validation, multiline edit, completion/filter, delete/undo, reload persistence, empty search and keyboard focus in Chrome, plus the responsive 390×844 form. Its screenshots remain useful examples; a narrow browser capture is not a physical phone test. The current desktop and macOS screenshots were refreshed after the package update.

Screenshots: [current Web desktop](screenshots/web-desktop.jpg), [initial empty state](screenshots/web-empty.jpg), [390px layout](screenshots/web-mobile.jpg), [390px form](screenshots/web-mobile-form.jpg), [current macOS](screenshots/macos.jpg).

## Tooling and publication

`crapper --root . --no-coverage lib`, `dryer --root . --threshold 0.8 lib` and `mutator --root . --scan lib` report no supported source files because Dart is not in their supported language lists. No score is inferred from an empty report.

GitHub About remains the verified English description of the offline planner; nine useful topics are preserved. The `Flutter` workflow uses Flutter 3.50.0 on the actual default branch `master`, enforcing formatting, analysis, tests, SQLite worker generation, Web release and artifact upload. The package-upgrade commit's CI passed; the final documentation commit's run is monitored and reported with delivery. No hard-coded passing/coverage badge is used.

The original [Medium article](https://medium.com/flutter-comunidade-br/criando-uma-lista-de-tarefas-com-flutter-fc81fa2bac6a) has now been **updated and republished**, with cover, app images, diagrams, explained code and five exercises. This supersedes the initial signed-out-session limitation. See [publication verification](MEDIUM_PUBLICATION.md) for the normal-reader checks and real proof captures. No subscriber email was sent.
