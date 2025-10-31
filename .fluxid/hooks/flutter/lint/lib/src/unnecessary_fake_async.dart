import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'timing_utils.dart';

/// Rule 3: Ban fakeAsync in Non-Service Tests
///
/// Business logic tests should not use fakeAsync
/// WHY: Business logic should mock timer services, keeps tests simple
class UnnecessaryFakeAsync extends DartLintRule {
  const UnnecessaryFakeAsync() : super(code: _code);

  static const _code = LintCode(
    name: 'unnecessary_fake_async',
    problemMessage: 'Mock timer services instead of using fakeAsync in business logic tests',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only check test files
    if (!isTestFile(resolver)) return;

    // Check if this test file imports timing services
    if (testsFileWithTimingOperations(resolver)) return; // Skip if testing timing services

    // Look for fakeAsync usage
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name == 'fakeAsync') {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
