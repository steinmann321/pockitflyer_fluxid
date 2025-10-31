---
id: m02-e02-t06
title: Backend Geocoding Integration with Geopy
epic: m02-e02
milestone: m02
status: pending
---

# Task: Backend Geocoding Integration with Geopy

## Context
Part of Flyer Creation & Publishing (m02-e02) in Milestone m02 (Authenticated User Experience).

Implements geocoding service integration to convert user-provided addresses into latitude/longitude coordinates using geopy library. Includes circuit breaker pattern for resilience, caching for performance, retry logic with exponential backoff, and graceful error handling. Coordinates enable proximity-based ranking in the discovery feed.

## Implementation Guide for LLM Agent

### Objective
Create geocoding service using geopy with circuit breaker, caching, retry logic, and integration into flyer creation endpoint to populate lat/lng from addresses.

### Steps

1. Add geopy dependency
   - File: `pockitflyer_backend/requirements.txt`
   - Add: `geopy>=2.4.0`
   - Run: `pip install geopy`

2. Add circuit breaker dependency
   - File: `pockitflyer_backend/requirements.txt`
   - Add: `pybreaker>=1.0.0`
   - Run: `pip install pybreaker`

3. Configure geocoding settings
   - File: `pockitflyer_backend/pockitflyer_backend/settings.py`
   ```python
   # Geocoding configuration
   GEOCODING_SERVICE = 'nominatim'  # or 'google', 'mapbox', etc.
   GEOCODING_USER_AGENT = 'pockitflyer/1.0'
   GEOCODING_TIMEOUT = 5  # seconds
   GEOCODING_CACHE_TTL = 86400  # 24 hours in seconds

   # Circuit breaker settings
   GEOCODING_CIRCUIT_FAIL_MAX = 5  # failures before opening circuit
   GEOCODING_CIRCUIT_TIMEOUT = 60  # seconds to wait before retry
   ```

4. Create geocoding service with circuit breaker
   - File: `pockitflyer_backend/flyers/services/geocoding.py` (NEW)
   ```python
   from geopy.geocoders import Nominatim
   from geopy.exc import GeocoderTimedOut, GeocoderServiceError
   import pybreaker
   import logging
   from django.core.cache import cache
   from django.conf import settings
   import hashlib
   import time

   logger = logging.getLogger(__name__)

   # Circuit breaker instance
   geocoding_breaker = pybreaker.CircuitBreaker(
       fail_max=settings.GEOCODING_CIRCUIT_FAIL_MAX,
       timeout_duration=settings.GEOCODING_CIRCUIT_TIMEOUT,
       name='geocoding_service'
   )

   class GeocodingService:
       def __init__(self):
           self.geocoder = Nominatim(
               user_agent=settings.GEOCODING_USER_AGENT,
               timeout=settings.GEOCODING_TIMEOUT
           )

       def _get_cache_key(self, address):
           """Generate cache key from address"""
           address_hash = hashlib.md5(address.lower().encode()).hexdigest()
           return f"geocode:{address_hash}"

       def _geocode_with_retry(self, address, max_retries=3):
           """Geocode with exponential backoff retry"""
           for attempt in range(max_retries):
               try:
                   location = self.geocoder.geocode(address)
                   return location
               except GeocoderTimedOut:
                   if attempt == max_retries - 1:
                       raise
                   wait_time = 2 ** attempt  # Exponential backoff: 1s, 2s, 4s
                   logger.warning(f"Geocoding timeout, retrying in {wait_time}s...")
                   time.sleep(wait_time)
               except GeocoderServiceError as e:
                   logger.error(f"Geocoding service error: {e}")
                   raise

       @geocoding_breaker
       def geocode(self, address):
           """
           Geocode address to (latitude, longitude) with caching and circuit breaker.

           Returns:
               tuple: (latitude, longitude) or (None, None) if geocoding fails
           """
           if not address or not address.strip():
               logger.warning("Empty address provided for geocoding")
               return (None, None)

           # Check cache
           cache_key = self._get_cache_key(address)
           cached_result = cache.get(cache_key)
           if cached_result:
               logger.info(f"Geocoding cache hit for: {address}")
               return cached_result

           # Geocode with retry
           try:
               location = self._geocode_with_retry(address)

               if location:
                   result = (location.latitude, location.longitude)
                   # Cache successful result
                   cache.set(cache_key, result, settings.GEOCODING_CACHE_TTL)
                   logger.info(f"Geocoded: {address} -> {result}")
                   return result
               else:
                   logger.warning(f"No geocoding result for: {address}")
                   return (None, None)

           except GeocoderTimedOut:
               logger.error(f"Geocoding timeout after retries: {address}")
               return (None, None)
           except GeocoderServiceError as e:
               logger.error(f"Geocoding service error: {e}")
               return (None, None)
           except pybreaker.CircuitBreakerError:
               logger.error("Geocoding circuit breaker open, service unavailable")
               return (None, None)
           except Exception as e:
               logger.error(f"Unexpected geocoding error: {e}")
               return (None, None)

   # Singleton instance
   geocoding_service = GeocodingService()
   ```

