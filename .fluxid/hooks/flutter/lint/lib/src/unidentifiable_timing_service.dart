import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'timing_utils.dart';

/// Rule 4: Enforce Timer Service Identification
///
/// Classes with timing operations must be identifiable
/// WHY: Enables other rules, enforces architecture, blocks until fixed
class UnidentifiableTimingService extends DartLintRule {
  const UnidentifiableTimingService() : super(code: _code);

  static const _code = LintCode(
    name: 'unidentifiable_timing_service',
    problemMessage: 'Classes using timing operations must be identifiable. '
        'Use timing-related name, add \'// timing-allowed\' comment, or add @TimingAllowed() annotation',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only check lib/ files
    if (!isLibFile(resolver)) return;

    final Set<int> reportedLines = {};

    context.registry.addMethodInvocation((node) {
      // Check for timing operations
      if (!isTimingOperation(node)) return;

      // Check if this is in an identifiable timing service
      if (isTimingService(resolver, node)) return;

      // Avoid reporting the same line multiple times
      final line = node.offset;
      if (reportedLines.contains(line)) return;
      reportedLines.add(line);

      reporter.reportErrorForNode(code, node);
    });

    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType?.getDisplayString(withNullability: false);
      if (type == null) return;

      // Check for Timer creation
      if (!type.startsWith('Timer')) return;

      // Check if this is in an identifiable timing service
      if (isTimingService(resolver, node)) return;

      // Avoid reporting the same line multiple times
      final line = node.offset;
      if (reportedLines.contains(line)) return;
      reportedLines.add(line);

      reporter.reportErrorForNode(code, node);
    });
  }
}
