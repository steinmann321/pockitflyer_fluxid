---
id: m01-e01-t01
title: Django Models for Flyer, Creator, Location
epic: m01-e01
milestone: m01
status: pending
---

# Task: Django Models for Flyer, Creator, Location

## Context
Part of Backend Flyer API and Data Services (m01-e01) in Milestone 1: Anonymous Flyer Browsing (m01).

Foundation task that creates the core Django data models for flyers, creators, and locations. This establishes the database schema with proper indexes, validation rules, and relationships needed for the flyer discovery API.

## Implementation Guide for LLM Agent

### Objective
Create Django models for Flyer, Creator, and Location with business logic validation, database indexes, and proper relationships to support the anonymous browsing experience.

### Steps

1. **Create base Creator model** in `pockitflyer_backend/flyers/models.py`
   - Extend Django's AbstractUser or create custom model with:
     - `email` (unique, indexed, required)
     - `display_name` (max 100 chars, required)
     - `bio` (text, optional, max 500 chars)
     - `avatar_url` (URL field, optional)
     - `created_at` (auto timestamp)
     - `updated_at` (auto timestamp)
   - Add model-level validation:
     - Email format validation
     - Display name cannot be empty or whitespace only
   - Add database indexes on `email`, `created_at`
   - Implement `__str__()` method returning display_name

2. **Create Location model** in same file
   - Fields:
     - `address` (text, required, max 255 chars)
     - `latitude` (decimal, 9 digits, 6 decimals, required)
     - `longitude` (decimal, 9 digits, 6 decimals, required)
     - `city` (max 100 chars, optional)
     - `country` (max 100 chars, optional)
     - `geocoded_at` (timestamp, auto-set when coordinates are set)
   - Add model-level validation:
     - Latitude range: -90 to 90
     - Longitude range: -180 to 180
     - Address cannot be empty or whitespace only
   - Add composite database index on `(latitude, longitude)` for proximity queries
   - Add database index on `city`
   - Implement `__str__()` method returning address

3. **Create Flyer model** in same file
   - Fields:
     - `creator` (ForeignKey to Creator, CASCADE, required)
     - `title` (max 200 chars, required)
     - `description` (text, required, max 2000 chars)
     - `category` (choices: 'events', 'nightlife', 'service', required)
     - `location` (ForeignKey to Location, CASCADE, required)
     - `image_url` (URL field, required)
     - `thumbnail_url` (URL field, optional)
     - `valid_from` (datetime, required)
     - `valid_until` (datetime, required)
     - `created_at` (auto timestamp)
     - `updated_at` (auto timestamp)
     - `is_active` (boolean, default True)
   - Add model-level validation:
     - Title and description cannot be empty or whitespace only
     - `valid_until` must be after `valid_from`
     - `valid_from` cannot be in the past (on creation)
     - Category must be one of allowed choices
   - Add database indexes:
     - `category` (for filtering)
     - `valid_from`, `valid_until` (for date range queries)
     - `created_at` (for recency sorting)
     - `is_active` (for filtering active flyers)
     - Composite index on `(category, is_active, created_at)` for optimized feed queries
   - Add property method `is_currently_valid()` that checks current datetime against valid_from/valid_until
   - Implement `__str__()` method returning title

4. **Create migrations**
   - Run `python manage.py makemigrations flyers`
   - Verify migration file contains all fields, indexes, and constraints
   - Run `python manage.py migrate` to apply

5. **Create comprehensive test suite** in `pockitflyer_backend/flyers/tests/test_models.py`
   - **Creator model tests**:
     - Valid creator creation with all fields
     - Email uniqueness constraint
     - Email validation (invalid formats rejected)
     - Display name cannot be empty/whitespace
     - String representation
     - Timestamps auto-populate
   - **Location model tests**:
     - Valid location creation
     - Latitude/longitude range validation (edge cases: -90, 90, -180, 180)
     - Invalid coordinates rejected (-91, 91, -181, 181)
     - Address cannot be empty/whitespace
     - Geocoded timestamp set automatically
     - String representation
   - **Flyer model tests**:
     - Valid flyer creation with all required fields
     - ForeignKey relationships (creator, location)
     - Category choices validation
     - Valid date range (valid_until > valid_from)
     - Invalid date ranges rejected (until before from, from in past)
     - `is_currently_valid()` property (before valid_from, within range, after valid_until)
     - Title/description cannot be empty/whitespace
     - is_active defaults to True
     - String representation
     - Database indexes exist (verify via Django ORM)