5. Integrate geocoding into flyer creation
   - File: `pockitflyer_backend/flyers/views.py` (MODIFY)
   ```python
   from .services.geocoding import geocoding_service

   class FlyerViewSet(viewsets.ModelViewSet):
       # ... existing code

       def perform_create(self, serializer):
           # Get address from validated data
           address = serializer.validated_data.get('address')

           # Geocode address
           latitude, longitude = geocoding_service.geocode(address)

           # Save flyer with coordinates
           serializer.save(
               creator=self.request.user,
               latitude=latitude,
               longitude=longitude
           )

           # Log warning if geocoding failed (flyer still created)
           if latitude is None or longitude is None:
               logger.warning(f"Flyer created without coordinates: {address}")
   ```

6. Add geocoding status to API response (optional)
   - File: `pockitflyer_backend/flyers/serializers.py` (MODIFY)
   ```python
   class FlyerSerializer(serializers.ModelSerializer):
       geocoding_status = serializers.SerializerMethodField()

       class Meta:
           fields = [
               # ... existing fields
               'geocoding_status'
           ]

       def get_geocoding_status(self, obj):
           """Indicate if geocoding was successful"""
           if obj.latitude is not None and obj.longitude is not None:
               return 'success'
           elif obj.address:
               return 'failed'
           else:
               return 'not_applicable'
   ```

7. Create manual geocoding retry endpoint (optional)
   - File: `pockitflyer_backend/flyers/views.py` (MODIFY)
   ```python
   class FlyerViewSet(viewsets.ModelViewSet):
       # ... existing code

       @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated])
       def retry_geocoding(self, request, pk=None):
           """Retry geocoding for a flyer (creator only)"""
           flyer = self.get_object()

           # Ensure user is creator
           if flyer.creator != request.user:
               return Response(
                   {"error": "Only the creator can retry geocoding"},
                   status=status.HTTP_403_FORBIDDEN
               )

           # Retry geocoding
           latitude, longitude = geocoding_service.geocode(flyer.address)

           if latitude is not None and longitude is not None:
               flyer.latitude = latitude
               flyer.longitude = longitude
               flyer.save()
               serializer = self.get_serializer(flyer)
               return Response(serializer.data)
           else:
               return Response(
                   {"error": "Geocoding failed"},
                   status=status.HTTP_500_INTERNAL_SERVER_ERROR
               )
   ```

8. Create geocoding service tests
   - File: `pockitflyer_backend/flyers/tests/test_geocoding.py` (NEW)
   - Test: Valid address returns (lat, lng)
   - Test: Invalid address returns (None, None)
   - Test: Empty address returns (None, None)
   - Test: Geocoding timeout triggers retry with backoff
   - Test: After max retries, returns (None, None)
   - Test: Circuit breaker opens after fail_max failures
   - Test: Circuit breaker closed after timeout_duration
   - Test: Successful geocoding cached
   - Test: Cache hit skips geocoding API call
   - Test: Different addresses use different cache keys
   - Test: Same address (case-insensitive) uses same cache

