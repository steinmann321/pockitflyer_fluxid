---
id: m04-e02-t14
epic: m04-e02
title: Implement Concurrent Edit Conflict Resolution
status: pending
priority: low
tdd_phase: red
---

# Task: Implement Concurrent Edit Conflict Resolution

## Objective
Implement mechanism to handle concurrent edits of the same flyer from multiple devices, using optimistic locking or last-write-wins strategy.

## Acceptance Criteria
- [ ] Backend detects concurrent modifications using version field or updated_at
- [ ] 409 Conflict response returned when concurrent edit detected
- [ ] Response includes current flyer state for conflict resolution
- [ ] Client can choose to overwrite or reload current state
- [ ] Transaction isolation prevents data corruption
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Concurrent updates from two clients detected
- First update succeeds, second returns 409
- 409 response includes current flyer state
- Version/timestamp comparison works correctly
- Transaction isolation prevents partial updates
- Client receiving 409 can reload and retry

## Files to Modify/Create
- `pockitflyer_backend/flyers/models.py` (add version or updated_at field)
- `pockitflyer_backend/flyers/views.py` (conflict detection in update view)
- `pockitflyer_backend/flyers/tests/test_concurrent_updates.py`

## Dependencies
- M04-E02-T02 (Backend update API)

## Notes
- Two approaches: version field (explicit) or updated_at comparison (implicit)
- Version field: increment on each update, reject if version mismatch
- updated_at: compare timestamp, reject if changed since client loaded
- Consider last-write-wins if conflicts are rare and acceptable
- Client should display clear message about conflict and options
- This is low priority - can be deferred if time-constrained
- Documentation should explain chosen strategy and trade-offs
