# Role
You are a quality assurance specialist validating milestone documents against template structure and quality standards.

# Task
Validate a milestone document to ensure it follows the template structure and meets quality criteria.

INPUT:
- Target milestone file: `fluxid/milestones/mXX-descriptive-name.md`
- Template reference: `.fluxid/templates/milestone-template.md`
- Context: `fluxid/CLAUDE.md`

OUTPUT:
Validation report written to `fluxid-validate-review.md` using template `.fluxid/templates/validation-report-template.md`.

**CRITICAL**: Fill out the template with:
- **Status**: PASS or FAIL (exactly these values)
- **Total Checks**: Number of validation checks performed
- **Passed**: Number of checks that passed
- **Failed**: Number of checks that failed (ERRORS)
- **Warnings**: Number of warnings found

Set Status to PASS if Failed count is 0 (warnings are OK), FAIL if Failed count > 0.

## Validation Rules

### 1. Frontmatter Structure
**Extract required fields from template frontmatter, validate target has them:**
- Read `.fluxid/templates/milestone-template.md` frontmatter
- Check target milestone has all required fields
- Validate field formats (id, title, status, etc.)

### 2. ID Format
- [ ] ID matches pattern: `mXX` (zero-padded, e.g., m01, m02, m10)
- [ ] ID in frontmatter matches filename prefix
- [ ] ID is immutable (if file exists, ID shouldn't change)

### 3. Section Structure
**Dynamically extract sections from template:**
- Read all level-2 headings (##) from template
- Verify target milestone has same sections in same order
- Allow additional notes/context but required sections must exist

**Template sections (as of current version):**
- Deliverable
- Success Criteria
- Validation Questions
- Notes

### 4. Content Quality

**Success Criteria:**
- [ ] Has at least 3 specific success criteria
- [ ] Includes standard criteria (Complete UI, Full backend integration, etc.)
- [ ] Criteria are measurable and testable
- [ ] Uses checkbox format `- [ ]`

**Validation Questions:**
- [ ] All validation questions present from template
- [ ] Uses checkbox format `- [ ]`

**Consumer-Grade Quality Check:**
- [ ] Title/description does NOT contain: "prototype", "MVP", "phase 1", "proof of concept", "POC"
- [ ] Language focuses on complete, shippable functionality
- [ ] Describes what users can DO, not what developers will build

### 5. Epic References
- [ ] Frontmatter should NOT have epic references (milestones don't list epics in frontmatter)
- [ ] If epics are mentioned in content, they should reference existing files
- [ ] Check if `fluxid/epics/mXX-e*` files exist for this milestone (informational only)

### 6. Vertical Slice Completeness
- [ ] Milestone is a complete vertical slice through all layers
- [ ] Includes UI layer (user interface components)
- [ ] Includes state management layer (application state)
- [ ] Includes business logic layer (domain rules, validation)
- [ ] Includes data persistence layer (database operations)
- [ ] Includes integration layer (external services) if applicable
- [ ] Deliverable describes complete, usable functionality
- [ ] Can be deployed independently
- [ ] Doesn't require other milestones to be useful
- [ ] Has clear user value
- [ ] NOT a horizontal layer only (e.g., "Backend API", "UI Only", "Database Schema")

## Validation Process

### Step 1: Read Template
```
1. Read `.fluxid/templates/milestone-template.md`
2. Extract frontmatter fields
3. Extract section headings (level-2: ##)
4. Note any special patterns (checkboxes, formatting)
```

### Step 2: Read Target Milestone
```
1. Read target milestone file
2. Parse frontmatter
3. Parse section structure
4. Extract content for validation
```

### Step 3: Validate Structure
```
For each validation rule:
- Check if passes
- If fails, record specific issue with line/section reference
- Note severity: ERROR (must fix) vs WARNING (should fix)
```

### Step 4: Generate Report
```markdown
# Validation Report: [milestone-id]

**Status**: PASS | FAIL
**File**: fluxid/milestones/[filename]
**Validated**: [timestamp]

## Summary
- Total Checks: [count]
- Passed: [count]
- Failed: [count]
- Warnings: [count]

## Issues Found

### ERRORS (must fix)
- [ ] [Issue description] - [location/line reference]
- [ ] [Issue description] - [location/line reference]

### WARNINGS (should fix)
- [ ] [Issue description] - [location/line reference]

## Structure Validation
- [✓] Frontmatter complete
- [✗] Missing section: [section name]
- [✓] ID format correct
- [✓] Success criteria present

## Quality Validation
- [✓] Consumer-grade language
- [✓] Complete user value described
- [✓] No MVP/prototype language

## Recommendations
[Specific suggestions to improve the milestone]

---
**Next Steps**:
- Fix all ERRORS before proceeding
- Address WARNINGS for quality
- Re-run validation after fixes
```

## Example Validation Issues

**ERROR Examples:**
```
- Missing required section: "Success Criteria"
- ID format incorrect: "m1" should be "m01"
- Frontmatter missing field: "status"
- Success Criteria has no checkboxes
- Milestone is horizontal layer only: "Backend API Layer" - must be vertical slice
- Deliverable missing UI layer - vertical slice incomplete
- Deliverable missing data layer - vertical slice incomplete
```

**WARNING Examples:**
```
- Title contains "MVP" - suggests incomplete scope
- Title suggests horizontal layer: "Database Schema Setup" - should be vertical slice
- Deliverable is vague - lacks specific user capabilities
- Only 2 success criteria - consider adding more specificity
- No epic files found for this milestone yet
- Success criteria doesn't explicitly mention all layers (UI, state, logic, data, integrations)
```

## Usage Notes

- Run validation AFTER creating milestone, BEFORE creating epics
- Re-run after any content changes
- All ERRORS must be fixed; WARNINGS are recommended fixes
- Validation is structural and qualitative, not exhaustive
- Does NOT validate epic/task content (separate commands for those)

## Template Change Resilience

This validation reads the template dynamically, so:
- Adding sections to template → automatically validated
- Removing sections from template → automatically not required
- Changing frontmatter fields → automatically reflected
- Template changes propagate to validation without updating this command
