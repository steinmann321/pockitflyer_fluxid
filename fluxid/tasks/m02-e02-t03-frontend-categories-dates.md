---
id: m02-e02-t03
title: Frontend Category Selector and Date Pickers
epic: m02-e02
milestone: m02
status: pending
---

# Task: Frontend Category Selector and Date Pickers

## Context
Part of Flyer Creation & Publishing (m02-e02) in Milestone m02 (Authenticated User Experience).

Implements category multi-select and date pickers for publication and expiration dates in the flyer creation form. Categories (Events, Nightlife, Service) allow users to tag flyers for better discoverability. Date pickers enable scheduling (publish in future) and automatic expiration management.

## Implementation Guide for LLM Agent

### Objective
Create category multi-select widget and publication/expiration date pickers with validation, integrated into the flyer creation form.

### Steps

1. Define category data model
   ```dart
   // Category enum or class
   enum FlyerCategory {
     events,
     nightlife,
     service
   }

   // Helper methods
   extension FlyerCategoryExtension on FlyerCategory {
     String get displayName {
       switch (this) {
         case FlyerCategory.events: return 'Events';
         case FlyerCategory.nightlife: return 'Nightlife';
         case FlyerCategory.service: return 'Service';
       }
     }
   }
   ```

2. Create category selector widget
   ```dart
   // CategorySelector widget structure
   Widget CategorySelector:
     Input:
       - Set<FlyerCategory> selectedCategories
       - Function onCategoriesChanged(Set<FlyerCategory>)
       - bool required (default: false)

     Display:
       - Section label: "Categories"
       - Chip-based UI (FilterChip or ChoiceChip)
       - Each category as a chip:
         * Label: category display name
         * Selected state: filled/highlighted
         * Unselected state: outlined
       - Multi-select: tap to toggle on/off
       - Show all 3 categories (Events, Nightlife, Service)
       - Optional: validation error message if required and none selected
   ```

3. Implement category selection logic
   ```dart
   onCategoryToggled(FlyerCategory category):
     - If category in selectedCategories:
       * Remove from set
     - Else:
       * Add to set
     - Call onCategoriesChanged callback
     - Update UI (chip selected state)
   ```

4. Create date picker widgets
   ```dart
   // DatePickerField widget structure
   Widget DatePickerField:
     Input:
       - String label
       - DateTime? selectedDate
       - Function onDateSelected(DateTime)
       - DateTime? minDate (optional)
       - DateTime? maxDate (optional)
       - bool required

     Display:
       - Label (e.g., "Publication Date")
       - Display field showing selected date or "Select date"
       - Calendar icon button
       - Tap anywhere to open date picker
       - Show validation error if required and null
   ```

