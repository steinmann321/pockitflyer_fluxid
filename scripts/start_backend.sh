#!/bin/bash

# Simple backend starter: kill existing, start detached, quick check

BACKEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/pockitflyer_backend"
PORT=8000
LOG_FILE="$BACKEND_DIR/backend_server.log"

# Kill any existing server on the port
PID_LIST=$(lsof -ti:$PORT 2>/dev/null || true)
if [ -n "$PID_LIST" ]; then
  kill -9 $PID_LIST || true
fi

cd "$BACKEND_DIR"
[ -d venv ] && source venv/bin/activate

rm -f "$LOG_FILE" && : > "$LOG_FILE"
nohup python manage.py runserver >"$LOG_FILE" 2>&1 &
PID=$!

# Minimal health check
sleep 3
if lsof -ti:$PORT >/dev/null 2>&1; then
  echo "Backend started (PID: $PID). Logs: $LOG_FILE"
  exit 0
fi

if ! kill -0 "$PID" >/dev/null 2>&1; then
  echo "Backend failed to start. Last logs:"
  tail -n 60 "$LOG_FILE" || true
  exit 1
fi

echo "Backend not bound to :$PORT yet (PID: $PID). Check logs: $LOG_FILE"
exit 1