9. Create integration tests
   - File: `pockitflyer_backend/flyers/tests/test_flyer_geocoding.py` (NEW)
   - Test: Create flyer with valid address, verify lat/lng populated
   - Test: Create flyer with invalid address, flyer created with null lat/lng
   - Test: Geocoding failure doesn't block flyer creation (graceful degradation)
   - Test: Retry geocoding endpoint updates coordinates
   - Test: Retry geocoding requires authentication
   - Test: Retry geocoding requires creator ownership
   - Test: Geocoding status in API response (success/failed/not_applicable)

10. Add geocoding monitoring/logging
    - Log successful geocoding with address and coordinates
    - Log failed geocoding with address and reason
    - Log circuit breaker state changes (open/half-open/closed)
    - Log cache hit/miss for performance monitoring

11. Document geocoding limitations
    - Add to API docs: geocoding may fail, coordinates will be null
    - Nominatim has usage policy (1 request/second for free tier)
    - Consider paid geocoding service for production (Google Maps, Mapbox)
    - Flyers without coordinates excluded from proximity-based ranking

### Acceptance Criteria
- [ ] Valid address geocoded to (lat, lng) [Test: "123 Main St, Boston, MA"]
- [ ] Invalid address returns (None, None) [Test: "asdfjkl"]
- [ ] Empty address returns (None, None) [Test: ""]
- [ ] Flyer creation succeeds even if geocoding fails [Test: trigger failure, verify 201]
- [ ] Coordinates populated in database when geocoding succeeds [Test: query DB, verify lat/lng]
- [ ] Coordinates null in database when geocoding fails [Test: invalid address, verify null]
- [ ] Geocoding timeout triggers retry with exponential backoff [Test: mock timeout]
- [ ] Circuit breaker opens after 5 consecutive failures [Test: mock 5 failures]
- [ ] Circuit breaker prevents calls when open [Test: trigger open, verify no calls]
- [ ] Circuit breaker closes after timeout duration [Test: wait, verify half-open]
- [ ] Successful geocoding result cached [Test: geocode twice, verify 1 API call]
- [ ] Cache key case-insensitive [Test: "Boston" and "boston" use same cache]
- [ ] Retry geocoding endpoint updates coordinates [Test: POST /api/flyers/1/retry_geocoding/]
- [ ] Retry requires creator ownership [Test: different user, verify 403]
- [ ] Unit tests pass with ≥90% coverage
- [ ] Integration tests pass

### Files to Create/Modify
- `pockitflyer_backend/requirements.txt` - MODIFY: add geopy, pybreaker
- `pockitflyer_backend/pockitflyer_backend/settings.py` - MODIFY: add geocoding settings
- `pockitflyer_backend/flyers/services/__init__.py` - NEW: services package
- `pockitflyer_backend/flyers/services/geocoding.py` - NEW: geocoding service
- `pockitflyer_backend/flyers/views.py` - MODIFY: integrate geocoding in create
- `pockitflyer_backend/flyers/serializers.py` - MODIFY: add geocoding_status field
- `pockitflyer_backend/flyers/tests/test_geocoding.py` - NEW: service tests
- `pockitflyer_backend/flyers/tests/test_flyer_geocoding.py` - NEW: integration tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/integration tests here.

- **Unit tests** (mock geopy):
  - GeocodingService: success, failure, timeout, retry, caching, circuit breaker
  - Cache key generation (case-insensitive)
  - Retry logic with exponential backoff

