---
id: m01-e04
title: User Views Creator Profiles
milestone: m01
status: pending
---

# Epic: User Views Creator Profiles

## Overview
Users tap on creator names or avatars from flyer cards to navigate to public profile pages. Profile pages display creator information (profile picture, name) and a feed of all flyers created by that user. This epic delivers creator discovery and establishes the foundation for creator-user relationships in future milestones.

## Scope
- Creator profile page UI
- Navigation from flyer card to profile page
- Creator information display (profile picture, name)
- Creator's flyers feed (all flyers by this creator)
- Backend API endpoint for user profiles
- Backend API endpoint for flyers filtered by creator
- Profile picture loading with fallback
- Back navigation to main feed

## Success Criteria
- [ ] Users can tap creator name or avatar to navigate to profile [Test: tap name, tap avatar, various flyer cards, navigation animation]
- [ ] Profile page displays creator information accurately [Test: with profile picture, without profile picture, various name lengths]
- [ ] Profile page shows all flyers by creator [Test: single flyer, multiple flyers, no flyers edge case, pagination if >20]
- [ ] Creator's flyers display with same card format as main feed [Test: consistency with main feed, all fields present, image carousels work]
- [ ] Profile picture loads with proper fallback [Test: valid image, missing image, failed load, loading state]
- [ ] Back navigation returns to main feed at previous scroll position [Test: scroll preservation, filter state maintained]
- [ ] Backend API returns complete user profile data [Test: all fields, privacy considerations for anonymous users viewing]
- [ ] Backend API filters flyers by creator efficiently [Test: query performance with indexes, various creator flyer counts]
- [ ] Profile page performance matches main feed [Test: load time <2s, smooth scrolling, efficient queries]
- [ ] Anonymous users can view all public creator profiles [Test: no authentication required, no restricted content]

## Dependencies
- Epic m01-e01 (requires flyer feed and user models)
- Backend user model must support profile pictures and public profile fields

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
- Profile pages are fully public (no authentication required for viewing)
- Profile picture fallback: show default avatar/initials if no picture
- Creator's flyers are shown in same smart-ranked order as main feed
- Profile page does not show private/draft flyers (only published, valid flyers)
- Database query requires index on flyer.creator_id for performance
- Profile data accessed via user ID extracted from flyer card
- Back navigation should maintain main feed state (scroll position, filters)
- Future milestones will add follow/unfollow functionality to profiles
- Profile picture should be optimized/resized by backend for mobile display
