import '../core/statement_nodes.dart';
import '../core/comparer.dart';

/// Parser for control flow statements (IF/ELSE/ENDIF, WHILE/ENDWHILE, JUMP)
class ControlFlowParser {
  /// Parse a script into a list of statement nodes
  static List<StatementNode> parseScript(String script) {
    final lines = script.split('\n');
    final statements = <StatementNode>[];
    final labelMap = <String, int>{};

    var i = 0;
    while (i < lines.length) {
      final line = lines[i].trim();

      // Skip empty lines and comments
      if (line.isEmpty || line.startsWith('##')) {
        if (line.startsWith('##')) {
          statements.add(CommentNode(
            originalStatement: lines[i],
            lineNumber: i + 1,
            comment: line.substring(2).trim(),
          ));
        }
        i++;
        continue;
      }

      // Parse label if present
      String? label;
      String workingLine = line;
      if (line.startsWith('#') && !line.startsWith('##')) {
        final labelMatch =
            RegExp(r'^#([A-Za-z0-9_]+)\s*(.*)$').firstMatch(line);
        if (labelMatch != null) {
          label = labelMatch.group(1)!;
          workingLine = labelMatch.group(2)!.trim();

          labelMap[label] = statements.length;
        }
      }

      try {
        // Parse control flow statements
        if (workingLine.toUpperCase().startsWith('IF ')) {
          final result = _parseIfBlock(lines, i, label);
          statements.add(result.node);
          i = result.nextIndex;
          continue;
        } else if (workingLine.toUpperCase().startsWith('WHILE ')) {
          final result = _parseWhileBlock(lines, i, label);
          statements.add(result.node);
          i = result.nextIndex;
          continue;
        } else if (workingLine.toUpperCase().startsWith('JUMP ')) {
          final jumpNode = _parseJumpStatement(workingLine, i + 1, label);
          statements.add(jumpNode);
        } else {
          // Regular statement
          final statementNode = SimpleStatementNode(
            originalStatement: lines[i],
            lineNumber: i + 1,
            label: label,
            statement: workingLine,
          );
          statements.add(statementNode);
        }
      } catch (e) {
        // If parsing fails, treat as simple statement
        final statementNode = SimpleStatementNode(
          originalStatement: lines[i],
          lineNumber: i + 1,
          label: label,
          statement: workingLine,
        );
        statements.add(statementNode);
      }

      i++;
    }

    return statements;
  }

  /// Parse an IF block and return the node with next index
  static ParseResult _parseIfBlock(
      List<String> lines, int startIndex, String? label) {
    final startLine = lines[startIndex].trim();

    // Extract label if present
    String workingLine = startLine;
    if (startLine.startsWith('#') && !startLine.startsWith('##')) {
      final labelMatch =
          RegExp(r'^#([A-Za-z0-9_]+)\s*(.*)$').firstMatch(startLine);
      if (labelMatch != null) {
        workingLine = labelMatch.group(2)!.trim();
      }
    }

    // Parse IF condition: IF "STRING1" CONDITION "STRING2"
    final condition = _parseCondition(workingLine.substring(3).trim());

    // Parse THEN block
    final thenBlock = <StatementNode>[];
    var currentIndex = startIndex + 1;

    while (currentIndex < lines.length) {
      final line = lines[currentIndex].trim();

      if (line.toUpperCase() == 'ELSE') {
        break;
      } else if (line.toUpperCase() == 'ENDIF') {
        // IF without ELSE
        final ifNode = ConditionalNode(
          originalStatement: lines[startIndex],
          lineNumber: startIndex + 1,
          label: label,
          condition: condition,
          thenBlock: thenBlock,
        );
        return ParseResult(ifNode, currentIndex + 1);
      } else if (line.isEmpty || line.startsWith('##')) {
        // Skip empty lines and comments in block
        currentIndex++;
        continue;
      }

      // Parse nested statement
      if (line.toUpperCase().startsWith('IF ')) {
        final nestedResult = _parseIfBlock(lines, currentIndex, null);
        thenBlock.add(nestedResult.node);
        currentIndex = nestedResult.nextIndex;
      } else if (line.toUpperCase().startsWith('WHILE ')) {
        final nestedResult = _parseWhileBlock(lines, currentIndex, null);
        thenBlock.add(nestedResult.node);
        currentIndex = nestedResult.nextIndex;
      } else {
        // Regular statement
        final statementNode = SimpleStatementNode(
          originalStatement: lines[currentIndex],
          lineNumber: currentIndex + 1,
          statement: line,
        );
        thenBlock.add(statementNode);
        currentIndex++;
      }
    }

    // Parse ELSE block if present
    List<StatementNode>? elseBlock;
    if (currentIndex < lines.length &&
        lines[currentIndex].trim().toUpperCase() == 'ELSE') {
      elseBlock = <StatementNode>[];
      currentIndex++;

      while (currentIndex < lines.length) {
        final line = lines[currentIndex].trim();

        if (line.toUpperCase() == 'ENDIF') {
          break;
        } else if (line.isEmpty || line.startsWith('##')) {
          // Skip empty lines and comments in block
          currentIndex++;
          continue;
        }

        // Parse nested statement
        if (line.toUpperCase().startsWith('IF ')) {
          final nestedResult = _parseIfBlock(lines, currentIndex, null);
          elseBlock.add(nestedResult.node);
          currentIndex = nestedResult.nextIndex;
        } else if (line.toUpperCase().startsWith('WHILE ')) {
          final nestedResult = _parseWhileBlock(lines, currentIndex, null);
          elseBlock.add(nestedResult.node);
          currentIndex = nestedResult.nextIndex;
        } else {
          // Regular statement
          final statementNode = SimpleStatementNode(
            originalStatement: lines[currentIndex],
            lineNumber: currentIndex + 1,
            statement: line,
          );
          elseBlock.add(statementNode);
          currentIndex++;
        }
      }
    }

    // Should end with ENDIF
    if (currentIndex >= lines.length ||
        lines[currentIndex].trim().toUpperCase() != 'ENDIF') {
      throw FormatException('IF block at line ${startIndex + 1} missing ENDIF');
    }

    final ifNode = ConditionalNode(
      originalStatement: lines[startIndex],
      lineNumber: startIndex + 1,
      label: label,
      condition: condition,
      thenBlock: thenBlock,
      elseBlock: elseBlock,
    );

    return ParseResult(ifNode, currentIndex + 1);
  }

