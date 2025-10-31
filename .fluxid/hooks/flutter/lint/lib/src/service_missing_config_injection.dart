import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'timing_utils.dart';

/// New Rule: service_missing_config_injection
///
/// Service classes using timing operations must inject a TimingConfig field
/// and accept it in the constructor.
class ServiceMissingConfigInjection extends DartLintRule {
  const ServiceMissingConfigInjection() : super(code: _code);

  static const _code = LintCode(
    name: 'service_missing_config_injection',
    problemMessage: 'Service using timing operations must inject TimingConfig (field + constructor parameter).',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!isLibFile(resolver)) return;

    context.registry.addClassDeclaration((node) {
      // Only consider identifiable timing-related services
      if (!isTimingService(resolver, node)) return;

      // Check if the class contains timing operations
      var hasTimingOps = false;
      node.visitChildren(_TimingOpVisitor(onTimingOpFound: () {
        hasTimingOps = true;
      }));

      if (!hasTimingOps) return;

      final hasTimingField = _hasTimingConfigField(node) || _hasDurationField(node);
      final hasTimingCtorParam =
          _hasTimingConfigCtorParam(node) || _hasDurationCtorParam(node);

      if (!hasTimingField || !hasTimingCtorParam) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }

  bool _hasTimingConfigField(ClassDeclaration node) {
    for (final member in node.members) {
      if (member is FieldDeclaration) {
        for (final variable in member.fields.variables) {
          final type = variable.declaredElement?.type.getDisplayString(withNullability: false) ?? '';
          if (type == 'TimingConfig') {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _hasDurationField(ClassDeclaration node) {
    for (final member in node.members) {
      if (member is FieldDeclaration) {
        for (final variable in member.fields.variables) {
          final type = variable.declaredElement?.type
                  .getDisplayString(withNullability: false) ??
              '';
          if (type == 'Duration') {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _hasTimingConfigCtorParam(ClassDeclaration node) {
    for (final member in node.members) {
      if (member is ConstructorDeclaration) {
        final params = member.parameters?.parameters ?? const [];
        for (final p in params) {
          final type = p.declaredElement?.type
                  .getDisplayString(withNullability: false) ??
              '';
          if (type == 'TimingConfig') {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _hasDurationCtorParam(ClassDeclaration node) {
    for (final member in node.members) {
      if (member is ConstructorDeclaration) {
        final params = member.parameters?.parameters ?? const [];
        for (final p in params) {
          final type = p.declaredElement?.type
                  .getDisplayString(withNullability: false) ??
              '';
          if (type == 'Duration') {
            return true;
          }
        }
      }
    }
    return false;
  }
}

class _TimingOpVisitor extends RecursiveAstVisitor<void> {
  final void Function() onTimingOpFound;
  _TimingOpVisitor({required this.onTimingOpFound});

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (isTimingOperation(node)) onTimingOpFound();
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final type = node.staticType?.getDisplayString(withNullability: false) ?? '';
    if (type.startsWith('Timer')) onTimingOpFound();
    super.visitInstanceCreationExpression(node);
  }
}
