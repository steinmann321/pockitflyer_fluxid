import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidAnimationRepeat extends DartLintRule {
  const AvoidAnimationRepeat() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_animation_repeat',
    problemMessage: 'Avoid AnimationController.repeat in tests; disable in test mode.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name == 'repeat' && _isAnimationControllerTarget(node)) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }

  bool _isAnimationControllerTarget(MethodInvocation node) {
    final target = node.realTarget;
    if (target == null) return false;

    final type = target.staticType;
    if (type == null) return false;

    return type.getDisplayString(withNullability: false).contains('AnimationController');
  }
}
