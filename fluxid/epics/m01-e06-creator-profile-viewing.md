---
id: m01-e06
title: Creator Profile Viewing
milestone: m01
status: pending
tasks:
  - m01-e06-t01
  - m01-e06-t02
  - m01-e06-t03
---

# Epic: Creator Profile Viewing

## Overview
Enables users to discover creators by viewing public profile pages that show creator information and all their published flyers. This epic adds a secondary discovery path through creator exploration.

## Scope
- Public creator profile page UI
- Creator information display (name, avatar, bio if available)
- Creator's flyers feed (all active flyers by this creator)
- Navigation from flyer card to creator profile
- Back navigation to main feed
- Backend public profile endpoint integration
- Profile loading and error states

## Success Criteria
- [ ] Tapping creator name/avatar on flyer card navigates to their profile [Test: tap targets, navigation animation, various flyer states]
- [ ] Profile page displays creator information clearly [Test: various data combinations, missing optional fields, long names, special characters]
- [ ] Profile page shows all active flyers by this creator [Test: creator with multiple flyers, single flyer, no current flyers, pagination if many]
- [ ] Flyers on profile use same card component as main feed [Test: consistency, all features work (carousel, location button), scroll behavior]
- [ ] Users can navigate back to main feed with preserved state [Test: back button, gesture, scroll position maintained, filters preserved]
- [ ] Profile loading state is shown while fetching data [Test: slow network, loading indicators, skeleton UI]
- [ ] Profile handles errors gracefully [Test: creator not found, network failure, timeout, backend errors]
- [ ] Deep linking to profiles works correctly [Test: direct URL navigation, return to previous context]
- [ ] Profile updates reflect current flyer status [Test: expired flyers not shown, new flyers appear, real-time consistency]
- [ ] Performance is smooth with many flyers [Test: creators with 50+ flyers, scroll performance, image loading]

## Tasks
- Public creator profile page UI layout (m01-e06-t01)
- Creator profile navigation from flyer cards (m01-e06-t02)
- Backend profile endpoint integration and state management (m01-e06-t03)

## Dependencies
- m01-e01 (Backend Flyer API) - requires public profile endpoint
- m01-e02 (Core Feed Display) - reuses flyer card component
- Flutter navigation system

## Completion Checklist
**Before marking this epic complete:**
- [ ] All tasks are completed and tested
- [ ] All success criteria are validated
- [ ] Epic contributes to milestone deliverability
- [ ] No regressions or breaking changes introduced

## Notes
Creator profiles add a secondary discovery mechanism: users can find interesting creators and explore all their flyers. This supports community building and creator visibility.

**Key UX Decisions:**
- Tappable creator info on flyer cards (name and avatar)
- Reuse flyer card component for consistency
- Standard back navigation to preserve context
- Show only active flyers (not expired)
- Profile is public (no authentication required)

**Technical Considerations:**
- Reuse existing FlyerCard component from main feed
- Use same infinite scroll pattern if creator has many flyers
- Cache profile data to avoid redundant API calls
- Handle navigation state properly (back button behavior)
- Consider hero animation for creator avatar transition

**Profile Page Layout:**
- Header: Creator avatar (larger), name, bio (if available)
- Body: Scrollable feed of creator's flyers using FlyerCard component
- All flyer card features work (carousel, location, map button)
- Consistent visual design with main feed

**Navigation Flow:**
- Main feed → Tap creator name/avatar → Creator profile
- Creator profile → Back button/gesture → Main feed (state preserved)
- Maintain scroll position and filter state on return
- Support deep linking for direct profile access

**Error Handling:**
- Creator not found: show helpful message, offer return to feed
- Network error: show retry option
- No active flyers: show empty state with explanation
- Backend errors: graceful degradation with error message
