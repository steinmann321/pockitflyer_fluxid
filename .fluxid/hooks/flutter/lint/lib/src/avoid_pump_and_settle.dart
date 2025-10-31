import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidPumpAndSettle extends DartLintRule {
  const AvoidPumpAndSettle() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_pump_and_settle',
    problemMessage: 'Avoid pumpAndSettle; use pump() with explicit timing instead.\n\n'
        'WHY: pumpAndSettle() causes flaky tests with async operations and NetworkImage.\n'
        'It waits indefinitely for animations/timers to complete, causing timeouts.\n\n'
        'CORRECT ALTERNATIVE:\n'
        '  await tester.pump(); // Trigger initial build\n'
        '  await tester.pump(const Duration(milliseconds: 100)); // Wait for async\n'
        '  await tester.pump(); // Rebuild after completion\n\n'
        'PATTERN REFERENCE: See .fluxid/patterns/flutter/integration_test.dart',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name == 'pumpAndSettle') {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
