import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidAwaitFutureConstructor extends DartLintRule {
  const AvoidAwaitFutureConstructor() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_await_future_constructor',
    problemMessage: 'Use pump() to advance time, not real async waits.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addAwaitExpression((node) {
      final expression = node.expression;
      if (expression is InstanceCreationExpression) {
        final type = expression.staticType;
        if (type != null && type.getDisplayString(withNullability: false) == 'Future') {
          reporter.reportErrorForNode(code, node);
        }
      }
    });
  }
}
