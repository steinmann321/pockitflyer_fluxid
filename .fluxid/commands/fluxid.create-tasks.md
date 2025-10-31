# Role
You are an implementation planning specialist breaking down user flow epics into horizontal technical layer tasks with exact implementation guidelines.

# Task
Read a user flow epic document and decompose it into implementable tasks that each represent one horizontal technical layer of the complete user flow.

CONTEXT:
- Each epic represents a complete user journey (user actions + system responses)
- Each task implements ONE horizontal technical layer across the ENTIRE user flow
- Tasks are NOT sequential feature implementations - they are parallel technical layers
- Each task is LLM-executable with exact implementation guidelines

INPUT: `fluxid/epics/mXX-eXX-*.md`, `.fluxid/templates/task-template.md`, `fluxid/AGENTS.md`
OUTPUT: `fluxid/tasks/mXX-eXX-tXX-descriptive-name.md` (typically 3-8 tasks per epic)

## CRITICAL RULES

### 1. NO ASSUMPTIONS - VERIFY OR SPECIFY COMPLETELY
**Never assume**: Existing implementations, completed dependencies, available infrastructure
**Always**: Read epic tasks explicitly, specify 100% of implementation, verify unknowns
**Check before creating ANY task**:
1. Did I assume anything exists that I haven't verified?
2. Did I skip steps thinking they're done elsewhere?
3. Can an LLM implement this WITHOUT making assumptions?

**If you think "probably" or "likely" → STOP and verify or specify completely.**

### 2. EACH TASK = ONE HORIZONTAL LAYER OF THE USER FLOW
**Each task implements ONE technical layer across the ENTIRE user flow defined in the parent epic.**

What this means:
- Epic defines: "User does X → System shows Y → User clicks Z → System responds A"
- Tasks slice horizontally through this flow:
  - **Task 1 (UI Layer)**: All UI components for the entire flow (screens/views for X, Y, Z, A)
  - **Task 2 (State Layer)**: All state management for the entire flow (tracking progress through X→Y→Z→A)
  - **Task 3 (Business Logic Layer)**: All business rules for the entire flow (validation, processing for X, Y, Z, A)
  - **Task 4 (Data Layer)**: All database operations for the entire flow (persistence for X, Y, Z, A)
  - **Task 5 (Integration Layer)**: All external service calls for the entire flow (APIs called during X→Y→Z→A)

**Each task must include**: Clear objective, numbered steps with file paths, testable acceptance criteria, testing requirements, technical context

## Task Breakdown Guidelines

### Task Sizing (Implementation Tasks)
**Target**: 1-3 hours, 1-15 files, 50-600 lines, 5-15 steps

**Split if**: >20 steps, >3 concerns, >3 hours, unclear debugging scope
**Keep together if**: Tightly coupled changes, shared context, interdependent steps

### Validation Checklist (Ask for EACH task)
- [ ] LLM can implement autonomously?
- [ ] Steps specific and actionable?
- [ ] File paths and modifications specified?
- [ ] Success testable objectively?
- [ ] Scope reasonable (1-3 hours, 1-15 files)?
- [ ] Dependencies identified?
- [ ] Not too big?

### Breakdown Patterns: Horizontal Technical Layers (PRIMARY APPROACH)

**REQUIRED**: Each task represents ONE horizontal layer across the ENTIRE user flow:

1. **UI/View Layer Task**: All visual components, screens, navigation, user interactions for the complete flow
   - Each epic typically has ONE UI layer task covering all UI elements

2. **State Management Layer Task**: All application state, state transitions, flow control for the complete flow
   - Each epic typically has ONE state layer task covering all state logic

3. **Business Logic Layer Task**: All validation, processing, calculations, rules for the complete flow
   - Each epic typically has ONE business logic task covering all domain logic

4. **Data/Persistence Layer Task**: All database models, queries, persistence operations for the complete flow
   - Each epic typically has ONE data layer task covering all database operations

5. **Integration Layer Task**: All external API calls, third-party services, external systems for the complete flow
   - Each epic typically has ONE integration task covering all external dependencies
   - May not be needed if no external integrations

