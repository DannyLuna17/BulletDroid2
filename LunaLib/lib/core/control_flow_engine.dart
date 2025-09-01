import 'dart:async';
import 'bot_data.dart';
import 'app_configuration.dart';
import 'statement_nodes.dart';
import '../parsing/control_flow_parser.dart';
import '../blocks/utility/loli_code_block.dart';

/// Control flow engine for executing LoliCode with IF/ELSE/ENDIF, WHILE/ENDWHILE, and JUMP support
class ControlFlowEngine {
  final List<StatementNode> statements;
  final Map<String, int> labelMap;
  final List<ExecutionContext> contextStack;
  int currentIndex;
  int maxIterations;
  int currentIterations;

  ControlFlowEngine._({
    required this.statements,
    required this.labelMap,
    required this.maxIterations,
  })  : contextStack = [],
        currentIndex = 0,
        currentIterations = 0;

  /// Create a control flow engine from LoliCode script
  static ControlFlowEngine fromScript(String script) {
    final statements = ControlFlowParser.parseScript(script);
    final labelMap = ControlFlowParser.buildLabelMap(statements);

    // Validate all jumps have valid targets
    ControlFlowParser.validateJumps(statements, labelMap);

    final maxIterations = AppConfiguration.maxLoopIterations;

    return ControlFlowEngine._(
      statements: statements,
      labelMap: labelMap,
      maxIterations: maxIterations,
    );
  }

  /// Execute the entire script
  Future<void> execute(BotData data) async {
    data.log(
        'Starting control flow execution with ${statements.length} statements');

    currentIndex = 0;
    currentIterations = 0;

    // Push root execution context
    _pushContext(ControlFlowType.SCRIPT, 0, statements.length - 1);

    try {
      while (currentIndex < statements.length) {
        // Safety check for infinite loops
        if (currentIterations > maxIterations) {
          throw ControlFlowException(
            'Maximum iteration limit exceeded ($maxIterations). Possible infinite loop detected.',
            'LOOP',
            currentIndex + 1,
          );
        }

        final statement = statements[currentIndex];
        data.log(
            'Executing statement ${currentIndex + 1}: ${statement.originalStatement.trim()}');

        try {
          final result = await _executeStatement(statement, data);

          // Handle execution result
          if (!result.shouldContinue) {
            data.log('Execution stopped by statement');
            break;
          }

          if (result.shouldReturn) {
            data.log('Returning from script execution');
            break;
          }

          if (result.breakLoop) {
            data.log('Breaking from current loop');
            _handleLoopBreak();
            continue;
          }

          if (result.jumpToLabel != null) {
            _handleJump(result.jumpToLabel!, data);
            continue;
          }

          if (result.jumpToIndex != null) {
            currentIndex = result.jumpToIndex!;
            continue;
          }

          // Normal progression
          currentIndex++;
          currentIterations++;
        } catch (e) {
          data.logError(
              'Error executing statement at line ${statement.lineNumber}: $e');
          rethrow;
        }
      }
    } finally {
      contextStack.clear();
    }

    data.log('Control flow execution completed');
  }

  /// Execute a single statement node
  Future<ExecutionResult> _executeStatement(
      StatementNode statement, BotData data) async {
    if (statement is SimpleStatementNode) {
      return await _executeSimpleStatement(statement, data);
    } else if (statement is ConditionalNode) {
      return await _executeConditional(statement, data);
    } else if (statement is LoopNode) {
      return await _executeLoop(statement, data);
    } else if (statement is JumpNode) {
      return await statement.execute(data);
    } else if (statement is CommentNode) {
      return await statement.execute(data);
    } else {
      data.logWarning('Unknown statement type: ${statement.runtimeType}');
      return ExecutionResult.continueExecution;
    }
  }

  /// Execute a simple LoliCode statement using existing LoliCodeBlock logic
  Future<ExecutionResult> _executeSimpleStatement(
      SimpleStatementNode statement, BotData data) async {
    final loliBlock = LoliCodeBlock();
    loliBlock.script = statement.statement;

    try {
      await loliBlock.execute(data);
      return ExecutionResult.continueExecution;
    } catch (e) {
      data.logError('Failed to execute statement: ${statement.statement}');
      rethrow;
    }
  }

