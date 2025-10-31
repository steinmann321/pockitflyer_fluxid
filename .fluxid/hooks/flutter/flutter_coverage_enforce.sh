#!/usr/bin/env bash
set -euo pipefail

# Enforce >=90% line coverage for Flutter tests (tdd_green).
# Uses smart test selection based on changed files.

# Get list of changed Dart files in lib/
CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR | grep '^pockitflyer_app/lib/.*\.dart$' || true)

if [[ -z "$CHANGED_FILES" ]]; then
  echo "[coverage] No Flutter lib code changes detected; skipping Flutter coverage enforcement."
  exit 0
fi

pushd pockitflyer_app >/dev/null

if ! command -v flutter >/dev/null 2>&1; then
  echo "[coverage] 'flutter' not found. Install Flutter SDK and ensure it is on PATH." >&2
  popd >/dev/null
  exit 1
fi

# Map changed files to test files
TEST_FILES=()
while IFS= read -r lib_file; do
  relative=${lib_file#pockitflyer_app/lib/}
  relative=${relative%.dart}
  test_file="test/${relative}_test.dart"

  if [[ -f "$test_file" ]]; then
    TEST_FILES+=("$test_file")
  fi
done <<< "$CHANGED_FILES"

if [[ ${#TEST_FILES[@]} -eq 0 ]]; then
  echo "[coverage] No matching test files found for changed lib files; skipping coverage"
  popd >/dev/null
  exit 0
fi

# Clean previous coverage outputs to avoid stale data
rm -rf coverage || true

# Run only affected tests with coverage
echo "[coverage] Running coverage for ${#TEST_FILES[@]} affected test file(s)..."
flutter test --tags tdd_green --coverage -r compact "${TEST_FILES[@]}"

LCOV="coverage/lcov.info"
if [[ ! -f "$LCOV" ]]; then
  echo "[coverage] Coverage file not found: $LCOV" >&2
  popd >/dev/null
  exit 1
fi

# Build list of changed lib files for AWK (relative paths)
CHANGED_LIB_FILES_FOR_AWK=""
while IFS= read -r changed_file; do
  relative=${changed_file#pockitflyer_app/}
  if [[ -n "$CHANGED_LIB_FILES_FOR_AWK" ]]; then
    CHANGED_LIB_FILES_FOR_AWK="${CHANGED_LIB_FILES_FOR_AWK}|"
  fi
  CHANGED_LIB_FILES_FOR_AWK="${CHANGED_LIB_FILES_FOR_AWK}${relative}"
done <<< "$CHANGED_FILES"

# Sum LF (lines found) and LH (lines hit) for ONLY changed files
# Ignore generated code (e.g., *.g.dart, *.freezed.dart) and non-changed files
awk -v changed_files="$CHANGED_LIB_FILES_FOR_AWK" '
  BEGIN {
    split(changed_files, arr, "|")
    for (i in arr) changed_map[arr[i]] = 1
  }
  /^SF:/ {
    fname = substr($0,4)
    include = 0
    # Only include files that were changed
    if (fname in changed_map) { include = 1 }
    # Skip generated files even if changed
    if (fname ~ /\.g\.dart$/) { include = 0 }
    if (fname ~ /\.freezed\.dart$/) { include = 0 }
    if (fname ~ /\/generated\//) { include = 0 }
    next
  }
  /^LF:/ { if (include) lf += substr($0,4) }
  /^LH:/ { if (include) lh += substr($0,4) }
  END {
    if (lf == 0) {
      print "[coverage] No eligible lines found; ensure tests cover changed lib/*.dart files.";
      exit 1
    }
    pct = (lh / lf) * 100
    printf("[coverage] Flutter line coverage: %.2f%% (LH=%d, LF=%d)\n", pct, lh, lf)
    if (pct < 90.0) {
      printf("[coverage] Coverage below threshold (90%%). Please add/adjust tests.\n")
      exit 2
    }
  }
' "$LCOV"

popd >/dev/null