6. **Register models in Django admin** (optional, for manual testing)
   - Create `pockitflyer_backend/flyers/admin.py`
   - Register Creator, Location, Flyer models with list_display, search_fields, list_filter

### Acceptance Criteria
- [ ] Creator model stores user profile with email, display_name, bio, avatar [Test: create instance, verify all fields]
- [ ] Location model stores geocoded coordinates with address [Test: create with lat/long, verify storage]
- [ ] Flyer model stores complete flyer data with creator and location relationships [Test: create with FK relations]
- [ ] Email uniqueness enforced [Test: duplicate email creation raises error]
- [ ] Coordinate range validation enforces -90≤lat≤90, -180≤long≤180 [Test: boundary values and out-of-range values]
- [ ] Date validation enforces valid_until > valid_from [Test: reversed dates raise error]
- [ ] Category choices limited to events/nightlife/service [Test: invalid category rejected]
- [ ] Database indexes exist on all queried fields [Test: Django ORM index inspection]
- [ ] Composite indexes optimized for feed queries [Test: verify (category, is_active, created_at) index exists]
- [ ] `is_currently_valid()` correctly determines flyer validity [Test: past/current/future flyers]
- [ ] All tests pass with >90% coverage [Test: pytest with coverage]

### Files to Create/Modify
- `pockitflyer_backend/flyers/__init__.py` - NEW: empty init file if doesn't exist
- `pockitflyer_backend/flyers/models.py` - NEW: Creator, Location, Flyer models
- `pockitflyer_backend/flyers/admin.py` - NEW: admin registration
- `pockitflyer_backend/flyers/tests/__init__.py` - NEW: empty init file
- `pockitflyer_backend/flyers/tests/test_models.py` - NEW: comprehensive model tests
- `pockitflyer_backend/flyers/migrations/0001_initial.py` - GENERATED: initial migration
- `pockitflyer_backend/pokitflyer_api/settings.py` - MODIFY: add 'flyers' to INSTALLED_APPS if not present

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/integration tests here.

- **Unit tests**: Model validation logic (date ranges, coordinate ranges, email format, empty field checks), property methods (`is_currently_valid()`), string representations
- **Integration tests**: Database constraints (uniqueness, foreign keys), index existence verification, migration application

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Django conventions and project YAGNI principles
- [ ] No console errors or warnings during migration
- [ ] Minimal documentation added (why, not what) for non-obvious validation rules
- [ ] Changes committed with reference to task ID (m01-e01-t01)
- [ ] All TDD markers set to `tdd_green` after verifying tests pass
- [ ] Ready for m01-e01-t02 (REST API endpoints) to use these models

## Dependencies
- Django REST Framework installed (already in requirements)
- SQLite database configured (already in settings)
- No task dependencies (foundation task)

## Technical Notes

### Business Logic Validation Strategy
Per ARCHITECTURE.md: "Business logic enforced at model layer, not in serializers/views"
- Implement validation in model `clean()` methods
- Override `save()` to call `full_clean()` automatically
- This ensures validation runs regardless of how models are created (admin, API, fixtures)

### Index Strategy
Per epic notes: "Use database indexing on all queried fields for performance"
- Single-column indexes: Fields used in WHERE, ORDER BY clauses
- Composite indexes: Common query patterns (e.g., category + active + created_at for feed)
- Avoid over-indexing: Only add indexes for actual query patterns

### Model Design Principles
- Follow Django conventions: `created_at`/`updated_at` timestamps, `is_active` flags
- Use CharField for short text, TextField for long text
- Use DecimalField for coordinates (avoid FloatField precision issues)
- ForeignKey with CASCADE: Deleting creator/location deletes related flyers (acceptable for MVP)

### Testing with pytest-testmon
Per CLAUDE.md: Backend requires `pytest-testmon` for smart test selection in pre-commit hooks
- Tests in this task should use `@pytest.mark.tdd_red` initially
- After implementation complete and tests verified passing, change to `@pytest.mark.tdd_green`
- NEVER mark tests green without actually running them first

### Migration Best Practices
- Always review auto-generated migrations before applying
- Verify indexes are created in migration file
- Run migrations in a transaction (SQLite default)
- Keep migrations small and focused

## References
- Django Model Field Reference: https://docs.djangoproject.com/en/5.1/ref/models/fields/
- Django Model Meta Options (indexes): https://docs.djangoproject.com/en/5.1/ref/models/options/#indexes
- Django Model Validation: https://docs.djangoproject.com/en/5.1/ref/models/instances/#validating-objects
- Project ARCHITECTURE.md for validation strategy and tech stack
- Project CLAUDE.md for TDD markers and testing approach
