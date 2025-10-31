# Business Understanding: [Extracted Core Topic]

## Comprehensive Request Summary

[Detailed business-focused summary translating raw input into clear business language. This section answers: "What is being requested and why does it matter?"]

**Key aspects to cover:**
- Primary purpose and business goals
- Target users and their needs
- Core capabilities or features requested
- Expected business outcomes
- Context of the request (new feature, enhancement, fix, etc.)

## Business Context

[Why this matters to the business and how it fits into broader operations]

**Address:**
- Business problem being solved
- Opportunity being captured
- Strategic alignment
- Market or competitive drivers
- User pain points addressed
- Expected business impact

## Stakeholders

**Primary Users:**
- [User type 1]: [Their goals and needs]
- [User type 2]: [Their goals and needs]

**Secondary Stakeholders:**
- [Stakeholder type]: [Their interest/concern]

## Scope

### Includes
- [Capability 1 from user perspective]
- [Capability 2 from user perspective]
- [User interaction pattern or workflow]
- [Business rule or constraint]

### Excludes
- [Out of scope item 1]
- [Out of scope item 2]
- [Future consideration]

## User Journeys

[Describe key user workflows from beginning to end - focus on WHAT users do, not HOW it's implemented]

### Journey 1: [Journey Name]
**User Goal:** [What they want to accomplish]

**Steps:**
1. User [action in business terms]
2. System [response in business terms]
3. User [next action]
4. Outcome: [What user achieves]

**Success Scenario:** [When everything works as expected]
**Alternative Scenarios:** [Other paths or edge cases]

### Journey 2: [Journey Name]
[Repeat pattern]

## Interaction Patterns

[Describe HOW users interact with the system - patterns, behaviors, workflows]

### Pattern 1: [Pattern Name]
**Description:** [What this pattern provides]
**User Experience:** [How it feels/works from user perspective]
**Business Rationale:** [Why this pattern was chosen]

### Pattern 2: [Pattern Name]
[Repeat pattern]

## Business Rules

[Domain logic, constraints, validation requirements in business language]

1. **Rule Category: [e.g., Access Control]**
   - [Rule 1]: [Business rationale]
   - [Rule 2]: [Business rationale]

2. **Rule Category: [e.g., Data Validation]**
   - [Rule 1]: [Business rationale]
   - [Rule 2]: [Business rationale]

## Information Architecture

[What information/data the system manages - structure and relationships in business terms]

**Core Entities:**
- **[Entity 1]**: [What it represents, key attributes in business language]
- **[Entity 2]**: [What it represents, key attributes in business language]

**Relationships:**
- [Entity A] relates to [Entity B]: [Nature of relationship]

## Interface Understanding

_[Only include this section if the request contains UI/interface elements]_

### Layout Zones
[Describe functional areas and their purpose - not specific widgets/controls]

**[Zone Name]**:
- Purpose: [What users accomplish here]
- Contains: [Type of information/controls]
- Behavior: [How it responds to user actions]

### Visual Hierarchy
[What's most important to least important from user attention perspective]

1. [Primary element]: [Why it's primary]
2. [Secondary element]: [Why it's secondary]
3. [Supporting element]: [Why it's supporting]

### User Flow Patterns
[How users navigate through the interface]

**Primary Flow:**
[Entry point] → [Key interaction 1] → [Key interaction 2] → [Outcome]

**Alternative Flows:**
- [Scenario]: [Different path]

## Success Indicators

[How we measure if this delivers value - from business perspective]

**User Success:**
- Users can [accomplish goal 1] within [timeframe/effort]
- [User outcome 2] achieved
- [User satisfaction metric]

**Business Success:**
- [Business metric 1]: [Target]
- [Business metric 2]: [Target]
- [Adoption/usage indicator]

**Quality Indicators:**
- [Quality measure 1]
- [Quality measure 2]

## Assumptions

[What we're assuming to be true - needs validation]

1. [Assumption about users]
2. [Assumption about environment]
3. [Assumption about constraints]
4. [Assumption about dependencies]

## Constraints

[Known limitations or requirements that restrict solutions]

**Business Constraints:**
- [Regulatory, policy, or business rule constraint]

**User Constraints:**
- [User environment, capability, or access constraint]

**External Constraints:**
- [Third-party, integration, or dependency constraint]

## Validation Checklist

[Questions that emerged during analysis - areas needing stakeholder clarification]

### Clarified Decisions
_[After validation with stakeholder, move items here with answers]_

- ✅ **[Question]**: [Chosen answer and rationale]

### Pending Clarifications
_[Remove this section once all items clarified]_

- ❓ **[Question]**: [Why this needs clarification]

---

## Template Usage Notes

**For Requirements Engineers:**
- This document is tech-stack agnostic - no implementation details
- Focus on WHAT and WHY, never HOW
- Write for stakeholder validation, not developer implementation
- Use business language, not technical jargon
- Extract implicit requirements not explicitly stated
- Organize scattered input into coherent narrative
- Validate completeness - ensure no input details lost

**Validation Checklist Process:**
1. Identify all unclear or ambiguous points during analysis
2. Formulate as questions with 3-4 meaningful answer options
3. Present to stakeholder for clarification
4. Record answers and mark items as clarified
5. Refine document based on clarifications
6. Remove "Pending Clarifications" section when complete

**Optional Sections:**
- Skip "Interface Understanding" if no UI component
- Skip "User Journeys" if pure data/system request
- Add domain-specific sections as needed
- Adapt structure to fit request nature

**Remember:**
- You are translating stakeholder ideas into structured requirements
- This is input TO development planning, not output FROM it
- Every word should be understandable by non-technical stakeholders
- Complete this phase before any technical design begins
