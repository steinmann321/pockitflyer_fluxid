---
id: mXX-eXX
title: E2E Milestone Validation (No Mocks)
milestone: mXX
status: pending
---

# Epic: E2E Milestone Validation (No Mocks)

## Overview
Validates the complete milestone [XX] deliverable through end-to-end testing WITHOUT MOCKS. All tests run against real backend, real database, and real external services to verify the milestone works exactly as it will be shipped to users.

## Scope
- Real backend server running (all services operational)
- Real database with test data
- Real external service integrations (APIs, third-party services)
- Complete user workflows from product requirements
- Performance validation under realistic conditions
- Error scenarios with actual service failures

## Success Criteria
- [ ] All critical user journeys complete successfully [Test: real backend + database + services, no mocks]
- [ ] System performs within defined targets under realistic load [Test: real network latency, real data volumes]
- [ ] Error handling works with actual service failures [Test: real timeouts, real error responses]
- [ ] Data persists correctly across the full stack [Test: verify database state after operations]
- [ ] All milestone success criteria validated end-to-end [Test: reference milestone success criteria]

## Dependencies
- All other epics in milestone mXX must be complete
- Real backend deployment capability (local or test environment)
- Test data seeding capability
- External service access (or test accounts)

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks completed with real services (NO MOCKS)
- [ ] All milestone success criteria validated end-to-end
- [ ] Performance meets targets in realistic conditions
- [ ] Error handling verified with actual failures
- [ ] Complete vertical slice works as shipped to users

## Notes
**CRITICAL: This epic uses NO MOCKS**

All services, databases, and external integrations must be real and functional. This is the final validation that the milestone delivers on its promise to users.

**Setup Requirements:**
- Backend server running locally or in test environment
- Database with realistic test data
- External service credentials/access (or test/sandbox accounts)
- Ability to simulate realistic network conditions
- Ability to trigger actual error scenarios

**What This Is NOT:**
- Not unit tests (those are in regular tasks)
- Not integration tests with mocks (those are in regular tasks)
- Not performance benchmarks (though performance is validated)
- Not load testing (though realistic load is used)

**What This IS:**
- Validation that milestone works end-to-end as shipped
- Real user workflows through the complete stack
- Verification with actual services and data
- Final quality gate before milestone completion
