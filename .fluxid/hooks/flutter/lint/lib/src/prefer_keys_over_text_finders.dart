import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class PreferKeysOverTextFinders extends DartLintRule {
  const PreferKeysOverTextFinders() : super(code: _code);

  static const _code = LintCode(
    name: 'prefer_keys_over_text_finders',
    problemMessage: 'Use find.byKey() or find.bySemanticsLabel() instead of find.text().\n\n'
        'WHY: Text-based finders are fragile and break with:\n'
        '  - Text content changes\n'
        '  - Internationalization (i18n)\n'
        '  - Text styling/formatting changes\n'
        '  - Text split across multiple widgets\n\n'
        'CORRECT ALTERNATIVES:\n'
        '  // In widget: Text(\'Hello\', key: const Key(\'greeting\'))\n'
        '  // In test: find.byKey(const Key(\'greeting\'))\n\n'
        '  // Or with semantics:\n'
        '  // In widget: Semantics(label: \'greeting\', child: Text(\'Hello\'))\n'
        '  // In test: find.bySemanticsLabel(\'greeting\')\n\n'
        'PATTERN REFERENCE: See .fluxid/patterns/flutter/widget_with_keys.dart',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodInvocation((node) {
      final target = node.realTarget?.toString();
      final methodName = node.methodName.name;

      if (target == 'find' && (methodName == 'text' || methodName == 'widgetWithText')) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}
