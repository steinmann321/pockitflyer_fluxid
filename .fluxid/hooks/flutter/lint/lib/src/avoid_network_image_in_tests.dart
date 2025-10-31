import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Rule 8: Ban NetworkImage in Tests
///
/// Detects NetworkImage usage in test files
/// WHY: Makes HTTP requests, fails in test environment (returns 400), causes flaky/hanging tests
class AvoidNetworkImageInTests extends DartLintRule {
  const AvoidNetworkImageInTests() : super(code: _code);

  static const _code = LintCode(
    name: 'network_image_in_tests',
    problemMessage: 'Never use NetworkImage in tests - use Image.memory() or asset images.\n\n'
        'WHY: NetworkImage causes flaky and hanging tests because:\n'
        '  - Flutter test environment returns HTTP 400 for all network requests\n'
        '  - Widgets wait indefinitely for images to load\n'
        '  - pumpAndSettle() times out waiting for image loading to complete\n'
        '  - Tests become unpredictable and fail randomly\n\n'
        'CORRECT ALTERNATIVES:\n'
        '  // Use memory image with empty bytes:\n'
        '  Image.memory(Uint8List(0), key: const Key(\'test_image\'))\n\n'
        '  // Or use asset images:\n'
        '  Image.asset(\'assets/test_image.png\')\n\n'
        '  // Or mock the image provider in tests\n\n'
        'PATTERN REFERENCE: See .fluxid/patterns/flutter/widget_test.dart',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only check test files
    final path = resolver.path;
    if (!path.contains('/test/') &&
        !path.contains('/integration_test/') &&
        !path.contains('/test_driver/')) {
      return;
    }

    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType?.getDisplayString(withNullability: false);
      if (type == null) return;

      // Check for NetworkImage creation
      if (type == 'NetworkImage' || type.startsWith('NetworkImage<')) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
