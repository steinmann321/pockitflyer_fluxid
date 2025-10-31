---
id: m01-e01-t05
title: Filter, Search, and Distance Utilities
epic: m01-e01
milestone: m01
status: pending
---

# Task: Filter, Search, and Distance Utilities

## Context
Part of Backend Flyer API and Data Services (m01-e01) in Milestone 1: Anonymous Flyer Browsing (m01).

Implements filtering, search, and distance calculation utilities for the flyer feed API. Users can filter by category tags (multi-select OR logic), proximity distance, search by text, and see distance from their location. This task completes the backend API functionality for anonymous flyer browsing.

## Implementation Guide for LLM Agent

### Objective
Add category filtering, proximity filtering, full-text search, and distance calculation to the FlyerViewSet, enabling users to refine their flyer feed based on preferences and location.

### Steps

1. **Create filter utilities** in `pockitflyer_backend/flyers/services/filters.py`

   **FilterService class**:

   **Method**: `filter_by_categories(queryset: QuerySet, categories: list[str]) -> QuerySet`
   - Takes base queryset and list of category strings
   - Returns filtered queryset
   - Logic: OR condition (include if ANY category matches)
   - Implementation: `queryset.filter(category__in=categories)`
   - Handle empty list: return original queryset (no filtering)
   - Validate categories: ignore invalid values, only filter on valid choices (events, nightlife, service)

   **Method**: `filter_by_proximity(queryset: QuerySet, user_lat: float, user_long: float, max_distance_km: float) -> QuerySet`
   - Takes base queryset, user location, and max distance threshold
   - Returns flyers within max_distance_km from user location
   - Implementation approach (two options):
     - Option A: Python-side filtering (fetch all, calculate distances, filter) - simple
     - Option B: Database-side filtering (bounding box query) - efficient
     - **Recommended**: Option B for better performance
   - **Bounding box approach**:
     1. Calculate bounding box (min/max lat/long) for distance threshold
     2. Filter queryset by lat/long ranges (rectangular approximation)
     3. Optionally: refine with exact haversine distance in Python (removes corner overreach)
   - Formula for bounding box:
     ```python
     lat_delta = max_distance_km / 111.0  # ~111 km per degree latitude
     long_delta = max_distance_km / (111.0 * cos(radians(user_lat)))  # varies by latitude
     min_lat = user_lat - lat_delta
     max_lat = user_lat + lat_delta
     min_long = user_long - long_delta
     max_long = user_long + long_delta
     ```
   - Filter: `queryset.filter(location__latitude__gte=min_lat, location__latitude__lte=max_lat, location__longitude__gte=min_long, location__longitude__lte=max_long)`

2. **Create search utilities** in `pockitflyer_backend/flyers/services/search.py`

   **SearchService class**:

   **Method**: `search_flyers(queryset: QuerySet, query: str) -> QuerySet`
   - Takes base queryset and search query string
   - Returns filtered queryset matching search terms
   - Search fields: title, description (case-insensitive, partial match)
   - Implementation:
     - Use Django ORM `Q` objects for OR conditions
     - `queryset.filter(Q(title__icontains=query) | Q(description__icontains=query))`
   - Handle empty/whitespace query: return original queryset
   - Sanitize input: strip whitespace, limit length (prevent DoS with huge strings)
   - Max query length: 200 characters (reject longer queries)

   **Optimization**: Use database indexes
   - Create database index on `title` and `description` fields (text search performance)
   - Add `db_index=True` to Flyer model fields or create migration with GIN index (PostgreSQL) / FULLTEXT index (MySQL)
   - For SQLite (MVP): basic `icontains` is sufficient, no special index needed

3. **Create distance calculation utility** in `pockitflyer_backend/flyers/services/distance.py`

   **DistanceService class**:

   **Method**: `calculate_distance(user_lat: float, user_long: float, flyer_lat: float, flyer_long: float) -> float`
   - Returns distance in kilometers
   - Uses haversine formula (same as ranking service - consider reusing code)
   - Reuse haversine implementation from m01-e01-t04 if possible (DRY principle)
   - Can import from `flyers.services.ranking` or extract to shared utility

   **Method**: `annotate_distances(flyers: list[Flyer], user_lat: float, user_long: float) -> list[dict]`
   - Takes list of Flyer instances and user location
   - Returns list of dicts with flyer data + distance
   - Format: `[{'flyer': flyer_instance, 'distance_km': 5.2}, ...]`
   - Used to add distance to API responses

