#!/usr/bin/env python3
import re
import sys
from pathlib import Path
from typing import Iterable, List, Tuple


ALLOWED = {"tdd_green", "tdd_red", "tdd_refactor"}


def is_test_file(path: Path) -> bool:
    name = path.name
    return (
        name.startswith("test_")
        or name.endswith("_test.py")
        or name == "tests.py"
    )


def find_def_lines(lines: List[str]) -> Iterable[Tuple[int, str]]:
    for i, line in enumerate(lines):
        if re.match(r"^\s*def\s+test_", line):
            yield i, line


def decorators_above(lines: List[str], def_index: int) -> List[str]:
    decs: List[str] = []
    i = def_index - 1
    while i >= 0:
        s = lines[i].rstrip()
        if not s.strip():
            i -= 1
            continue
        if not s.lstrip().startswith("@"):
            break
        decs.append(s)
        i -= 1
    return list(reversed(decs))


def check_file(path: Path) -> Tuple[List[str], List[str]]:
    missing: List[str] = []
    red_or_refactor: List[str] = []
    try:
        text = path.read_text(encoding="utf-8")
    except Exception as e:
        return [f"{path}: unreadable: {e}"], []
    lines = text.splitlines()

    # quick presence check for markers anywhere
    has_any_marker = any(f"tdd_" in ln for ln in lines)

    for idx, _ in find_def_lines(lines):
        decs = decorators_above(lines, idx)
        markers = [d for d in decs if "pytest.mark" in d and any(m in d for m in ALLOWED)]
        if not markers:
            missing.append(f"{path}:{idx+1}: test missing @pytest.mark.[tdd_green|tdd_red|tdd_refactor]")
        else:
            if any("tdd_red" in m or "tdd_refactor" in m for m in markers):
                red_or_refactor.append(f"{path}:{idx+1}: contains red/refactor marker")

    # if file contains tests but no markers anywhere, mark at least one missing
    if not has_any_marker and any(re.match(r"^\s*def\s+test_", ln) for ln in lines):
        # Avoid duplicate noise; already captured per-test missing
        pass

    return missing, red_or_refactor


def main(argv: List[str]) -> int:
    files = [Path(p) for p in argv if p.endswith(".py")]
    if not files:
        return 0
    files = [f for f in files if is_test_file(f)]
    if not files:
        return 0

    missing_total: List[str] = []
    redref_total: List[str] = []
    for fp in files:
        missing, redref = check_file(fp)
        missing_total.extend(missing)
        redref_total.extend(redref)

    if redref_total:
        print("TDD enforcement: red/refactor tests present. Fix this test and rerun until it works.")
        for msg in redref_total:
            print("  " + msg)
        return 1

    if missing_total:
        print("TDD enforcement: all tests must be tagged with one of: tdd_green, tdd_red, tdd_refactor.")
        for msg in missing_total:
            print("  " + msg)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
