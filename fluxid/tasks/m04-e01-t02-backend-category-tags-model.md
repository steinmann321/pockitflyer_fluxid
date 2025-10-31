---
id: m04-e01-t02
epic: m04-e01
title: Create Category Tags Model and Integration
status: pending
priority: high
tdd_phase: red
---

# Task: Create Category Tags Model and Integration

## Objective
Create Category model for predefined tags (Events, Nightlife, Service, etc.) with many-to-many relationship to Flyer model.

## Acceptance Criteria
- [ ] Category model with fields: name (unique), slug, display_order, is_active
- [ ] Predefined categories: Events, Nightlife, Service, Food & Drink, Retail, Community, Other
- [ ] Many-to-many relationship between Flyer and Category
- [ ] Data migration to populate initial categories
- [ ] Database indexing on name and slug
- [ ] Model validation ensures unique names and slugs
- [ ] Categories can be activated/deactivated without deletion
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- Category model field validation
- Unique constraint enforcement on name and slug
- Many-to-many relationship with Flyer
- Initial data migration creates all predefined categories
- Category ordering by display_order
- Active/inactive category filtering
- Flyer can have multiple categories
- Flyer without categories validation

## Files to Modify/Create
- `pockitflyer_backend/flyers/models.py` (Category model, Flyer.categories field)
- `pockitflyer_backend/flyers/tests/test_models.py` (Category tests)
- `pockitflyer_backend/flyers/migrations/000X_create_category_model.py` (auto-generated)
- `pockitflyer_backend/flyers/migrations/000X_populate_categories.py` (data migration)

## Dependencies
- m01-e01-t02 (Flyer model must exist)

## Notes
- Categories are predefined and managed via admin, not user-created
- Slug used for API filtering and URL-friendly identifiers
- display_order allows custom sorting in UI
- is_active allows deprecating categories without breaking existing flyers
- Consider future expansion: category icons, colors, descriptions