  /// Parse a WHILE block and return the node with next index
  static ParseResult _parseWhileBlock(
      List<String> lines, int startIndex, String? label) {
    final startLine = lines[startIndex].trim();

    // Extract label if present
    String workingLine = startLine;
    if (startLine.startsWith('#') && !startLine.startsWith('##')) {
      final labelMatch =
          RegExp(r'^#([A-Za-z0-9_]+)\s*(.*)$').firstMatch(startLine);
      if (labelMatch != null) {
        workingLine = labelMatch.group(2)!.trim();
      }
    }

    // Parse WHILE condition: WHILE "STRING1" CONDITION "STRING2"
    final condition = _parseCondition(workingLine.substring(6).trim());

    // Parse body block
    final bodyBlock = <StatementNode>[];
    var currentIndex = startIndex + 1;

    while (currentIndex < lines.length) {
      final line = lines[currentIndex].trim();

      if (line.toUpperCase() == 'ENDWHILE') {
        break;
      } else if (line.isEmpty || line.startsWith('##')) {
        // Skip empty lines and comments in block
        currentIndex++;
        continue;
      }

      // Parse nested statement
      if (line.toUpperCase().startsWith('IF ')) {
        final nestedResult = _parseIfBlock(lines, currentIndex, null);
        bodyBlock.add(nestedResult.node);
        currentIndex = nestedResult.nextIndex;
      } else if (line.toUpperCase().startsWith('WHILE ')) {
        final nestedResult = _parseWhileBlock(lines, currentIndex, null);
        bodyBlock.add(nestedResult.node);
        currentIndex = nestedResult.nextIndex;
      } else {
        // Regular statement
        final statementNode = SimpleStatementNode(
          originalStatement: lines[currentIndex],
          lineNumber: currentIndex + 1,
          statement: line,
        );
        bodyBlock.add(statementNode);
        currentIndex++;
      }
    }

    // Should end with ENDWHILE
    if (currentIndex >= lines.length ||
        lines[currentIndex].trim().toUpperCase() != 'ENDWHILE') {
      throw FormatException(
          'WHILE block at line ${startIndex + 1} missing ENDWHILE');
    }

    final whileNode = LoopNode(
      originalStatement: lines[startIndex],
      lineNumber: startIndex + 1,
      label: label,
      condition: condition,
      bodyBlock: bodyBlock,
    );

    return ParseResult(whileNode, currentIndex + 1);
  }

  /// Parse a JUMP statement
  static JumpNode _parseJumpStatement(
      String line, int lineNumber, String? label) {
    // Parse: JUMP #LABEL
    final jumpContent = line.substring(5).trim();

    if (!jumpContent.startsWith('#')) {
      throw FormatException(
          'JUMP statement must target a label starting with #');
    }

    final targetLabel = jumpContent.substring(1);

    return JumpNode(
      originalStatement: line,
      lineNumber: lineNumber,
      label: label,
      targetLabel: targetLabel,
    );
  }

  /// Parse a condition string into a ConditionNode
  static ConditionNode _parseCondition(String conditionStr) {
    // Parse: "STRING1" CONDITION "STRING2"
    final parts = conditionStr.trim().split(' ');

    if (parts.length < 3) {
      throw FormatException('Invalid condition format: $conditionStr');
    }

    final leftOperand = _extractQuotedString(parts[0]);

    final comparerStr = parts[1].toUpperCase();
    final comparer = ComparerExtension.fromString(comparerStr);

    final rightParts = parts.sublist(2);
    final rightOperand = _extractQuotedString(rightParts.join(' '));

    return ConditionNode(
      leftOperand: leftOperand,
      comparer: comparer,
      rightOperand: rightOperand,
    );
  }

  /// Extract content from quoted string
  static String _extractQuotedString(String input) {
    final trimmed = input.trim();
    if (trimmed.startsWith('"') &&
        trimmed.endsWith('"') &&
        trimmed.length > 1) {
      return trimmed.substring(1, trimmed.length - 1);
    }
    return trimmed;
  }

  /// Build label-to-statement index mapping
  static Map<String, int> buildLabelMap(List<StatementNode> statements) {
    final labelMap = <String, int>{};

    for (var i = 0; i < statements.length; i++) {
      final statement = statements[i];
      if (statement.label != null) {
        labelMap[statement.label!] = i;
      }
    }

    return labelMap;
  }

  /// Validate that all JUMP statements have valid target labels
  static void validateJumps(
      List<StatementNode> statements, Map<String, int> labelMap) {
    for (final statement in statements) {
      if (statement is JumpNode) {
        if (!labelMap.containsKey(statement.targetLabel)) {
          throw FormatException(
              'JUMP statement at line ${statement.lineNumber} references undefined label: ${statement.targetLabel}');
        }
      }
    }
  }
}

/// Result of parsing a control flow block
class ParseResult {
  final StatementNode node;
  final int nextIndex;

  ParseResult(this.node, this.nextIndex);
}
