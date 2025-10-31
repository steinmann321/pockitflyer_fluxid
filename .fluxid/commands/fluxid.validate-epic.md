# Role
You are a quality assurance specialist validating epic documents against template structure and quality standards.

# Task
Validate an epic document to ensure it follows the template structure and meets quality criteria.

INPUT:
- Target epic file: `fluxid/epics/mXX-eXX-descriptive-name.md`
- Template reference: `.fluxid/templates/epic-template.md` OR `.fluxid/templates/e2e-epic-template.md`
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

## Validation Rules

### 1. Determine Epic Type
**Check if this is E2E validation epic or feature epic:**
- If filename contains `e2e-milestone-validation` → use `.fluxid/templates/e2e-epic-template.md`
- Otherwise → use `.fluxid/templates/epic-template.md`

### 2. Frontmatter Structure
**Extract required fields from appropriate template, validate target has them:**
- Read template frontmatter
- Check target epic has all required fields
- Validate field formats (id, title, milestone, status)

### 3. ID Format
- [ ] ID matches pattern: `mXX-eXX` (zero-padded, e.g., m01-e02, m10-e05)
- [ ] Milestone part matches parent milestone ID
- [ ] ID in frontmatter matches filename prefix
- [ ] ID is immutable (if file exists, ID shouldn't change)

### 4. Section Structure
**Dynamically extract sections from appropriate template:**
- Read all level-2 headings (##) from template
- Verify target epic has same sections in same order
- Allow additional notes/context but required sections must exist

**Feature Epic Template sections (as of current version):**
- Overview
- Scope
- Success Criteria
- Tasks
- Dependencies
- Completion Checklist
- Notes

**E2E Epic Template sections (as of current version):**
- Overview
- Scope
- Success Criteria
- Tasks
- Dependencies
- Completion Checklist
- Notes

### 5. Content Quality

**Success Criteria (Feature Epics):**
- [ ] Has at least 3 success criteria
- [ ] Each criterion includes test hints: `[Test: ...]`
- [ ] Criteria are outcome-focused (what's delivered, not how)
- [ ] Uses checkbox format `- [ ]`

**Success Criteria (E2E Epics):**
- [ ] References real backend, real database, real services (NO MOCKS)
- [ ] Tests complete user workflows
- [ ] References milestone success criteria
- [ ] Uses checkbox format `- [ ]`

**Epic Type Quality:**

*For Feature Epics (User Flow Epics):*
- [ ] Title describes a complete user flow (user journey from start to finish)
- [ ] NOT feature-focused ("Data Management Features", "Authentication System")
- [ ] NOT infrastructure/setup focused ("Infrastructure Setup", "Testing Phase")
- [ ] NOT prototype language ("Prototype", "POC", "Phase 1")
- [ ] Describes user actions and system responses in sequence
- [ ] Has clear entry point (what triggers the flow)
- [ ] Has clear exit point (what completes the flow)
- [ ] NOT a horizontal technical layer ("UI Components", "API Layer", "Database Schema")

*For E2E Epics:*
- [ ] Filename ends with `e2e-milestone-validation.md`
- [ ] Title contains "E2E" and "Validation" or similar
- [ ] Explicitly mentions NO MOCKS in notes/description
- [ ] Is last epic in milestone (highest eXX number)

### 6. Milestone Reference
- [ ] Milestone ID in frontmatter matches existing milestone file
- [ ] Check `fluxid/milestones/mXX-*.md` exists
- [ ] Epic contributes to parent milestone's success criteria

### 7. E2E Epic Position (if applicable)
**If this is an E2E epic:**
- [ ] Check if other epics exist for same milestone
- [ ] This should be the last epic (highest eXX number)
- [ ] All other epics should be feature epics
- [ ] Dependencies list all previous epics in this milestone

**If this is NOT an E2E epic:**
- [ ] Check if there's already an E2E epic for this milestone
- [ ] This epic's eXX number should be less than E2E epic's number

### 8. Scope Definition (User Flow Epics)
- [ ] Scope section lists user actions and system responses
- [ ] Describes the sequence of the user flow
- [ ] Uses bullet points
- [ ] Clear entry and exit points defined
- [ ] Not too vague ("various features") or too detailed (implementation steps)
- [ ] NOT a list of technical components or horizontal layers
- [ ] Describes the behavioral journey, not technical architecture

## Validation Process

### Step 1: Determine Epic Type
```
1. Read target epic filename
2. If contains "e2e-milestone-validation" → E2E epic
3. Otherwise → Feature epic
4. Load appropriate template
```

### Step 2: Read Template
```
1. Read appropriate template (epic-template.md or e2e-epic-template.md)
2. Extract frontmatter fields
3. Extract section headings (level-2: ##)
4. Note special patterns (test hints, checkboxes)
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

### Step 6: Validate E2E Epic Position (if applicable)
```
If E2E epic:
  1. List all epics for this milestone
  2. Verify this is the last one (highest eXX)
  3. Verify all others are feature epics

If Feature epic:
  1. Check if E2E epic exists
  2. Verify this epic's number is lower
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
- E2E epic not last: found m01-e05-feature-x.md but this is m01-e04-e2e-validation.md
- Epic is horizontal layer: "Backend API Implementation" - must be user flow
- Epic is feature group: "Authentication Features" - must be user flow
- Scope lists technical components instead of user actions
```

**WARNING Examples:**
```
- Title suggests infrastructure focus: "Database Setup" - should be user flow
- Title suggests feature grouping: "Data Management" - should be user flow
- Title contains "Phase 1" - suggests incomplete scope
- Only 2 success criteria - consider adding more
- Scope is vague - "various authentication features"
- Scope doesn't describe user action sequence
- No clear entry/exit points for user flow
- Parent milestone file not found (might not be created yet)
- No task files found yet (might not be created yet)
```

## Mandatory E2E Epic Check

**Special validation for milestone epic completeness:**
- When validating ANY epic, check if milestone has E2E epic
- If milestone has multiple epics, verify E2E epic exists and is last
- Report WARNING if E2E epic is missing (might not be created yet)
- Report ERROR if E2E epic exists but is not last

## Usage Notes

- Run validation AFTER creating epic, BEFORE creating tasks
- Re-run after any content changes
- All ERRORS must be fixed; WARNINGS are recommended fixes
- Validation is structural and qualitative, not exhaustive
- Validates against appropriate template based on epic type
- Cross-validates with milestone and other epics

## Template Change Resilience

This validation reads templates dynamically, so:
- Adding sections to template → automatically validated
- Removing sections from template → automatically not required
- Changing frontmatter fields → automatically reflected
- Template changes propagate to validation without updating this command
- Supports multiple template types (feature vs E2E epics)
