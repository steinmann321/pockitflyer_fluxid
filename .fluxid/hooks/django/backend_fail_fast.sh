#!/usr/bin/env bash
set -euo pipefail

# Smart test runner for backend using pytest-testmon.
# Only runs tests affected by changed code.
# Usage:
#   scripts/backend_fail_fast.sh [PYTEST_ARGS]

pushd pockitflyer_backend >/dev/null

# Check if pytest-testmon is available
if ! python -c "import testmon" 2>/dev/null; then
  echo "[testmon] pytest-testmon not installed, running all tests..."
  pytest -m "tdd_green and not integration" -x "$@" -q || test_exit=$?
else
  echo "[testmon] Running affected tests only..."
  # testmon doesn't support branch coverage with pytest-cov, so disable --cov
  pytest --testmon -m "tdd_green and not integration" -x "$@" -q --no-cov || test_exit=$?
fi

# Exit code 5 means no tests collected - this is OK for initial setup
if [ ${test_exit:-0} -eq 5 ]; then
  echo "[testmon] No tests collected (exit code 5) - skipping"
  exit 0
elif [ ${test_exit:-0} -ne 0 ]; then
  exit ${test_exit}
fi

popd >/dev/null
