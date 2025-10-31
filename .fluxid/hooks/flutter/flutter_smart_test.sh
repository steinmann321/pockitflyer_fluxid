#!/usr/bin/env bash
set -euo pipefail

# Run Flutter unit tests for changed files (simple fallback: run all tests)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Move from .fluxid/hooks/flutter -> repo root
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"

cd "$PROJECT_ROOT/pockitflyer_app"

if [ -d "test" ]; then
  echo "Running Flutter unit tests..."
  # Prefer coverage if available; otherwise run plain tests
  if flutter test --coverage; then
    echo "Flutter tests completed with coverage."
  else
    echo "Coverage run failed, retrying without coverage..."
    flutter test
  fi
else
  echo "No Flutter test directory found. Skipping."
fi
