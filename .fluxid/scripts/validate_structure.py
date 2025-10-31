#!/usr/bin/env python3
"""
Structural validation script for fluxid milestone breakdown.
Validates cross-file relationships, IDs, dependencies, template conformance.
"""

import re
import yaml
from pathlib import Path
from collections import defaultdict
from datetime import datetime

# Paths
ROOT = Path(__file__).parent.parent.parent
MILESTONES_DIR = ROOT / "fluxid" / "milestones"
EPICS_DIR = ROOT / "fluxid" / "epics"
TASKS_DIR = ROOT / "fluxid" / "tasks"
PROGRESS_FILE = ROOT / "fluxid" / "progress.yaml"
TEMPLATES_DIR = ROOT / ".fluxid" / "templates"

# Required frontmatter fields
MILESTONE_REQUIRED = ["id", "title", "status"]
EPIC_REQUIRED = ["id", "title", "milestone", "status"]
TASK_REQUIRED = ["id", "title", "epic", "status"]
E2E_TASK_REQUIRED = ["id", "title", "epic", "milestone", "status"]

class ValidationReport:
    def __init__(self):
        self.errors = []
        self.warnings = []
        self.passed = []
        self.details = {}

    def add_error(self, msg):
        self.errors.append(msg)

    def add_warning(self, msg):
        self.warnings.append(msg)

    def add_passed(self, msg):
        self.passed.append(msg)

    def is_pass(self):
        return len(self.errors) == 0

    def status(self):
        return "PASS" if self.is_pass() else "FAIL"

def parse_frontmatter(content):
    """Extract YAML frontmatter from markdown file."""
    match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
    if not match:
        return None
    try:
        return yaml.safe_load(match.group(1))
    except yaml.YAMLError:
        return None

def extract_id_from_filename(filename):
    """Extract milestone/epic/task ID from filename."""
    # m01-e01-t01-... → m01-e01-t01
    # m01-e01-... → m01-e01
    # m01-... → m01
    match = re.match(r'(m\d+-e\d+-t\d+|m\d+-e\d+|m\d+)', filename)
    return match.group(1) if match else None

def is_e2e_task(filename):
    """Check if task is an E2E task based on filename pattern."""
    return '-e2e-' in filename

def discover_files(report):
    """Discover all milestone, epic, and task files."""
    milestones = sorted(MILESTONES_DIR.glob("m*.md"))
    epics = sorted(EPICS_DIR.glob("m*-e*.md"))
    tasks = sorted(TASKS_DIR.glob("m*-e*-t*.md"))

    # Separate regular and e2e tasks
    regular_tasks = [t for t in tasks if not is_e2e_task(t.name)]
    e2e_tasks = [t for t in tasks if is_e2e_task(t.name)]

    report.details["files"] = {
        "milestones": len(milestones),
        "epics": len(epics),
        "tasks": len(tasks),
        "regular_tasks": len(regular_tasks),
        "e2e_tasks": len(e2e_tasks)
    }

    return milestones, epics, tasks, regular_tasks, e2e_tasks

def validate_template_conformance(report, milestones, epics, tasks, regular_tasks, e2e_tasks):
    """Validate that files conform to template requirements."""
    # Check milestones (sample 2-3)
    milestone_errors = []
    for m_file in milestones[:3]:
        content = m_file.read_text()
        fm = parse_frontmatter(content)
        if not fm:
            milestone_errors.append(f"{m_file.name}: Missing or invalid frontmatter")
            continue
        for field in MILESTONE_REQUIRED:
            if field not in fm:
                milestone_errors.append(f"{m_file.name}: Missing required field '{field}'")

    # Check epics (sample 2-3)
    epic_errors = []
    for e_file in epics[:3]:
        content = e_file.read_text()
        fm = parse_frontmatter(content)
        if not fm:
            epic_errors.append(f"{e_file.name}: Missing or invalid frontmatter")
            continue
        for field in EPIC_REQUIRED:
            if field not in fm:
                epic_errors.append(f"{e_file.name}: Missing required field '{field}'")

    # Check regular tasks (sample 2-3)
    task_errors = []
    for t_file in regular_tasks[:3]:
        content = t_file.read_text()
        fm = parse_frontmatter(content)
        if not fm:
            task_errors.append(f"{t_file.name}: Missing or invalid frontmatter")
            continue
        for field in TASK_REQUIRED:
            if field not in fm:
                task_errors.append(f"{t_file.name}: Missing required field '{field}'")

    # Check e2e tasks (sample 2-3)
    e2e_errors = []
    for t_file in e2e_tasks[:3]:
        content = t_file.read_text()
        fm = parse_frontmatter(content)
        if not fm:
            e2e_errors.append(f"{t_file.name}: Missing or invalid frontmatter")
            continue
        # E2E tasks need milestone field too
        for field in E2E_TASK_REQUIRED:
            if field not in fm:
                e2e_errors.append(f"{t_file.name}: Missing required field '{field}'")
        # Check filename pattern
        if '-e2e-' not in t_file.name:
            e2e_errors.append(f"{t_file.name}: E2E task filename must contain '-e2e-'")

    report.details["template_conformance"] = {
        "milestones": "✓ all match" if not milestone_errors else f"✗ errors: {milestone_errors}",
        "epics": "✓ all match" if not epic_errors else f"✗ errors: {epic_errors}",
        "regular_tasks": "✓ all match" if not task_errors else f"✗ errors: {task_errors}",
        "e2e_tasks": "✓ all match" if not e2e_errors else f"✗ errors: {e2e_errors}"
    }

    all_errors = milestone_errors + epic_errors + task_errors + e2e_errors
    if all_errors:
        for err in all_errors:
            report.add_error(f"Template conformance: {err}")
    else:
        report.add_passed("All files conform to template requirements")

