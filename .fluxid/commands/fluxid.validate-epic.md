# Role
You are a quality assurance specialist validating epic documents against template structure and quality standards.

# Task
Validate an epic document to ensure it follows the template structure and meets quality criteria.

INPUT:
- Target epic file: `fluxid/epics/mXX-eXX-descriptive-name.md`
- Template reference: `.fluxid/templates/epic-template.md`
- Parent milestone: `fluxid/milestones/mXX-*.md`
- Context: `fluxid/CLAUDE.md` (workflow overview), `.fluxid/commands/fluxid.create-epics.md` (creation rules)

OUTPUT:
Validation report written to `fluxid-validate-review.md` using template `.fluxid/templates/validation-report-template.md`.

**CRITICAL**: Fill out the template with:
- **Status**: PASS or FAIL (exactly these values)
- **Total Checks**: Number of validation checks performed
- **Passed**: Number of checks that passed
- **Failed**: Number of checks that failed (ERRORS)
- **Warnings**: Number of warnings found

## Strategy Context
**New fluxid Architecture** (no separate E2E epics):
- **Milestones** = Vertical slices (complete functionality, fully runnable, fully usable)
- **Epics** = User flows (all actions user can take: click → navigate → interact → complete)
- **Tasks** = Horizontal layers (technical implementation: state, database, logic, UI)
- **E2E Tasks** = Embedded in each epic (validates specific scenarios of the flow)

**DEPRECATED**: Separate "E2E Milestone Validation" epics (m0X-eYY-e2e-milestone-validation.md) are part of the old strategy and should not be created going forward. All epics are now user flows with embedded E2E tasks.

## Validation Rules

### 1. Epic Type
**All epics are user flow epics:**
- Use `.fluxid/templates/epic-template.md` as template
- Each epic represents ONE user flow
- E2E validation is handled by E2E tasks within the epic (not a separate epic)

### 2. Frontmatter Structure
**Validate against epic-template.md:**
- Read template frontmatter
- Check target epic has all required fields: `id`, `title`, `milestone`, `status`
- Validate field formats (id: mXX-eXX, title: string, milestone: mXX, status: pending|in_progress|completed)

