# Business Understanding: pokitflyer - Digital Flyer Platform

## Comprehensive Request Summary

pokitflyer is a comprehensive mobile application that creates a digital alternative to paper flyers and local advertisements. The platform enables users to create, publish, discover, and interact with digital flyers from local businesses and community members. The application serves as the main entry point for connecting users with local services, promotions, and events through a digital platform that replaces traditional paper flyer distribution.

The initial requirements focus primarily on the **home screen discovery interface**, with additional supporting features for user profiles, flyer creation, and account management that complete the full user experience.

**Core Functionality:**

The home screen provides a feed-based browsing experience where users can discover relevant local content through multiple filtering and discovery mechanisms. Users can browse flyers without authentication (anonymous mode), with optional login to unlock personalization features like favorites and following.

**Key Components:**

1. **Header Navigation**: Provides app branding, in-place search functionality, flyer creation access ("Flyern" button), and user authentication/profile access. The header remains persistent across the browsing experience. When logged out, shows a "Login" button; when authenticated, shows user's profile avatar that navigates to their profile page. Search filters the current feed in real-time without navigating to a separate screen.

2. **Multi-Tier Filtering System**: Two rows of filter options allow users to refine content by category tags (Events, Nightlife, Service) and by relationship to user (Near Me, Favorites, Following). Multiple category tags can be selected simultaneously using OR logic (showing flyers that match any selected tag). Filters can be combined across both tiers.

3. **Flyer Feed**: Vertical scrolling feed displaying flyer cards using a smart ranking algorithm that balances recency, proximity, and relevance. Users manually refresh the feed via pull-to-refresh to see new content. Each card presents comprehensive information about a local offering in a structured, scannable format.

4. **Flyer Cards**: Individual flyer cards showcase all essential information about a local offering:
   - Creator identity (profile picture, name)
   - Image carousel (1-5 images) with dot indicators
   - Location with address and distance from user
   - Title/headline of the offering
   - Descriptive text (caption and additional information fields)
   - Validity period (date range)
   - Interaction options (favorite, follow creator, open in device map app)

**User Interaction Patterns:**

- **Discovery**: Users scroll through the feed to discover local offerings, using filters to narrow down content based on their interests and needs. Pull-to-refresh gesture updates the feed with new content.
- **Quick Assessment**: Card design enables users to quickly scan and assess relevance. The card background itself is not tappable - users interact only with specific interactive elements.
- **Engagement**: Users tap specific buttons to favorite flyers, follow creators, or open location in device's native map app
- **Navigation**: Users tap the creator's name/avatar to navigate to their public profile page. Tapping individual interactive buttons triggers specific actions rather than navigating to detail views.

**Anonymous vs Authenticated Experience:**

- **Anonymous Users**: Full browsing and discovery capabilities, filters limited to category tags and "Near Me". Can view all flyers and public user profiles, but cannot create flyers, favorite, or follow.
- **Authenticated Users**: Additional access to "Favorites" and "Following" filters, ability to create flyers, save favorites, follow creators, and manage their own profile and flyers

**Localization & Discoverability:**

The platform leverages device location to show distance to each flyer's location, enabling users to find nearby services and events. The "Near Me" filter prioritizes content based on proximity to the user's current location. All address-to-geocoordinate conversion happens in the backend - the app works exclusively with geocoordinates and never performs geolocation conversion.

## Business Context

The home screen is the primary value delivery mechanism for pokitflyer's core business proposition. It directly addresses two key market needs:

1. **For Consumers**: Provides a curated, localized discovery platform to find relevant local services, promotions, and events without physical distribution limitations
2. **For Businesses**: Offers immediate visibility to local audiences who are actively looking for services, replacing paper flyer distribution with digital reach

The screen's design balances two critical business objectives:
- **Low Barrier to Entry**: Anonymous browsing removes friction for new users to immediately experience value
- **Engagement & Retention**: Personalization features (favorites, following) encourage account creation and repeated usage

This approach supports a network effect business model where more users attract more flyers, and more quality flyers attract more users. The filtering system helps manage content volume as the platform scales, ensuring users can always find relevant content.

## Scope

**Includes**:

