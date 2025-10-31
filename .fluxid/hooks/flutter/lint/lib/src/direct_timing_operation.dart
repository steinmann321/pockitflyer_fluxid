import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'timing_utils.dart';

/// Rule 1: Ban Direct Time-Based Operations in Business Logic
///
/// Detects Timer, Timer.periodic, Future.delayed, Stream.periodic in non-service production code
/// WHY: Makes tests complex, hard to mock, violates single responsibility, poor coverage
class DirectTimingOperation extends DartLintRule {
  const DirectTimingOperation() : super(code: _code);

  static const _code = LintCode(
    name: 'direct_timing_operation',
    problemMessage: 'Encapsulate timing operations in service classes, not business logic.\n\n'
        'WHY: Direct timing operations cause:\n'
        '  - Hard to test (need to wait for real delays)\n'
        '  - Difficult to mock in tests\n'
        '  - Violates single responsibility principle\n'
        '  - Poor test coverage\n'
        '  - Flaky tests\n\n'
        'CORRECT ALTERNATIVE:\n'
        '  // Create a service class:\n'
        '  class DebounceService {\n'
        '    Timer? _timer;\n'
        '    void call(VoidCallback cb) {\n'
        '      _timer?.cancel();\n'
        '      _timer = Timer(duration, cb);\n'
        '    }\n'
        '  }\n\n'
        '  // Use in business logic:\n'
        '  final _debouncer = DebounceService();\n'
        '  _debouncer.call(() => performAction());\n\n'
        'PATTERN REFERENCES:\n'
        '  - .fluxid/patterns/flutter/service_with_timing.dart\n'
        '  - .fluxid/patterns/flutter/widget_consuming_service.dart',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only check lib/ files (production code)
    if (!isLibFile(resolver)) return;

    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType?.getDisplayString(withNullability: false);
      if (type == null) return;

      // Check for Timer creation
      if (type.startsWith('Timer')) {
        if (!isTimingService(resolver, node)) {
          reporter.reportErrorForNode(code, node);
        }
      }
    });

    context.registry.addMethodInvocation((node) {
      // Check for Timer.periodic, Future.delayed, Stream.periodic
      if (isTimingOperation(node)) {
        if (!isTimingService(resolver, node)) {
          reporter.reportErrorForNode(code, node);
        }
      }
    });
  }
}
