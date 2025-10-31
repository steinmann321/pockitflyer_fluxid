#!/usr/bin/env bash
set -euo pipefail

# Enforce >=90% line coverage for backend green tests.
# Uses pytest-testmon for smart test selection.

pushd pockitflyer_backend >/dev/null

if ! command -v coverage >/dev/null 2>&1; then
  echo "[coverage] 'coverage' tool not found. Install it (e.g., 'pip install coverage pytest')." >&2
  exit 1
fi

# Skip coverage enforcement if no app code (*.py) changes are staged
# Matches any .py file in app directories (excludes tests/, venv/, fixtures/, migrations/)
CHANGED_APP_FILES=$(git diff --cached --name-only | grep -E '^pockitflyer_backend/.*\.py$' | grep -vE '/(tests|venv|fixtures|migrations)/' || true)
if [[ -z "$CHANGED_APP_FILES" ]]; then
  echo "[coverage] No app code changes detected; skipping backend coverage enforcement."
  popd >/dev/null
  exit 0
fi

# Clean previous data to avoid stale measurements
coverage erase || true

# For coverage enforcement, we need to run without testmon since they conflict with branch coverage
# Just run all green tests with coverage
echo "[coverage] Running all green tests with coverage..."
python -m pytest -m "tdd_green and not integration" -q --cov=. --cov-report=term --cov-fail-under=90

popd >/dev/null
