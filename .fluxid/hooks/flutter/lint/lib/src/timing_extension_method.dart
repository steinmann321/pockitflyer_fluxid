import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'timing_utils.dart';

/// Rule 6: Ban Duration Extension Methods with Callbacks
///
/// Duration extensions cannot execute callbacks with timers
/// WHY: Extension methods hide Timer usage and bypass detection
class TimingExtensionMethod extends DartLintRule {
  const TimingExtensionMethod() : super(code: _code);

  static const _code = LintCode(
    name: 'timing_extension_method',
    problemMessage: 'Timing extensions must delegate to timer services, not implement timing directly',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Check all lib/ files
    if (!isLibFile(resolver)) return;

    context.registry.addExtensionDeclaration((node) {
      // Check if it's an extension on Duration
      final extendedType = node.extendedType.toString();
      if (!extendedType.contains('Duration')) return;

      // Check each method in the extension
      for (final member in node.members) {
        if (member is! MethodDeclaration) continue;

        // Check if method has a Function/callback parameter
        bool hasCallbackParam = false;
        final params = member.parameters;
        if (params != null) {
          for (final param in params.parameters) {
            final type = param.declaredElement?.type.toString() ?? '';
            if (type.contains('Function') || type.contains('VoidCallback')) {
              hasCallbackParam = true;
              break;
            }
          }
        }

        if (!hasCallbackParam) continue;

        // Check if method body contains timing operations
        bool hasTimingOp = false;
        member.visitChildren(_TimingOpVisitor(
          onTimingOpFound: () => hasTimingOp = true,
        ));

        if (hasTimingOp) {
          reporter.reportErrorForNode(code, member);
        }
      }
    });
  }
}

class _TimingOpVisitor extends RecursiveAstVisitor<void> {
  final void Function() onTimingOpFound;

  _TimingOpVisitor({required this.onTimingOpFound});

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (isTimingOperation(node)) {
      onTimingOpFound();
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final type = node.staticType?.getDisplayString(withNullability: false);
    if (type != null && type.startsWith('Timer')) {
      onTimingOpFound();
    }
    super.visitInstanceCreationExpression(node);
  }
}
