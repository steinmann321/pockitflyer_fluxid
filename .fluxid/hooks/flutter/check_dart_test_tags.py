#!/usr/bin/env python3
import re
import sys
from pathlib import Path
from typing import List, Tuple


ALLOWED = {"tdd_green", "tdd_red", "tdd_refactor"}


def is_test_file(p: Path) -> bool:
    return p.suffix == ".dart" and ("/test/" in p.as_posix() or p.name.endswith("_test.dart"))


def extract_test_invocations(text: str) -> List[Tuple[int, str]]:
    lines = text.splitlines()
    results: List[Tuple[int, str]] = []
    for i, ln in enumerate(lines):
        if "test(" in ln or "testWidgets(" in ln:
            # Look ahead up to 100 lines to find the tags parameter (some tests are very long)
            snippet = "\n".join(lines[i : min(len(lines), i + 100)])
            results.append((i, snippet))
    return results


def has_allowed_tag(snippet: str) -> bool:
    m = re.search(r"tags\s*:\s*\[(.*?)\]", snippet, re.DOTALL)
    if not m:
        return False
    tags_blob = m.group(1)
    return any(tag in tags_blob for tag in ALLOWED)


def has_red_or_refactor(snippet: str) -> bool:
    return ("tdd_red" in snippet) or ("tdd_refactor" in snippet)


def check_file(p: Path) -> Tuple[List[str], List[str]]:
    try:
        text = p.read_text(encoding="utf-8")
    except Exception as e:
        return [f"{p}: unreadable: {e}"], []
    invocations = extract_test_invocations(text)
    missing: List[str] = []
    redref: List[str] = []
    for line_no, snippet in invocations:
        if not has_allowed_tag(snippet):
            missing.append(f"{p}:{line_no+1}: test missing tags: [tdd_green|tdd_red|tdd_refactor]")
        elif has_red_or_refactor(snippet):
            redref.append(f"{p}:{line_no+1}: contains red/refactor tag")
    return missing, redref


def main(argv: List[str]) -> int:
    files = [Path(a) for a in argv if a.endswith(".dart")]
    if not files:
        return 0
    files = [f for f in files if is_test_file(f)]
    if not files:
        return 0

    missing_total: List[str] = []
    redref_total: List[str] = []
    for f in files:
        missing, redref = check_file(f)
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
