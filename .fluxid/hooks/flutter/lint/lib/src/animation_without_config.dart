import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'timing_utils.dart';

/// New Rule: animation_without_config
///
/// Bans literal Duration in Animated* widget constructors.
/// Enforce using TimingConfig.animationDuration.
class AnimationWithoutConfig extends DartLintRule {
  const AnimationWithoutConfig() : super(code: _code);

  static const _code = LintCode(
    name: 'animation_without_config',
    problemMessage: 'Animated widgets must use TimingConfig.animationDuration, not a hardcoded Duration',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!isLibFile(resolver)) return;

    context.registry.addInstanceCreationExpression((node) {
      final type = node.staticType?.getDisplayString(withNullability: false) ?? '';
      if (!type.startsWith('Animated')) return;

      // Find a named argument "duration:" that is a literal Duration
      for (final arg in node.argumentList.arguments) {
        if (arg is NamedExpression && arg.name.label.name == 'duration') {
          final value = arg.expression;
          if (_isLiteralDuration(value)) {
            reporter.reportErrorForNode(code, arg);
          }
        }
      }
    });
  }

  bool _isLiteralDuration(Expression expr) {
    if (expr is InstanceCreationExpression) {
      final type = expr.staticType?.getDisplayString(withNullability: false) ?? '';
      if (type.contains('Duration')) return true;
    }
    final text = expr.toString();
    return text.contains('Duration(');
  }
}

