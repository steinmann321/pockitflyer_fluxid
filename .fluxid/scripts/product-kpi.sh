#!/bin/bash

set -e  # Exit on error

# Always run from project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Generating Product KPI Report...${NC}"
echo ""

# Execute the Claude command via para with random suffix for unique instance
RANDOM_SUFFIX=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | fold -w 3 | head -n 1)
para start maintenance-product-kpi-${RANDOM_SUFFIX} --file .claude/commands/product-kpi.md --dangerously-skip-permissions

echo ""
echo -e "${GREEN}KPI report generation complete!${NC}"
