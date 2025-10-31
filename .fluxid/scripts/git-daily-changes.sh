#!/usr/bin/env sh
# POSIX-compatible script that does NOT use bash-only features (no associative arrays).
# Save as git-daily-changes-posix.sh and run with: sh git-daily-changes-posix.sh 2025-09-27 2025-09-29
set -eu

usage() {
  cat <<EOF
Usage: $0 [start-date] [end-date]
Dates must be in YYYY-MM-DD format. Both dates inclusive.
Defaults: Last week from today (7 days ago to today, inclusive)
Example: $0 2025-09-27 2025-09-29
EOF
  exit 1
}

# Default to last week (7 days ago to today, inclusive)
get_default_dates() {
  # Try GNU date first
  if date -d "7 days ago" >/dev/null 2>&1; then
    START=$(date -I -d "7 days ago")
    END=$(date -I)
    return 0
  fi

  # Fallback to python3
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY'
import sys
from datetime import datetime, timedelta
today = datetime.now()
week_ago = today - timedelta(days=7)
print(week_ago.strftime("%Y-%m-%d"))
print(today.strftime("%Y-%m-%d"))
PY
    return 0
  fi

  echo "Error: neither GNU date nor python3 available to calculate default dates." >&2
  exit 3
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
fi

if [ "${1:-}" = "" ] || [ "${2:-}" = "" ]; then
  # Use defaults
  if [ "${1:-}" = "" ] && [ "${2:-}" = "" ]; then
    dates=$(get_default_dates)
    START=$(echo "$dates" | sed -n '1p')
    END=$(echo "$dates" | sed -n '2p')
    echo "Using default date range: $START to $END (last 7 days)" >&2
  else
    usage
  fi
else
  START="$1"
  END="$2"
fi

# basic date format check YYYY-MM-DD
case "$START" in
  ????-??-??) ;;
  *) echo "Error: start date must be YYYY-MM-DD" >&2; exit 2 ;;
esac
case "$END" in
  ????-??-??) ;;
  *) echo "Error: end date must be YYYY-MM-DD" >&2; exit 2 ;;
esac

# Ensure inside a git repo and use repository root
if ! git_root=$(git rev-parse --show-toplevel 2>/dev/null); then
  echo "Error: Not inside a git repository." >&2
  exit 2
fi
cd "$git_root"

# Temp files
tmp_dates=$(mktemp)
tmp_agg=$(mktemp)
trap 'rm -f "$tmp_dates" "$tmp_agg"' EXIT

# Generate date list inclusive
generate_dates() {
  s="$1"; e="$2"
  # Prefer GNU date
  if date -d "$s" >/dev/null 2>&1; then
    cur="$s"
    while :; do
      printf "%s\n" "$cur"
      [ "$cur" = "$e" ] && break
      cur=$(date -I -d "$cur + 1 day")
      # safety: if date calc failed, break
      [ -z "$cur" ] && break
    done
    return 0
  fi

  # Fallback to python3
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$s" "$e" <<'PY'
import sys
from datetime import datetime, timedelta
s=sys.argv[1]; e=sys.argv[2]
fmt="%Y-%m-%d"
start=datetime.strptime(s,fmt)
end=datetime.strptime(e,fmt)
d=start
while d<=end:
    print(d.strftime(fmt))
    d+=timedelta(days=1)
PY
    return 0
  fi

  echo "Error: neither GNU date nor python3 available to generate date range." >&2
  exit 3
}

# fill tmp_dates
generate_dates "$START" "$END" >"$tmp_dates"

# Aggregate git numstat per date (date add del)
# If there are no commits in the range, this will create an empty tmp_agg
git --no-pager log --since="$START 00:00" --until="$END 23:59:59" --pretty=format:"%ad" --date=short --numstat \
  | awk '
    /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ { cur=$0; next }
    /^[0-9-]+\t[0-9-]+\t/ {
      split($0,a,"\t")
      add=a[1]; del=a[2]
      if (add == "-") add=0
      if (del == "-") del=0
      adds[cur]+=add
      dels[cur]+=del
      next
    }
    END {
      for (d in adds) {
        printf "%s %d %d\n", d, adds[d]+0, dels[d]+0
      }
    }' >"$tmp_agg"

# Output header
printf "%-12s %12s %12s %12s %12s\n" "Date" "Additions" "Deletions" "Net(+/-)" "Total"
printf "%-12s %12s %12s %12s %12s\n" "------------" "------------" "------------" "------------" "------------"

total_add=0
total_del=0

# For each date in order, lookup aggregated sums (or zero)
while IFS= read -r day; do
  # find line starting with date in tmp_agg
  # grep -F is safe because format is "YYYY-MM-DD add del"
  line=$(grep -F -- "$day " "$tmp_agg" 2>/dev/null || true)
  if [ -z "$line" ]; then
    add=0
    del=0
  else
    # split fields
    # set -- splits on IFS (default whitespace)
    set -- $line
    # $1=date, $2=add, $3=del
    add="${2:-0}"
    del="${3:-0}"
  fi

  net=$((add - del))
  total=$((add + del))
  printf "%-12s %12d %12d %12d %12d\n" "$day" "$add" "$del" "$net" "$total"

  total_add=$((total_add + add))
  total_del=$((total_del + del))
done <"$tmp_dates"

total_net=$((total_add - total_del))
total_changed=$((total_add + total_del))
printf "%-12s %12s %12s %12s %12s\n" "------------" "------------" "------------" "------------" "------------"
printf "%-12s %12d %12d %12d %12d\n" "TOTAL" "$total_add" "$total_del" "$total_net" "$total_changed"
