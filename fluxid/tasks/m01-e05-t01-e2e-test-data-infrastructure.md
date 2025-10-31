---
id: m01-e05-t01
epic: m01-e05
title: E2E Test Data Seeding Infrastructure
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test Data Seeding Infrastructure

## Objective
Create comprehensive test data seeding infrastructure for E2E milestone validation with realistic data volumes and diversity to support all M01 workflows without mocks.

## Acceptance Criteria
- [ ] Django management command: `python manage.py seed_e2e_data` creates complete test dataset
- [ ] 100+ flyers with diverse characteristics:
  - Categories: Events, Nightlife, Service (distributed evenly)
  - Locations: Various distances (0.1km to 50km from test center point)
  - Images: 1-5 images per flyer (realistic image URLs or test images)
  - Validity periods: Mix of fresh (just created), expiring soon, long-term
  - Addresses: Street addresses, landmarks, international formats
- [ ] 20+ users with realistic profiles:
  - Profile pictures (optional, 70% have pictures)
  - Bios (optional, 60% have bios)
  - Flyer counts: Distributed 0-50 flyers per creator
  - Some users with no flyers (for profile edge cases)
- [ ] Geocoding data pre-computed (all addresses converted to coordinates via real geopy)
- [ ] Database cleanup command: `python manage.py cleanup_e2e_data`
- [ ] Idempotent seeding (can run multiple times without duplicates)
- [ ] Deterministic data (same seed produces same dataset for reproducible tests)
- [ ] Test data markers: All E2E test data tagged for easy identification/cleanup
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Management command execution (seed and cleanup)
- Data volume validation (100+ flyers, 20+ users created)
- Data diversity validation (categories, distances, image counts)
- Geocoding integration (all addresses have valid coordinates)
- Idempotency (running seed twice doesn't duplicate data)
- Cleanup completeness (all test data removed, production data preserved)
- Performance (seeding completes in <30 seconds)

## Files to Modify/Create
- `pockitflyer_backend/users/management/commands/seed_e2e_data.py`
- `pockitflyer_backend/users/management/commands/cleanup_e2e_data.py`
- `pockitflyer_backend/users/tests/test_e2e_data_seeding.py`
- `pockitflyer_backend/users/fixtures/e2e_addresses.json` (realistic address list)
- `pockitflyer_backend/users/fixtures/e2e_flyer_templates.json` (titles, descriptions)

## Dependencies
- m01-e01-t02 (Flyer model must exist)
- m01-e01-t01 (User model must exist)
- m01-e01-t03 (Geocoding service must exist)

## Notes
**Test Center Point**: Use a configurable reference location (default: Zurich center, 47.3769, 8.5417)

**Address Diversity**:
- Urban addresses: Dense areas with multiple flyers nearby
- Suburban addresses: Medium density
- Rural addresses: Sparse, greater distances
- International formats: Swiss, German, French address styles

**Realistic Image Handling**:
- Option 1: Pre-generated placeholder images stored in test fixtures
- Option 2: Use placeholder image service (e.g., picsum.photos)
- Images must be downloadable/viewable by iOS app

**Geocoding Strategy**:
- Use real geopy service during seeding (NOT during tests)
- Cache geocoded coordinates in fixtures for fast seeding
- Include circuit breaker simulation: some addresses with geocoding failures

**Performance Considerations**:
- Bulk create operations where possible
- Pre-computed coordinates (no geocoding during test runs)
- Database indexing validated during seeding
