# Verified results — 17 November 2026

Environment: macOS 27.2.1 Apple Silicon, Flutter 3.41.9 stable, Dart 3.11.5, Chrome 157, Xcode 27.2 and CocoaPods 1.16.2. No global SDK install/update was performed.

## Local checks

- Dart formatting: clean on `lib` and `test`.
- `flutter analyze --no-pub`: no issues.
- `flutter test --coverage --no-pub`: **19 passed**. Model validation, real SQLite migration/reopening/restore/ID reuse protection/retry, state/filter/search/failure behavior, widget CRUD/undo/priority/loading/retry/accessibility, and 390px layout with 150% text.
- Measured line coverage: **395/403 lines (98.0%)**. Generated LCOV from this run is available locally in `coverage/lcov.info`; CI uploads its own report. This is line coverage of imported application files, not branch coverage, not mutation coverage and not evidence that every platform-specific bootstrap path ran.
- `dart run sqflite_common_ffi_web:setup`: generated SQLite worker and binary successfully using the package's official setup tool.
- `flutter build web --release`: succeeded, including the optional Flutter Wasm compatibility dry run. The finalized build uses `--no-wasm-dry-run` and also succeeded. No production Flutter Wasm runtime build was tested.
- macOS default universal release build: **failed**, first on template deployment targets, then on the known Xcode 27 `lipo -verify_arch arm64 x86_64` incompatibility ([upstream issue](https://github.com/flutter/flutter/issues/188346)). The local app/Pods targets were raised to macOS 12. No shared Flutter files were patched.
- macOS **arm64** release build: succeeded with `flutter build macos --release --config-only --no-pub` followed by the single-architecture `xcodebuild` command in the README. `file` confirms an arm64 executable. This does not validate a universal or Intel release.
- `flutter build ios --release --no-codesign --no-pub`: succeeded. This is an unsigned device build, not an iOS device/simulator execution or a distributable signed app.
- Android: doctor detects SDK 36.1 / JDK 21 but reports licenses not accepted. Terms were not accepted and Android build/device validation is not claimed. Android project was migrated to current Flutter templates, v2 embedding, Kotlin and Gradle plugin DSL, retaining its application ID.

## Actual application interaction

Opened the compiled JavaScript release build in Chrome at `http://127.0.0.1:8765` and used the app's actual controls, without a mockup or injected app state:

1. Confirmed empty state and explicitly loaded three local example tasks.
2. Submitted an empty title and observed its validation error.
3. Created a task with a multiline description and priority 1, then reloaded and confirmed the saved record.
4. Edited its title, completed it, filtered completed tasks, deleted it and used undo. Reloaded and verified the restored record and completion totals (two pending, two completed).
5. Searched for unmatched text and observed the empty-results state; cleared search.
6. Inspected the final accessible tree: each task group has independent completion, edit and delete controls. The checkbox no longer absorbs the whole card's text/actions.
7. Tested responsive Chrome viewport **390×844**, opened the form, and verified Tab moves from title to description. This is a browser viewport test, not a physical phone/virtual keyboard test.

Opened the built macOS app, observed a separate initially empty native database, loaded sample tasks through its real button, quit, reopened the final build and verified that all three tasks persisted. Confirmed the native SQLite plugin works and the final accessible tree separates task controls. Screenshots are actual captured app output; browser and native stores are intentionally independent.

Screenshots: [Web desktop](screenshots/web-desktop.jpg), [empty state](screenshots/web-empty.jpg), [390px layout](screenshots/web-mobile.jpg), [390px form](screenshots/web-mobile-form.jpg), [macOS](screenshots/macos.png).

## Tool limits and source updates

`crapper --root . --no-coverage lib`, `dryer --root . --threshold 0.8 lib` and `mutator --root . --scan lib` all reported no supported source files. Their documented language lists exclude Dart. No CRAP, duplication, mutation score or mutant kill claim is inferred from that result.

GitHub About was updated and read back as:

> Offline Flutter task planner with SQLite persistence, priorities, search, accessible Material 3 UI, and tested legacy data migration.

Verified topics: `dart`, `education`, `flutter`, `mobile-development`, `todo-list`, `material-design`, `null-safety`, `offline-first`, `sqlite` (existing useful topics preserved).

The workflow is configured for actual default branch `master`; the CI badge displays its real remote status. Remote rules/protection were read before push, not altered. The actual publication run is monitored after pushing and reported in the delivery message.

The [own Medium article](https://medium.com/flutter-comunidade-br/criando-uma-lista-de-tarefas-com-flutter-fc81fa2bac6a) was opened and read in Chrome. The session shows Sign in/Sign up and Unknown user, with no edit control. No published update is claimed. The complete Portuguese technical revision is prepared in [medium-update.pt-BR.md](medium-update.pt-BR.md).
