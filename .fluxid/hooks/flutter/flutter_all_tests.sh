#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Move from .fluxid/hooks/flutter -> repo root
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"

cd "$PROJECT_ROOT/pockitflyer_app"

echo "Running ALL Flutter tests..."
if flutter test --coverage; then
  echo "All Flutter tests passed with coverage."
else
  echo "Coverage run failed, retrying without coverage..."
  flutter test
fi
