#!/bin/bash

# Simple full stack starter: start backend and app, both detached

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/start_backend.sh"
bash "$SCRIPT_DIR/start_app.sh"

echo "Project started: backend and frontend detached."
exit 0
