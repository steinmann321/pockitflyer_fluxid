# pockitflyer_app

A new Flutter project, set up for TDD (unit, widget, golden, and integration tests).

## TDD Tooling Included

- `flutter_test` with global `test/flutter_test_config.dart` to load golden fonts and init mocks
- `mocktail` for mocking and stubbing
- `golden_toolkit` for reliable golden tests (fonts auto-loaded)
- `mocktail_image_network` to stub `Image.network` in tests
- `integration_test` for end-to-end tests
- `remove_from_coverage` to post-process coverage reports
- Strict analyzer rules from `very_good_analysis`
- Deterministic time with `clock` and `fake_async`

## Test Runner Configuration

- `dart_test.yaml`: compact reporter, sensible default timeout, no retries
- Randomized ordering via CLI to expose hidden dependencies

## Common Commands

- Run all tests with coverage:
  - `flutter test --test-randomize-ordering-seed=random --coverage`
  - Strip generated/entrypoint noise from coverage:
    - `dart run remove_from_coverage:remove_from_coverage -f coverage/lcov.info -r "\\.g\\.dart$" -r "^lib/main\\.dart$"`
- Run a single test: `flutter test test/widget_test.dart`
- Run integration tests: `flutter test integration_test`

## Golden Tests

- Golden fonts are loaded globally via `golden_toolkit.loadAppFonts()`
- Use `golden_toolkit`’s devices and builders for stable snapshots

## Notes

- Prefer writing tests first (red -> green -> refactor)
- Keep widget tests deterministic (mock time, network, and randomness)
