// Global test configuration for flutter_test.
// Runs before any tests. Useful for overriding debug prints, binding setup, etc.
import 'dart:async';

import 'package:golden_toolkit/golden_toolkit.dart';

import 'helpers/mocks.dart';
import 'helpers/mocktail_helpers.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Load Material fonts for stable golden tests
  await loadAppFonts();

  // Initialize mocktail fallbacks/utilities if any are registered
  registerCommonFallbacks();
  initMocktail();

  // Example: suppress noisy debug prints in tests
  // debugPrint = (String? message, {int? wrapWidth}) {};

  await testMain();
}