  /// Execute an IF/ELSE/ENDIF conditional block
  Future<ExecutionResult> _executeConditional(
      ConditionalNode conditional, BotData data) async {
    final conditionResult = conditional.condition.evaluate(data);

    data.log(
        'IF condition ${conditional.condition.toString()} evaluated to: $conditionResult');

    if (conditionResult) {
      data.log(
          'Executing THEN block (${conditional.thenBlock.length} statements)');
      return await _executeBlock(
          conditional.thenBlock, data, ControlFlowType.IF_BLOCK);
    } else if (conditional.elseBlock != null) {
      data.log(
          'Executing ELSE block (${conditional.elseBlock!.length} statements)');
      return await _executeBlock(
          conditional.elseBlock!, data, ControlFlowType.ELSE_BLOCK);
    } else {
      data.log('Condition false and no ELSE block, skipping');
      return ExecutionResult.continueExecution;
    }
  }

  /// Execute a WHILE/ENDWHILE loop
  Future<ExecutionResult> _executeLoop(LoopNode loop, BotData data) async {
    var loopIterations = 0;
    final loopStartIterations = currentIterations;

    data.log('Starting WHILE loop');

    while (loop.condition.evaluate(data)) {
      loopIterations++;

      // Safety check for infinite loops
      if (loopIterations > maxIterations) {
        throw ControlFlowException(
          'WHILE loop exceeded maximum iterations ($maxIterations)',
          'WHILE',
          loop.lineNumber,
        );
      }

      if (currentIterations - loopStartIterations > maxIterations) {
        throw ControlFlowException(
          'Total execution exceeded maximum iterations due to loop',
          'WHILE',
          loop.lineNumber,
        );
      }

      data.log(
          'WHILE loop iteration $loopIterations, condition: ${loop.condition.toString()}');

      // Execute loop body
      final result = await _executeBlock(
          loop.bodyBlock, data, ControlFlowType.WHILE_BLOCK);

      // Handle loop control
      if (result.breakLoop) {
        data.log('Breaking from WHILE loop');
        break;
      }

      if (result.shouldReturn || !result.shouldContinue) {
        return result;
      }

      if (result.jumpToLabel != null || result.jumpToIndex != null) {
        // Jumps break out of the loop
        return result;
      }

      currentIterations++;
    }

    data.log('WHILE loop completed after $loopIterations iterations');
    return ExecutionResult.continueExecution;
  }

  /// Execute a block of statements
  Future<ExecutionResult> _executeBlock(List<StatementNode> block, BotData data,
      ControlFlowType contextType) async {
    _pushContext(contextType, 0, block.length - 1);

    try {
      for (var i = 0; i < block.length; i++) {
        final statement = block[i];
        final result = await _executeStatement(statement, data);

        if (!result.shouldContinue || result.shouldReturn) {
          return result;
        }

        if (result.breakLoop) {
          return result;
        }

        if (result.jumpToLabel != null || result.jumpToIndex != null) {
          return result;
        }

        currentIterations++;
      }

      return ExecutionResult.continueExecution;
    } finally {
      _popContext();
    }
  }

  /// Handle a jump to a labeled statement
  void _handleJump(String targetLabel, BotData data) {
    if (!labelMap.containsKey(targetLabel)) {
      throw ControlFlowException(
        'Jump target label not found: $targetLabel',
        'JUMP',
        currentIndex + 1,
      );
    }

    final targetIndex = labelMap[targetLabel]!;
    data.log('Jumping to label "$targetLabel" at statement ${targetIndex + 1}');
    currentIndex = targetIndex;
  }

  /// Handle a loop break
  void _handleLoopBreak() {
    for (var i = contextStack.length - 1; i >= 0; i--) {
      if (contextStack[i].type == ControlFlowType.WHILE_BLOCK) {
        currentIndex = contextStack[i].endIndex + 1;
        return;
      }
    }

    currentIndex++;
  }

  /// Push a new execution context
  void _pushContext(ControlFlowType type, int startIndex, int endIndex) {
    contextStack.add(ExecutionContext(
      currentIndex: currentIndex,
      localVariables: {},
      parent: contextStack.isNotEmpty ? contextStack.last : null,
      type: type,
      startIndex: startIndex,
      endIndex: endIndex,
    ));
  }

  /// Pop the current execution context
  void _popContext() {
    if (contextStack.isNotEmpty) {
      contextStack.removeLast();
    }
  }

  /// Get current execution context
  ExecutionContext? get currentContext {
    return contextStack.isNotEmpty ? contextStack.last : null;
  }

  /// Check if currently inside a loop
  bool get isInLoop {
    return contextStack
        .any((context) => context.type == ControlFlowType.WHILE_BLOCK);
  }
}

/// Exception thrown during control flow execution
class ControlFlowException implements Exception {
  final String message;
  final String statementType;
  final int lineNumber;

  ControlFlowException(this.message, this.statementType, this.lineNumber);

  @override
  String toString() {
    return 'ControlFlowException at line $lineNumber ($statementType): $message';
  }
}