4. **Integrate filters into FlyerViewSet** in `pockitflyer_backend/flyers/views.py`

   **Modify FlyerViewSet.get_queryset()**:
   - Add query parameters:
     - `categories`: comma-separated category list (e.g., "events,nightlife")
     - `max_distance`: maximum distance in km (requires lat/long)
     - `search`: search query string
   - Extract query params from `self.request.query_params`
   - Apply filters in order:
     1. Base filter: `is_active=True` (already done in m01-e01-t02)
     2. Category filter: if categories param provided
     3. Proximity filter: if lat, long, max_distance provided
     4. Search filter: if search param provided
     5. Ranking: apply ranking logic from m01-e01-t04 (already integrated)
   - Validate parameters:
     - Categories: split by comma, strip whitespace, validate choices
     - max_distance: must be positive number, reasonable range (1-200 km)
     - search: strip whitespace, check length <= 200 chars
   - Handle invalid parameters gracefully: ignore invalid values, log warning, continue with valid filters

5. **Add distance to API response** (optional but recommended)

   **Modify FlyerListSerializer** in `pockitflyer_backend/flyers/serializers.py`:
   - Add `distance_km` field (optional, only when user location provided)
   - Use `SerializerMethodField` to compute distance dynamically
   - Implementation:
     ```python
     distance_km = serializers.SerializerMethodField()

     def get_distance_km(self, obj):
         user_lat = self.context.get('user_lat')
         user_long = self.context.get('user_long')
         if user_lat is None or user_long is None:
             return None
         return DistanceService.calculate_distance(user_lat, user_long, obj.location.latitude, obj.location.longitude)
     ```
   - Pass user_lat/user_long via serializer context in viewset

6. **Update settings for filter configuration** in `pockitflyer_backend/pokitflyer_api/settings.py`
   - Add FILTERS settings dict:
     ```python
     FILTERS = {
         'PROXIMITY': {
             'MAX_DISTANCE_KM': 200,  # Maximum allowed proximity filter
             'DEFAULT_DISTANCE_KM': 50,  # Default if not specified
         },
         'SEARCH': {
             'MAX_QUERY_LENGTH': 200,
         },
         'CATEGORIES': {
             'VALID_CHOICES': ['events', 'nightlife', 'service'],
         }
     }
     ```

7. **Create comprehensive test suite** in `pockitflyer_backend/flyers/tests/test_filters.py`

   **FilterService tests**:
   - **Category filtering**:
     - Single category: returns only matching flyers
     - Multiple categories (OR logic): returns flyers matching any category
     - All categories: returns all flyers
     - Empty category list: returns all flyers (no filtering)
     - Invalid category names: ignored, only valid categories applied
   - **Proximity filtering**:
     - Flyers within 10km: included
     - Flyers beyond 10km: excluded
     - Edge case: flyer exactly at max_distance boundary
     - Bounding box accuracy: verify lat/long ranges calculated correctly
     - Edge case: user near poles (high latitude)
     - Edge case: user at dateline (longitude wraparound) - skip for MVP if too complex

   **SearchService tests**:
   - **Text search**:
     - Partial match in title: found
     - Partial match in description: found
     - Case-insensitive: "EVENT" matches "event"
     - No match: empty result
     - Empty query: returns all flyers
     - Whitespace-only query: returns all flyers
     - Query exceeds max length: rejected or truncated
     - Special characters: handled safely (no SQL injection)

   **DistanceService tests**:
   - **Distance calculation**:
     - Same location: distance = 0
     - Known distance (e.g., NYC to LA): verify accuracy within 1%
     - Annotate distances: verify correct distance for each flyer
   - **Haversine formula**: reuse tests from m01-e01-t04 if code is shared

   **API integration tests** in `pockitflyer_backend/flyers/tests/test_api.py`:
   - **GET /api/flyers/?categories=events**:
     - Returns only event flyers
   - **GET /api/flyers/?categories=events,nightlife**:
     - Returns event OR nightlife flyers
   - **GET /api/flyers/?lat=X&long=Y&max_distance=10**:
     - Returns only flyers within 10km
     - Verify flyers beyond 10km excluded
   - **GET /api/flyers/?search=pizza**:
     - Returns flyers with "pizza" in title or description
     - Case-insensitive match
   - **Combined filters**:
     - GET /api/flyers/?categories=events&lat=X&long=Y&max_distance=5&search=music
     - Verify all filters applied together (AND logic between filter types)
   - **Distance in response**:
     - Verify distance_km field present when user location provided
     - Verify distance_km null when no user location
   - **Error handling**:
     - Invalid max_distance (negative, too large): rejected or clamped
     - Invalid category: ignored
     - Too-long search query: rejected or truncated

