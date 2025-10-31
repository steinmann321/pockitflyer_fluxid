---
id: m01-e04-t02
title: Real-time Search Filtering Logic and Backend Integration
epic: m01-e04
milestone: m01
status: pending
---

# Task: Real-time Search Filtering Logic and Backend Integration

## Context
Part of Search and Real-time Feed Updates (m01-e04) in Milestone 1 (m01).

Implements the backend search API endpoint and frontend search filtering logic that enables users to find specific flyers by matching text against flyer title, description, and creator name. Search combines with existing category/proximity filters using AND logic.

## Implementation Guide for LLM Agent

### Objective
Create backend search query support and frontend search state management that filters flyers in real-time as users type, combining search with existing filters.

### Steps

#### Backend Implementation

1. Add search query parameter to Flyer API endpoint
   - Locate the flyer list view in `pockitflyer_backend/flyers/views.py` or similar
   - Add `search` query parameter to the GET endpoint
   - Implement case-insensitive search across three fields:
     - `title` (flyer title)
     - `description` (flyer description)
     - `creator__name` or `creator__username` (creator name, adjust field name based on User model)
   - Use Django ORM Q objects for OR logic across fields: `Q(title__icontains=search) | Q(description__icontains=search) | Q(creator__name__icontains=search)`
   - Handle empty/None search parameter (return all results without search filter)
   - Combine search filter with existing category/proximity filters using AND logic
   - Handle special characters and SQL injection (Django ORM handles this automatically, but verify)
   - Return filtered queryset through existing serializer

2. Add search parameter to API serializer/filter class
   - If using django-filter or DRF filter backends, add `search` to filter class
   - If implementing in view directly, ensure query parameter is validated and sanitized
   - Document search parameter in API schema (if using drf-spectacular)

3. Create backend integration tests
   - Test search finds flyers by title [Test: search for known title substring]
   - Test search finds flyers by description [Test: search for known description substring]
   - Test search finds flyers by creator name [Test: search for known creator name]
   - Test search is case-insensitive [Test: uppercase, lowercase, mixed case queries]
   - Test search returns empty results for no matches [Test: search for non-existent term]
   - Test search combines with category filter [Test: search + category filter applied together]
   - Test search combines with proximity filter [Test: search + proximity filter applied together]
   - Test search handles empty/None parameter [Test: empty string returns unfiltered results]
   - Test search handles special characters [Test: search with quotes, ampersands, emoji]
   - Test search handles very long query strings [Test: 500+ character search string]

#### Frontend Implementation

4. Create search state provider
   - Create `pockitflyer_app/lib/providers/search_provider.dart`
   - Implement Riverpod StateNotifier or StateProvider for search query state
   - Store current search query string
   - Expose methods: `setSearchQuery(String query)`, `clearSearch()`
   - Emit state changes when search query updates

5. Integrate search with flyer feed provider
   - Locate flyer feed provider from m01-e02 (likely `pockitflyer_app/lib/providers/flyer_provider.dart`)
   - Add dependency on search provider
   - Include search parameter in API request when search query is not empty
   - Combine search parameter with existing filter parameters (category, proximity)
   - Trigger feed refresh when search query changes
   - Handle loading states during search operations

6. Connect search field UI to search provider
   - Locate SearchField widget from m01-e04-t01
   - Connect SearchField onChanged callback to search provider's `setSearchQuery()`
   - Connect SearchField onClear callback to search provider's `clearSearch()`
   - Ensure debounced input triggers provider state update
   - Show loading indicator in feed during search operation

7. Add empty search results state
   - Update feed display widget to detect empty results during active search
   - Show helpful message when search returns zero results: "No flyers match your search"
   - If filters are active, suggest: "Try clearing filters or adjusting your search"
   - Provide clear action to clear search and return to unfiltered feed

8. Create frontend integration tests
   - Test search query updates flyer feed [Test: mock API response with filtered results]
   - Test search combines with category filter [Test: both search and category parameters sent to API]
   - Test search combines with proximity filter [Test: both search and proximity parameters sent to API]
   - Test empty search clears filter [Test: empty query returns to unfiltered state]
   - Test search loading states [Test: loading indicator shown during API request]
   - Test empty search results display [Test: zero results shows empty state message]
   - Test rapid search query changes [Test: debounce prevents excessive API calls]

