/// PATTERN: Widget with Keys - Making Widgets Testable
///
/// WHY THIS IS IMPORTANT:
/// Keys are the foundation of reliable widget testing. Text-based finders (find.text(),
/// find.widgetWithText()) are fragile - they break when text changes, don't work with
/// internationalization, and fail when text is split across multiple widgets. Keys
/// provide a stable contract between your widgets and tests.
///
/// WHEN TO USE:
/// - Every interactive widget (buttons, text fields, etc.)
/// - Every widget that displays dynamic state
/// - Every widget that needs to be found in tests
/// - Every widget that is part of a list or scrollable view
///
/// RELATED RULES:
/// - Rule: prefer_keys_over_text_finders (custom lint)

import 'package:flutter/material.dart';

// ============================================================================
// BASIC KEY USAGE
// ============================================================================

// ✅ ALWAYS: Add Keys to widgets that will be tested
class MyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const MyButton({
    super.key, // Widget's own key for widget tree identity
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: const Key('my_button'), // ✅ Key for finding in tests
      onPressed: onPressed,
      child: Text(
        label,
        key: const Key('button_label'), // ✅ Key for verifying text widget exists
      ),
    );
  }
}

// ❌ NEVER: Create widgets without keys if they need to be tested
class MyBadButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const MyBadButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // ❌ No key - must use find.widgetWithText() which is fragile
      onPressed: onPressed,
      child: Text(label), // ❌ No key - must use find.text() which breaks with i18n
    );
  }
}

// ============================================================================
// DYNAMIC KEYS FOR LISTS
// ============================================================================

// ✅ ALWAYS: Use ValueKey for list items with unique identifiers
class FlyerCard extends StatelessWidget {
  final String flyerId;
  final String title;
  final String location;

  const FlyerCard({
    super.key,
    required this.flyerId,
    required this.title,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('flyer_card_$flyerId'), // ✅ Unique key per item
      child: Column(
        children: [
          Text(
            title,
            key: Key('flyerTitle_$flyerId'), // ✅ Unique key for title
          ),
          Text(
            location,
            key: Key('flyerLocation_$flyerId'), // ✅ Unique key for location
          ),
          IconButton(
            key: Key('favoriteButton_$flyerId'), // ✅ Unique key for button
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ❌ NEVER: Use the same key for multiple widgets
class BadFlyerCard extends StatelessWidget {
  final String flyerId;
  final String title;

  const BadFlyerCard({
    super.key,
    required this.flyerId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('flyer_card'), // ❌ Same key for all cards - won't work in tests
      child: Text(
        title,
        key: const Key('title'), // ❌ Same key for all titles - ambiguous
      ),
    );
  }
}

// ============================================================================
// KEYS FOR STATE INDICATORS
// ============================================================================

// ✅ ALWAYS: Use Keys for different states of a widget
class LoadingStateWidget extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final String? data;

  const LoadingStateWidget({
    super.key,
    required this.isLoading,
    required this.hasError,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator(
        key: Key('loading_indicator'), // ✅ Key for loading state
      );
    }

    if (hasError) {
      return Column(
        key: const Key('error_state'), // ✅ Key for error state
        children: [
          const Icon(
            Icons.error,
            key: Key('error_icon'), // ✅ Key for error icon
          ),
          ElevatedButton(
            key: const Key('retry_button'), // ✅ Key for retry button
            onPressed: () {},
            child: const Text('Retry'),
          ),
        ],
      );
    }

    return Text(
      data ?? '',
      key: const Key('loaded_data'), // ✅ Key for loaded state
    );
  }
}

// ============================================================================
// KEYS FOR FORMS
// ============================================================================

// ✅ ALWAYS: Use Keys for form fields and validation
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: const Key('login_form'), // ✅ Key for form itself
      child: Column(
        children: [
          TextFormField(
            key: const Key('email_field'), // ✅ Key for email field
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          TextFormField(
            key: const Key('password_field'), // ✅ Key for password field
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          ElevatedButton(
            key: const Key('submit_button'), // ✅ Key for submit button
            onPressed: () {},
            child: const Text('Login'),
          ),
          // ✅ Conditional error message with key
          const Text(
            'Invalid credentials',
            key: Key('login_error'), // ✅ Key for error message
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SEMANTIC LABELS (Alternative to Keys)
// ============================================================================

// ✅ ALTERNATIVE: Use Semantics with labels for accessibility + testing
class AccessibleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AccessibleButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'submit_button', // ✅ Can find with find.bySemanticsLabel()
      child: ElevatedButton(
        onPressed: onPressed,
        child: const Text('Submit'),
      ),
    );
  }
}

// ============================================================================
// KEYS IN COMPLEX WIDGETS
// ============================================================================

// ✅ ALWAYS: Add keys at multiple levels for granular testing
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('feed_screen'), // ✅ Screen-level key
      appBar: AppBar(
        key: const Key('feed_appbar'), // ✅ AppBar key
        title: const Text(
          'Feed',
          key: Key('feed_title'), // ✅ Title key
        ),
      ),
      body: RefreshIndicator(
        key: const Key('feed_refresh_indicator'), // ✅ Refresh key
        onRefresh: () async {},
        child: ListView(
          key: const Key('feed_list'), // ✅ List key
          children: const [
            // Each item would have its own unique key
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_flyer_button'), // ✅ FAB key
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ============================================================================
// KEY PRINCIPLES
// ============================================================================

// 1. WHEN TO USE KEYS:
//    - Interactive widgets (buttons, fields, etc.)
//    - Widgets displaying dynamic state
//    - List items (use unique identifiers)
//    - State indicators (loading, error, success)
//    - Form elements
//
// 2. KEY NAMING CONVENTIONS:
//    - Use descriptive names: 'submit_button' not 'btn1'
//    - For lists: 'itemType_uniqueId' (e.g., 'flyerCard_123')
//    - For states: 'feature_state' (e.g., 'feed_loading', 'feed_error')
//    - Use snake_case for consistency
//
// 3. DYNAMIC KEYS:
//    - Use Key('prefix_$id') for list items
//    - Ensure id is unique and stable
//    - Don't use index as id if list can be reordered
//
// 4. AVOID THESE MISTAKES:
//    - Don't reuse the same key for multiple widgets
//    - Don't use random or changing keys
//    - Don't skip keys thinking "I'll find it by text"
//    - Don't use generic keys like 'button' or 'text'
//
// 5. TESTING WITH KEYS:
//    - find.byKey(const Key('my_widget'))
//    - find.bySemanticsLabel('my_widget')
//    - Keys work with internationalization
//    - Keys are stable across code changes
