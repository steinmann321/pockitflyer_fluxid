import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'timing_utils.dart';

/// New Rule: hardcoded_timing_duration
///
/// Bans literal Duration in timing operations (Timer/Future.delayed/Stream.periodic).
/// Enforce using TimingConfig-provided durations.
class HardcodedTimingDuration extends DartLintRule {
  const HardcodedTimingDuration() : super(code: _code);

  static const _code = LintCode(
    name: 'hardcoded_timing_duration',
    problemMessage: 'Use TimingConfig duration instead of a hardcoded Duration in timing operations',
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
      // Detect Timer(...) constructor with hardcoded Duration as first argument
      final type = node.staticType?.getDisplayString(withNullability: false) ?? '';
      if (type.startsWith('Timer')) {
        if (_firstArgIsLiteralDuration(node.argumentList)) {
          reporter.reportErrorForNode(code, node);
        }
      }
    });

    context.registry.addMethodInvocation((node) {
      final name = node.methodName.name;
      final target = node.realTarget?.toString() ?? node.target?.toString() ?? '';

      // Future.delayed(Duration(...))
      if (name == 'delayed' && target.contains('Future')) {
        if (_firstArgIsLiteralDuration(node.argumentList)) {
          reporter.reportErrorForNode(code, node);
        }
      }

      // Stream.periodic(Duration(...))
      if (name == 'periodic' && target.contains('Stream')) {
        if (_firstArgIsLiteralDuration(node.argumentList)) {
          reporter.reportErrorForNode(code, node);
        }
      }
    });
  }

  bool _firstArgIsLiteralDuration(ArgumentList args) {
    if (args.arguments.isEmpty) return false;
    final first = args.arguments.first;
    // Match instance creation of Duration(...)
    if (first is InstanceCreationExpression) {
      final type = first.staticType?.getDisplayString(withNullability: false) ?? '';
      if (type.contains('Duration')) return true;
    }
    // Fallback: string pattern match for Duration(...)
    final text = first.toString();
    return text.contains('Duration(');
  }
}

