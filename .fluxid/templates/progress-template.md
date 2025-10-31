# fluxid Progress Tracking

**Project**: [Project Name]
**Last Updated**: YYYY-MM-DD

---

## 🚀 Milestone 01: [Milestone Title] (m01)
**Deliverable**: [What users can do with this milestone]

### Epics:
- [ ] **Epic 01**: [Epic Title] (m01-e01)
  - [ ] `m01-e01-t01` [Task description]
  - [ ] `m01-e01-t02` [Task description]
  - [ ] `m01-e01-t03` [Task description]

- [ ] **Epic 02**: [Epic Title] (m01-e02)
  - [ ] `m01-e02-t01` [Task description]
  - [ ] `m01-e02-t02` [Task description]
  - [ ] `m01-e02-t03` [Task description]

- [ ] **Epic 03**: [Epic Title] (m01-e03)
  - [ ] `m01-e03-t01` [Task description]
  - [ ] `m01-e03-t02` [Task description]

- [ ] **Milestone 01 Complete** - Ship consumer-grade [milestone name] *(requires user review)*

---

## 🚀 Milestone 02: [Milestone Title] (m02)
**Deliverable**: [What users can do with this milestone]

### Epics:
- [ ] **Epic 04**: [Epic Title] (m02-e01)
  - [ ] `m02-e01-t01` [Task description]
  - [ ] `m02-e01-t02` [Task description]

- [ ] **Epic 05**: [Epic Title] (m02-e02)
  - [ ] `m02-e02-t01` [Task description]
  - [ ] `m02-e02-t02` [Task description]

- [ ] **Milestone 02 Complete** - Ship consumer-grade [milestone name] *(requires user review)*

---

## 🚀 Milestone 03: [Milestone Title] (m03)
**Deliverable**: [What users can do with this milestone]

### Epics:
- [ ] **Epic 06**: [Epic Title] (m03-e01)
  - [ ] `m03-e01-t01` [Task description]
  - [ ] `m03-e01-t02` [Task description]

- [ ] **Milestone 03 Complete** - Ship consumer-grade [milestone name] *(requires user review)*

---

## Legend
- 🚀 **Milestone** - Consumer-grade deliverable (shippable to users)
- **Epic** - Feature group within milestone
- `mXX-eXX-tXX` - Task ID (LLM implementation guide)
- [ ] Pending
- [x] Complete

---

## Completion Rules

### Task Completion
 Mark complete when:
- Implementation finished and tested
- All acceptance criteria met
- Code merged to main branch

### Epic Completion
 Mark complete when:
- All tasks within epic are complete
- Epic validated against quality gates
- Integration tested

### Milestone Completion
 **CHECKPOINT - REQUIRES USER REVIEW**

 Mark complete when:
- All epics within milestone are complete
- Milestone validated against Critical Rule
- **Actually shipped to users** (not just code complete)
- Consumer-grade quality confirmed
- **User has reviewed and approved milestone completion**

**Important**: Milestone completion is a workflow checkpoint. When all epics are done, LLM agents must STOP and request user review before proceeding to the next milestone.

---

## Notes for LLM Agents

1. **Update this file** as you complete work
2. **Milestone checkpoint**: When all epics in a milestone are complete, STOP and notify the user for review - do NOT proceed to next milestone automatically
3. **Check milestone checkbox** only after user approval, when shipped, not when coded
4. **Add new tasks** to epics as needed (discovery is iterative)
5. **Never skip quality gates** - consumer-grade is non-negotiable
6. **Read this file first** to understand current project state
7. **Update Last Updated date** when making changes

---

## File Locations
- **Tasks**: `fluxid/tasks/mXX-eXX-tXX-name.md`
- **Epics**: `fluxid/epics/mXX-eXX-name.md`
- **Milestones**: `fluxid/milestones/mXX-name.md`