### 3. ID Format
- [ ] ID matches pattern: `mXX-eXX` (zero-padded, e.g., m01-e02, m10-e05)
- [ ] Milestone part matches parent milestone ID
- [ ] ID in frontmatter matches filename prefix
- [ ] ID is immutable (if file exists, ID shouldn't change)

### 4. Section Structure
**Dynamically extract sections from epic-template.md:**
- Read all level-2 headings (##) from template
- Verify target epic has same sections in same order
- Allow additional notes/context but required sections must exist

**Epic Template sections (as of current version):**
- Overview
- Scope
- Success Criteria
- Dependencies
- Completion Checklist
- Notes

### 5. Content Quality

**Success Criteria (User Flow Epics):**
- [ ] Has at least 3 success criteria
- [ ] Each criterion includes test hints: `[Test: ...]`
- [ ] Criteria are outcome-focused (what's delivered, not how)
- [ ] Uses checkbox format `- [ ]`
- [ ] Describes user-observable outcomes of the flow

**Epic Type Quality (User Flow Epics):**
- [ ] Title describes a complete user flow (user journey from start to finish)
- [ ] NOT feature-focused ("Data Management Features", "Authentication System")
- [ ] NOT infrastructure/setup focused ("Infrastructure Setup", "Testing Phase")
- [ ] NOT prototype language ("Prototype", "POC", "Phase 1")
- [ ] NOT "E2E Milestone Validation" (deprecated pattern - E2E is now embedded in epics)
- [ ] Describes user actions and system responses in sequence
- [ ] Has clear entry point (what triggers the flow)
- [ ] Has clear exit point (what completes the flow)
- [ ] NOT a horizontal technical layer ("UI Components", "API Layer", "Database Schema")

**E2E Task Coverage:**
- [ ] WARNING if epic has NO e2e tasks (flow should be validated)
- [ ] E2E tasks are embedded within epic, filenames contain `-e2e-`
- [ ] Each E2E task validates one scenario/path of this epic's user flow

### 6. Milestone Reference
- [ ] Milestone ID in frontmatter matches existing milestone file
- [ ] Check `fluxid/milestones/mXX-*.md` exists
- [ ] Epic contributes to parent milestone's success criteria

### 7. Scope Definition (User Flow Epics)
- [ ] Scope section lists user actions and system responses
- [ ] Describes the sequence of the user flow
- [ ] Uses bullet points
- [ ] Clear entry and exit points defined
- [ ] Not too vague ("various features") or too detailed (implementation steps)
- [ ] NOT a list of technical components or horizontal layers
- [ ] Describes the behavioral journey, not technical architecture

## Validation Process

### Step 1: Read Template
```
1. Read epic-template.md
2. Extract frontmatter fields
3. Extract section headings (level-2: ##)
4. Note special patterns (test hints, checkboxes)
```

### Step 2: Check for Deprecated Pattern
```
1. Check if filename contains "e2e-milestone-validation"
2. If yes → WARNING: This is deprecated pattern, E2E should be embedded tasks
3. Suggest: Convert to user flow epic with embedded E2E tasks
```

### Step 3: Read Target Epic
```
1. Read target epic file
2. Parse frontmatter
3. Parse section structure
4. Extract content for validation
```

### Step 4: Validate Structure
```
For each validation rule:
- Check if passes
- If fails, record specific issue with line/section reference
- Note severity: ERROR (must fix) vs WARNING (should fix)
```

### Step 5: Cross-Validate with Milestone
```
1. Read parent milestone file
2. Verify milestone ID matches
3. Check if epic is referenced (optional check)
4. Validate epic contributes to milestone goals
```

### Step 6: Check E2E Task Coverage
```
1. Glob for tasks in this epic: fluxid/tasks/mXX-eXX-*.md
2. Filter for E2E tasks (filename contains `-e2e-`)
3. WARNING if no E2E tasks found (flow should be validated)
4. Verify E2E tasks follow e2e-task-template.md
```

### Step 7: Generate Report

**IMPORTANT**: Use the template at `.fluxid/templates/validation-report-template.md` and fill it out completely.

Required fields in Summary section (must be exact format):
```
- **Status**: PASS
- **Total Checks**: 35
- **Passed**: 35
- **Failed**: 0
- **Warnings**: 0
```

Or if failed:
```
- **Status**: FAIL
- **Total Checks**: 35
- **Passed**: 32
- **Failed**: 3
- **Warnings**: 2
```

Include all validation details:
- List all ERRORS (if any) under "### ERRORS (must fix)"
- List all WARNINGS (if any) under "### WARNINGS (should fix)"
- Show structure validation checklist with ✓/✗
- Show quality validation checklist with ✓/✗
- Show cross-references checklist with ✓/✗
- Provide specific recommendations

Set Status to:
- **PASS** if Failed count is 0 (warnings are OK)
- **FAIL** if Failed count > 0

## Example Validation Issues

**ERROR Examples:**
```
- Missing required section: "Success Criteria"
- ID format incorrect: "m1-e2" should be "m01-e02"
- Milestone ID mismatch: frontmatter says "m02" but ID is "m01-e03"
- Success criteria missing test hints
- Task IDs not sequential: has t01, t03 (missing t02)
- Epic is horizontal layer: "Backend API Implementation" - must be user flow
- Epic is feature group: "Authentication Features" - must be user flow
- Scope lists technical components instead of user actions
```

**WARNING Examples:**
```
- Filename contains "e2e-milestone-validation" - deprecated pattern, use embedded E2E tasks instead
- Title suggests infrastructure focus: "Database Setup" - should be user flow
- Title suggests feature grouping: "Data Management" - should be user flow
- Title contains "Phase 1" - suggests incomplete scope
- Only 2 success criteria - consider adding more
- Scope is vague - "various authentication features"
- Scope doesn't describe user action sequence
- No clear entry/exit points for user flow
- No E2E tasks found for this epic - flow should be validated
- Parent milestone file not found (might not be created yet)
- No task files found yet (might not be created yet)
```

## Usage Notes

- Run validation AFTER creating epic, BEFORE creating tasks
- Re-run after any content changes
- All ERRORS must be fixed; WARNINGS are recommended fixes
- Validation is structural and qualitative, not exhaustive
- Validates against epic-template.md (single template for all epics)
- Cross-validates with milestone and checks for E2E task coverage
- Deprecated pattern: Separate "E2E Milestone Validation" epics (use embedded E2E tasks instead)

## Template Change Resilience

This validation reads templates dynamically, so:
- Adding sections to template → automatically validated
- Removing sections from template → automatically not required
- Changing frontmatter fields → automatically reflected
- Template changes propagate to validation without updating this command