5. Implement publication date picker
   - Field label: "Publication Date"
   - Default: current date/time
   - Min date: current date (can't publish in the past)
   - Max date: none (can schedule far future)
   - Required: yes
   - On selection: update form state
   - Format display: "MMM dd, yyyy" (e.g., "Jan 15, 2025")

6. Implement expiration date picker
   - Field label: "Expiration Date"
   - Default: null (optional field)
   - Min date: publication date (can't expire before publish)
   - Max date: none
   - Required: no (optional expiration)
   - On selection: update form state
   - Format display: "MMM dd, yyyy" or "No expiration"
   - Dynamic min date: update when publication date changes

7. Add date validation logic
   ```dart
   validateDates(DateTime? publicationDate, DateTime? expirationDate):
     - Publication date required
     - Publication date cannot be in the past (allow today)
     - If expiration date set:
       * Must be after publication date
       * Must be in the future
     - Return validation errors or null
   ```

8. Integrate components into flyer creation form
   - Add to form provider state:
     * `Set<FlyerCategory> selectedCategories`
     * `DateTime? publicationDate` (default: now)
     * `DateTime? expirationDate`
     * `String? categoriesError`
     * `String? datesError`
   - Place category selector after address field
   - Place publication date picker after category selector
   - Place expiration date picker after publication date
   - Update form validation to include category and date validation

9. Implement form-level validation
   ```dart
   validateFlyerForm():
     - All existing validations (title, address, images from t01/t02)
     - Categories: at least 1 selected (or make optional based on requirements)
     - Publication date: required, not in past
     - Expiration date: if set, must be after publication date
     - Return comprehensive validation state
   ```

10. Create widget tests
    - Test: Category selector displays all 3 categories
    - Test: Tapping category toggles selection
    - Test: Multiple categories can be selected
    - Test: All categories can be unselected
    - Test: Publication date picker shows current date by default
    - Test: Publication date picker rejects past dates
    - Test: Expiration date picker allows null (optional)
    - Test: Expiration date min updates when publication date changes
    - Test: Date validation rejects expiration before publication
    - Test: Error messages display for invalid dates

11. Create integration tests
    - Test: Select multiple categories, verify form state
    - Test: Change publication date, verify expiration min date updates
    - Test: Set expiration before publication, verify validation error
    - Test: Complete form with valid categories and dates, verify form valid
    - Test: Submit form without categories (if required), verify error

### Acceptance Criteria
- [ ] Category selector displays Events, Nightlife, Service [Test: render widget]
- [ ] Users can select multiple categories [Test: tap 2 categories, verify both selected]
- [ ] Users can deselect categories [Test: tap selected category, verify deselected]
- [ ] Selected categories are visually distinct [Test: verify chip styling]
- [ ] Publication date picker defaults to current date [Test: open form, verify default]
- [ ] Publication date picker rejects past dates [Test: attempt to select yesterday]
- [ ] Expiration date picker is optional [Test: submit form without expiration]
- [ ] Expiration date min is publication date [Test: set pub date, open exp picker, verify min]
- [ ] Expiration date picker rejects dates before publication [Test: select earlier date, verify error]
- [ ] Changing publication date updates expiration min [Test: change pub date, verify exp min changes]
- [ ] Form validation includes category and date checks [Test: submit invalid, verify errors]
- [ ] Error messages display for validation failures [Test: trigger errors, verify messages]
- [ ] Widget tests pass with ≥90% coverage
- [ ] Integration tests pass for category and date flows

### Files to Create/Modify
- `pockitflyer_app/lib/models/flyer_category.dart` - NEW: category enum/model
- `pockitflyer_app/lib/widgets/category_selector.dart` - NEW: category multi-select widget
- `pockitflyer_app/lib/widgets/date_picker_field.dart` - NEW: date picker field widget
- `pockitflyer_app/lib/widgets/flyer_creation_form.dart` - MODIFY: integrate category and date widgets
- `pockitflyer_app/lib/providers/flyer_creation_provider.dart` - MODIFY: add category and date state
- `pockitflyer_app/test/widgets/category_selector_test.dart` - NEW: widget tests
- `pockitflyer_app/test/widgets/date_picker_field_test.dart` - NEW: widget tests
- `pockitflyer_app/test/integration/flyer_form_validation_test.dart` - NEW: integration tests

### Testing Requirements
**Note**: E2E testing (without mocks) is handled in the dedicated E2E validation epic. Use unit/component/integration tests here.

- **Unit tests**:
  - Date validation logic (past dates, expiration before publication)
  - Category model/enum helpers

- **Widget tests**:
  - CategorySelector: rendering, selection, multi-select, deselection
  - DatePickerField: rendering, date display, picker opening, min/max enforcement
  - Error message display

- **Integration tests**:
  - Category selection affects form state
  - Date selection affects form validation
  - Publication date change updates expiration date min
  - Complete form validation with all fields
  - Form submission with valid categories and dates

### Definition of Done
- [ ] Code written and passes all tests
- [ ] Code follows Flutter and project conventions
- [ ] No console errors or warnings
- [ ] Category selector is intuitive and easy to use
- [ ] Date pickers prevent invalid date ranges
- [ ] Changes committed with `m02-e02-t03` reference
- [ ] Ready for integration with t04 (backend submission)

## Dependencies
- Requires: m02-e02-t01 (flyer creation form structure)
- Requires: m02-e02-t02 (image upload for complete form)
- Blocks: m02-e02-t04 (backend needs category and date data)

## Technical Notes

**Category UI Pattern**:
- Use `FilterChip` with `selected` property for toggle behavior
- Wrap in `Wrap` widget for responsive layout
- Color selected chips with primary theme color
- Show checkmark or different icon when selected

**Date Picker Implementation**:
- Use `showDatePicker()` from Flutter material library
- Configure `firstDate`, `lastDate` for validation
- Format dates using `intl` package (DateFormat)
- Store dates as `DateTime` objects, not strings

**Date Picker Configuration**:
```dart
showDatePicker(
  context: context,
  initialDate: publicationDate ?? DateTime.now(),
  firstDate: DateTime.now(), // Can't publish in past
  lastDate: DateTime.now().add(Duration(days: 365 * 2)), // 2 years max
);
```

**Expiration Date Dependency**:
- When publication date changes, recalculate expiration min
- If expiration date is now invalid (before new publication date), clear it or show error
- Update expiration picker's `firstDate` dynamically

**Category Validation**:
- Decide: are categories required or optional?
- Epic suggests categories are part of flyer model, likely required
- If required: validate at least 1 category selected
- If optional: allow empty set

**Date Display Formatting**:
```dart
import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('MMM dd, yyyy').format(date);
}
```

**State Management**:
- Store `Set<FlyerCategory>` for efficient add/remove/contains
- Store `DateTime?` for nullable expiration date
- Update form validation whenever category or date state changes

**UX Guidelines**:
- Category chips should be large enough to tap easily
- Selected state should be obvious (color, icon, border)
- Date fields should look tappable (icon, underline, or button style)
- Validation errors should appear inline below each section
- Date picker should open with one tap (not requiring separate button)

**Accessibility**:
- Category chips should have semantic labels
- Date picker fields should announce selected date
- Validation errors should be announced by screen readers

## References
- FilterChip widget: https://api.flutter.dev/flutter/material/FilterChip-class.html
- showDatePicker: https://api.flutter.dev/flutter/material/showDatePicker.html
- intl package for date formatting: https://pub.dev/packages/intl
- Wrap widget for responsive chip layout: https://api.flutter.dev/flutter/widgets/Wrap-class.html
