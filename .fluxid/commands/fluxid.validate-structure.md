# Role
Validate structural integrity of fluxid milestone breakdown (cross-file relationships, IDs, dependencies).

# Task
INPUT: Milestone ID `mXX` (e.g., m01)
OUTPUT: `fluxid-structure-review.md` with Status: PASS/FAIL, counts (Total/Passed/Failed/Warnings)

Status = PASS if Failed = 0 (warnings OK), FAIL if Failed > 0.

## Validation Checks

### 1. File Discovery & ID Format
- Glob: `fluxid/milestones/mXX-*.md`, `fluxid/epics/mXX-e*.md`, `fluxid/tasks/mXX-e*-t*.md`
- Epic filenames: `mXX-eXX-descriptive-name.md`
- Task filenames: `mXX-eXX-tXX-descriptive-name.md`

### 2. Frontmatter Validation
**Epics**: `milestone: mXX`, `id: mXX-eXX`
**Tasks**: `epic: mXX-eXX`, ID matches filename

### 3. Sequential IDs (No Gaps/Duplicates)
**Epics**: N epics → e01 through eN
**Tasks**: M tasks per epic → t01 through tM per epic

### 4. Dependencies
- Reference valid IDs (files exist)
- No circular dependencies
- Tasks depend on same/earlier epics only

### 5. Granularity
- Epic task count: 3-20 optimal
- WARNING if >20 (split epic) or <3 (too coarse)
- Epic = user flow, tasks = atomic

## Execution

1. **Discover**: Glob files, count epics/tasks
2. **Sample frontmatter**: Read 2-3 epic/task files to verify fields
3. **Check sequences**: Extract IDs, sort, find gaps
4. **Check counts**: Task count per epic
5. **Scan dependencies**: Look for invalid refs (sample approach)
6. **Generate report** (see template below)

## Report Template

```markdown
# Structural Validation Report: mXX

**Status**: PASS | FAIL
**Milestone**: mXX - [title]
**Validated**: [timestamp]

## Summary
- Total Checks: [N]
- Passed: [N]
- Failed: [N]
- Warnings: [N]

## Issues
**ERRORS**: [list or "None"]
**WARNINGS**: [list or "None"]

## Details
**Files Found**:
- 1 milestone, X epics, Y tasks

**Sequential IDs**:
- Epics: e01-eX [✓ no gaps | ✗ missing eN]
- Tasks per epic: [✓ all sequential | ✗ epic eX missing tN]

**Granularity**:
- Epic eX: N tasks [✓ | ⚠ >20 tasks | ⚠ <3 tasks]

**Dependencies**: [✓ all valid | ✗ issue details]

**Readiness**: [✓ ready | ✗ fix errors]

## Next Steps
[Fix errors if FAIL | Ready for implementation if PASS]
```

## Architecture Notes
- Epic = user flow (E2E tasks distributed within, not final epic)
- More small tasks > few big tasks
- Structural focus: IDs, refs, sequences (not content quality)

## Examples
**ERRORS**: Epic ID gap (e01, e03 - missing e02), circular dependency (e02→e03→e02), invalid ref (task depends on non-existent m01-e05)
**WARNINGS**: Epic has 25 tasks (split?), epic has 2 tasks (too coarse?)
