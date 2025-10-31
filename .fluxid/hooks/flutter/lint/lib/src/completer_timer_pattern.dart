import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'timing_utils.dart';

/// Rule 7: Detect Completer with Timer Pattern
///
/// Catch Completer + Timer combination in non-service code
/// WHY: Common pattern bypassing Future.delayed detection
class CompleterTimerPattern extends DartLintRule {
  const CompleterTimerPattern() : super(code: _code);

  static const _code = LintCode(
    name: 'completer_timer_pattern',
    problemMessage: 'Completer with Timer pattern should be abstracted to timer service',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only check lib/ files
    if (!isLibFile(resolver)) return;

    context.registry.addVariableDeclaration((node) {
      // Check if this is a Completer variable
      final type = node.declaredElement?.type.toString() ?? '';
      if (!type.startsWith('Completer')) return;

      // Exempt if in a timing service
      if (isTimingService(resolver, node)) return;

      // Check if Completer is used with Timer pattern
      if (hasCompleterTimerPattern(node)) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
