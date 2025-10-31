import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Timing-related keywords for service detection
const _serviceKeywords = [
  'service',
  'timer',
  'timing',
  'scheduler',
  'schedule',
  'debounce',
  'throttle',
  'delay',
  'async',
  'periodic',
  'interval',
  'future',
  'stream',
];

/// Timing operation patterns
const _timingOperations = [
  'Timer',
  'Timer.periodic',
  'Future.delayed',
  'Stream.periodic',
];

/// Third-party timing packages
const _thirdPartyTimingPackages = [
  'package:rxdart',
  'package:async',
  'package:quiver',
];

/// Third-party timing methods from rxdart
const _rxdartTimingMethods = ['debounceTime', 'throttleTime', 'interval', 'timer'];

/// Third-party timing methods from async
const _asyncTimingMethods = ['RestartableTimer', 'CancelableOperation'];

/// Third-party timing methods from quiver
const _quiverTimingMethods = ['Metronome', 'Clock'];

/// Checks if a file is identified as a timing service based on:
/// 1. Class name or file name contains timing keywords (case-insensitive)
/// 2. File contains timing-allowed comments
/// 3. Class has @TimingAllowed annotation
bool isTimingService(CustomLintResolver resolver, AstNode node) {
  final filePath = resolver.source.fullName.toLowerCase();

  // Check file path/name for timing keywords
  if (_serviceKeywords.any((keyword) => filePath.contains(keyword))) {
    return true;
  }

  // Check for timing-allowed comments in file
  final fileContent = resolver.source.contents.data;
  if (fileContent.contains('// timing-allowed') ||
      fileContent.contains('// lint:allow-timing')) {
    return true;
  }

  // Check for @TimingAllowed annotation on containing class
  final classDeclaration = node.thisOrAncestorOfType<ClassDeclaration>();
  if (classDeclaration != null) {
    // Check class name
    final className = classDeclaration.name.lexeme.toLowerCase();
    if (_serviceKeywords.any((keyword) => className.contains(keyword))) {
      return true;
    }

    // Check for @TimingAllowed annotation
    for (final metadata in classDeclaration.metadata) {
      final name = metadata.name.name;
      if (name == 'TimingAllowed') {
        return true;
      }
    }
  }

  return false;
}

/// Checks if a file is in the lib/ directory (production code)
bool isLibFile(CustomLintResolver resolver) {
  final filePath = resolver.source.fullName;
  return filePath.contains('/lib/') && !filePath.contains('/test/');
}

/// Checks if a file is in the test/ directory
bool isTestFile(CustomLintResolver resolver) {
  final filePath = resolver.source.fullName;
  return filePath.contains('/test/') ||
         filePath.contains('/integration_test/') ||
         filePath.contains('_test.dart');
}

/// Checks if a method invocation is a timing operation
bool isTimingOperation(MethodInvocation node) {
  final methodName = node.methodName.name;

  // Check for Timer.periodic
  if (methodName == 'periodic') {
    final target = node.realTarget?.toString() ?? node.target?.toString() ?? '';
    if (target.contains('Timer')) {
      return true;
    }
  }

  // Check for Future.delayed
  if (methodName == 'delayed') {
    final target = node.realTarget?.toString() ?? node.target?.toString() ?? '';
    if (target.contains('Future')) {
      return true;
    }
  }

  // Check for Stream.periodic
  if (methodName == 'periodic') {
    final target = node.realTarget?.toString() ?? node.target?.toString() ?? '';
    if (target.contains('Stream')) {
      return true;
    }
  }

  // Fallback: check full invocation string
  final invocationStr = node.toString();
  return _timingOperations.any((op) => invocationStr.startsWith(op));
}

/// Checks if a node is inside a fakeAsync callback
bool isInsideFakeAsync(AstNode node) {
  AstNode? current = node.parent;
  while (current != null) {
    if (current is MethodInvocation && current.methodName.name == 'fakeAsync') {
      return true;
    }
    current = current.parent;
  }
  return false;
}

/// Checks if a timing operation is mocked (inside when/verify or target contains "mock")
bool isTimingMocked(MethodInvocation node) {
  final invocationStr = node.toString().toLowerCase();

  // Check if target contains "mock"
  if (invocationStr.contains('mock')) {
    return true;
  }

  // Check if inside when() or verify()
  AstNode? current = node.parent;
  while (current != null) {
    if (current is MethodInvocation) {
      final name = current.methodName.name;
      if (name == 'when' || name == 'verify') {
        return true;
      }
    }
    current = current.parent;
  }

  return false;
}

/// Checks if file imports any third-party timing packages
bool hasThirdPartyTimingImports(CustomLintResolver resolver) {
  // Access the source unit directly - this is synchronous
  final source = resolver.source;
  final contents = source.contents.data;

  // Simple string-based check for imports
  return _thirdPartyTimingPackages.any((pkg) =>
    contents.contains("import '$pkg") || contents.contains('import "$pkg')
  );
}

/// Checks if a method invocation is a third-party timing operation
bool isThirdPartyTimingOperation(MethodInvocation node) {
  final methodName = node.methodName.name;
  return _rxdartTimingMethods.contains(methodName) ||
         _asyncTimingMethods.contains(methodName) ||
         _quiverTimingMethods.contains(methodName);
}

/// Checks if the file being tested imports files with timing operations
bool testsFileWithTimingOperations(CustomLintResolver resolver) {
  // Access the source contents directly
  final source = resolver.source;
  final contents = source.contents.data.toLowerCase();

  // Simple heuristic: check if any imports contain timing-related keywords
  return _serviceKeywords.any((keyword) => contents.contains(keyword));
}

/// Checks if a Completer is used with Timer in the same scope
bool hasCompleterTimerPattern(VariableDeclaration completerNode) {
  final method = completerNode.thisOrAncestorOfType<MethodDeclaration>();
  if (method == null) return false;

  // Scan up to 50 nodes in the method body for Timer + completer reference
  bool foundTimer = false;
  bool foundCompleterInCallback = false;
  final completerName = completerNode.name.lexeme;

  method.visitChildren(_CompleterTimerVisitor(
    completerName: completerName,
    onTimerFound: () => foundTimer = true,
    onCompleterInCallbackFound: () => foundCompleterInCallback = true,
  ));

  return foundTimer && foundCompleterInCallback;
}

class _CompleterTimerVisitor extends RecursiveAstVisitor<void> {
  final String completerName;
  final void Function() onTimerFound;
  final void Function() onCompleterInCallbackFound;

  int nodeCount = 0;
  static const maxNodes = 50;

  _CompleterTimerVisitor({
    required this.completerName,
    required this.onTimerFound,
    required this.onCompleterInCallbackFound,
  });

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (nodeCount++ > maxNodes) return;

    final invocationStr = node.toString();
    if (invocationStr.startsWith('Timer')) {
      onTimerFound();
    }

    super.visitMethodInvocation(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (nodeCount > maxNodes) return;

    if (node.name == completerName) {
      final parent = node.parent;
      if (parent is FunctionExpression ||
          (parent?.parent is FunctionExpression)) {
        onCompleterInCallbackFound();
      }
    }

    super.visitSimpleIdentifier(node);
  }
}
