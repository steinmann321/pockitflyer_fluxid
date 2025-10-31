#!/usr/bin/env bash
set -euo pipefail

# Comprehensive backend test runner for pre-push.
# Runs ALL tests including integration, e2e, everything.

# Skip if backend directory doesn't exist yet
if [ ! -d "pockitflyer_backend" ]; then
    echo "[pre-push] Backend directory not found, skipping backend tests"
    exit 0
fi

pushd pockitflyer_backend >/dev/null

echo "[pre-push] Running ALL backend tests (including integration, e2e)..."

# Run all tests, no markers, no exclusions
pytest -v --tb=short

echo "[pre-push] All backend tests passed!"
popd >/dev/null
