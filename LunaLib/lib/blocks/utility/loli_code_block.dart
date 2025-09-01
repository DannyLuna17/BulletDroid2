import '../base/block_instance.dart';
import '../../core/bot_data.dart';
import '../../core/status.dart';
import '../../core/comparer.dart';
import '../../core/condition.dart';
import '../../core/control_flow_engine.dart';
import '../../parsing/interpolation_engine.dart';
import '../../parsing/statement_parser.dart';
import '../../variables/variable_factory.dart';
import '../functions/function_block.dart';
import '../../parsing/line_parser.dart';

class LoliCodeBlock extends BlockInstance {
  String script = '';

  LoliCodeBlock() : super(id: 'LoliCode');

  @override
  Future<void> execute(BotData data) async {
    try {
      if (_hasControlFlowStatements(script)) {
        data.log(
            'Script contains control flow statements, using ControlFlowEngine');
        await _executeWithControlFlow(data);
      } else {
        data.log(
            'Script contains only simple statements, using sequential execution');
        await _executeSequentially(data);
      }
    } catch (e, stackTrace) {
      data.logError('LoliCode execution failed: $e');
      data.logError('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Check if script contains control flow statements
  bool _hasControlFlowStatements(String script) {
    final lines = script.split('\n');
    for (final line in lines) {
      final trimmed = line.trim().toUpperCase();

      // Check for control flow keywords
      if (trimmed.startsWith('IF ') ||
          trimmed == 'ELSE' ||
          trimmed == 'ENDIF' ||
          trimmed.startsWith('WHILE ') ||
          trimmed == 'ENDWHILE' ||
          trimmed.startsWith('JUMP ')) {
        return true;
      }

      // Check for labeled statements
      if (trimmed.startsWith('#') && !trimmed.startsWith('##')) {
        final labelMatch = RegExp(r'^#([A-Za-z0-9_]+)').firstMatch(trimmed);
        if (labelMatch != null) {
          return true;
        }
      }
    }
    return false;
  }

  /// Execute script using ControlFlowEngine
  Future<void> _executeWithControlFlow(BotData data) async {
    try {
      final engine = ControlFlowEngine.fromScript(script);
      await engine.execute(data);
      data.log('Control flow execution completed successfully');
    } catch (e) {
      data.logError('Control flow execution failed: $e');
      rethrow;
    }
  }

  /// Execute script sequentially
  Future<void> _executeSequentially(BotData data) async {
    final preprocessedScript = _preprocessScript(script);

    final statements = _parseStatements(preprocessedScript);

    // Execute statements sequentially
    for (int i = 0; i < statements.length; i++) {
      final statement = statements[i].trim();

      if (statement.isEmpty || statement.startsWith('##')) {
        continue;
      }

      try {
        await _executeStatement(statement, data, statements, i);
      } catch (e) {
        data.logError('Error executing statement: $statement');
        data.logError('Error: $e');
        rethrow;
      }
    }

    data.log('Executed LoliCode script with ${statements.length} statements');
  }

  String _preprocessScript(String script) {
    final lines = script.split('\n');
    final processedLines = <String>[];
    var currentLine = '';

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().isEmpty || line.trim().startsWith('##')) {
        if (currentLine.isNotEmpty) {
          processedLines.add(currentLine);
          currentLine = '';
        }
        processedLines.add(line);
        continue;
      }

      if (line.startsWith(' ') || line.startsWith('\t')) {
        // This is a continuation line
        if (currentLine.isNotEmpty) {
          currentLine += ' ' + line.trim();
        } else {
          currentLine = line.trim();
        }
      } else {
        if (currentLine.isNotEmpty) {
          processedLines.add(currentLine);
        }
        currentLine = line;
      }
    }

    if (currentLine.isNotEmpty) {
      processedLines.add(currentLine);
    }

    return processedLines.join('\n');
  }

  /// Parse LoliCode into logical statements
  List<String> _parseStatements(String script) {
    return script.split('\n').where((line) => line.trim().isNotEmpty).toList();
  }

  Future<void> _executeStatement(String statement, BotData data,
      List<String> statements, int index) async {
    String workingStatement = statement;
    // Parse labels (#LABEL prefix)
    if (workingStatement.startsWith('#')) {
      final labelMatch =
          RegExp(r'^#([A-Za-z0-9_]+)\s+(.*)$').firstMatch(workingStatement);
      if (labelMatch != null) {
        workingStatement = labelMatch.group(2)!;
      }
    }

    try {
      // DELETE statement
      if (workingStatement.startsWith('DELETE ')) {
        await _executeDeleteStatement(
            workingStatement.substring(7).trim(), data);
        return;
      }

      // LOG statement
      if (workingStatement.startsWith('LOG ')) {
        final message = workingStatement.substring(4);
        final interpolated = InterpolationEngine.interpolateForLoliCode(
            message, data.variables, data);
        data.log('LOG: $interpolated');
        return;
      }

      // PRINT statement
      if (workingStatement.startsWith('PRINT ')) {
        final message = workingStatement.substring(6);
        final interpolated = InterpolationEngine.interpolateForLoliCode(
            message, data.variables, data);
        data.log('PRINT: $interpolated');
        return;
      }

      // PRINT statement with no content
      if (workingStatement == 'PRINT') {
        data.log('PRINT: ');
        return;
      }

      // SET statement with various identifiers
      if (workingStatement.startsWith('SET ')) {
        await _executeSetStatement(workingStatement.substring(4).trim(), data);
        return;
      }

      // MARK statement: MARK myVar
      if (workingStatement.startsWith('MARK ')) {
        final varName = workingStatement.substring(5).trim();
        data.variables.markForCapture(varName);
        data.log('Marked variable $varName for capture');
        return;
      }

      // UNMARK statement: UNMARK myVar
      if (workingStatement.startsWith('UNMARK ')) {
        final varName = workingStatement.substring(7).trim();
        data.variables.unmarkForCapture(varName);
        data.log('Unmarked variable $varName for capture');
        return;
      }

      // Simple variable assignment: myVar = "value"
      final assignmentMatch =
          RegExp(r'^(\w+)\s*=\s*(.+)$').firstMatch(workingStatement);
      if (assignmentMatch != null) {
        final varName = assignmentMatch.group(1)!;
        var value = assignmentMatch.group(2)!;

        // Remove quotes if present
        if (value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
        }

        // Interpolate the value safely
        value = InterpolationEngine.interpolateForLoliCode(
            value, data.variables, data);

        final variable = VariableFactory.fromObject(varName, value);
        data.variables.set(variable);
        data.log('Set variable $varName = "$value"');
        return;
      }

      // FUNCTION statement: FUNCTION Name [ARGUMENTS] ["INPUT STRING"] [-> VAR/CAP "NAME"]
      if (workingStatement.startsWith('FUNCTION ')) {
        await _executeFunctionStatement(workingStatement, data);
        return;
      }

      // HEADER statement: HEADER "Key: Value" (standalone headers)
      if (workingStatement.startsWith('HEADER ')) {
        final headerContent = workingStatement.substring(7).trim();
        // Remove quotes if present
        final cleanHeader =
            headerContent.startsWith('"') && headerContent.endsWith('"')
                ? headerContent.substring(1, headerContent.length - 1)
                : headerContent;

        data.log('Processed standalone HEADER: $cleanHeader');
        return;
      }

      // STRINGCONTENT statement: STRINGCONTENT "key: value" (for multipart form data)
      if (workingStatement.startsWith('STRINGCONTENT ')) {
        final content = workingStatement.substring(14).trim();
        // Remove quotes if present
        final cleanContent = content.startsWith('"') && content.endsWith('"')
            ? content.substring(1, content.length - 1)
            : content;

        data.log('Processed STRINGCONTENT: $cleanContent');
        return;
      }

      // SECPROTO statement: SECPROTO TLS12 (security protocol)
      if (workingStatement.startsWith('SECPROTO ')) {
        final protocol = workingStatement.substring(9).trim();
        data.log('Set security protocol: $protocol');
        return;
      }

      data.logWarning('Unsupported LoliCode statement: $workingStatement');
    } catch (e, stackTrace) {
      data.logError('Statement execution failed: $e');
      data.logError('Statement: $workingStatement');
      data.logError('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _executeFunctionStatement(String statement, BotData data) async {
    try {
      // Create and configure a FunctionBlock
      final functionBlock = FunctionBlock();
      functionBlock.fromLoliCode(statement);

      // Execute the function block
      await functionBlock.execute(data);
    } catch (e, stackTrace) {
      data.logError('FUNCTION statement execution failed: $e');
      data.logError('Statement: $statement');
      data.logError('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _executeSetStatement(String content, BotData data) async {
    final parts = content.split(' ');
    if (parts.isEmpty) return;

    final originalIdentifier = parts[0];
    final identifier = parts[0].toUpperCase();
    final remainingContent = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    switch (identifier) {
      case 'SOURCE':
        final value = _extractQuotedValue(remainingContent);
        data.responseSource = InterpolationEngine.interpolateForLoliCode(
            value, data.variables, data);
        data.log('Set SOURCE = "${data.responseSource}"');
        break;

      case 'STATUS':
        if (remainingContent.toUpperCase().startsWith('CUSTOM ')) {
          data.status = BotStatus.CUSTOM;
          final customValue =
              _extractQuotedValue(remainingContent.substring(7));
          data.customStatus = InterpolationEngine.interpolateForLoliCode(
              customValue, data.variables, data);
          data.log('Set STATUS = CUSTOM "${data.customStatus}"');
        } else {
          data.status = _parseStatusValue(remainingContent);
          data.log('Set STATUS = ${data.status}');
        }
        break;

      case 'RESPONSECODE':
        try {
          data.responseCode = int.parse(remainingContent.trim());
          data.log('Set RESPONSECODE = ${data.responseCode}');
        } catch (e) {
          data.logError('Invalid RESPONSECODE value: $remainingContent');
        }
        break;

      case 'COOKIE':
        final cookieParts = remainingContent.split(' ');
        if (cookieParts.length >= 2) {
          final name = _extractQuotedValue(cookieParts[0]);
          final value = _extractQuotedValue(cookieParts.sublist(1).join(' '));
          data.cookies[name] = InterpolationEngine.interpolateForLoliCode(
              value, data.variables, data);
          data.log('Set COOKIE "$name" = "${data.cookies[name]}"');
        }
        break;

      case 'ADDRESS':
        final value = _extractQuotedValue(remainingContent);
        data.address = InterpolationEngine.interpolateForLoliCode(
            value, data.variables, data);
        data.log('Set ADDRESS = "${data.address}"');
        break;

      case 'USEPROXY':
        data.useProxy = remainingContent.trim().toUpperCase() == 'TRUE';
        data.log('Set USEPROXY = ${data.useProxy}');
        break;

      case 'PROXY':
        final proxyStr = _extractQuotedValue(remainingContent);
        final proxy = _parseProxyString(proxyStr);
        if (proxy != null) {
          data.proxy = proxy;
          data.log('Set PROXY = "$proxyStr"');
        }
        break;

      case 'PROXYTYPE':
        if (data.proxy != null) {
          data.proxy!.type = _parseProxyType(remainingContent.trim());
          data.log('Set PROXYTYPE = ${data.proxy!.type}');
        }
        break;

      case 'DATA':
        final value = _extractQuotedValue(remainingContent);
        data.input = InterpolationEngine.interpolateForLoliCode(
            value, data.variables, data);

        // Update USER and PASS variables
        if (data.input.contains(':')) {
          final parts = data.input.split(':');
          if (parts.length >= 2) {
            data.variables.set(VariableFactory.fromObject('USER', parts[0]));
            data.variables.set(
                VariableFactory.fromObject('PASS', parts.sublist(1).join(':')));
            data.variables
                .set(VariableFactory.fromObject('USERNAME', parts[0]));
            data.variables.set(VariableFactory.fromObject(
                'PASSWORD', parts.sublist(1).join(':')));
          }
        }

        data.log('Set DATA = "${data.input}"');
        break;

      case 'VAR':
        _executeVariableAssignment(remainingContent, data, false);
        break;

      case 'CAP':
        _executeVariableAssignment(remainingContent, data, true);
        break;

      case 'NEWGVAR':
        _executeNewGlobalVariable(remainingContent, data);
        break;

      case 'GVAR':
        _executeGlobalVariable(remainingContent, data);
        break;

      case 'GCOOKIES':
        data.cookies.forEach((key, value) {
          BotData.globalCookies[key] = value;
        });
        data.log('Copied ${data.cookies.length} cookies to global cookie jar');
        break;

      default:
        _executeVariableAssignment(
            '$originalIdentifier $remainingContent', data, false);
        break;
    }
  }

  void _executeVariableAssignment(
      String content, BotData data, bool markAsCapture) {
    final spaceIndex = content.indexOf(' ');
    if (spaceIndex == -1) return;

    final varName = content.substring(0, spaceIndex);
    var valueStr = content.substring(spaceIndex + 1).trim();

    try {
      dynamic value;

      if (valueStr.startsWith('[') && valueStr.endsWith(']')) {
        value = LineParser.parseList(valueStr);
      } else if (valueStr.startsWith('{') && valueStr.endsWith('}')) {
        value = LineParser.parseMap(valueStr);
      } else {
        valueStr = _extractQuotedValue(valueStr);
        value = InterpolationEngine.interpolateForLoliCode(
            valueStr, data.variables, data);
      }

      final variable = VariableFactory.fromObject(varName, value);

      if (markAsCapture) {
        data.variables.setCapture(varName, value);
        data.log('Set captured variable $varName = ${_formatValue(value)}');
      } else {
        data.variables.set(variable);
        data.log('Set variable $varName = ${_formatValue(value)}');
      }
    } catch (e) {
      data.logError('Failed to set variable $varName: $e');
    }
  }

  void _executeNewGlobalVariable(String content, BotData data) {
    final parts = content.split(' ');
    if (parts.length < 2) return;

    final varName = _extractQuotedValue(parts[0]);
    final valueStr = _extractQuotedValue(parts.sublist(1).join(' '));

    if (!BotData.globalVariables.containsKey(varName)) {
      final value = InterpolationEngine.interpolateForLoliCode(
          valueStr, data.variables, data);

      BotData.globalVariables[varName] =
          VariableFactory.fromObject(varName, value);
      data.log('Created new global variable $varName = "$value"');
    } else {
      data.log('Global variable $varName already exists, skipping');
    }
  }

  void _executeGlobalVariable(String content, BotData data) {
    final parts = content.split(' ');
    if (parts.length < 2) return;

    final varName = _extractQuotedValue(parts[0]);
    final valueStr = _extractQuotedValue(parts.sublist(1).join(' '));
    final value = InterpolationEngine.interpolateForLoliCode(
        valueStr, data.variables, data);

    BotData.globalVariables[varName] =
        VariableFactory.fromObject(varName, value);
    data.log('Set global variable $varName = "$value"');
  }

  String _extractQuotedValue(String input) {
    final trimmed = input.trim();
    if (trimmed.startsWith('"') &&
        trimmed.endsWith('"') &&
        trimmed.length > 1) {
      return trimmed.substring(1, trimmed.length - 1);
    }
    return trimmed;
  }

  String _formatValue(dynamic value) {
    if (value is List) {
      return '[${value.join(', ')}]';
    } else if (value is Map) {
      final pairs = value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      return '{$pairs}';
    } else {
      return '"$value"';
    }
  }

  BotStatus _parseStatusValue(String value) {
    switch (value.trim().toUpperCase()) {
      case 'SUCCESS':
        return BotStatus.SUCCESS;
      case 'FAIL':
        return BotStatus.FAIL;
      case 'RETRY':
        return BotStatus.RETRY;
      case 'BAN':
        return BotStatus.BAN;
      case 'ERROR':
        return BotStatus.ERROR;
      case 'UNKNOWN':
        return BotStatus.UNKNOWN;
      case 'CUSTOM':
        return BotStatus.CUSTOM;
      default:
        return BotStatus.NONE;
    }
  }

  Proxy? _parseProxyString(String proxyStr) {
    final parts = proxyStr.split(':');
    if (parts.length >= 2) {
      try {
        return Proxy(
          host: parts[0],
          port: int.parse(parts[1]),
          type: ProxyType.HTTP,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ProxyType _parseProxyType(String type) {
    switch (type.toUpperCase()) {
      case 'SOCKS4':
        return ProxyType.SOCKS4;
      case 'SOCKS5':
        return ProxyType.SOCKS5;
      default:
        return ProxyType.HTTP;
    }
  }

  Future<void> _executeDeleteStatement(String content, BotData data) async {
    try {
      // Parse the identifier (COOKIE, VAR, GVAR)
      final identifier = LineParser.parseToken(content).toUpperCase();
      var remaining = LineParser.consumeToken(content);

      // Parse optional comparer (default is EqualTo)
      Comparer comparer = Comparer.equalTo;

      // Check if next token is a comparer
      final nextToken = LineParser.parseToken(remaining);
      if (nextToken.isNotEmpty && StatementParser.isParameter(nextToken)) {
        final testComparer = ComparerExtension.fromString(nextToken);
        if (testComparer != Comparer.equalTo ||
            nextToken.toUpperCase() == 'EQUALTO') {
          comparer = testComparer;
          remaining = LineParser.consumeToken(remaining);
        }
      }

      // Parse the literal value
      final pattern = LineParser.parseLiteral(remaining);

      switch (identifier) {
        case 'COOKIE':
          _deleteCookiesByCondition(comparer, pattern, data);
          break;

        case 'VAR':
          _deleteVariablesByCondition(comparer, pattern, data);
          break;

        case 'GVAR':
          _deleteGlobalVariablesByCondition(comparer, pattern, data);
          break;

        default:
          throw FormatException('Invalid DELETE identifier: $identifier');
      }
    } catch (e) {
      data.logError('DELETE statement execution failed: $e');
      rethrow;
    }
  }

  void _deleteCookiesByCondition(
      Comparer comparer, String pattern, BotData data) {
    final toRemove = <String>[];

    // Find all cookies that match the condition
    for (final cookieName in data.cookies.keys) {
      if (Condition.evaluateWithData(cookieName, comparer, pattern, data)) {
        toRemove.add(cookieName);
      }
    }

    // Remove matching cookies
    for (final key in toRemove) {
      data.cookies.remove(key);
    }

    data.log(
        'Deleted ${toRemove.length} cookies matching pattern "$pattern" with comparer ${comparer.name}');
  }

  void _deleteVariablesByCondition(
      Comparer comparer, String pattern, BotData data) {
    final beforeCount = data.variables.count;
    data.variables.removeByCondition(comparer, pattern, data);
    final deletedCount = beforeCount - data.variables.count;

    data.log(
        'Deleted $deletedCount variables matching pattern "$pattern" with comparer ${comparer.name}');
  }

  void _deleteGlobalVariablesByCondition(
      Comparer comparer, String pattern, BotData data) {
    final toRemove = <String>[];

    // Find all global variables that match the condition
    for (final varName in BotData.globalVariables.keys) {
      if (Condition.evaluateWithData(varName, comparer, pattern, data)) {
        toRemove.add(varName);
      }
    }

    // Remove matching global variables
    for (final key in toRemove) {
      BotData.globalVariables.remove(key);
    }

    data.log(
        'Deleted ${toRemove.length} global variables matching pattern "$pattern" with comparer ${comparer.name}');
  }

  @override
  void fromLoliCode(String content) {
    script = content;
  }

  @override
  String toLoliCode() {
    return script;
  }
}
