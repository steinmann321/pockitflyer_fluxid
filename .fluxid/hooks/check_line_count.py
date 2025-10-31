#!/usr/bin/env python3
import argparse
import os
import sys
from typing import List, Tuple


def count_lines(path: str) -> int:
    # Binary-safe and fast enough for pre-commit
    count = 0
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            count += chunk.count(b"\n")
    return count


def check_files(files: List[str], max_lines: int) -> List[Tuple[str, int]]:
    violations: List[Tuple[str, int]] = []
    for fp in files:
        if not os.path.isfile(fp):
            continue
        try:
            lines = count_lines(fp)
        except Exception as exc:  # minimal handling; pre-commit should not crash
            print(f"ERROR: could not read {fp}: {exc}", file=sys.stderr)
            return [(fp, -1)]
        if lines > max_lines:
            violations.append((fp, lines))
    return violations


def main(argv: List[str]) -> int:
    parser = argparse.ArgumentParser(description="Fail if any file exceeds max line count.")
    parser.add_argument("files", nargs="*", help="Files to check (provided by pre-commit)")
    parser.add_argument("--max-lines", type=int, default=400, help="Maximum allowed lines per file")
    args = parser.parse_args(argv)

    violations = check_files(args.files, args.max_lines)
    if not violations:
        return 0

    print("Line count check failed:")
    for fp, lines in violations:
        if lines >= 0:
            print(f"  {fp}: {lines} > {args.max_lines}")
        else:
            print(f"  {fp}: unreadable")
    print("Consider splitting large files to maintain readability and cohesion.")
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
