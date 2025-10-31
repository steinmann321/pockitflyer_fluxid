# fluxid Workflow - Context Guide

## Purpose
Transform requirements into shippable, user-ready software through structured decomposition.

**Note1**: This document provides context about the fluxid workflow. For step-by-step instructions, see command files in `.fluxid/commands/`.
**Note2**: Company name is fluxid. All lowercase.
**Note3**: Version tracking - When modifying any `.fluxid/` or `fluxid/` files, increment the version in `.fluxid/VERSION` using semantic versioning (MAJOR.MINOR.PATCH).

## Critical Rule
**EACH MILESTONE MUST DELIVER CONSUMER-GRADE, FULLY USABLE SOFTWARE**
- Not prototypes, not demos, not MVPs
- End-user ready functionality
- Complete, polished, production-quality
- Independently deployable and valuable

## Workflow Stages

### 1. Requirements → Product Analysis
**Input**: `fluxid/requirements/*.md` + images (mockups, designs, wireframes, diagrams)
**Output**: `fluxid/product/refined-product-analysis.md`
**Focus**: WHAT is needed (business value), not HOW to build it (technical implementation)

### 2. Product → Milestones
**Input**: `fluxid/product/refined-product-analysis.md`
**Output**: `fluxid/milestones/mXX-name.md`
**Rule**: Each milestone = complete user-facing functionality
**Think**: WHAT feature set delivers complete user value?

### 3. Milestones → Epics
**Input**: `fluxid/milestones/mXX-*.md`
**Output**: `fluxid/epics/mXX-eXX-name.md`
**Focus**: Break milestone into logical feature groups

### 4. Epics → Tasks
**Input**: `fluxid/epics/mXX-eXX-*.md`
**Output**: `fluxid/tasks/mXX-eXX-tXX-name.md`
**Focus**: LLM-executable implementation guides

## File Structure & Naming

```
fluxid/
├── progress.md                              # Master progress tracking
├── requirements/                            # Raw input (*.md, images)
├── product/refined-product-analysis.md      # WHAT to build
├── milestones/mXX-descriptive-name.md       # Shippable releases
├── epics/mXX-eXX-descriptive-name.md        # Feature groups
└── tasks/mXX-eXX-tXX-descriptive-name.md    # Implementation guides
```

### ID Scheme (Path-Encoded)

Self-documenting IDs using zero-padded numbers in kebab-case filenames:
- **Milestone**: `mXX` → `m01-user-authentication.md`
- **Epic**: `mXX-eXX` → `m01-e02-social-login.md`
- **Task**: `mXX-eXX-tXX` → `m01-e02-t03-implement-oauth.md`

**Benefits**: No metadata lookup needed, fewer file reads, natural sorting, full context in ID.

## Progress Tracking (progress.md)

Master tracking file with 3-level checkbox hierarchy (Milestone → Epic → Task).

**Completion Rules**:
- ✅ **Task** = implementation complete & tested
- ✅ **Epic** = all tasks done & validated
- ✅ **Milestone** = all epics done & **shipped to users** & **user review approved**

**IMPORTANT - Milestone Checkpoint**:
Milestone completion is a **workflow checkpoint that requires user review**. When all epics in a milestone are complete:
1. LLM agents MUST STOP and notify the user
2. DO NOT automatically proceed to the next milestone
3. Wait for user review and approval
4. Only mark milestone checkbox complete after user approval

This checkpoint ensures quality validation and allows the user to verify consumer-grade delivery before moving forward.

## Key Principles

1. **User-First**: Every decision validates against end-user value
2. **Ship Early**: Milestones as small as possible while remaining useful
3. **No Compromises**: Consumer-grade quality is non-negotiable
4. **Progressive Enhancement**: Each milestone builds on previous
5. **LLM-Optimized**: Structure designed for autonomous execution

## Commands

**Location**: `.fluxid/commands/`
Step-by-step workflow execution commands for LLM agents.

## Templates

**Location**: `.fluxid/templates/`
- `milestone-template.md` - Shippable release structure
- `epic-template.md` - Feature group structure
- `task-template.md` - LLM implementation guide structure
- `progress-template.md` - Progress tracking structure