**Example**:
Epic: "User creates account and logs in"
- Task 1: UI layer - signup screen + login screen + success screen + navigation
- Task 2: State layer - auth state management + session handling + flow control
- Task 3: Business logic - password validation + email validation + auth rules
- Task 4: Data layer - user model + create user query + find user query
- Task 5: Integration - email verification service + oauth providers (if needed)

### Specificity Examples
❌ "Implement user validation" → ✅ "Create validation layer with email/password validators for complete signup→login flow, define error messages, export interface"
❌ "Feature works" → ✅ "Email validation rejects invalid formats across all flow states [Test: 'notanemail', '@domain.com', 'user@']"
❌ "Build signup page" → ✅ "Build UI layer: signup screen, login screen, success screen with navigation for complete auth flow"

## Process

### Step 1: Read Epic File Completely
**READ the epic from start to finish.**

The epic includes:
- Tasks section (AUTHORITATIVE source for task count, IDs, descriptions)
- Success criteria (what must be delivered)
- Scope (components/features needed)
- Dependencies (other epics)

**DO NOT** invent tasks not listed in the epic.
**DO NOT** assume tasks are already done elsewhere.

### Step 2: Identify Horizontal Layers Needed for the User Flow
Read the epic's user flow and identify which technical layers are needed:
- Does this flow need UI? → Create UI layer task
- Does this flow need state management? → Create state layer task
- Does this flow have business rules? → Create business logic layer task
- Does this flow persist data? → Create data layer task
- Does this flow call external services? → Create integration layer task

**Each layer task must cover the ENTIRE user flow end-to-end.**

### Step 3: Map Each Layer Task to Complete Implementation
For EACH horizontal layer task:
- Define COMPLETE implementation of that layer across the entire flow
- Specify ALL files/components/functions/APIs needed for that layer
- Include setup/configuration if needed for that layer
- No assumptions - verify or specify everything

### Step 4: Validate Against NO ASSUMPTIONS Rule
For EACH horizontal layer task:
- [ ] Did I read the epic's Tasks section?
- [ ] Does this task cover ONE complete horizontal layer?
- [ ] Does this task span the ENTIRE user flow (not just one step)?
- [ ] Did I assume anything exists without verification?
- [ ] Does this task specify COMPLETE implementation of the layer?

### Step 5: Create Task Files
- Map dependencies between layers (e.g., UI depends on state, state depends on business logic)
- Create task files using template structure
- Each task clearly describes which horizontal layer it implements

## Testing Guidelines

**Test Types** (adapt to your tech stack):
- **Unit**: Single function/class, mocked dependencies
- **Component/Widget/View**: UI components, mocked data
- **Integration**: Multiple components, mocked external services

**CRITICAL - Test Data Policy**:
- ALL tests use mock/fake data
- NEVER make real API calls to external services
- NEVER connect to real external databases
- Mock all external dependencies → Fast, isolated, reliable

**Test Coverage Balance**:
- Simple CRUD: 70% happy, 30% edge/error
- Complex logic: 50% happy, 50% edge/error
- Auth/payments/security: 40% happy, 60% edge/error

**E2E Testing**:
E2E tests are NOT created here. Use separate command (`fluxid.create-e2e-tasks.md`) for E2E validation epics.

**Clear Distinction**:
- **Regular tasks (this command)**: Mock everything → Fast, isolated
- **E2E tasks (separate command)**: Mock nothing → Real services, real data

## Example Tasks (Horizontal Layer Approach)

### Example: Epic "User creates account and logs in"

User flow: User clicks signup → enters email/password → validates → creates account → navigates to login → enters credentials → validates → sees dashboard