**Home Screen - Discovery Interface:**
- Feed-based browsing interface with infinite scroll and pull-to-refresh
- Multi-level filtering system with OR logic for category tags
- Smart ranking algorithm (recency, proximity, relevance)
- Anonymous browsing capability
- Location-based distance calculation and display (using geocoordinates from backend)
- Flyer card display with all key information
- Image carousel with multiple images per flyer
- Interactive buttons for specific actions (favorite, follow, open in device map)
- Non-tappable card background (only buttons are interactive)
- Creator name/avatar is tappable and navigates to creator's public profile
- Native map integration (opens device's default map app)
- In-place search that filters the current feed in real-time
- Persistent header with: branding, search, "Flyern" (create) button, login/profile button

**User Management:**
- Email-based registration and authentication (creates empty default profile)
- Login button in header switches to profile avatar/icon when authenticated
- Public user profile pages (viewable by anyone, including anonymous users)
- Profile displays: profile picture, name, and list of user's flyers
- From profile's flyer list, users can navigate to edit screen for their own flyers
- Basic profile management (edit profile picture and name)
- Privacy settings (including email contact permission)
- Favorites filter on home screen (no dedicated favorites list view)
- Following filter on home screen (no dedicated following list view)

**Flyer Creation & Management:**
- "Flyern" button in header provides access to creation interface (authentication required)
- Flyer creation interface with image upload (1-5 images required)
- Text fields: title/caption, two free-text information fields
- Tag selection from predefined categories
- Location setting with address input (converted to geocoordinates by backend)
- No "My Address" setting - address required per flyer
- Publication and expiration date selection
- Full editing capability for published flyers at any time (images, text, tags, dates, location)
- Expired flyers are auto-deactivated; extending duration requires manual reactivation
- Hard delete only (delete = permanently remove, no soft delete/archiving)
- Edit access from profile page flyer list

**Settings & Account Management:**
- Account settings interface
- Privacy controls
- Profile management access

**Excludes**:
- Dedicated search screen or popup (search is in-place on home screen)
- Dedicated favorites/following list views (accessible only via home screen filters)
- "My Address" user setting (addresses per flyer only)
- In-app geolocation/geocoding (backend handles address-to-coordinate conversion)
- Notifications system
- In-app map view (uses device's native map app instead)
- Direct messaging or contact functionality
- Comments or reviews on flyers
- Social sharing functionality (no share buttons)
- Flyer detail view as separate screen (all info shown in feed cards)
- Soft delete/archiving (only hard delete)

## Behavior Specifications

### Feed Ranking Algorithm
The feed uses a **smart ranking algorithm** that balances multiple factors:
- **Recency**: Newer flyers receive priority to keep content fresh
- **Proximity**: Flyers closer to user's location are weighted higher
- **Relevance**: User's selected filters and browsing patterns influence ranking

This approach optimizes for discovery while maintaining local relevance, helping users find both timely and nearby offerings.

### Filter Interaction Logic
**Category Tags** (Events, Nightlife, Service):
- **Multi-select enabled**: Users can select multiple tags simultaneously
- **OR logic**: Feed shows flyers matching ANY selected tag
- Example: Selecting "Events" + "Nightlife" shows flyers tagged with Events OR Nightlife OR both

**Relationship Filters** (Near Me, Favorites, Following):
- Work independently and can be combined with category tags
- "Favorites" and "Following" require authentication

### Feed Update Mechanism
**Pull-to-refresh only** - manual control approach:
- Feed does NOT update automatically with new content
- Users must perform pull-to-refresh gesture to fetch new flyers
- Provides predictable, stable browsing experience
- Prevents jarring content shifts while user is browsing

### Search Behavior
**In-place filtering** - no separate search screen:
- Search field is located in the header, always accessible
- As user types, the feed filters in real-time to show matching flyers
- Search applies to current feed (respects active filters)
- No navigation away from home screen - results appear in the same feed view
- Search looks for matches in: flyer title, description, location, creator name
- Clearing search returns to the full filtered feed

### Card Interaction Model
**Button-only interactivity**:
- Card background is NOT tappable/clickable
- Only specific UI elements trigger actions:
  - Creator name/avatar → Navigate to creator's public profile page
  - Favorite button → Toggle favorite status (requires authentication)
  - Follow button → Toggle follow status (requires authentication)
  - Location button → Open device's default map app with flyer location
  - Image carousel → Swipe to view multiple images

This explicit interaction model prevents accidental taps and gives users precise control over their actions.

### Authentication & User Profiles
**Registration & Login**:
- Email-based authentication required for creating flyers, favoriting, and following
- Registration creates an empty default profile automatically
- Login button in header is replaced by user's profile avatar when authenticated
- Anonymous users can browse all content and view all public profiles

**Profile Pages**:
- All user profiles are fully public (viewable by anyone including anonymous users)
- Profile displays: profile picture, user name, list of user's published flyers
- Owner can tap flyers in their own profile to navigate to edit screen
- Profile editing allows changing: profile picture and name
- No bio, location, or detailed information fields

### Flyer Lifecycle Management
**Creation**:
- Access via "Flyern" button in header (authentication required)
- Must provide: 1-5 images, title/caption, two free-text info fields, category tags, address, publication/expiration dates
- Address is sent to backend and converted to geocoordinates (app never handles geocoding)

**Editing**:
- Full editing allowed at any time, even after expiration
- Can edit: images, text, tags, dates, location
- Access edit from profile page flyer list

**Expiration & Reactivation**:
- Expired flyers are automatically deactivated
- To extend/republish: user must manually edit dates and reactivate
- No automatic republishing or date extension

**Deletion**:
- Hard delete only - permanently removes flyer from system
- No soft delete, archiving, or recovery

### Favorites & Following
**Access Pattern**:
- No dedicated list views or pages
- Accessed exclusively through home screen filter buttons
- "Favorites" filter: shows only flyers the user has favorited
- "Following" filter: shows only flyers from creators the user follows
- Both require authentication to use

### Geocoding & Location
**Backend Responsibility**:
- All address-to-geocoordinate conversion happens in backend
- App only works with geocoordinates provided by backend
- No in-app geolocation or geocoding libraries needed
- Distance calculations use device location + flyer geocoordinates

## Success Indicator

The home screen successfully delivers value when:

1. **Discovery Efficiency**: Users can quickly find relevant local offerings through filtering and scrolling without frustration
2. **Content Clarity**: Each flyer card provides sufficient information for users to determine relevance without needing to open every detail
3. **Engagement Conversion**: Anonymous users recognize value and are motivated to create accounts to access personalization features
4. **Creator Visibility**: Business users posting flyers receive meaningful exposure to their target local audience
5. **Performance**: Feed loads quickly and scrolling remains smooth even with image-heavy content

**Measurable Outcomes**:
- Time to find relevant content < 2 minutes for typical use case
- Anonymous-to-authenticated conversion rate indicates perceived value
- Repeat usage patterns demonstrate ongoing relevance
- Flyer engagement rates (taps, favorites) validate content quality

## UI Layout Understanding

The home screen follows a standard mobile app structure with distinct functional zones:

**Layout Structure** (top to bottom):

1. **System Status Bar** (device OS managed)
   - Time, date, battery, network indicators
   - Not controlled by app but part of screen real estate

2. **App Header** (fixed, ~80px)
   - Left: App logo/branding "pokitflyer"
   - Center: Search icon button
   - Center-Right: "Flyern" button/icon (create flyer - requires authentication)
   - Right: Login button (switches to profile avatar icon when authenticated)
   - Tapping profile avatar navigates to user's own profile page
   - Background: White/light with subtle border

3. **Filter Bar - Category Tags** (fixed, ~50px)
   - Horizontal scrollable row of tag chips
   - Chips: "Events", "Nightlife", "Service", etc.
   - Visual state: Selected tags show checkmark and different styling
   - Background: White/light

4. **Filter Bar - Relationship** (fixed, ~50px)
   - Horizontal scrollable row of filter options
   - Options: "Near Me", "❤️ Favorites", "Following"
   - "Near Me" is primary/default option
   - Background: White/light

5. **Flyer Feed** (scrollable, remaining viewport)
   - Vertical list of flyer cards
   - Each card: ~400-600px height depending on content
   - Cards have consistent structure:
     - **Card Header**: Creator avatar + name, follow button
     - **Image Area**: Full-width image carousel with dot indicators, overlaid with favorite/share/location icons
     - **Location Line**: Pin icon + address, distance aligned right
     - **Title/Headline**: Bold, prominent text
     - **Description**: Body text, expandable if truncated
     - **Additional Info**: Secondary information fields
     - **Date Range**: Validity period with calendar icon
   - Card spacing: ~16px margin between cards
   - Card styling: White background, subtle shadow/border

**Visual Hierarchy**:
- Header fixed at top (always visible)
- Filters fixed below header (always accessible)
- Feed content scrolls beneath filters
- Cards use whitespace and borders to create clear separation

**Responsive Behavior**:
- Horizontal scrolling for filter chips when they exceed screen width
- Vertical infinite scroll for feed with pull-to-refresh gesture
- Image carousel swipes horizontally within cards

**Interaction Zones**:
- Fixed header and filters remain accessible while scrolling
- Only explicit buttons/links are tappable (card background is non-interactive)
- Clear visual affordances for interactive elements

An HTML visualization showing the layout structure is available in `home-screen-layout.html`.
