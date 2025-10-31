---
id: m01-e01-t04
title: Smart Ranking Algorithm Implementation
epic: m01-e01
milestone: m01
status: pending
---

# Task: Smart Ranking Algorithm Implementation

## Context
Part of Backend Flyer API and Data Services (m01-e01) in Milestone 1: Anonymous Flyer Browsing (m01).

Implements the smart ranking algorithm that balances three factors: recency (when flyer was created), proximity (distance from user's location), and relevance (category match). This algorithm determines the order of flyers in the feed, ensuring users see the most relevant and timely flyers first.

## Implementation Guide for LLM Agent

### Objective
Create a ranking algorithm that scores flyers based on recency, proximity, and category relevance, then integrates it into the FlyerViewSet to order feed results.

### Steps

1. **Create ranking service** in `pockitflyer_backend/flyers/services/ranking.py`

   **RankingService class**:

   **Method**: `calculate_score(flyer: Flyer, user_lat: float | None, user_long: float | None, preferred_categories: list[str] | None) -> float`
   - Returns composite score (0.0 to 100.0, higher = better ranking)
   - Combines three weighted sub-scores:
     - Recency score: 40% weight
     - Proximity score: 40% weight
     - Relevance score: 20% weight
   - Handles missing user location (proximity defaults to neutral score)
   - Handles missing category preferences (relevance defaults to neutral score)

2. **Implement recency scoring**

   **Method**: `_calculate_recency_score(created_at: datetime) -> float`
   - Returns 0.0 to 100.0
   - Algorithm:
     - Calculate age in hours: `hours_old = (now - created_at).total_seconds() / 3600`
     - Apply decay function: `score = 100.0 * exp(-hours_old / 168.0)` (168 hours = 1 week half-life)
     - Flyers created within last hour: ~100 score
     - Flyers 1 week old: ~50 score
     - Flyers 1 month old: ~10 score
   - Use Python's `math.exp()` for exponential decay

3. **Implement proximity scoring**

   **Method**: `_calculate_proximity_score(user_lat: float, user_long: float, flyer_lat: float, flyer_long: float) -> float`
   - Returns 0.0 to 100.0
   - Algorithm:
     - Calculate distance using haversine formula (see step 4)
     - Apply inverse distance scoring:
       - 0-1 km: 100 score
       - 1-5 km: 80 score
       - 5-10 km: 60 score
       - 10-25 km: 40 score
       - 25-50 km: 20 score
       - >50 km: 10 score
     - Use piecewise linear interpolation within ranges
   - If user location missing: return 50.0 (neutral score)

4. **Implement haversine distance calculation**

   **Method**: `_calculate_distance_km(lat1: float, long1: float, lat2: float, long2: float) -> float`
   - Returns distance in kilometers
   - Haversine formula implementation:
     ```python
     R = 6371  # Earth radius in km
     dlat = radians(lat2 - lat1)
     dlong = radians(long2 - long1)
     a = sin(dlat/2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlong/2)**2
     c = 2 * atan2(sqrt(a), sqrt(1-a))
     distance = R * c
     ```
   - Use Python's `math` module (sin, cos, radians, sqrt, atan2)

5. **Implement relevance scoring**

   **Method**: `_calculate_relevance_score(flyer_category: str, preferred_categories: list[str] | None) -> float`
   - Returns 0.0 to 100.0
   - Algorithm:
     - If no preferences provided: return 50.0 (neutral)
     - If flyer category in preferred_categories: return 100.0 (perfect match)
     - If flyer category not in preferences: return 25.0 (low relevance)
   - Simple boolean matching (can enhance later with multi-category weights)

6. **Integrate ranking into FlyerViewSet** in `pockitflyer_backend/flyers/views.py`

   **Modify FlyerViewSet**:
   - Add query parameters to `list` action:
     - `lat` (float, optional): user latitude
     - `long` (float, optional): user longitude
     - `categories` (comma-separated string, optional): preferred categories (e.g., "events,nightlife")
   - Override `get_queryset()`:
     - Get base queryset (active flyers)
     - Extract query params (lat, long, categories)
     - If no location provided: fall back to simple `-created_at` ordering
     - If location provided: annotate queryset with scores
   - Use Django's `annotate()` with custom ranking:
     - Option A: Python-side ranking (fetch all, score, sort) - simpler, less efficient
     - Option B: Database-side ranking (SQL expression) - more complex, more efficient
     - **Recommended**: Option A for MVP (YAGNI), optimize later if needed

   **Option A Implementation** (Python-side ranking):
   - Fetch queryset as list: `flyers = list(queryset)`
   - Score each flyer: `scored_flyers = [(flyer, RankingService.calculate_score(...)) for flyer in flyers]`
   - Sort by score descending: `scored_flyers.sort(key=lambda x: x[1], reverse=True)`
   - Return sorted flyers: `return [f[0] for f in scored_flyers]`
   - NOTE: Pagination still works, but scores not persisted in response (can add as annotation later)

7. **Add ranking configuration to settings** in `pockitflyer_backend/pokitflyer_api/settings.py`
   - Add RANKING settings dict:
     ```python
     RANKING = {
         'WEIGHTS': {
             'RECENCY': 0.4,
             'PROXIMITY': 0.4,
             'RELEVANCE': 0.2,
         },
         'RECENCY': {
             'HALF_LIFE_HOURS': 168,  # 1 week
         },
         'PROXIMITY': {
             'DISTANCE_RANGES': [
                 (1, 100),    # 0-1km: 100 score
                 (5, 80),     # 1-5km: 80 score
                 (10, 60),    # 5-10km: 60 score
                 (25, 40),    # 10-25km: 40 score
                 (50, 20),    # 25-50km: 20 score
             ],
             'DEFAULT_SCORE': 10,  # >50km
             'NEUTRAL_SCORE': 50,  # no user location
         },
         'RELEVANCE': {
             'MATCH_SCORE': 100,
             'NO_MATCH_SCORE': 25,
             'NEUTRAL_SCORE': 50,
         }
     }
     ```

8. **Create comprehensive test suite** in `pockitflyer_backend/flyers/tests/test_ranking.py`

   **RankingService unit tests**:
   - **Recency scoring**:
     - Flyer created 1 hour ago: score ~100
     - Flyer created 1 week ago: score ~50
     - Flyer created 1 month ago: score <15
     - Edge case: flyer created in future (should handle gracefully)
   - **Proximity scoring**:
     - User at same location as flyer: score = 100
     - User 3 km away: score = 80
     - User 30 km away: score = 40
     - User 100 km away: score = 10
     - No user location: score = 50 (neutral)
   - **Haversine distance**:
     - Known distance calculation (e.g., NYC to LA ~3944 km)
     - Same location: distance = 0
     - Nearby locations: verify accuracy within 1%
     - Edge cases: locations near poles, across dateline
   - **Relevance scoring**:
     - Flyer category in preferences: score = 100
     - Flyer category not in preferences: score = 25
     - No preferences: score = 50
   - **Composite scoring**:
     - Verify weights applied correctly (40% recency, 40% proximity, 20% relevance)
     - Recent + close + relevant flyer: score >80
     - Old + far + irrelevant flyer: score <30
     - Test various combinations

   **API integration tests** in `pockitflyer_backend/flyers/tests/test_api.py`:
   - **GET /api/flyers/ with location**:
     - Create 3 flyers at different locations (near, medium, far)
     - Request with user location
     - Verify order: nearest ranked higher (assuming similar recency)
   - **GET /api/flyers/ with categories**:
     - Create flyers with different categories
     - Request with preferred categories
     - Verify matching categories ranked higher
   - **GET /api/flyers/ with location + categories**:
     - Combined ranking test
     - Verify composite scoring
   - **GET /api/flyers/ without location**:
     - Falls back to `-created_at` ordering
     - Verify newest flyers first
   - **Edge cases**:
     - Invalid lat/long format (should handle gracefully)
     - Invalid category names (should ignore)

9. **Add score to API response** (optional enhancement)
   - Modify FlyerListSerializer to include `ranking_score` field
   - Pass score from ranking calculation to serializer context
   - Helps debugging and frontend display

### Acceptance Criteria
- [ ] Recency score decreases exponentially with age [Test: flyers at 1h, 1w, 1m old]
- [ ] Proximity score decreases with distance [Test: flyers at 1km, 10km, 50km, 100km]
- [ ] Relevance score highest for matching categories [Test: preferred vs non-preferred categories]
- [ ] Composite score combines all three factors with correct weights [Test: verify calculation]
- [ ] Haversine distance calculation accurate within 1% [Test: known distances]
- [ ] GET /api/flyers/?lat=X&long=Y returns ranked results [Test: verify nearby flyers first]
- [ ] GET /api/flyers/?categories=events,nightlife prioritizes matching categories [Test: verify category matches ranked higher]
- [ ] GET /api/flyers/ without location falls back to recency ordering [Test: verify newest first]
- [ ] Ranking handles missing user location gracefully [Test: proximity score = neutral]
- [ ] Ranking handles missing category preferences gracefully [Test: relevance score = neutral]
- [ ] All tests pass with >85% coverage [Test: pytest with coverage]

### Files to Create/Modify
- `pockitflyer_backend/flyers/services/ranking.py` - NEW: RankingService class with scoring methods
- `pockitflyer_backend/flyers/views.py` - MODIFY: integrate ranking into FlyerViewSet.list()
- `pockitflyer_backend/pokitflyer_api/settings.py` - MODIFY: add RANKING configuration
- `pockitflyer_backend/flyers/tests/test_ranking.py` - NEW: ranking algorithm tests
- `pockitflyer_backend/flyers/tests/test_api.py` - MODIFY: add ranking integration tests
- `pockitflyer_backend/flyers/serializers.py` - MODIFY (optional): add ranking_score field to response

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/integration tests here.

- **Unit tests**: Each scoring method isolated (recency, proximity, relevance), haversine formula, composite score calculation, edge cases (future dates, invalid coordinates)
- **Integration tests**: Full API requests with ranked results, various query parameter combinations, fallback behavior

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows project YAGNI principles (simple Python-side ranking, no premature optimization)
- [ ] Ranking weights configurable via settings
- [ ] Edge cases handled gracefully (no exceptions on invalid input)
- [ ] Minimal documentation explaining scoring algorithm
- [ ] Changes committed with reference to task ID (m01-e01-t04)
- [ ] All TDD markers set to `tdd_green` after verifying tests pass
- [ ] Ready for frontend integration

## Dependencies
- Requires: m01-e01-t01 (Flyer model), m01-e01-t02 (FlyerViewSet)
- No dependency on m01-e01-t03 (geocoding) - uses already-stored coordinates

## Technical Notes

### Why These Weights?
- **Recency 40%**: Fresh content is critical for engagement (events, limited-time offers)
- **Proximity 40%**: Location-based relevance is core to the app's value proposition
- **Relevance 20%**: Category preferences are secondary - users browse broadly
- Weights are configurable and can be tuned based on user behavior data later

### Exponential Decay for Recency
Linear decay (score = 100 - age_in_hours) would drop too fast:
- 4-day-old flyer would score 4/10 (too low)
Exponential decay with 1-week half-life provides better curve:
- Fresh flyers: very high scores (strong signal)
- Week-old flyers: still 50% (reasonable)
- Month-old flyers: low but not zero (still discoverable)

### Haversine Formula
Great-circle distance between two points on sphere:
- More accurate than Euclidean distance for geographic coordinates
- Standard formula for lat/long distance calculation
- Accuracy sufficient for city-scale distances (± few meters)
- Can upgrade to Vincenty formula later if higher precision needed (YAGNI for MVP)

### Why Python-Side Ranking (Not Database)?
Per YAGNI principle:
- Database-side ranking requires complex SQL with custom functions
- Python-side is simple, readable, testable
- Performance acceptable for MVP (< 1000 active flyers expected)
- Can optimize later with database expressions or caching if needed
- Pagination still works, just applied after sorting

### Performance Considerations
Current approach:
- Fetches all active flyers into memory
- Scores in Python
- Sorts in Python
- Paginates results
This is O(n log n) for n flyers. Acceptable for n < 10,000.
If performance becomes issue:
- Add database-side scoring (PostgreSQL window functions)
- Add caching layer (Redis)
- Pre-compute scores periodically (background task)

### Distance Ranges Rationale
Scoring ranges based on walkability and urban density:
- 0-1 km: Walking distance, perfect relevance
- 1-5 km: Biking distance, high relevance
- 5-10 km: Short drive, moderate relevance
- 10-25 km: Medium drive, lower relevance
- 25-50 km: Long drive, minimal relevance
- >50 km: Different city, very low relevance
Ranges can be adjusted based on user feedback.

### Handling Missing Data
Graceful degradation:
- No user location → proximity score = 50 (neutral, doesn't penalize)
- No category preferences → relevance score = 50 (neutral)
- Missing scores don't break ranking, just reduce weight of that factor
This ensures API works for all users (logged in or anonymous)

### Future Enhancements (Out of Scope)
- Personalized weights per user (learn from behavior)
- Time-of-day relevance (nightlife higher at night)
- Popularity factor (views, shares)
- Decay based on valid_until instead of created_at
- Machine learning ranking model
Per YAGNI: Don't implement until proven necessary

## References
- Haversine Formula: https://en.wikipedia.org/wiki/Haversine_formula
- Exponential Decay: https://en.wikipedia.org/wiki/Exponential_decay
- Python math module: https://docs.python.org/3/library/math.html
- Django QuerySet annotate: https://docs.djangoproject.com/en/5.1/ref/models/querysets/#annotate
- Project CLAUDE.md for YAGNI principles
- Project ARCHITECTURE.md for performance considerations
