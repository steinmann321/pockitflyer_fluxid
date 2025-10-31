#!/usr/bin/env python3
"""
Anti-Bypass Hook - Rejects ALL attempts to bypass quality checks.

This hook enforces the ABSOLUTE RULE: No bypasses allowed, ever.
Detects and blocks:
- // ignore_for_file:
- // ignore:
- # type: ignore
- # noqa
- # pylint: disable
- @ts-ignore, @ts-nocheck
- eslint-disable
- Any other bypass mechanism

WHY: Bypasses create flaky tests, technical debt, and erode quality standards.
"""
import re
import sys
from pathlib import Path
from typing import List, Tuple

# Bypass patterns to detect (language-agnostic)
BYPASS_PATTERNS = [
    # Dart/Flutter
    (r'//\s*ignore_for_file:', 'Dart ignore_for_file directive'),
    (r'//\s*ignore:', 'Dart ignore directive'),

    # Python
    (r'#\s*type:\s*ignore', 'Python type ignore'),
    (r'#\s*noqa', 'Python noqa'),
    (r'#\s*pylint:\s*disable', 'Python pylint disable'),

    # TypeScript/JavaScript
    (r'//\s*@ts-ignore', 'TypeScript ts-ignore'),
    (r'//\s*@ts-nocheck', 'TypeScript ts-nocheck'),
    (r'//\s*eslint-disable', 'ESLint disable'),
    (r'/\*\s*eslint-disable', 'ESLint disable block'),
]


def is_allowed_type_ignore(line: str) -> bool:
    """
    Check if a type: ignore is for a legitimate third-party library issue.

    Allowed patterns:
    1. Import statements with [import-untyped], [import], etc.
       Example: from geopy.geocoders import Nominatim  # type: ignore[import-untyped]

    2. Django/DRF framework patterns with [assignment]
       Example: field = serializers.SerializerMethodField()  # type: ignore[assignment]
    """
    # Must have bracket notation with specific allowed codes
    allowed_codes = [
        r'import[^\]]*',      # import, import-untyped, import-not-found
        r'assignment',        # Django/DRF SerializerMethodField type issues
    ]

    for code in allowed_codes:
        if re.search(rf'#\s*type:\s*ignore\[{code}\]', line):
            # Additional check for assignment: must be for known framework patterns
            if 'assignment' in code:
                # Must contain SerializerMethodField or other known DRF/Django patterns
                if 'SerializerMethodField' in line:
                    return True
                return False
            return True

    return False


def check_file(file_path: Path) -> List[Tuple[int, str, str]]:
    """
    Check a file for bypass directives.

    Returns:
        List of (line_number, pattern_name, line_content) tuples
    """
    violations = []

    try:
        content = file_path.read_text(encoding='utf-8')
    except Exception as e:
        print(f"Warning: Could not read {file_path}: {e}", file=sys.stderr)
        return violations

    lines = content.splitlines()

    for line_num, line in enumerate(lines, start=1):
        for pattern, pattern_name in BYPASS_PATTERNS:
            if re.search(pattern, line, re.IGNORECASE):
                # Allow type: ignore for third-party library issues only
                if pattern_name == 'Python type ignore' and is_allowed_type_ignore(line):
                    continue

                violations.append((line_num, pattern_name, line.strip()))

    return violations


def main(argv: List[str]) -> int:
    """
    Main entry point.

    Args:
        argv: List of file paths to check

    Returns:
        0 if no violations found, 1 if violations detected
    """
    if len(argv) < 1:
        # No files to check
        return 0

    file_paths = [Path(arg) for arg in argv if Path(arg).exists()]

    if not file_paths:
        return 0

    all_violations = []

    for file_path in file_paths:
        violations = check_file(file_path)
        if violations:
            all_violations.append((file_path, violations))

    if all_violations:
        print("Bypass directives detected in your code (not third-party):")
        print()

        for file_path, violations in all_violations:
            for line_num, pattern_name, line_content in violations:
                print(f"{file_path}:{line_num}: {pattern_name}")
                print(f"  {line_content}")

        print()
        print("WHY: Bypasses create flaky tests and technical debt")
        print("WHAT TO DO: Fix the underlying issue the linter found")

        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
