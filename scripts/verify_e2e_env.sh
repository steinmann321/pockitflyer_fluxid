#!/bin/bash
# Verify E2E test environment is ready
# Checks: Django server running, test data loaded, geopy service working

set -e  # Exit on error

echo "====================================="
echo "Verifying E2E Test Environment"
echo "====================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall status
ALL_CHECKS_PASSED=true

# Check 1: Django server is running
echo ""
echo "Check 1: Django server running on http://localhost:8000"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/api/flyers/ | grep -q "200"; then
    echo -e "${GREEN}✓ Backend server is running${NC}"
else
    echo -e "${RED}✗ Backend server is NOT running${NC}"
    echo -e "${YELLOW}  Please start the backend: ./scripts/start_e2e_backend.sh${NC}"
    ALL_CHECKS_PASSED=false
fi

# Check 2: Test data is loaded
echo ""
echo "Check 2: Test data loaded (expecting 30 flyers)"
FLYER_COUNT=$(curl -s http://localhost:8000/api/flyers/ | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('count', len(data)) if isinstance(data, dict) else len(data))" 2>/dev/null || echo "0")

if [ "$FLYER_COUNT" = "30" ]; then
    echo -e "${GREEN}✓ Test data loaded: $FLYER_COUNT flyers${NC}"
else
    echo -e "${RED}✗ Expected 30 flyers, found $FLYER_COUNT${NC}"
    echo -e "${YELLOW}  Please seed test data: cd pockitflyer_backend && python manage.py seed_e2e_data --clear${NC}"
    ALL_CHECKS_PASSED=false
fi

# Check 3: Verify categories
echo ""
echo "Check 3: All three categories present"
# Fetch both pages to get all flyers
RESPONSE1=$(curl -s http://localhost:8000/api/flyers/ 2>/dev/null || echo "{}")
RESPONSE2=$(curl -s http://localhost:8000/api/flyers/?page=2 2>/dev/null || echo "{}")
RESPONSE="$RESPONSE1 $RESPONSE2"
HAS_EVENTS=$(echo "$RESPONSE" | grep -o '"category":"events"' | wc -l | tr -d ' ')
HAS_NIGHTLIFE=$(echo "$RESPONSE" | grep -o '"category":"nightlife"' | wc -l | tr -d ' ')
HAS_SERVICE=$(echo "$RESPONSE" | grep -o '"category":"service"' | wc -l | tr -d ' ')

if [ "$HAS_EVENTS" -gt "0" ] && [ "$HAS_NIGHTLIFE" -gt "0" ] && [ "$HAS_SERVICE" -gt "0" ]; then
    echo -e "${GREEN}✓ All categories present (events: $HAS_EVENTS, nightlife: $HAS_NIGHTLIFE, service: $HAS_SERVICE)${NC}"
else
    echo -e "${RED}✗ Missing categories (events: $HAS_EVENTS, nightlife: $HAS_NIGHTLIFE, service: $HAS_SERVICE)${NC}"
    ALL_CHECKS_PASSED=false
fi

# Check 4: Verify geocoded data
echo ""
echo "Check 4: Flyers have geocoded locations"
HAS_LATITUDE=$(echo "$RESPONSE" | grep -o '"latitude":' | wc -l | tr -d ' ')
HAS_LONGITUDE=$(echo "$RESPONSE" | grep -o '"longitude":' | wc -l | tr -d ' ')

if [ "$HAS_LATITUDE" -gt "0" ] && [ "$HAS_LONGITUDE" -gt "0" ]; then
    echo -e "${GREEN}✓ Geocoded locations present${NC}"
else
    echo -e "${RED}✗ Missing geocoded location data${NC}"
    ALL_CHECKS_PASSED=false
fi

# Check 5: Test geopy service (simple test)
echo ""
echo "Check 5: geopy service accessible"
# This is a basic check - the actual geocoding happens during data seeding
if [ "$HAS_LATITUDE" -gt "0" ]; then
    echo -e "${GREEN}✓ geopy appears to be working (geocoded data found)${NC}"
else
    echo -e "${YELLOW}⚠ Cannot verify geopy - no geocoded data found${NC}"
fi

# Final summary
echo ""
echo "====================================="
if [ "$ALL_CHECKS_PASSED" = true ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo "E2E test environment is ready"
    echo ""
    echo "You can now run Flutter integration tests:"
    echo "  cd pockitflyer_app"
    echo "  flutter test integration_test/environment_verification_test.dart"
    exit 0
else
    echo -e "${RED}✗ Some checks failed${NC}"
    echo "Please fix the issues above before running integration tests"
    exit 1
fi