- **Integration tests** (mock geopy or use test addresses):
  - Flyer creation with geocoding success
  - Flyer creation with geocoding failure (graceful degradation)
  - Retry geocoding endpoint
  - Permissions (creator-only retry)
  - API response includes geocoding_status

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Django and project conventions
- [ ] All tests marked with appropriate TDD markers
- [ ] Geocoding failures don't block flyer creation
- [ ] Circuit breaker prevents cascading failures
- [ ] Caching reduces API calls
- [ ] Logging provides observability
- [ ] Changes committed with `m02-e02-t06` reference
- [ ] Ready for feed integration (proximity-based ranking)

## Dependencies
- Requires: m02-e02-t04 (Flyer model with lat/lng fields)
- Requires: m02-e02-t01, t02, t03 (frontend provides address)
- Blocks: Complete flyer creation flow
- Blocks: Proximity-based ranking in discovery feed (m01)

## Technical Notes

**Geocoding Service Selection**:
- **Nominatim** (OpenStreetMap): Free, 1 req/sec limit, good for development
- **Google Maps Geocoding API**: Paid, high accuracy, higher limits
- **Mapbox Geocoding API**: Paid, good alternative to Google
- Configure via `GEOCODING_SERVICE` setting for easy switching

**Circuit Breaker Pattern**:
- Prevents cascading failures when geocoding service is down
- States: Closed (normal) → Open (blocked) → Half-Open (testing) → Closed
- `fail_max=5`: open after 5 consecutive failures
- `timeout_duration=60`: wait 60s before retry

**Retry Strategy**:
- Exponential backoff: 1s, 2s, 4s
- Only retry on timeouts (not on service errors)
- Max 3 retries per geocoding attempt

**Caching Strategy**:
- Cache key: MD5 hash of lowercase address
- TTL: 24 hours (addresses don't change frequently)
- Cache backend: Django's default (Redis recommended for production)
- Cache invalidation: automatic via TTL

**Error Handling Philosophy**:
- Geocoding failure is NOT a critical error
- Flyer creation should succeed even if geocoding fails
- Coordinates set to null if geocoding fails
- Flyers without coordinates excluded from proximity ranking
- Users can retry geocoding via API endpoint

**Performance Considerations**:
- Caching reduces geocoding API calls by ~90%
- Exponential backoff prevents aggressive retries
- Circuit breaker prevents wasted attempts during outages
- Async geocoding in production (Celery task after flyer creation)

**Nominatim Usage Policy**:
- Max 1 request per second
- Must provide User-Agent header
- Free tier, community-run
- Not for high-volume production use
- See: https://operations.osmfoundation.org/policies/nominatim/

**Production Recommendations**:
- Use paid geocoding service (Google Maps, Mapbox)
- Implement rate limiting (respect service quotas)
- Use Redis for caching (faster than database)
- Geocode asynchronously (Celery task)
- Monitor circuit breaker state (alerts when open)

**Geocoding Response Example**:
```python
# Successful geocoding
{
  "address": "123 Main St, Boston, MA",
  "latitude": 42.3601,
  "longitude": -71.0589,
  "geocoding_status": "success"
}

# Failed geocoding
{
  "address": "invalid address",
  "latitude": null,
  "longitude": null,
  "geocoding_status": "failed"
}
```

**Proximity Ranking Integration**:
- Flyers with coordinates: ranked by distance from user location
- Flyers without coordinates: excluded from proximity ranking or ranked last
- Ranking algorithm (in feed endpoint):
  ```python
  if user_location and flyer.latitude and flyer.longitude:
      distance = calculate_distance(user_location, (flyer.latitude, flyer.longitude))
      proximity_score = 1 / (1 + distance)  # Closer = higher score
  ```

## References
- geopy documentation: https://geopy.readthedocs.io/
- Nominatim usage policy: https://operations.osmfoundation.org/policies/nominatim/
- pybreaker circuit breaker: https://github.com/danielfm/pybreaker
- Django caching: https://docs.djangoproject.com/en/stable/topics/cache/
- Exponential backoff: https://en.wikipedia.org/wiki/Exponential_backoff