8. **Document API parameters** in code comments or docstrings
   - Explain query parameters for FlyerViewSet
   - Provide examples:
     - `/api/flyers/?categories=events,nightlife`
     - `/api/flyers/?lat=37.7749&long=-122.4194&max_distance=10`
     - `/api/flyers/?search=coffee`
     - `/api/flyers/?categories=service&lat=X&long=Y&max_distance=5&search=plumber`

### Acceptance Criteria
- [ ] Category filter supports single category [Test: GET ?categories=events returns only events]
- [ ] Category filter supports multi-select with OR logic [Test: ?categories=events,nightlife returns both]
- [ ] Proximity filter returns flyers within max_distance [Test: ?max_distance=10 with known locations]
- [ ] Proximity filter excludes flyers beyond max_distance [Test: verify distant flyer excluded]
- [ ] Search query matches title and description (case-insensitive) [Test: ?search=pizza finds "Pizza Party" and "Free pizza"]
- [ ] Search handles empty/whitespace query gracefully [Test: ?search= returns all flyers]
- [ ] Search rejects or truncates queries exceeding max length [Test: 250-char query]
- [ ] Distance calculation accurate within 1% [Test: known distances]
- [ ] Distance included in API response when location provided [Test: verify distance_km field]
- [ ] Combined filters work together (AND logic) [Test: categories + proximity + search]
- [ ] Invalid parameters handled gracefully (no crashes) [Test: negative distance, invalid category]
- [ ] All tests pass with >85% coverage [Test: pytest with coverage]

### Files to Create/Modify
- `pockitflyer_backend/flyers/services/filters.py` - NEW: FilterService class
- `pockitflyer_backend/flyers/services/search.py` - NEW: SearchService class
- `pockitflyer_backend/flyers/services/distance.py` - NEW: DistanceService class
- `pockitflyer_backend/flyers/views.py` - MODIFY: integrate filters into FlyerViewSet.get_queryset()
- `pockitflyer_backend/flyers/serializers.py` - MODIFY: add distance_km field to FlyerListSerializer
- `pockitflyer_backend/pokitflyer_api/settings.py` - MODIFY: add FILTERS configuration
- `pockitflyer_backend/flyers/tests/test_filters.py` - NEW: filter and search tests
- `pockitflyer_backend/flyers/tests/test_api.py` - MODIFY: add filter integration tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/integration tests here.

- **Unit tests**: Each filter/search method isolated, bounding box calculation, distance calculation, parameter validation
- **Integration tests**: Full API requests with various filter combinations, verify SQL queries (no N+1), edge cases

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project YAGNI principles (simple implementations)
- [ ] Filters can be combined without conflicts
- [ ] Invalid input handled gracefully (no exceptions)
- [ ] Minimal documentation for API parameters
- [ ] Changes committed with reference to task ID (m01-e01-t05)
- [ ] All TDD markers set to `tdd_green` after verifying tests pass
- [ ] Backend API complete and ready for frontend integration

## Dependencies
- Requires: m01-e01-t01 (Flyer model), m01-e01-t02 (FlyerViewSet), m01-e01-t04 (ranking service for haversine function reuse)
- No dependency on m01-e01-t03 (geocoding) - uses stored coordinates

## Technical Notes

### Filter Combination Logic
Filters combine with AND logic:
- Category filter: flyer in [selected categories]
- AND proximity filter: flyer within distance
- AND search filter: flyer matches query
- THEN ranking: sort by composite score

