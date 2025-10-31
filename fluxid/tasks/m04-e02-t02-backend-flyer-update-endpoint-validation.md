---
id: m04-e02-t02
title: Backend Flyer Update Endpoint with Validation
epic: m04-e02
milestone: m04
status: pending
---

# Task: Backend Flyer Update Endpoint with Validation

## Context
Part of Flyer Editing (m04-e02) in Milestone 4 (Creator Profile & Content Management).

This task creates the backend REST API endpoint that handles flyer updates, including field validation, authorization checks (users can only edit their own flyers), and data persistence. It processes updates to all flyer fields (text, categories, dates) but excludes image and geocoding logic, which are handled in m04-e02-t03. This endpoint ensures data integrity and enforces business rules before committing changes to the database.

## Implementation Guide for LLM Agent

### Objective
Create a PATCH endpoint at `/api/flyers/{id}/` that validates and persists flyer updates with proper authorization and comprehensive field validation.

### Steps

1. Create or modify Flyer model (if not already complete)
   - Location: `pockitflyer_backend/pokitflyer_api/models.py`
   - Ensure Flyer model includes all fields:
     - `id` (primary key, auto-generated)
     - `owner` (ForeignKey to User, required)
     - `title` (CharField, max_length=100, required)
     - `description` (TextField, max_length=500, required)
     - `info_text` (TextField, max_length=500, optional/blank)
     - `categories` (ManyToManyField to Category or JSONField with list)
     - `address` (CharField, max_length=255, required)
     - `latitude` (DecimalField, required)
     - `longitude` (DecimalField, required)
     - `publication_date` (DateTimeField, required)
     - `expiration_date` (DateTimeField, required)
     - `created_at` (DateTimeField, auto_now_add=True)
     - `updated_at` (DateTimeField, auto_now=True)
   - Add model-level validation method:
     ```python
     def clean(self):
         # Validate expiration_date is after publication_date
         if self.expiration_date <= self.publication_date:
             raise ValidationError("Expiration date must be after publication date")
     ```
   - Add database indexes:
     - `owner` (for ownership queries)
     - `publication_date`, `expiration_date` (for filtering)
     - `latitude`, `longitude` (for geospatial queries)

2. Create serializer for flyer updates
   - Location: `pockitflyer_backend/pokitflyer_api/serializers.py`
   - Create `FlyerUpdateSerializer(serializers.ModelSerializer)`:
     - Fields: `title`, `description`, `info_text`, `categories`, `address`, `publication_date`, `expiration_date`
     - Make all fields optional (PATCH allows partial updates)
     - Add field-level validators:
       - `title`: min_length=1, max_length=100
       - `description`: min_length=1, max_length=500
       - `info_text`: max_length=500 (allow blank)
       - `address`: min_length=1, max_length=255
       - `categories`: non-empty list
     - Add `validate()` method for cross-field validation:
       ```python
       def validate(self, data):
           # If both dates provided, validate order
           pub_date = data.get('publication_date', self.instance.publication_date)
           exp_date = data.get('expiration_date', self.instance.expiration_date)
           if exp_date <= pub_date:
               raise serializers.ValidationError("Expiration date must be after publication date")
           return data
       ```
     - Exclude `latitude`, `longitude` (handled in m04-e02-t03)
     - Exclude `owner`, `created_at`, `updated_at` (not editable)

3. Create flyer update view
   - Location: `pockitflyer_backend/pokitflyer_api/views.py`
   - Create `FlyerUpdateView(UpdateAPIView)` or add update logic to existing view:
     - HTTP method: PATCH
     - Endpoint: `/api/flyers/<int:pk>/`
     - Authentication: Required (JWT or session auth)
     - Permissions: Custom permission class `IsOwner` (see step 4)
     - Serializer: `FlyerUpdateSerializer`
     - Query: `Flyer.objects.filter(id=pk).select_related('owner')`
   - Override `update()` or `perform_update()` method:
     ```python
     def perform_update(self, serializer):
         # Verify user owns the flyer (already enforced by permission, but double-check)
         if serializer.instance.owner != self.request.user:
             raise PermissionDenied("You can only edit your own flyers")

         # Call model's clean() method for validation
         try:
             instance = serializer.save()
             instance.full_clean()  # Triggers model-level validation
         except ValidationError as e:
             raise serializers.ValidationError(e.message_dict)
     ```
   - Handle errors:
     - 400: Validation errors (field errors, date logic errors)
     - 401: Not authenticated
     - 403: Not owner of flyer
     - 404: Flyer not found
     - 500: Database errors