def validate_sequential_ids(report, milestones, epics, tasks):
    """Check that IDs are sequential with no gaps or duplicates."""
    # Extract milestone IDs
    m_ids = []
    for m_file in milestones:
        mid = extract_id_from_filename(m_file.name)
        if mid:
            m_ids.append(mid)

    # Extract epic IDs grouped by milestone
    epics_by_milestone = defaultdict(list)
    for e_file in epics:
        eid = extract_id_from_filename(e_file.name)
        if eid:
            mid = eid.split('-e')[0]  # Extract milestone ID
            epics_by_milestone[mid].append(eid)

    # Extract task IDs grouped by epic
    tasks_by_epic = defaultdict(list)
    task_files_by_epic = defaultdict(list)
    for t_file in tasks:
        tid = extract_id_from_filename(t_file.name)
        if tid:
            # Extract epic ID (m01-e01-t01 → m01-e01)
            parts = tid.split('-t')
            eid = parts[0] if len(parts) > 1 else None
            if eid:
                tasks_by_epic[eid].append(tid)
                task_files_by_epic[eid].append(t_file.name)

    # Check milestone sequence
    m_nums = sorted([int(mid[1:]) for mid in m_ids])
    expected_m = list(range(1, max(m_nums) + 1))
    if m_nums != expected_m:
        missing = set(expected_m) - set(m_nums)
        report.add_error(f"Milestone ID gaps: missing {['m{:02d}'.format(m) for m in missing]}")
    else:
        report.add_passed(f"Milestones m01-m{max(m_nums):02d} sequential (no gaps)")

    # Check epic sequences per milestone
    epic_issues = []
    for mid in sorted(epics_by_milestone.keys()):
        eids = epics_by_milestone[mid]
        e_nums = sorted([int(eid.split('-e')[1]) for eid in eids])
        expected_e = list(range(1, max(e_nums) + 1))
        if e_nums != expected_e:
            missing = set(expected_e) - set(e_nums)
            epic_issues.append(f"{mid}: missing {[f'{mid}-e{e:02d}' for e in missing]}")

    if epic_issues:
        for issue in epic_issues:
            report.add_error(f"Epic ID gaps: {issue}")
    else:
        report.add_passed("All epic IDs sequential per milestone (no gaps)")

    # Check task sequences per epic
    task_issues = []
    duplicate_issues = []
    for eid in sorted(tasks_by_epic.keys()):
        tids = tasks_by_epic[eid]
        # Check for duplicates
        tid_counts = defaultdict(int)
        for tid in tids:
            tid_counts[tid] += 1

        duplicates = {tid: count for tid, count in tid_counts.items() if count > 1}
        if duplicates:
            for tid, count in duplicates.items():
                # Find filenames with this ID
                matching_files = [f for f in task_files_by_epic[eid] if tid in f]
                duplicate_issues.append(f"{tid} appears {count} times: {matching_files}")

        # Check for gaps (using unique IDs only)
        unique_tids = list(set(tids))
        t_nums = sorted([int(tid.split('-t')[1]) for tid in unique_tids])
        expected_t = list(range(1, max(t_nums) + 1))
        if t_nums != expected_t:
            missing = set(expected_t) - set(t_nums)
            task_issues.append(f"{eid}: missing {[f'{eid}-t{t:02d}' for t in missing]}")

    if duplicate_issues:
        for issue in duplicate_issues:
            report.add_error(f"Duplicate task IDs: {issue}")

    if task_issues:
        for issue in task_issues:
            report.add_error(f"Task ID gaps: {issue}")

    if not task_issues and not duplicate_issues:
        report.add_passed("All task IDs sequential per epic (no gaps or duplicates)")

    report.details["sequential_ids"] = {
        "milestones": "✓ no gaps" if not [e for e in report.errors if "Milestone ID gaps" in e] else "✗ has gaps",
        "epics": "✓ all sequential" if not epic_issues else f"✗ {len(epic_issues)} issues",
        "tasks": "✓ all sequential" if not (task_issues or duplicate_issues) else f"✗ {len(task_issues)} gaps, {len(duplicate_issues)} duplicates"
    }

