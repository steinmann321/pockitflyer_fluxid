# Role
You are a quality assurance specialist validating the structural integrity of the fluxid workflow across milestones, epics, and tasks.

# Task
Validate cross-file relationships and structural requirements across the entire milestone breakdown.

INPUT:
- Target milestone ID: `mXX` (e.g., m01)
- All related files:
  - Milestone: `fluxid/milestones/mXX-*.md`
  - Epics: `fluxid/epics/mXX-e*.md`
  - Tasks: `fluxid/tasks/mXX-e*-t*.md`
- Context: `fluxid/CLAUDE.md`, `.fluxid/commands/fluxid.create-epics.md`

OUTPUT:
Validation report written to `fluxid-structure-review.md` using template `.fluxid/templates/validation-report-template.md`.

**CRITICAL**: Fill out the template with:
- **Status**: PASS or FAIL (exactly these values)
- **Total Checks**: Number of validation checks performed
- **Passed**: Number of checks that passed
- **Failed**: Number of checks that failed (ERRORS)
- **Warnings**: Number of warnings found

Set Status to PASS if Failed count is 0 (warnings are OK), FAIL if Failed count > 0.

## Validation Rules

### 1. Milestone-Epic Relationship
**Verify all epics reference valid milestone:**
- [ ] All epic files for this milestone exist: `fluxid/epics/mXX-e*.md`
- [ ] Each epic's frontmatter has `milestone: mXX` matching the milestone ID
- [ ] Epic IDs follow sequential pattern: e01, e02, e03 (no gaps)
- [ ] Epic filenames match ID format: `mXX-eXX-descriptive-name.md`

### 2. Epic-Task Relationship
**Verify all tasks reference valid epics:**
- [ ] All task files for this milestone exist: `fluxid/tasks/mXX-e*-t*.md`
- [ ] Each task's frontmatter has `epic: mXX-eXX` matching its parent epic ID
- [ ] Each task's frontmatter has `milestone: mXX` matching the milestone ID
- [ ] Task IDs follow sequential pattern per epic: t01, t02, t03 (no gaps)
- [ ] Task filenames match ID format: `mXX-eXX-tXX-descriptive-name.md`

### 3. Mandatory E2E Validation Epic
**CRITICAL: Every milestone MUST have a dedicated E2E validation epic as its final epic**
- [ ] List all epic files for milestone: `fluxid/epics/mXX-e*.md`
- [ ] Parse epic numbers from filenames (e01, e02, e03, etc.)
- [ ] Sort by epic number to find last epic
- [ ] Last epic filename MUST contain: `e2e-milestone-validation`
- [ ] ERROR if no E2E epic found
- [ ] ERROR if E2E epic exists but is not last (not highest eXX number)
- [ ] E2E epic MUST use `.fluxid/templates/e2e-epic-template.md` structure
- [ ] E2E epic MUST list all previous epics as dependencies

### 4. Sequential ID Validation
**Verify IDs are sequential with no gaps:**

**Epics:**
- [ ] If there are N epics, they should be numbered e01 through eN
- [ ] No missing numbers (e.g., e01, e02, e04 ← missing e03)
- [ ] No duplicate numbers

**Tasks per Epic:**
- [ ] For each epic with M tasks, they should be numbered t01 through tM
- [ ] No missing numbers within an epic
- [ ] No duplicate numbers within an epic

### 5. Dependency Chain Validation
**Verify dependencies reference valid IDs:**
- [ ] In epic files: dependencies reference valid milestone/epic IDs
- [ ] In task files: dependencies reference valid milestone/epic/task IDs
- [ ] No circular dependencies
- [ ] Dependent items exist (files exist for referenced IDs)

### 6. E2E Epic Quality Checks
**If E2E epic exists, validate its structure:**
- [ ] Contains "NO MOCKS" language in notes/overview
- [ ] Success criteria mention "real backend", "real database", "real services"
- [ ] Lists all feature epics (e01 through eXX-1) as dependencies
- [ ] Tasks focus on user workflow validation (not implementation)

## Validation Process

### Step 1: Discover Files
```
1. Get milestone ID from user input (e.g., m01)
2. Glob for milestone file: fluxid/milestones/mXX-*.md
3. Glob for epic files: fluxid/epics/mXX-e*.md
4. Glob for task files: fluxid/tasks/mXX-e*-t*.md
5. Count: X epics, Y tasks total
```

### Step 2: Validate Milestone-Epic Relationships
```
For each epic file:
1. Read frontmatter
2. Verify `milestone:` field matches milestone ID
3. Extract epic ID from filename
4. Verify epic ID format: mXX-eXX
5. Record any mismatches
```

### Step 3: Validate Epic-Task Relationships
```
For each task file:
1. Read frontmatter
2. Verify `milestone:` field matches milestone ID
3. Verify `epic:` field matches a valid epic ID
4. Extract task ID from filename
5. Verify task ID format: mXX-eXX-tXX
6. Record any mismatches
```

### Step 4: Validate Sequential IDs
```
Epics:
1. Extract all epic numbers (e01, e02, e03, etc.)
2. Sort numerically
3. Check sequence: should be 1, 2, 3, ..., N
4. Report gaps or duplicates

Tasks per Epic:
1. Group tasks by epic
2. For each epic group:
   - Extract task numbers (t01, t02, t03, etc.)
   - Sort numerically
   - Check sequence: should be 1, 2, 3, ..., M
   - Report gaps or duplicates
```

