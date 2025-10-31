---
id: m04
title: Flyer Creation and Management
status: pending
---

# Milestone: Flyer Creation and Management

## Deliverable
Authenticated users can create, publish, edit, and delete their own digital flyers. The "Flyern" button in the header provides access to a complete flyer creation interface where users upload images (1-5 required), add text content, select category tags, input location (with backend geocoding), and set publication/expiration dates. Users can view their published flyers on their profile page, tap to edit any aspect, extend expiration dates with manual reactivation, and permanently delete flyers. All flyer data is persisted with image storage and geocoding integration.

## Success Criteria
- [ ] Authenticated users can access flyer creation via "Flyern" button in header - UI navigation to creation screen (requires authentication)
- [ ] Users can upload 1-5 images for their flyer - image upload UI with validation, preview, and reordering
- [ ] Users can add title/caption and two free-text information fields - text input UI with character limits and validation
- [ ] Users can select category tags from predefined options - tag selection UI (multi-select for Events, Nightlife, Service, etc.)
- [ ] Users can input flyer location as an address - address input UI that sends to backend for geocoding
- [ ] Backend converts address to geocoordinates using geocoding service (geopy) - address validation and coordinate storage
- [ ] Users can set publication start date and expiration date - date picker UI with validation (expiration must be after publication)
- [ ] Users can publish flyer and see it appear in the main feed immediately - create flyer API with optimistic UI update
- [ ] Users can view their published flyers listed on their own profile page - profile UI shows user's flyers
- [ ] Users can tap any of their flyers from profile to navigate to edit screen - navigation to edit interface
- [ ] Users can edit all aspects of published flyers (images, text, tags, dates, location) at any time - complete edit UI with backend update APIs
- [ ] Expired flyers are automatically deactivated and don't appear in public feeds - backend expiration logic with scheduled checks
- [ ] Users can manually extend expiration dates, requiring manual reactivation - date edit with reactivation toggle in UI
- [ ] Users can permanently delete flyers (hard delete, no recovery) - delete confirmation UI with backend delete API
- [ ] Complete UI implementation for creation and management workflows - polished creation, edit, and delete screens
- [ ] Full backend flyer models with all fields (images, text, tags, geocoordinates, dates) - database tables with proper validation and indexing
- [ ] Image storage integration (Pillow for image processing) - backend handles image upload, storage, and serving
- [ ] Geocoding service integration for address-to-coordinate conversion - backend geocoding API calls with error handling
- [ ] Backend validation for all flyer data (required fields, date logic, image limits) - model-layer validation enforced
- [ ] All flows are polished and production-ready - consumer-grade content creation experience
- [ ] Can be deployed on top of M01-M03 - completes the platform with content creation
- [ ] Delivers core creator value - users can promote their services/events

## Validation Questions
**Before marking this milestone complete, answer:**
- [ ] Can a real user perform complete workflows with only this milestone? (create, publish, edit, delete flyers)
- [ ] Is it polished enough to ship publicly? (production-ready creation and management UI)
- [ ] Does it solve a real problem end-to-end? (digital flyer creation and distribution)
- [ ] Does it include both complete UI and functional backend integration? (yes - full creation stack)
- [ ] Can it run independently without waiting for other milestones? (yes - builds on M01-M03)
- [ ] Would you personally use this if it were released today? (yes - complete platform for creating and discovering flyers)

## Notes
- Requires M01 (Anonymous Discovery) for flyer display infrastructure
- Requires M02 (User Authentication) for authenticated creator context
- Requires M03 (Authenticated Engagement) for complete user experience
- Backend handles all geocoding - frontend never performs address conversion
- Image upload must handle validation, size limits, format restrictions
- Geocoding service requires error handling (invalid addresses, API failures)
- Flyer expiration requires backend scheduled task or check-on-read logic
- Hard delete is permanent - confirm user intent with clear UI warning
- Edit functionality must preserve flyer ID and creator relationship
- Consider edge cases: geocoding failures, image upload failures, concurrent edits
- Performance: image uploads should provide progress feedback for large files
- After M04, the platform is feature-complete for the core use case (create and discover local flyers)
