import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'timing_utils.dart';

/// Rule 2: Require fakeAsync in Timer Service Tests
///
/// Timer service tests must wrap timing operations in fakeAsync or mock them
/// WHY: Must test actual timing behavior with deterministic control
class MissingFakeAsync extends DartLintRule {
  const MissingFakeAsync() : super(code: _code);

  static const _code = LintCode(
    name: 'missing_fake_async',
    problemMessage: 'Timer service tests must use fakeAsync to control time or mock timing operations',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only check test files
    if (!isTestFile(resolver)) return;

    // Check if this test file imports timing services
    if (!testsFileWithTimingOperations(resolver)) return;

    // Visit test method declarations
    context.registry.addMethodInvocation((node) {
      // Check if this is a test method invocation
      final methodName = node.methodName.name;
      if (!['test', 'testWidgets', 'blocTest'].contains(methodName)) return;

      // Get the callback argument (the test body)
      if (node.argumentList.arguments.isEmpty) return;

      final testBody = node.argumentList.arguments.last;
      if (testBody is! FunctionExpression) return;

      // Check if test body contains timing operations
      bool hasTimingOps = false;
      bool isInFakeAsync = false;
      bool isMocked = false;

      testBody.visitChildren(_TimingOpVisitor(
        onTimingOpFound: () => hasTimingOps = true,
        onFakeAsyncFound: () => isInFakeAsync = true,
        onMockedFound: () => isMocked = true,
      ));

      // Report error if timing ops exist but not in fakeAsync and not mocked
      if (hasTimingOps && !isInFakeAsync && !isMocked) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }
}

class _TimingOpVisitor extends RecursiveAstVisitor<void> {
  final void Function() onTimingOpFound;
  final void Function() onFakeAsyncFound;
  final void Function() onMockedFound;

  _TimingOpVisitor({
    required this.onTimingOpFound,
    required this.onFakeAsyncFound,
    required this.onMockedFound,
  });

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Check for timing operations
    if (isTimingOperation(node)) {
      onTimingOpFound();

      // Check if it's mocked
      if (isTimingMocked(node)) {
        onMockedFound();
      }
    }

    // Check for fakeAsync
    if (node.methodName.name == 'fakeAsync') {
      onFakeAsyncFound();
    }

    super.visitMethodInvocation(node);
  }
}