4. Create ownership permission class
   - Location: `pockitflyer_backend/pokitflyer_api/permissions.py` (create if doesn't exist)
   - Create `IsOwner(permissions.BasePermission)`:
     ```python
     class IsOwner(permissions.BasePermission):
         """
         Permission to only allow owners of a flyer to edit it.
         """
         def has_object_permission(self, request, view, obj):
             # Read permissions allowed for any request (handled elsewhere)
             # Write permissions only for owner
             return obj.owner == request.user
     ```

5. Register URL route
   - Location: `pockitflyer_backend/pokitflyer_api/urls.py`
   - Add PATCH route for flyer update:
     ```python
     path('api/flyers/<int:pk>/', FlyerUpdateView.as_view(), name='flyer-update'),
     # or include in router if using ViewSet
     ```
   - Ensure route accessible only to authenticated users

6. Add database migration
   - Run: `python manage.py makemigrations`
   - Review generated migration for Flyer model changes
   - Run: `python manage.py migrate`
   - Verify migrations applied successfully

7. Create comprehensive test suite
   - Location: `pockitflyer_backend/tests/test_flyer_update.py`
   - Mark all tests with `@pytest.mark.tdd_red` initially
   - **Authorization Tests**:
     - Test: authenticated user can update their own flyer → 200 OK [mark `tdd_green` after verification]
     - Test: unauthenticated user cannot update → 401 Unauthorized [mark `tdd_green` after verification]
     - Test: authenticated user cannot update another user's flyer → 403 Forbidden [mark `tdd_green` after verification]
     - Test: non-existent flyer ID returns 404 Not Found [mark `tdd_green` after verification]
   - **Field Validation Tests (Happy Path)**:
     - Test: valid title update (1-100 chars) → 200 OK, title updated [mark `tdd_green` after verification]
     - Test: valid description update (1-500 chars) → 200 OK, description updated [mark `tdd_green` after verification]
     - Test: valid info_text update (0-500 chars) → 200 OK, info_text updated [mark `tdd_green` after verification]
     - Test: valid category update → 200 OK, categories updated [mark `tdd_green` after verification]
     - Test: valid address update → 200 OK, address updated [mark `tdd_green` after verification]
     - Test: valid date updates (expiration after publication) → 200 OK, dates updated [mark `tdd_green` after verification]
   - **Field Validation Tests (Unhappy Path)**:
     - Test: empty title → 400 Bad Request, error: "title required" [mark `tdd_green` after verification]
     - Test: title >100 chars → 400 Bad Request, error: "title too long" [mark `tdd_green` after verification]
     - Test: empty description → 400 Bad Request, error: "description required" [mark `tdd_green` after verification]
     - Test: description >500 chars → 400 Bad Request, error: "description too long" [mark `tdd_green` after verification]
     - Test: info_text >500 chars → 400 Bad Request, error: "info_text too long" [mark `tdd_green` after verification]
     - Test: empty categories → 400 Bad Request, error: "at least one category required" [mark `tdd_green` after verification]
     - Test: empty address → 400 Bad Request, error: "address required" [mark `tdd_green` after verification]
   - **Date Validation Tests**:
     - Test: expiration_date before publication_date → 400 Bad Request, error: "expiration must be after publication" [mark `tdd_green` after verification]
     - Test: expiration_date equal to publication_date → 400 Bad Request, error: "expiration must be after publication" [mark `tdd_green` after verification]
     - Test: only updating publication_date (valid order maintained) → 200 OK [mark `tdd_green` after verification]
     - Test: only updating expiration_date (valid order maintained) → 200 OK [mark `tdd_green` after verification]
   - **Partial Update Tests (PATCH behavior)**:
     - Test: update only title, other fields unchanged → 200 OK, only title modified [mark `tdd_green` after verification]
     - Test: update multiple fields → 200 OK, all specified fields modified [mark `tdd_green` after verification]
     - Test: empty PATCH body → 200 OK, no changes (or 400 if implementation requires at least one field) [mark `tdd_green` after verification]
   - **Data Integrity Tests**:
     - Test: updated_at timestamp changes after update [mark `tdd_green` after verification]
     - Test: created_at timestamp unchanged after update [mark `tdd_green` after verification]
     - Test: owner field cannot be changed [mark `tdd_green` after verification]
     - Test: latitude/longitude unchanged (handled in m04-e02-t03) [mark `tdd_green` after verification]
   - **Integration Tests**:
     - Test: full update workflow (create flyer → update all fields → verify changes persisted) [mark `tdd_green` after verification]
     - Test: concurrent update handling (if applicable) [mark `tdd_green` after verification]

8. Run tests and mark with TDD markers
   - Run: `pytest pockitflyer_backend/tests/test_flyer_update.py -v`
   - For each test:
     - If passing: change marker from `@pytest.mark.tdd_red` to `@pytest.mark.tdd_green`
     - If failing: keep `@pytest.mark.tdd_red`, fix implementation, re-run, then mark `tdd_green`
   - **CRITICAL**: NEVER mark a test `tdd_green` without verifying it actually passes
   - Ensure >90% coverage for update view and serializer

### Acceptance Criteria
- [ ] PATCH `/api/flyers/{id}/` endpoint exists and responds [Test: endpoint accessible]
- [ ] Authenticated users can update their own flyers [Test: owner updates flyer → 200 OK]
- [ ] Non-owners cannot update flyers [Test: non-owner attempts update → 403 Forbidden]
- [ ] Unauthenticated requests rejected [Test: no auth token → 401 Unauthorized]
- [ ] All field validations enforced [Test: invalid title, description, categories, address, dates → 400 with errors]
- [ ] Date logic validated (expiration after publication) [Test: invalid date order → 400]
- [ ] Partial updates work (PATCH behavior) [Test: update only title → other fields unchanged]
- [ ] `updated_at` timestamp refreshed on save [Test: timestamp changes after update]
- [ ] Non-editable fields protected (owner, created_at) [Test: attempt to change owner → ignored or error]
- [ ] Database transactions handle errors gracefully [Test: validation error doesn't corrupt data]
- [ ] All tests pass with `tdd_green` markers [Test: `pytest -m tdd_green` shows all passing]
- [ ] Test coverage >90% for views, serializers, models [Test: `pytest --cov` report]

### Files to Create/Modify
- `pockitflyer_backend/pokitflyer_api/models.py` - MODIFY: Add/update Flyer model with validation
- `pockitflyer_backend/pokitflyer_api/serializers.py` - NEW/MODIFY: Create FlyerUpdateSerializer
- `pockitflyer_backend/pokitflyer_api/views.py` - NEW/MODIFY: Create FlyerUpdateView
- `pockitflyer_backend/pokitflyer_api/permissions.py` - NEW: Create IsOwner permission class
- `pockitflyer_backend/pokitflyer_api/urls.py` - MODIFY: Add PATCH route for flyer update
- `pockitflyer_backend/tests/test_flyer_update.py` - NEW: Comprehensive test suite
- `pockitflyer_backend/migrations/00XX_flyer_model.py` - NEW: Migration file (auto-generated)

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - Serializer validation: all field validators, cross-field validation (dates)
  - Model validation: `clean()` method, date logic
  - Permission class: ownership check logic
  - Edge cases: boundary values (0/1/100/101 chars, equal dates, missing fields)
- **Integration tests**:
  - Full endpoint workflow with test database
  - Authentication and authorization flow
  - Database persistence verification
  - Error response formats
  - Concurrent update scenarios (if applicable)

**Testing pyramid balance**: 40% unit (validation logic), 60% integration (endpoint workflows with database)

### Definition of Done
- [ ] Code written and passes all tests
- [ ] All tests marked `tdd_green` (verified passing)
- [ ] Code follows Django/DRF conventions
- [ ] No console errors or warnings
- [ ] Database migrations created and applied
- [ ] API documentation updated (if applicable)
- [ ] Changes committed with reference to m04-e02-t02
- [ ] Ready for image/geocoding integration in m04-e02-t03

## Dependencies
- Requires: m02 (authentication system with User model and JWT)
- Requires: m03 (Flyer model and creation logic exist)
- Requires: m04-e02-t01 (frontend edit UI for testing context)
- Blocks: m04-e02-t03 (image and geocoding integration builds on this)

## Technical Notes

**Django/DRF Specifics**:
- Use `UpdateAPIView` for clean PATCH implementation
- Use `serializers.ValidationError` for validation errors
- Use `PermissionDenied` for authorization errors
- Use `get_object_or_404` for safe object retrieval

**Validation Strategy**:
- Serializer handles field-level validation (types, lengths, required/optional)
- Serializer's `validate()` handles cross-field validation (date logic)
- Model's `clean()` provides additional business logic validation
- Call `full_clean()` before save to trigger model validation

**Authorization**:
- Use custom `IsOwner` permission class for object-level permissions
- DRF's permission system checks `has_object_permission()` automatically
- Double-check ownership in `perform_update()` for defense-in-depth

**PATCH vs PUT**:
- Use PATCH for partial updates (only update provided fields)
- Do not require all fields in request body
- Use serializer's `partial=True` if needed

**Error Responses**:
- Return consistent error format: `{"field": ["error message"]}`
- Use DRF's default error handling for consistency
- Provide actionable error messages

**Database Considerations**:
- Use `select_related('owner')` to avoid N+1 queries
- Ensure indexes on `owner`, `publication_date`, `expiration_date`
- Use transactions for data integrity (DRF handles this by default)

**Testing Best Practices**:
- Use Django's `TestCase` or `APITestCase` for database tests
- Use `APIClient` for endpoint testing
- Create test fixtures for User and Flyer objects
- Use `reverse()` for URL resolution in tests
- Test both success and error scenarios comprehensively

**Migration Strategy**:
- Review auto-generated migrations before applying
- Test migrations on copy of production data if applicable
- Consider backward compatibility if Flyer model already exists

## References
- Django Model Validation: https://docs.djangoproject.com/en/stable/ref/models/instances/#validating-objects
- DRF UpdateAPIView: https://www.django-rest-framework.org/api-guide/generic-views/#updateapiview
- DRF Serializer Validation: https://www.django-rest-framework.org/api-guide/serializers/#validation
- DRF Permissions: https://www.django-rest-framework.org/api-guide/permissions/
- Project's existing authentication setup (m02)
- Project's existing Flyer model (m03)
