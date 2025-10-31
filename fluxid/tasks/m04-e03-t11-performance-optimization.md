---
id: m04-e03-t11
title: Performance Optimization
epic: m04-e03
status: pending
---

# Task: Performance Optimization

## Description
Optimize expiration queries and deletion operations for performance with 1000+ flyers. Verify database indexes are utilized and operations complete within acceptable timeframes.

## Scope
- Verify database indexes on `is_active` and `expiration_date`
- Add composite index on (`is_active`, `expiration_date`) if needed
- Optimize feed queries with EXPLAIN analysis
- Benchmark feed query performance with 1000+ flyers
- Optimize deletion cascade performance
- Add database query logging for slow queries
- Profile image deletion performance
- Test with realistic dataset sizes

## Success Criteria
- [ ] Database indexes exist on `is_active`, `expiration_date`
- [ ] Composite index on (`is_active`, `expiration_date`) exists
- [ ] Feed queries use indexes (verified with EXPLAIN)
- [ ] Feed query with 1000+ flyers completes in <200ms
- [ ] Deletion completes in <1000ms including image cleanup
- [ ] No N+1 query problems
- [ ] Slow query logging configured
- [ ] Performance benchmarks documented
- [ ] All tests pass with `tdd_green` marker

## Test Cases
```python
@pytest.mark.tdd_red
def test_feed_query_uses_index():
    """EXPLAIN shows index usage for feed queries"""

@pytest.mark.tdd_red
def test_feed_query_performance_1000_flyers():
    """Feed query with 1000 flyers completes in <200ms"""

@pytest.mark.tdd_red
def test_feed_query_performance_1000_expired():
    """Feed query with 1000 expired flyers completes in <200ms"""

@pytest.mark.tdd_red
def test_deletion_performance():
    """Flyer deletion completes in <1000ms"""

@pytest.mark.tdd_red
def test_deletion_with_images_performance():
    """Deletion with 5 images completes in <2000ms"""

@pytest.mark.tdd_red
def test_no_n_plus_one_in_feed():
    """Feed query generates constant number of queries"""

@pytest.mark.tdd_red
def test_composite_index_exists():
    """Database has composite index on (is_active, expiration_date)"""
```

## Dependencies
- M04-E03-T01 (Backend Expiration Model Logic)
- M04-E03-T02 (Backend Expiration Feed Filtering)
- M04-E03-T04 (Backend Hard Delete API)

## Acceptance
- All tests marked `tdd_green`
- Performance benchmarks meet criteria
- Indexes optimized
- Documentation updated with performance characteristics
