#!/bin/bash

# Start Flutter iOS app detached; kill existing run processes first

set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/pockitflyer_app"
LOG_FILE="$APP_DIR/flutter_run.log"

cd "$APP_DIR"

# Kill any existing flutter run processes to avoid conflicts
PID_LIST=$(pgrep -f "flutter run" 2>/dev/null || true)
if [ -n "$PID_LIST" ]; then
  echo "Killing existing Flutter run processes: $PID_LIST"
  kill -9 $PID_LIST || true
fi

# Ensure iOS Simulator is open
open -a Simulator >/dev/null 2>&1 || true

# Start detached
rm -f "$LOG_FILE" && : > "$LOG_FILE"
nohup flutter run >"$LOG_FILE" 2>&1 &
PID=$!

# Minimal check that a flutter run process is active
sleep 3
if pgrep -f "flutter run" >/dev/null 2>&1; then
  echo "Flutter app started (PID: $PID). Logs: $LOG_FILE"
  exit 0
fi

if ! kill -0 "$PID" >/dev/null 2>&1; then
  echo "Flutter app failed to start. Last logs:"
  tail -n 60 "$LOG_FILE" || true
  exit 1
fi

echo "Flutter run process not confirmed (PID: $PID). Check logs: $LOG_FILE"
exit 1
