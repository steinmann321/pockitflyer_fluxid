---
id: m02
title: Users can create accounts and publish their own flyers
status: pending
---

# Milestone: Users can create accounts and publish their own flyers

## Deliverable
Users can register for accounts using email authentication, log in to access authenticated features, and create/publish digital flyers that immediately appear in the discovery feed. This enables the two-sided marketplace where businesses and individuals can reach local audiences with their services, events, and promotions. The flyer creation interface provides complete control over images, text, categories, location, and validity dates.

## Success Criteria
- [ ] Users can register new accounts using email and password
- [ ] Registration automatically creates a default profile for the user
- [ ] Users can log in with email and password
- [ ] Logged-in users see their profile avatar in header instead of "Login" button
- [ ] Users can tap "Flyern" button in header to access flyer creation interface (requires login)
- [ ] Creation interface allows uploading 1-5 images with preview
- [ ] Creation interface provides fields for: title/caption, two free-text information fields, category tag selection, address input, publication date, expiration date
- [ ] Users can select multiple category tags from predefined options (Events, Nightlife, Service)
- [ ] Address input sends address to backend for geocoding conversion (no in-app geocoding)
- [ ] Users can publish completed flyers which immediately appear in the discovery feed
- [ ] Published flyers are visible to all users (anonymous and authenticated) in the feed
- [ ] Flyers respect ranking algorithm (recency, proximity, relevance)
- [ ] Backend validates flyer data and stores with associated user
- [ ] Backend handles geocoding of addresses to coordinates
- [ ] JWT authentication system for secure session management
- [ ] Complete UI implementation for registration, login, and creation workflows
- [ ] Full backend integration for auth and flyer storage
- [ ] All flows are polished and production-ready
- [ ] Can be deployed independently (builds on m01)
- [ ] Requires no additional milestones to be useful

## Validation Questions
**Before marking this milestone complete, answer:**
- [ ] Can a real user perform complete workflows with only this milestone? Yes - register, login, create flyer, see it published in feed
- [ ] Is it polished enough to ship publicly? Yes - complete authentication and creation experience
- [ ] Does it solve a real problem end-to-end? Yes - businesses/individuals can reach local audiences digitally
- [ ] Does it include both complete UI and functional backend integration? Yes - auth UI, creation UI, JWT backend, storage, geocoding
- [ ] Can it run independently without waiting for other milestones? Yes - builds on m01's browse capability
- [ ] Would you personally use this if it were released today? Yes - enables content creation for the platform

## Notes
This milestone completes the two-sided marketplace by enabling content creation alongside discovery. Users who find value in browsing (m01) can now contribute their own content, creating network effects. The complete implementation includes:

**Frontend Components:**
- Registration form with email/password validation
- Login form with authentication
- "Flyern" button in header (auth-protected)
- Flyer creation interface with:
  - Image upload (1-5 images) with multi-select
  - Text input fields (title, 2 info fields)
  - Category tag selector with multi-select
  - Address input field
  - Date pickers for publication/expiration
  - Publish button
- Profile avatar display in header when authenticated
- Auth state management

**Backend Components:**
- User registration endpoint with password hashing
- Login endpoint with JWT token generation
- JWT authentication middleware
- Flyer creation endpoint with validation
- Image upload and storage handling
- Geocoding integration for address → coordinates
- Association of flyers with creator user
- Default profile creation on registration

**Key Dependencies:**
- JWT library for token management
- Password hashing (bcrypt or similar)
- Image storage solution
- Geocoding service integration (geopy)

**Security Considerations:**
- Password strength validation
- JWT token expiration and refresh
- Rate limiting on registration
- Image upload validation (size, type)
- XSS protection on text fields

This milestone maps to requirements in refined-product-analysis.md sections:
- Authentication & User Profiles (lines 168-180)
- Flyer Creation & Management - Creation (lines 183-186)
- User Management (lines 78-87)