def validate_granularity(report, epics, tasks):
    """Check task counts per epic and E2E coverage."""
    tasks_by_epic = defaultdict(list)
    e2e_by_epic = defaultdict(list)

    for t_file in tasks:
        tid = extract_id_from_filename(t_file.name)
        if tid:
            parts = tid.split('-t')
            eid = parts[0] if len(parts) > 1 else None
            if eid:
                tasks_by_epic[eid].append(tid)
                if is_e2e_task(t_file.name):
                    e2e_by_epic[eid].append(tid)

    granularity_details = []
    for eid in sorted(tasks_by_epic.keys()):
        task_count = len(tasks_by_epic[eid])
        e2e_count = len(e2e_by_epic.get(eid, []))

        status = "✓ 5-25 optimal" if 5 <= task_count <= 25 else ""
        if task_count > 25:
            status = "⚠ >25 tasks"
            report.add_warning(f"Epic {eid} has {task_count} tasks (consider splitting flow)")
        elif task_count < 5:
            status = "⚠ <5 tasks"
            report.add_warning(f"Epic {eid} has {task_count} tasks (possibly too coarse)")
        else:
            report.add_passed(f"Epic {eid} has optimal task count ({task_count})")

        # Check E2E coverage
        e2e_status = f"✓ {e2e_count} e2e" if e2e_count > 0 else "⚠ no e2e"
        if e2e_count == 0:
            # Check if this is NOT an e2e validation epic
            if "e2e-milestone-validation" not in eid:
                report.add_warning(f"Epic {eid} has no E2E tasks (flow not validated?)")

        granularity_details.append(f"{eid}: {task_count} tasks ({e2e_count} e2e) [{status}]")

    report.details["granularity"] = granularity_details

def validate_progress_sync(report):
    """Check if progress.yaml exists and is in sync with filesystem."""
    if not PROGRESS_FILE.exists():
        report.add_error("progress.yaml does not exist")
        report.details["progress_sync"] = {"exists": "✗ missing", "sync": "N/A"}
        return

    report.add_passed("progress.yaml exists")

    # Parse progress.yaml
    progress_data = yaml.safe_load(PROGRESS_FILE.read_text())

    # Extract all IDs from progress.yaml
    progress_ids = set()
    for milestone in progress_data.get("milestones", []):
        progress_ids.add(milestone["id"])
        for epic in milestone.get("epics", []):
            progress_ids.add(epic["id"])
            for task in epic.get("tasks", []):
                progress_ids.add(task["id"])

    # Extract all IDs from filesystem
    fs_ids = set()
    for m_file in MILESTONES_DIR.glob("m*.md"):
        mid = extract_id_from_filename(m_file.name)
        if mid:
            fs_ids.add(mid)
    for e_file in EPICS_DIR.glob("m*-e*.md"):
        eid = extract_id_from_filename(e_file.name)
        if eid:
            fs_ids.add(eid)
    for t_file in TASKS_DIR.glob("m*-e*-t*.md"):
        tid = extract_id_from_filename(t_file.name)
        if tid:
            fs_ids.add(tid)

    # Compare
    in_fs_not_progress = fs_ids - progress_ids
    in_progress_not_fs = progress_ids - fs_ids

    if in_fs_not_progress:
        report.add_warning(f"{len(in_fs_not_progress)} items in filesystem not in progress.yaml: {sorted(list(in_fs_not_progress)[:5])}")
    if in_progress_not_fs:
        report.add_warning(f"{len(in_progress_not_fs)} items in progress.yaml not in filesystem: {sorted(list(in_progress_not_fs)[:5])}")

    if not in_fs_not_progress and not in_progress_not_fs:
        report.add_passed("progress.yaml is in sync with filesystem")
        sync_status = "✓ all IDs match"
    else:
        sync_status = f"⚠ {len(in_fs_not_progress)} missing in progress, {len(in_progress_not_fs)} missing in filesystem"

    report.details["progress_sync"] = {
        "exists": "✓ exists",
        "sync": sync_status
    }

