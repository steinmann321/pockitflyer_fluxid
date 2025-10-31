---
id: m02-e02-t09
epic: m02-e02
title: Add Profile Picture to Flyer Cards
status: pending
priority: medium
tdd_phase: red
---

# Task: Add Profile Picture to Flyer Cards

## Objective
Update FlyerCard widget to display creator's profile picture alongside flyer information, enabling visual creator identity in feed.

## Acceptance Criteria
- [ ] FlyerCard displays creator's profile picture (small circular avatar)
- [ ] Default avatar shown when creator has no profile picture
- [ ] Avatar size: 32x32px (small, fits card layout)
- [ ] Avatar positioned near creator name on card
- [ ] Tapping avatar navigates to creator's profile
- [ ] Avatar image cached for performance
- [ ] Card layout adjusted to accommodate avatar
- [ ] Consistent avatar styling across all flyer cards
- [ ] All tests tagged with `tags: ['tdd_green']` after passing

## Test Coverage Requirements
- Flyer card renders with creator profile picture
- Flyer card renders with default avatar when creator has no picture
- Avatar size is 32x32px
- Tapping avatar navigates to creator profile
- Card layout looks good with avatar
- Avatar caching works correctly
- Multiple cards in feed show different avatars correctly

## Files to Modify/Create
- `pockitflyer_app/lib/widgets/flyer_card.dart` (update existing)
- `pockitflyer_app/lib/models/flyer.dart` (add creator_profile_picture field)
- `pockitflyer_app/test/widgets/flyer_card_test.dart` (update existing)

## Dependencies
- m01-e01-t06 (Existing FlyerCard widget)
- m02-e02-t05 (Profile screen for navigation)
- m01-e01-t04 (Backend feed API - update to include creator profile picture)

## Notes
- Requires backend API update to include creator profile picture in flyer data
- Backend feed API should include creator_profile_picture_url in flyer objects
- Reuse ProfileAvatar widget from t08 for consistency
- Avatar should not dominate card layout (small, subtle presence)
- Consider placeholder shimmer while avatar loads
- Image caching prevents repeated downloads of same avatar in feed