This provides intuitive narrowing behavior (more filters = fewer results, more relevant).

### Bounding Box vs Exact Distance
Bounding box approach:
- Pros: Fast database query using indexed lat/long columns
- Cons: Rectangular approximation (includes some flyers slightly beyond max_distance at corners)
For MVP, rectangular approximation is acceptable:
- Over-inclusion is minor (~10-15% at corners)
- User won't notice small deviation
- Can refine later by adding exact haversine check after bounding box filter (YAGNI for now)

### Search Implementation Trade-offs
Current approach: `icontains` (substring match)
- Pros: Simple, works on SQLite, no extra dependencies
- Cons: No relevance ranking, no stemming, slower on large datasets
Alternatives (future enhancements, out of scope):
- PostgreSQL full-text search (tsquery, tsvector)
- Elasticsearch integration
- Trigram similarity (pg_trgm)
Per YAGNI: Basic `icontains` is sufficient for MVP with <10k flyers.

### Distance Calculation Code Reuse
Haversine formula implemented in m01-e01-t04 (ranking service):
- Option A: Import from ranking.py: `from flyers.services.ranking import RankingService`
- Option B: Extract to shared utility: `flyers.services.geo_utils.calculate_distance()`
**Recommended**: Option B (create shared geo_utils module) for better organization and reusability.

### Performance Optimization
Current approach optimizes for simplicity:
- Database indexes on category, location lat/long (already in m01-e01-t01)
- Bounding box reduces search space before distance calculation
- Pagination limits result count
If performance issues arise:
- Add database-side distance calculation (PostgreSQL earthdistance extension)
- Add spatial indexes (PostGIS)
- Cache frequent queries (Redis)
Per YAGNI: Optimize only when proven necessary.

### Parameter Validation Strategy
Defensive programming without over-engineering:
- Validate types (float for lat/long, positive for distance)
- Validate ranges (lat: -90 to 90, long: -180 to 180, distance: 1-200 km)
- Sanitize strings (strip whitespace, check length)
- Ignore invalid values rather than rejecting entire request (graceful degradation)
- Log validation failures for debugging (don't expose to user)

### Multi-Select OR Logic for Categories
User selects "Events" and "Nightlife":
- Show flyers that are Events OR Nightlife (union)
- NOT Events AND Nightlife (intersection - would be too restrictive)
Implementation: `category__in=[events, nightlife]` (SQL IN clause = OR condition)

### Distance Display in UI
Including distance_km in API response enables frontend to:
- Display "1.2 km away" below flyer title
- Sort by distance (in addition to ranking)
- Show distance-based filters ("Show flyers within 5 km")
This enhances UX without additional API calls.

### Edge Cases to Handle
- User location at poles (latitude near ±90): bounding box calculation breaks down
  - Solution: Clamp longitude delta or skip proximity filter at extreme latitudes
  - For MVP: Document limitation, acceptable as most users not at poles
- User location at dateline (longitude ±180): wraparound issues
  - Solution: Complex longitude normalization
  - For MVP: Document limitation, acceptable as edge case
- Empty result sets: All filters applied but no matches
  - Solution: Return empty results array with 200 status (valid response, not error)

### Testing Strategy for Filters
- **Unit tests**: Test each filter method independently with mocked querysets
- **Integration tests**: Test full API with database, verify SQL query patterns
- **Edge cases**: Boundary values, empty inputs, invalid inputs
- **Combined filters**: Test all filter combinations (2^3 = 8 scenarios)

## References
- Django QuerySet filtering: https://docs.djangoproject.com/en/5.1/ref/models/querysets/#filter
- Django Q objects: https://docs.djangoproject.com/en/5.1/topics/db/queries/#complex-lookups-with-q-objects
- Haversine formula: https://en.wikipedia.org/wiki/Haversine_formula
- Bounding box calculation: https://gis.stackexchange.com/questions/2951/algorithm-for-offsetting-a-latitude-longitude-by-some-amount-of-meters
- DRF SerializerMethodField: https://www.django-rest-framework.org/api-guide/fields/#serializermethodfield
- Project CLAUDE.md for YAGNI principles
- Project ARCHITECTURE.md for performance and tech stack