### Acceptance Criteria
- [ ] Backend search parameter filters flyers by title [Test: search "pizza" finds flyer with "Pizza Night"]
- [ ] Backend search parameter filters flyers by description [Test: search "discount" finds flyer with description containing "discount"]
- [ ] Backend search parameter filters flyers by creator name [Test: search "john" finds flyers by creator "John Doe"]
- [ ] Backend search is case-insensitive [Test: "PIZZA", "pizza", "PiZzA" all return same results]
- [ ] Backend search combines with category filter [Test: search="pizza" + category="food" returns only food flyers matching "pizza"]
- [ ] Backend search combines with proximity filter [Test: search="pizza" + proximity=5km returns only nearby flyers matching "pizza"]
- [ ] Backend search handles special characters without errors [Test: search with quotes, emoji, ampersands]
- [ ] Frontend search updates feed in real-time [Test: type in search field, feed updates automatically]
- [ ] Frontend search shows loading indicator during API request [Test: visual feedback while searching]
- [ ] Frontend empty search returns to unfiltered state [Test: clear search, see all flyers based on current filters]
- [ ] Frontend empty results show helpful message [Test: search for non-existent term, see empty state]
- [ ] Frontend debounce prevents excessive API calls [Test: rapid typing triggers one API call after 300ms pause]
- [ ] Backend tests pass with >90% coverage
- [ ] Frontend tests pass with >90% coverage

### Files to Create/Modify
- `pockitflyer_backend/flyers/views.py` - MODIFY: add search parameter to flyer list endpoint
- `pockitflyer_backend/flyers/filters.py` - MODIFY or CREATE: add search filter class (if using django-filter)
- `pockitflyer_backend/tests/test_flyers_api.py` - MODIFY: add search endpoint integration tests
- `pockitflyer_app/lib/providers/search_provider.dart` - NEW: search state management
- `pockitflyer_app/lib/providers/flyer_provider.dart` - MODIFY: integrate search with feed fetching
- `pockitflyer_app/lib/widgets/feed_display.dart` - MODIFY: add empty search results state
- `pockitflyer_app/lib/main.dart` or header widget - MODIFY: connect search field to search provider
- `pockitflyer_app/test/providers/search_provider_test.dart` - NEW: search provider unit tests
- `pockitflyer_app/test/integration/search_integration_test.dart` - NEW: search integration tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Backend Unit test**: Search query construction, Q object logic, parameter sanitization
- **Backend Integration test**: Full search endpoint with test database, combination with filters
- **Frontend Unit test**: Search provider state management, query updates, clear operations
- **Frontend Integration test**: Search connected to feed provider with mocked API, combined filter scenarios

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project conventions (Django REST Framework, Flutter/Dart style guides)
- [ ] No console errors or warnings
- [ ] Search works smoothly without performance issues
- [ ] API documented (if using drf-spectacular)
- [ ] Changes committed with reference to task ID
- [ ] Ready for dependent tasks to use

## Dependencies
- Requires: m01-e01 (Backend Flyer API) - flyer list endpoint must exist
- Requires: m01-e02 (Core Feed Display) - feed display and provider must exist
- Requires: m01-e03 (Category and Proximity Filtering) - filter providers must exist for combination
- Requires: m01-e04-t01 (Header search field UI) - search input component must exist
- Blocks: m01-e04-t03 can be implemented in parallel (independent concern)

## Technical Notes

### Backend
- Use Django ORM `Q` objects for OR logic across multiple fields
- Use `__icontains` lookup for case-insensitive substring matching
- Django ORM automatically handles SQL injection prevention
- Consider using `django-filter` for cleaner filter implementation
- If creator model has multiple name fields (first_name, last_name), search both
- Empty search parameter should be treated as "no search filter" not "match empty string"

### Frontend
- Search provider should be a simple StateNotifier or StateProvider (lightweight)
- Feed provider already handles API calls and filter state, just add search parameter
- Debounce is handled in SearchField widget (t01), provider just receives final query
- Show loading indicator during API request to provide user feedback
- Empty state should be helpful and actionable (suggest clearing filters)
- Consider adding search query display in UI ("Showing results for: pizza")

### Performance
- Backend: Ensure database indexes exist on title, description, creator name fields
- Frontend: Debounce (300ms) prevents excessive API calls during typing
- Consider adding minimum search length (e.g., 2 characters) if needed for performance

## References
- Django Q objects documentation: https://docs.djangoproject.com/en/stable/topics/db/queries/#complex-lookups-with-q-objects
- Django QuerySet API: https://docs.djangoproject.com/en/stable/ref/models/querysets/
- Riverpod StateNotifier: https://riverpod.dev/docs/concepts/providers/#statenotifierprovider
- Flutter integration testing: https://docs.flutter.dev/cookbook/testing/integration/introduction