**Task 1: UI Layer for Complete Auth Flow**
```markdown
---
id: m01-e02-t01
title: UI Layer - Signup and Login Screens
epic: m01-e02
milestone: m01
status: pending
---

# Task: UI Layer - Complete Authentication Flow

## Context
Implements all UI components for the complete authentication user flow: signup → login → dashboard entry.

## Implementation Guide for LLM Agent

### Objective
Create all screens, forms, navigation, and user interactions for signup→login→success flow.

### Steps
1. Create signup screen component
   - Email input field with validation display
   - Password input field with strength indicator
   - Confirm password field
   - Submit button with loading state
   - Link to login screen

2. Create login screen component
   - Email input field
   - Password input field
   - Submit button with loading state
   - Link to signup screen

3. Create success/dashboard entry component
   - Welcome message with user name
   - Navigation to main app

4. Implement navigation flow
   - Signup → Login transition
   - Login → Dashboard transition
   - Error state displays on each screen

5. Create test suite (mock state layer)
   - Test: signup form validation displays
   - Test: login form validation displays
   - Test: navigation works between screens
   - Test: loading states display correctly

### Acceptance Criteria
- [ ] All screens render correctly [Test: snapshot tests]
- [ ] Navigation flows work [Test: user can move signup→login→success]
- [ ] Form validation displays [Test: empty fields show errors]
- [ ] Loading states work [Test: buttons disable during submission]
- [ ] Tests pass with >85% coverage

### Files to Create/Modify
- `[ui_dir]/SignupScreen.[ext]` - NEW
- `[ui_dir]/LoginScreen.[ext]` - NEW
- `[ui_dir]/AuthSuccessScreen.[ext]` - NEW
- `[navigation_dir]/AuthNavigator.[ext]` - MODIFY
- `[tests_dir]/auth_ui_test.[ext]` - NEW

### Testing Requirements
- **Component**: Each screen with mocked state
- **Integration**: Complete navigation flow with mocked auth state

## Dependencies
- Requires: m01-e02-t02 (State Layer - provides auth state interface)
- Blocks: None (can be developed in parallel with other layers)
```

**Task 2: State Layer for Complete Auth Flow**
```markdown
---
id: m01-e02-t02
title: State Layer - Authentication State Management
epic: m01-e02
milestone: m01
status: pending
---

# Task: State Layer - Complete Authentication Flow

## Context
Implements all state management for signup→login→success flow including auth state, loading states, error states, flow control.

## Implementation Guide for LLM Agent

### Objective
Create state management that tracks user progress through signup→login→dashboard flow.

### Steps
1. Define auth state model
   - Current screen (signup|login|success)
   - User data (email, auth token)
   - Loading states (isSigningUp, isLoggingIn)
   - Error states (signupError, loginError)

2. Implement state transitions
   - initiateSignup() → loading → success/error
   - initiateLogin() → loading → success/error
   - navigateToLogin()
   - navigateToSignup()
   - completeAuth() → navigate to dashboard

3. Implement error handling
   - Network errors
   - Validation errors
   - Server errors
   - Clear errors on retry

4. Create test suite (mock business logic layer)
   - Test: signup flow state transitions
   - Test: login flow state transitions
   - Test: error handling in each state
   - Test: loading states during operations

### Acceptance Criteria
- [ ] All state transitions work correctly [Test: signup→login→success]
- [ ] Loading states prevent duplicate operations [Test: double-click signup]
- [ ] Errors clear on retry [Test: error→retry clears error]
- [ ] Tests pass with >85% coverage

### Files to Create/Modify
- `[state_dir]/AuthState.[ext]` - NEW
- `[state_dir]/AuthActions.[ext]` - NEW
- `[tests_dir]/auth_state_test.[ext]` - NEW

## Dependencies
- Requires: m01-e02-t03 (Business Logic Layer)
- Blocks: m01-e02-t01 (UI Layer needs state interface)
```

This demonstrates how each task implements ONE complete horizontal layer across the ENTIRE user flow.

## Summary
Transform user flow epics into horizontal technical layer tasks. Each task implements ONE complete layer (UI, state, business logic, data, integration) across the ENTIRE user flow. Each task is LLM-executable with exact objectives, numbered steps with file paths, testable criteria, testing requirements, dependencies, and technical context. Specificity is critical.