def generate_report(report):
    """Generate markdown report."""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    lines = [
        f"# Structural Validation Report: All Milestones",
        "",
        f"**Status**: {report.status()}",
        f"**Validated**: {timestamp}",
        "",
        "## Summary",
        f"- Total Checks: {len(report.passed) + len(report.errors) + len(report.warnings)}",
        f"- Passed: {len(report.passed)}",
        f"- Failed: {len(report.errors)}",
        f"- Warnings: {len(report.warnings)}",
        ""
    ]

    # Issues section
    lines.append("## Issues")
    lines.append("")
    lines.append("**ERRORS**:")
    if report.errors:
        for err in report.errors:
            lines.append(f"- {err}")
    else:
        lines.append("- None")
    lines.append("")

    lines.append("**WARNINGS**:")
    if report.warnings:
        for warn in report.warnings:
            lines.append(f"- {warn}")
    else:
        lines.append("- None")
    lines.append("")

    # Details section
    lines.append("## Details")
    lines.append("")

    if "files" in report.details:
        files = report.details["files"]
        lines.append("**Files Found**:")
        lines.append(f"- {files['milestones']} milestones")
        lines.append(f"- {files['epics']} epics")
        lines.append(f"- {files['tasks']} tasks ({files['regular_tasks']} regular + {files['e2e_tasks']} e2e)")
        lines.append("")

    if "template_conformance" in report.details:
        tc = report.details["template_conformance"]
        lines.append("**Template Conformance**:")
        lines.append(f"- Milestones: {tc['milestones']}")
        lines.append(f"- Epics: {tc['epics']}")
        lines.append(f"- Regular Tasks: {tc['regular_tasks']}")
        lines.append(f"- E2E Tasks: {tc['e2e_tasks']}")
        lines.append("")

    if "sequential_ids" in report.details:
        si = report.details["sequential_ids"]
        lines.append("**Sequential IDs**:")
        lines.append(f"- Milestones: {si['milestones']}")
        lines.append(f"- Epics: {si['epics']}")
        lines.append(f"- Tasks: {si['tasks']}")
        lines.append("")

    if "granularity" in report.details:
        lines.append("**Granularity** (New Strategy):")
        for detail in report.details["granularity"]:
            lines.append(f"- {detail}")
        lines.append("")

    if "progress_sync" in report.details:
        ps = report.details["progress_sync"]
        lines.append("**Progress Sync**:")
        lines.append(f"- fluxid/progress.yaml: {ps['exists']}")
        lines.append(f"- Sync status: {ps['sync']}")
        lines.append("")

    lines.append("**Readiness**:")
    if report.is_pass():
        lines.append("✓ Ready for implementation")
    else:
        lines.append("✗ Fix errors before proceeding")
    lines.append("")

    lines.append("## Next Steps")
    if report.is_pass():
        lines.append("Structure is valid. Ready for implementation.")
    else:
        lines.append("Fix the errors listed above, then re-run validation.")

    return "\n".join(lines)

def main():
    report = ValidationReport()

    print("🔍 Discovering files...")
    milestones, epics, tasks, regular_tasks, e2e_tasks = discover_files(report)

    print("✅ Validating template conformance...")
    validate_template_conformance(report, milestones, epics, tasks, regular_tasks, e2e_tasks)

    print("🔢 Validating sequential IDs...")
    validate_sequential_ids(report, milestones, epics, tasks)

    print("📊 Validating granularity...")
    validate_granularity(report, epics, tasks)

    print("📄 Validating progress.yaml sync...")
    validate_progress_sync(report)

    print("\n" + "="*60)
    print(f"Validation {report.status()}")
    print(f"Passed: {len(report.passed)} | Failed: {len(report.errors)} | Warnings: {len(report.warnings)}")
    print("="*60 + "\n")

    # Generate report
    report_content = generate_report(report)
    report_file = ROOT / "fluxid" / "fluxid-structure-review.md"
    report_file.write_text(report_content)
    print(f"📝 Report saved to: {report_file}")

    # Print report to console
    print("\n" + report_content)

    return 0 if report.is_pass() else 1

if __name__ == "__main__":
    exit(main())