### Step 5: Validate E2E Epic
```
1. Sort epics by number
2. Get last epic (highest eXX)
3. Check filename contains "e2e"
4. If NO:
   - ERROR: "Missing mandatory E2E validation epic"
   - Suggest: "Create [milestone-id]-e[next-number]-e2e-milestone-validation.md"
5. If YES:
   - Read epic file
   - Verify uses e2e-epic-template structure
   - Check for "NO MOCKS" language
   - Verify dependencies list all previous epics
```

### Step 6: Validate Dependency Chains
```
For each epic:
1. Read Dependencies section
2. Parse referenced IDs (other epics, milestones)
3. Verify files exist for referenced IDs
4. Check no circular refs

For each task:
1. Read Dependencies section
2. Parse referenced IDs (epics, tasks, milestones)
3. Verify files exist for referenced IDs
4. Check dependencies are from same or earlier epics
```

### Step 8: Generate Report
```markdown
# Structural Validation Report: [milestone-id]

**Status**: PASS | FAIL
**Milestone**: [milestone-id] - [milestone-title]
**Validated**: [timestamp]

## Scope
- Milestone file: fluxid/milestones/[filename]
- Epic files: X epics found
- Task files: Y tasks found (across all epics)

## Summary
- Total Checks: [count]
- Passed: [count]
- Failed: [count]
- Warnings: [count]

## Issues Found

### ERRORS (must fix)
- [ ] [Issue description with file/ID reference]
- [ ] [Issue description with file/ID reference]

### WARNINGS (should fix)
- [ ] [Issue description with file/ID reference]

## Milestone-Epic Relationships
**Status**: PASS | FAIL
- [✓] All epics reference milestone mXX correctly
- [✗] Epic [epic-id] has wrong milestone reference: [actual]

**Epics Found**: e01, e02, e03, e04
- [✓] Sequential IDs (no gaps)
- [✗] Gap detected: missing e03

## E2E Validation Epic
**Status**: PASS | FAIL
- Last epic: [epic-id] - [epic-title]
- [✓] Is E2E validation epic (filename contains "e2e-milestone-validation")
- [✓] Contains "NO MOCKS" language
- [✓] Lists all feature epics as dependencies
- [✓] Success criteria mention real services

OR

- Last epic: [epic-id] - [epic-title]
- [✗] ERROR: Not E2E validation epic
- [✗] Missing mandatory E2E epic for milestone
- **Action Required**: Create [milestone-id]-e[next-number]-e2e-milestone-validation.md

## Dependency Validation
**Status**: PASS | FAIL
- [✓] All epic dependencies valid
- [✓] All task dependencies valid
- [✓] No circular dependencies
- [✗] Task [task-id] references non-existent epic [epic-id]

## Completeness Assessment

**Milestone Structure**:
- Milestone: ✓ Exists
- Epics: ✓ X epics
- Tasks: ✓ Y tasks
- E2E Epic: ✓ Present as last epic

**Readiness**:
- [✓] Structure is complete and valid
- [✓] Ready for implementation
- [ ] Has structural issues - fix before proceeding

## Recommendations
[Specific suggestions to fix structural issues]

**Critical Actions**:
- Fix all ERRORS before starting implementation
- Create missing E2E validation epic if needed
- Fix ID sequence gaps

---
**Next Steps**:
- Fix all ERRORS
- Address WARNINGS
- Re-run structural validation
- If PASS, proceed with task implementation
```

## Example Validation Issues

### ERROR Examples
```
- Missing E2E validation epic: Last epic is m01-e03-user-settings.md, expected m01-e04-e2e-milestone-validation.md
- Epic ID mismatch: m01-e02 frontmatter says milestone: m02 (should be m01)
- Gap in epic IDs: Found e01, e02, e04 (missing e03)
- Gap in task IDs for epic m01-e02: Found t01, t03 (missing t02)
- Circular dependency: Epic m01-e02 depends on m01-e03, which depends on m01-e02
- Task m01-e02-t03 depends on non-existent task m01-e01-t05
```

### WARNING Examples
```
- E2E epic exists but doesn't mention "NO MOCKS" explicitly
- Epic m01-e03 has no dependencies listed (might be intentional)
- Many tasks in epic m01-e04 (15 tasks - consider splitting epic)
- E2E epic doesn't list all previous epics in dependencies
```

## When to Run This Validation

**After creating epics:**
- Run to verify E2E epic is present and last
- Verify epic IDs are sequential

**After creating tasks:**
- Run to verify all task-epic relationships
- Verify task IDs are sequential per epic

**Before starting implementation:**
- Final structural check
- Ensure complete and valid breakdown

**During implementation:**
- Re-run if adding/removing epics or tasks
- Verify structural integrity maintained

## Usage Notes

- This is CROSS-FILE validation (different from single-file validation)
- Requires milestone, epics, and tasks to exist
- Run AFTER create-epics, AFTER create-tasks
- Do NOT run after create-milestones (no epics exist yet)
- Validates the ENTIRE milestone breakdown structure
- Enforces mandatory E2E epic requirement

## Template Change Resilience

This validation focuses on structural relationships and IDs, not template content:
- File naming patterns are fixed (mXX-eXX-tXX)
- ID relationships are fixed (epic → tasks, milestone → epics)
- E2E epic requirement is fixed (last epic, specific filename)
- Structural validation is independent of template content changes
