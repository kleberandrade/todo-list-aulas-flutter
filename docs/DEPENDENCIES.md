# Dependency refresh — 17 November 2026

Verified SDK: **Flutter 3.50.0 / Dart 3.14.0**, official release tag `3.50.0` at `ab2912035e160d9cad6306df307576da6128ebdb`. A separate SDK copy was used for this repository; the global Flutter 3.41.9 installation and the SDKs of other projects were not changed.

The official release tag was verified against the upstream Git repository. Flutter 3.50 introduced the formal deprecation of the bundled design libraries; application and widget-test imports now use the official `material_ui` package and its localization delegates. See [Flutter's migration guide](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui).

## Direct packages

All direct registry dependencies are at the latest published stable release resolved in this audit:

- `cupertino_icons`: 1.0.9 → **2.0.0**.
- `sqflite`: 2.4.2+1 → **2.4.6**.
- `sqflite_common`: 2.5.8 → **2.5.17**.
- `sqflite_common_ffi_web`: 1.1.1 → **1.2.2**.
- `sqflite_common_ffi`: 2.4.0+3 → **2.4.7** (test dependency).
- `material_ui`: newly added at **1.11.1**; its `cupertino_ui` dependency resolved to **1.1.7**.
- `path`: **1.9.1**, already current.
- `flutter_lints`: **6.0.0**, already current.

`flutter_localizations` is still provided through Material's SDK dependency. Its old direct import/declaration was removed because the app now uses `GlobalMaterialLocalizations.delegates` from `material_ui`.

The major-version upgrade refreshed 27 dependencies before adding the two standalone design packages. The lockfile includes current SQLite 3.9.1, intl 0.20.3, web 1.1.2 and the resolved transitive graph. Web worker and WASM files were regenerated together with the new adapter's official setup command.

## Two explicitly validated SDK-pin exceptions

At the user's request, the final two packages are now updated with exact, project-local `dependency_overrides`:

- `material_color_utilities`: **0.13.0 → 0.13.1**. The [official changelog](https://pub.dev/packages/material_color_utilities/changelog) describes a hue calculation correction and a documentation fix.
- `test_api`: **0.7.14 → 0.7.15**. The [official changelog](https://pub.dev/packages/test_api/changelog) adds backend API exports.

Flutter 3.50.0 still pins the previous patches in its own manifests. These overrides deliberately go beyond those pins; successful app checks are project-specific compatibility evidence, not an upstream Flutter guarantee. Exact versions and lockfile hashes keep the exceptions reproducible. Remove each override when a future Flutter release pins that version or newer, then resolve and run the checks again. No SDK files were edited.

The complete `flutter pub outdated --json` output (overrides enabled, the default) is committed in [dependency-audit.json](dependency-audit.json): **no outdated entries remain**. The lockfile contains both requested versions. This audit is not a separate security assessment.

## Behavioral validation

The existing 19 tests passed after migrating imports. A new test then reproduced the changed dropdown disabling behavior (`enabled` was true while saving). The form now explicitly sets `enabled: !_saving`, and **all 20 tests pass**. Analysis is clean. Current measured line coverage is **397/404 (98.3%)**; this is not a mutation or branch-coverage score.

The schema remains version 2. This is a package refresh, not a storage-format change. The release Web app reopened the four task records saved by the previous package versions on the same origin, keeping their text, priorities and completion counts. See [validation notes](VALIDATION.md) for builds and actual interaction results.

Reproduce with Flutter 3.50.0 on PATH:

```sh
flutter pub get --enforce-lockfile
flutter pub outdated
flutter analyze
flutter test --coverage
dart run sqflite_common_ffi_web:setup --force
flutter build web --release --no-wasm-dry-run
```
