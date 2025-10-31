#!/bin/bash
# Start E2E test backend with Django development server, detached
# Kills existing server and runs health check on port 8000

set -euo pipefail

echo "====================================="
echo "Starting E2E Test Backend"
echo "====================================="

BACKEND_DIR="$(cd "$(dirname "$0")/.." && pwd)/pockitflyer_backend"
PORT=8000
LOG_FILE="$BACKEND_DIR/e2e_backend_server.log"

cd "$BACKEND_DIR"

# Activate backend venv if present
[ -d venv ] && source venv/bin/activate

# Kill any existing server on the port
PID_LIST=$(lsof -ti:$PORT 2>/dev/null || true)
if [ -n "$PID_LIST" ]; then
  echo "Killing existing backend processes on :$PORT -> $PID_LIST"
  kill -9 $PID_LIST || true
fi

echo ""
echo "Step 1: Setting up E2E environment..."
python manage.py setup_e2e_env

echo ""
echo "Step 2: Seeding test data..."
python manage.py seed_e2e_data --clear

echo ""
echo "Step 3: Starting Django development server on port $PORT (detached)..."

rm -f "$LOG_FILE" && : > "$LOG_FILE"
nohup python manage.py runserver "$PORT" >"$LOG_FILE" 2>&1 &
PID=$!

# Minimal health check
sleep 3
if lsof -ti:$PORT >/dev/null 2>&1; then
  echo "E2E Backend started (PID: $PID). Logs: $LOG_FILE"
  exit 0
fi

if ! kill -0 "$PID" >/dev/null 2>&1; then
  echo "E2E Backend failed to start. Last logs:"
  tail -n 60 "$LOG_FILE" || true
  exit 1
fi

echo "E2E Backend not bound to :$PORT yet (PID: $PID). Check logs: $LOG_FILE"
exit 1
