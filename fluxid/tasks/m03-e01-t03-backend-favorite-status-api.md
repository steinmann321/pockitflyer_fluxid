---
id: m03-e01-t03
epic: m03-e01
title: Add Favorite Status to Flyer Responses
status: pending
priority: high
tdd_phase: red
---

# Task: Add Favorite Status to Flyer Responses

## Objective
Extend flyer API responses to include is_favorited boolean field indicating whether the requesting user has favorited each flyer. Field is null for anonymous users, true/false for authenticated users.

## Acceptance Criteria
- [ ] Flyer serializer includes is_favorited field (SerializerMethodField)
- [ ] is_favorited is null for anonymous users
- [ ] is_favorited is true if authenticated user has favorited the flyer
- [ ] is_favorited is false if authenticated user has not favorited the flyer
- [ ] Implementation uses efficient query (prefetch_related or annotate, not N+1 queries)
- [ ] Field appears in feed API, detail API, and creator flyers API
- [ ] All tests marked with `@pytest.mark.tdd_green` after passing

## Test Coverage Requirements
- is_favorited is null for anonymous requests
- is_favorited is true for favorited flyer (authenticated user)
- is_favorited is false for non-favorited flyer (authenticated user)
- Multiple flyers response includes correct is_favorited for each
- Query performance: verify no N+1 queries (use django-debug-toolbar or assertNumQueries)
- Integration with existing feed filters (favorited status works with category/location filters)

## Files to Modify/Create
- `pockitflyer_backend/flyers/serializers.py` (modify FlyerSerializer, add get_is_favorited method)
- `pockitflyer_backend/flyers/views.py` (modify FlyerViewSet queryset to prefetch favorites)
- `pockitflyer_backend/flyers/tests/test_serializers.py` (add is_favorited tests)
- `pockitflyer_backend/flyers/tests/test_views.py` (add query performance tests)

## Dependencies
- m03-e01-t01 (Favorite model must exist)
- m01-e01-t02 (Flyer model and serializer must exist)

## Notes
- Use prefetch_related('favorites') in viewset queryset for efficient loading
- SerializerMethodField accesses request.user via self.context['request'].user
- Check if request.user.is_authenticated before querying favorites
- Filter favorites: flyer.favorites.filter(user=request.user).exists()
- Consider using select_related/prefetch_related to minimize database queries
