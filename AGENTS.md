This file provides guidance to coding agents when working with code in this repository.

## Architecture Overview

### Monorepo Structure

```
pockitflyer_fluxid/
├── pockitflyer_backend/    # Django REST API
├── pockitflyer_app/        # Flutter iOS app
└── scripts/                # Startup helpers for automatted testing
```

**Note**: If you cannot find a directory or file, check your working directory first

**Startup Commands**: See `CONTRIBUTORS.md` for helper scripts and exact application start commands (backend/app/e2e). Always use these scripts to ensure detached start and proper kill-before-start behavior required for e2e tests.

### Technology Stack

**Backend**:
- Django REST Framework for API
- JWT authentication
- SQLite database
- External services: geopy (geocoding), Pillow (images)

**Frontend**:
- Flutter for iOS
- Target: iOS only initially

### Core Architectural Principles
- **Resilience**: All external service calls use circuit breakers and retry mechanisms with exponential backoff
- **Authentication**: Two-tier pattern - anonymous browsing with optional authentication for personalized features
- **Validation**: Business logic enforced at model layer, not in serializers/views
- **Performance**: Aggressive database indexing on all queried fields
- **Explicitness**: All relationships and configurations explicitly defined

## Minimal Documentation Style
- Document why, not what; use clear names and structure so code reads naturally.
- Avoid redundant docstrings and boilerplate comments that repeat the obvious.
- Document only non‑obvious behavior.

## Minimal code footprint
- YAGNI principle: Only implement what is explicitly needed right now
- Avoid premature abstraction: Don't create abstractions until you have 3+ concrete use cases
- Prefer simple, direct solutions over clever or complex ones
- No unnecessary frameworks, libraries, or design patterns
- No speculative features or "might need later" code
- Delete unused code immediately - don't comment it out

**Dependencies**:
- Backend requires: `pytest-testmon` (install via `pip install pytest-testmon`)

## TDD Markers

All tests must include TDD markers (implementation: `@pytest.mark.tdd_*` for Python, `tags: ['tdd_*']` for Dart):
- `tdd_green` - Passing test (safe to commit)
- `tdd_red` - Failing test (blocks commit until implemented)
- `tdd_refactor` - Refactoring in progress (blocks commit until complete)
- Use method markers only, not class/file markers
- ALWAYS verify a test is actually running and passing before marking it green:
    - NOT ALLOWED: "I'll add `tdd_green` to all these test methods since they should be passing tests" - ASSUMES the tests are passing
    - REQUIRED: "I'll run the affected tests to verify they are passing before adding `tdd_green`" - VERIFIES the tests are passing

## Refactoring

**File Splitting strategy**:
1. Strip redundant documentation
2. Split by domain/concern if still needed (never arbitrary line counts)
3. Maintain cohesion - don't break logical units
4. Create subpackages as needed to group related smaller files
5. Create common code classes as needed to reduce duplicate code
6. Mark tests `tdd_refactor` during splits, verify pass, mark `tdd_green`

**CRITICAL SPLIT RULES:**
- ALWAYS follow naming best practices
- NEVER use numbered names like "test_..._part3", "test_..._7"

## Commit and push strategy

- ALWAYS Use conventional commit messages
- ALWAYS rely on pre-commit hooks triggered by a commit command to find issues, fix the issues instantly
- ALWAYS accept that failing hooks will block a commit. Fix the root cause, never deactivate or bypass hooks
- ALWAYS fix pre-push and pre-commit issues, even if they are not related to your current work
    - NOT ALLOWED: "The pre-push hooks run ALL tests across the entire codebase, not just tests related to changed files. This means the branch cannot be pushed until someone fixes all 59 pre-existing test failures." - IGNORES failing tests
    - REQUIRED: "The pre-push hooks found failing tests I need to fix, even if my current changes are not affected" - ENSURES the tests are fixed and a push can be done
    
**BE HONEST**: Don't cheat, don't bypass problems, don't remove test files or even implementation code to do a commit. It does not matter at all from where testing issues or other commit blockers emerged. 
- YOU are responsible to fix them all. 
- YOU want to to do a clean commit on a clean codebase with NO EXCEPTION. 

**Pre-commit hooks** (fast, smart selection):
- Backend: Uses `pytest-testmon` to run only tests affected by code changes
- Flutter: Maps changed `lib/*.dart` files to corresponding `test/*_test.dart` files
- Coverage: Enforces ≥90% project wide
- Goal: Fast feedback loop for commits

**Pre-push hooks** (comprehensive):
- Runs ALL tests including integration and e2e tests - this is a intended behaviour to ensure a 100% tested codebase remotely
- No exclusions, no smart selection, no workarounds, no temporary disabling
- Goal: Ensure entire test suite passes before pushing to remote

**CRITICAL REMINDER**: !!NON RUNNING TESTS WILL BE REJECTED AUTOMATICALLY BY REVIEWERS!!
- YOU are responsible to fix ANY issue, related to your current work or not
- YOU are responsible ALL specifcations are met and ALL tests are running
