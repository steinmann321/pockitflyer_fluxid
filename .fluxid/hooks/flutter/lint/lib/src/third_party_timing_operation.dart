import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'timing_utils.dart';

/// Rule 5: Ban Third-Party Timer Wrappers
///
/// Detect third-party timing utilities in non-service code
/// WHY: Prevents bypassing Rule 1, same issues apply
class ThirdPartyTimingOperation extends DartLintRule {
  const ThirdPartyTimingOperation() : super(code: _code);

  static const _code = LintCode(
    name: 'third_party_timing_operation',
    problemMessage: 'Use timer service abstraction instead of third-party timing utilities',
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

    // Check if file has third-party timing imports
    if (!hasThirdPartyTimingImports(resolver)) return;

    // Check method invocations for third-party timing operations
    context.registry.addMethodInvocation((node) {
      if (!isThirdPartyTimingOperation(node)) return;

      // Exempt if this is a timing service
      if (isTimingService(resolver, node)) return;

      reporter.reportErrorForNode(code, node);
    });
  }
}
