import 'bot_data.dart';
import 'condition.dart';
import 'comparer.dart';

/// Result of executing a statement node
class ExecutionResult {
  final bool shouldContinue;
  final int? jumpToIndex;
  final String? jumpToLabel;
  final bool breakLoop;
  final bool shouldReturn;

  const ExecutionResult({
    this.shouldContinue = true,
    this.jumpToIndex,
    this.jumpToLabel,
    this.breakLoop = false,
    this.shouldReturn = false,
  });

  static const ExecutionResult continueExecution = ExecutionResult();
  static const ExecutionResult loopBreak = ExecutionResult(breakLoop: true);
  static const ExecutionResult returnFromScript =
      ExecutionResult(shouldReturn: true);

  static ExecutionResult jumpTo(int index) =>
      ExecutionResult(jumpToIndex: index);
  static ExecutionResult jumpToLabelNamed(String label) =>
      ExecutionResult(jumpToLabel: label);
}

/// Base class for all statement nodes in the control flow system
abstract class StatementNode {
  final String originalStatement;
  final int lineNumber;
  final String? label;

  StatementNode({
    required this.originalStatement,
    required this.lineNumber,
    this.label,
  });

  Future<ExecutionResult> execute(BotData data);
}

/// Represents a simple LoliCode statement (SET, LOG, FUNCTION, etc.)
class SimpleStatementNode extends StatementNode {
  final String statement;

  SimpleStatementNode({
    required String originalStatement,
    required int lineNumber,
    String? label,
    required this.statement,
  }) : super(
          originalStatement: originalStatement,
          lineNumber: lineNumber,
          label: label,
        );

  @override
  Future<ExecutionResult> execute(BotData data) async {
    return ExecutionResult.continueExecution;
  }
}

/// Represents a condition for IF/WHILE statements
class ConditionNode {
  final String leftOperand;
  final Comparer comparer;
  final String rightOperand;

  ConditionNode({
    required this.leftOperand,
    required this.comparer,
    required this.rightOperand,
  });

  bool evaluate(BotData data) {
    return Condition.evaluateWithData(
        leftOperand, comparer, rightOperand, data);
  }

  @override
  String toString() {
    return '"$leftOperand" ${comparer.name.toUpperCase()} "$rightOperand"';
  }
}

/// Represents an IF/ELSE/ENDIF conditional block
class ConditionalNode extends StatementNode {
  final ConditionNode condition;
  final List<StatementNode> thenBlock;
  final List<StatementNode>? elseBlock;

  ConditionalNode({
    required String originalStatement,
    required int lineNumber,
    String? label,
    required this.condition,
    required this.thenBlock,
    this.elseBlock,
  }) : super(
          originalStatement: originalStatement,
          lineNumber: lineNumber,
          label: label,
        );

  @override
  Future<ExecutionResult> execute(BotData data) async {
    final conditionResult = condition.evaluate(data);

    data.log(
        'IF condition ${condition.toString()} evaluated to: $conditionResult');

    if (conditionResult) {
      return ExecutionResult.continueExecution;
    } else if (elseBlock != null) {
      return ExecutionResult.continueExecution;
    }

    return ExecutionResult.continueExecution;
  }
}

/// Represents a WHILE/ENDWHILE loop block
class LoopNode extends StatementNode {
  final ConditionNode condition;
  final List<StatementNode> bodyBlock;

  LoopNode({
    required String originalStatement,
    required int lineNumber,
    String? label,
    required this.condition,
    required this.bodyBlock,
  }) : super(
          originalStatement: originalStatement,
          lineNumber: lineNumber,
          label: label,
        );

  @override
  Future<ExecutionResult> execute(BotData data) async {
    if (!condition.evaluate(data)) {
      data.log(
          'WHILE condition ${condition.toString()} is false, skipping loop');
      return ExecutionResult.continueExecution;
    }

    data.log('WHILE condition ${condition.toString()} is true, entering loop');
    return ExecutionResult.continueExecution;
  }
}

/// Represents a JUMP statement
class JumpNode extends StatementNode {
  final String targetLabel;

  JumpNode({
    required String originalStatement,
    required int lineNumber,
    String? label,
    required this.targetLabel,
  }) : super(
          originalStatement: originalStatement,
          lineNumber: lineNumber,
          label: label,
        );

  @override
  Future<ExecutionResult> execute(BotData data) async {
    data.log('JUMP to label: $targetLabel');
    return ExecutionResult.jumpToLabelNamed(targetLabel);
  }
}

/// Represents a comment or empty line
class CommentNode extends StatementNode {
  final String comment;

  CommentNode({
    required String originalStatement,
    required int lineNumber,
    String? label,
    required this.comment,
  }) : super(
          originalStatement: originalStatement,
          lineNumber: lineNumber,
          label: label,
        );

  @override
  Future<ExecutionResult> execute(BotData data) async {
    return ExecutionResult.continueExecution;
  }
}

/// Execution context for managing scope and control flow state
class ExecutionContext {
  int currentIndex;
  final Map<String, dynamic> localVariables;
  final ExecutionContext? parent;
  final ControlFlowType type;
  final int startIndex;
  final int endIndex;

  ExecutionContext({
    required this.currentIndex,
    required this.localVariables,
    this.parent,
    required this.type,
    required this.startIndex,
    required this.endIndex,
  });
}

/// Types of control flow contexts
enum ControlFlowType {
  SCRIPT,
  IF_BLOCK,
  ELSE_BLOCK,
  WHILE_BLOCK,
}
