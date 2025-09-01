/// Parser for LoliScript statements following CMDID [ARGUMENTS] pattern
class StatementParser {
  /// Parse the command identifier from a statement
  static String parseCmdId(String statement) {
    final trimmed = statement.trim();
    final match =
        RegExp(r'^([A-Z]+)(?:\s|$)', caseSensitive: false).firstMatch(trimmed);
    return match?.group(1)?.toUpperCase() ?? '';
  }

  /// Parse a parameter (enum/identifier) argument
  static String parseParameter(String input) {
    final trimmed = input.trim();
    final match = RegExp(r'^([A-Za-z][A-Za-z0-9_]*)').firstMatch(trimmed);
    if (match == null) {
      throw FormatException('Invalid parameter format');
    }
    return match.group(1)!;
  }

  /// Parse a numeric argument
  static int parseNumeric(String input) {
    final trimmed = input.trim();
    final match = RegExp(r'^(-?\d+)').firstMatch(trimmed);
    if (match == null) {
      throw FormatException('Invalid numeric format');
    }
    return int.parse(match.group(1)!);
  }

  /// Parse a boolean argument (ParamName=True/False)
  static Map<String, bool> parseBoolean(String input) {
    final trimmed = input.trim();
    final match =
        RegExp(r'^([A-Za-z][A-Za-z0-9_]*)=(True|False)', caseSensitive: false)
            .firstMatch(trimmed);
    if (match == null) {
      throw FormatException('Invalid boolean format');
    }
    final paramName = match.group(1)!;
    final value = match.group(2)!.toLowerCase() == 'true';
    return {paramName: value};
  }

  /// Parse a redirector (->VAR "name" or ->CAP "name")
  static Map<String, dynamic>? parseRedirector(String input) {
    final match = RegExp(r'->\s*(VAR|CAP)\s+"([^"]*)"').firstMatch(input);
    if (match == null) return null;

    return {
      'type': match.group(1),
      'name': match.group(2),
      'isCapture': match.group(1) == 'CAP',
    };
  }

  /// Extract all arguments from a statement after the CMDID
  static String extractArguments(String statement, String cmdId) {
    final index = statement.toUpperCase().indexOf(cmdId.toUpperCase());
    if (index == -1) return '';

    return statement.substring(index + cmdId.length).trim();
  }

  /// Check if a token is a known parameter/enum value
  static bool isParameter(String token) {
    final parameters = [
      'GET',
      'POST',
      'PUT',
      'DELETE',
      'PATCH',
      'HEAD',
      'OPTIONS',
      'MULTIPART',
      'BASICAUTH',
      'STANDARD',
      'URLENCODE',
      'APPLICATION/JSON',
      'APPLICATION/X-WWW-FORM-URLENCODED',
      'SHA1',
      'SHA256',
      'SHA384',
      'SHA512',
      'MD5',
      'BASE64',
      'HEX',
      'UPPERCASE',
      'LOWERCASE',
      'LR',
      'CSS',
      'JSON',
      'REGEX',
      'XPATH',
      'HEADERS',
      'SOURCE',
      'COOKIES',
      'RESPONSECODE',
      'ADDRESS',
      'SUCCESS',
      'FAIL',
      'RETRY',
      'BAN',
      'CUSTOM',
      'AND',
      'OR',
      'CONTAINS',
      'DOESNOTCONTAIN',
      'EQUALS',
      'DOESNOTEQUAL',
      'GREATERTHAN',
      'LESSTHAN',
      'STARTSWITH',
      'ENDSWITH',
      'MATCHES',
      'DOESNOTMATCH',
      'EXISTS',
      'DOESNOTEXIST',
      'EQUALTO',
      'NOTEQUALTO',
      'COOKIE',
      'VAR',
      'GVAR',
    ];

    return parameters.contains(token.toUpperCase());
  }

  /// Parse a complete statement and return structured data
  static Map<String, dynamic> parseStatement(String statement) {
    final cmdId = parseCmdId(statement);
    final arguments = extractArguments(statement, cmdId);

    return {
      'cmdId': cmdId,
      'arguments': arguments,
      'fullStatement': statement.trim(),
    };
  }

  /// Consume a token from the input and return the remaining string
  static String consumeToken(String input, String token) {
    final trimmed = input.trim();
    if (trimmed.toUpperCase().startsWith(token.toUpperCase())) {
      return trimmed.substring(token.length).trim();
    }
    return trimmed;
  }
}
