---
id: m02-e04-t05
epic: m02-e04
title: E2E Test - Privacy Settings Workflow (No Mocks)
status: pending
priority: high
tdd_phase: red
---

# Task: E2E Test - Privacy Settings Workflow (No Mocks)

## Objective
Validate complete privacy settings workflow end-to-end using real Django backend and real iOS app with no mocks. Tests cover accessing settings, toggling email permissions, persistence across app restarts, and default settings on registration.

## Acceptance Criteria
- [ ] Maestro flow: `m02_e04_privacy_settings_complete.yaml`
- [ ] Test steps:
  1. Start real Django backend
  2. Seed M02 E2E test data (test users with default privacy settings)
  3. Launch iOS app (fresh install)
  4. Login as test_user_001
  5. Navigate to profile screen (tap avatar)
  6. Tap "Settings" button (or gear icon)
  7. Assert privacy settings screen appears
  8. Assert "Email Permission" toggle visible
  9. Assert current state: Email permission ON (default: True)
  10. Toggle email permission OFF
  11. Assert toggle visual state changes
  12. Navigate back to profile screen
  13. Verify backend database: email_permission = False
  14. Navigate back to settings screen
  15. Assert email permission still OFF (persisted)
  16. Toggle email permission ON
  17. Navigate back to profile
  18. Verify backend database: email_permission = True
  19. Force quit app
  20. Relaunch app (should auto-login with persisted token)
  21. Navigate to settings screen
  22. Assert email permission still ON (persisted across app restart)
  23. Cleanup: stop backend
- [ ] Maestro flow: `m02_e04_privacy_settings_default_on_registration.yaml`
- [ ] Default settings on registration test steps:
  1. Start real Django backend
  2. Launch iOS app (fresh install)
  3. Register new user: `newuser_privacy@pockitflyer.test`
  4. Login succeeds (auto-login after registration)
  5. Navigate to profile screen
  6. Navigate to settings screen
  7. Assert email permission ON (default: True)
  8. Verify backend database:
      - Privacy settings record created automatically
      - email_permission = True (default)
      - created_at timestamp matches user creation
  9. Cleanup: delete test user, stop backend
- [ ] Real service validations:
  - Backend privacy settings retrieval API returns current settings
  - Backend privacy settings update API persists changes
  - Privacy settings auto-created on user registration (Django signal)
  - Toggle state changes reflected immediately in UI
  - Toggle changes persisted to backend within 1 second
  - Settings persist across app lifecycle (background/foreground/restart)
- [ ] All Maestro tests tagged with appropriate TDD markers after passing

## Test Coverage Requirements
- Complete vertical slice: iOS privacy settings screen → REST API → Django privacy settings update → SQLite
- Privacy settings retrieval for authenticated user
- Privacy settings update (email permission toggle)
- Auto-creation of privacy settings on user registration (signal validation)
- Default values (email_permission = True)
- Persistence: Settings changes saved to backend immediately
- Persistence: Settings persist across app restart
- UI state synchronization with backend state
- Navigation: Profile → Settings → Profile

## Files to Modify/Create
- `maestro/flows/m02-e04/privacy_settings_complete_workflow.yaml`
- `maestro/flows/m02-e04/privacy_settings_default_on_registration.yaml`
- `maestro/flows/m02-e04/privacy_settings_persistence_across_restart.yaml`
- `pockitflyer_backend/scripts/verify_privacy_settings.py` (helper script for database verification)

## Dependencies
- m02-e04-t01 (M02 E2E test data infrastructure with privacy settings)
- m02-e04-t03 (Login workflow for authentication)
- m02-e03-t01 (Privacy settings model and auto-creation)
- m02-e03-t02 (Backend privacy settings retrieval API)
- m02-e03-t03 (Backend privacy settings update API)
- m02-e03-t04 (Frontend privacy settings state management)
- m02-e03-t05 (Frontend privacy settings screen)

## Notes
**Critical: NO MOCKS**
- Real Django server running on localhost
- Real SQLite database with test data
- Real iOS app making actual HTTP requests
- Real authentication required to access settings

**Helper Scripts** (see CONTRIBUTORS.md):
- `./scripts/start_backend_e2e.sh` - Starts backend in detached mode
- `./scripts/start_app_e2e.sh` - Builds and launches iOS app
- `./scripts/stop_all_e2e.sh` - Clean shutdown of all services

**Privacy Settings Model Structure**:
```python
class PrivacySettings(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='privacy_settings')
    email_permission = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

**Default Privacy Settings**:
- Email permission: `True` (user opts in to email notifications by default)
- Profile visibility: Public (all profiles visible, no private option in M02)
- Auto-created on user registration via Django `post_save` signal

**Privacy Settings Auto-Creation Flow**:
1. User registers (new User created)
2. Django `post_save` signal triggers
3. Profile created (auto-creation from User signal)
4. Django `post_save` signal on Profile triggers
5. Privacy settings created with defaults (email_permission=True)

**Email Permission Toggle Behavior**:
- ON (True): User consents to receive email notifications (future feature)
- OFF (False): User opts out of email notifications
- Toggle change triggers immediate API call to backend
- Backend updates database immediately
- No confirmation dialog needed (simple toggle)

**Navigation Flow**:
1. User taps profile avatar in header
2. Profile screen appears
3. User taps "Settings" button (top right)
4. Privacy settings screen appears
5. User toggles email permission
6. User navigates back (back button or swipe)
7. Profile screen appears (settings saved automatically)

**Backend Database Verification** (after toggle):
```python
# pockitflyer_backend/scripts/verify_privacy_settings.py
settings = PrivacySettings.objects.get(user__email='test_user_001@pockitflyer.test')
assert settings.email_permission == False  # After toggling OFF
assert settings.updated_at > settings.created_at  # Timestamp updated
```

**Persistence Validation Strategy**:
1. **Immediate persistence**: Toggle OFF → API call → database updated
2. **Navigation persistence**: Toggle OFF → navigate away → navigate back → still OFF
3. **App lifecycle persistence**: Toggle OFF → background app → foreground → still OFF
4. **App restart persistence**: Toggle OFF → force quit → relaunch → still OFF (covered in t06)

**UI State Synchronization**:
- Toggle state always synced with backend state
- On screen load: Fetch current state from backend
- On toggle: Update local state immediately (optimistic UI), then call API
- If API fails: Revert local state, show error message

**Performance Expectations**:
- Settings screen load: <2 seconds
- Toggle API call: <1 second
- UI toggle response: Immediate (no lag)
- Settings persistence: Immediate (no delay)

**Error Handling Tests** (separate Maestro flows):
1. Network failure during toggle update → revert toggle state, show error message
2. Unauthorized access (no auth token) → redirect to login screen
3. Invalid user (token valid but user deleted) → logout, redirect to login

**Edge Cases to Test** (separate Maestro flows):
1. Toggle ON → OFF → ON rapidly (multiple toggles quickly)
2. Toggle during network outage → error message, state reverted
3. Navigate away from settings during API call → API completes in background
4. Settings screen while user logged in on another device → state synced correctly

**Success Indicators**:
- Privacy settings screen accessible from profile ✅
- Email permission toggle visible and functional ✅
- Toggle state changes reflected immediately in UI ✅
- Toggle changes persisted to backend within 1 second ✅
- Settings persist across navigation ✅
- Settings persist across app restart ✅
- Default settings created on registration ✅
- All error cases handled gracefully ✅
