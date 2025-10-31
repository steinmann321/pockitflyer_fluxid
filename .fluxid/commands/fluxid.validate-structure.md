# Role
Validate structural integrity of fluxid milestone breakdown (cross-file relationships, IDs, dependencies, template conformance).

# Task
INPUT: Milestone ID `mXX` (e.g., m01)
OUTPUT: `fluxid-structure-review.md` with Status: PASS/FAIL, counts (Total/Passed/Failed/Warnings)

Status = PASS if Failed = 0 (warnings OK), FAIL if Failed > 0.

## Template Mapping (Explicit)
**Milestone files** → `.fluxid/templates/milestone-template.md`
**Epic files** → `.fluxid/templates/epic-template.md`
**Regular task files** → `.fluxid/templates/task-template.md`
**E2E task files** (ending with `-e2e-*.md`) → `.fluxid/templates/e2e-task-template.md`
**Progress tracking** → `fluxid/progress.yaml` (must exist, tracks all milestones/epics/tasks)

## Validation Checks

### 1. File Discovery & ID Format
- Glob: `fluxid/milestones/mXX-*.md`, `fluxid/epics/mXX-e*.md`, `fluxid/tasks/mXX-e*-t*.md`
- Epic filenames: `mXX-eXX-descriptive-name.md`
- Task filenames: `mXX-eXX-tXX-descriptive-name.md`
- E2E task filenames: `mXX-eXX-tXX-e2e-descriptive-name.md`

### 2. Frontmatter Validation (Template Conformance)
**Milestones** (must match milestone-template.md):
- Required fields: `id: mXX`, `title: [string]`, `status: [pending|in_progress|completed]`

**Epics** (must match epic-template.md):
- Required fields: `id: mXX-eXX`, `title: [string]`, `milestone: mXX`, `status: [pending|in_progress|completed]`

**Regular Tasks** (must match task-template.md):
- Required fields: `id: mXX-eXX-tXX`, `title: [string]`, `epic: mXX-eXX`, `milestone: mXX`, `status: [pending|in_progress|completed]`

**E2E Tasks** (must match e2e-task-template.md):
- Required fields: `id: mXX-eXX-tXX`, `title: [string]`, `epic: mXX-eXX`, `milestone: mXX`, `status: [pending|in_progress|completed]`
- Filename pattern: Must contain `-e2e-` in the task ID portion

### 3. Sequential IDs (No Gaps/Duplicates)
**Epics**: N epics → e01 through eN
**Tasks**: M tasks per epic → t01 through tM per epic
**Note**: E2E tasks are embedded within epics (1 epic = 1 e2e testable flow), no separate e2e epic

### 4. Dependencies
- Reference valid IDs (files exist)
- No circular dependencies
- Tasks depend on same/earlier epics only

### 5. Granularity (New Strategy Alignment)
**Milestones** = Vertical slices (complete slice of functionality, fully runnable, fully usable)
**Epics** = User flows within slices (all actions user can take in meaningful flows: click button → navigate to page → etc.)
**Tasks** = Horizontal layers of each flow (application state, database, business logic, etc.)
**E2E Tasks** = One per epic (validates the complete user flow end-to-end)

- Epic task count: 5-25 optimal (smaller flows now, more granular)
- WARNING if >25 (split flow) or <5 (too coarse)
- Each epic should have at least 1 e2e task (validates the flow)

### 6. Progress Tracking Sync
- Verify `fluxid/progress.yaml` exists
- Check that all milestones, epics, and tasks in filesystem appear in progress.yaml
- Check that all items in progress.yaml have corresponding files
- WARNING if progress.yaml is out of sync with filesystem

## Execution

1. **Discover**: Glob files, count milestones/epics/tasks
2. **Template conformance**: Read 2-3 files per type (milestone/epic/regular-task/e2e-task) to verify required frontmatter fields
3. **Check sequences**: Extract IDs, sort, find gaps/duplicates
4. **Check counts**: Task count per epic, e2e task count per epic
5. **Scan dependencies**: Look for invalid refs (sample approach)
6. **Progress sync**: Check if `fluxid/progress.yaml` exists and contains all discovered IDs
7. **Generate report** (see template below)

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
- 1 milestone, X epics, Y tasks (Z regular + W e2e)

**Template Conformance**:
- Milestones: [✓ all match milestone-template.md | ✗ missing fields: list]
- Epics: [✓ all match epic-template.md | ✗ missing fields: list]
- Regular Tasks: [✓ all match task-template.md | ✗ missing fields: list]
- E2E Tasks: [✓ all match e2e-task-template.md | ✗ missing fields: list]

**Sequential IDs**:
- Epics: e01-eX [✓ no gaps | ✗ missing eN]
- Tasks per epic: [✓ all sequential | ✗ epic eX missing tN]

**Granularity** (New Strategy):
- Epic eX: N tasks (M e2e) [✓ 5-25 optimal | ⚠ >25 tasks | ⚠ <5 tasks]
- E2E Coverage: [✓ all epics have e2e tasks | ⚠ epic eX missing e2e validation]

**Dependencies**: [✓ all valid | ✗ issue details]

**Progress Sync**:
- fluxid/progress.yaml: [✓ exists | ✗ missing]
- Sync status: [✓ all IDs match | ⚠ X items in filesystem not in progress.yaml | ⚠ Y items in progress.yaml not in filesystem]

**Readiness**: [✓ ready | ✗ fix errors]

## Next Steps
[Fix errors if FAIL | Ready for implementation if PASS]
```

## Architecture Notes (New Strategy)
**Milestones** = Vertical slices: Complete functionality slice, fully runnable, fully usable by user
**Epics** = User flows: All actions a user can take in meaningful flows (click button → navigate → interact → etc.)
**Tasks** = Horizontal layers: Technical implementation of each flow (app state, database, business logic, UI components)
**E2E Tasks** = Flow validation: One per epic to validate the complete user flow end-to-end (no mocks)

- Epic = user flow (E2E tasks embedded within epic, validates the flow)
- NO separate E2E epic (old strategy deprecated)
- Each epic should have multiple e2e tasks covering different scenarios of the flow
- More small tasks > few big tasks
- Structural focus: IDs, refs, sequences, template conformance (not content quality)

## Examples
**ERRORS**:
- Epic ID gap (e01, e03 - missing e02)
- Circular dependency (e02→e03→e02)
- Invalid ref (task depends on non-existent m01-e05)
- Missing required frontmatter field (epic missing `milestone:` field)
- E2E task filename doesn't contain `-e2e-` pattern

**WARNINGS**:
- Epic has 28 tasks (split flow?)
- Epic has 3 tasks (too coarse?)
- Epic has no e2e tasks (flow not validated?)
- progress.yaml missing 5 tasks found in filesystem
