import '../variables/variable_pool.dart';
import '../variables/variable.dart';
import 'status.dart';
import 'app_configuration.dart';
import 'config_settings.dart';

enum LogLevel { DEBUG, INFO, WARNING, ERROR }

class BotData {
  static final Map<String, Variable> globalVariables = {};
  static final Map<String, String> globalCookies = {};

  String input;
  VariablePool variables;
  Proxy? proxy;
  BotStatus status;
  String responseSource;
  String address;
  int responseCode;
  Map<String, String> cookies;
  Map<String, String> headers;
  int timeout;
  bool useProxy;
  bool debugMode;
  String? customStatus;
  List<LogEntry> logs;
  ConfigSettings? configSettings;
  bool proxyBanned = false;

  BotData({
    required this.input,
    VariablePool? variables,
    this.proxy,
    this.status = BotStatus.NONE,
    this.responseSource = '',
    this.address = '',
    this.responseCode = 0,
    Map<String, String>? cookies,
    Map<String, String>? headers,
    int? timeout,
    this.useProxy = false,
    bool? debugMode,
    this.customStatus,
  })  : variables = variables ?? VariablePool(),
        cookies = cookies ?? {},
        headers = headers ?? {},
        logs = [],
        timeout = timeout ?? AppConfiguration.httpTimeout,
        debugMode = debugMode ?? AppConfiguration.debugMode {
    this.variables.set(StringVariable('input', input));

    if (input.contains(':')) {
      final parts = input.split(':');
      if (parts.length >= 2) {
        this.variables.set(StringVariable('USER', parts[0]));
        this.variables.set(StringVariable('PASS', parts.sublist(1).join(':')));
        this.variables.set(StringVariable('USERNAME', parts[0]));
        this
            .variables
            .set(StringVariable('PASSWORD', parts.sublist(1).join(':')));
      }
    }
  }

  void log(String message, [String? color]) {
    _addLog(LogLevel.INFO, message);
  }

  void logDebug(String message) {
    if (debugMode) {
      _addLog(LogLevel.DEBUG, message);
    }
  }

  void logWarning(String message) {
    _addLog(LogLevel.WARNING, message);
  }

  void logError(String message) {
    _addLog(LogLevel.ERROR, message);
  }

  void logObject(dynamic obj, [String? color]) {
    log(obj.toString(), color);
  }

  void _addLog(LogLevel level, String message) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
    );
    logs.add(entry);

    if (AppConfiguration.debugMode) {
      final prefix = _getLevelPrefix(level);
      // ignore: avoid_print
      print('$prefix[${entry.timestamp}] $message');
    }
  }

  String _getLevelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.DEBUG:
        return '[DEBUG] ';
      case LogLevel.INFO:
        return '[INFO]  ';
      case LogLevel.WARNING:
        return '[WARN]  ';
      case LogLevel.ERROR:
        return '[ERROR] ';
    }
  }

  List<LogEntry> getLogsByLevel(LogLevel level) {
    return logs.where((log) => log.level == level).toList();
  }

  String getLogsAsString() {
    return logs
        .map((log) =>
            '${_getLevelPrefix(log.level)}[${log.timestamp}] ${log.message}')
        .join('\n');
  }

  Map<String, dynamic> toJson() {
    return {
      'input': input,
      'status': status.toString(),
      'responseSource': responseSource,
      'address': address,
      'responseCode': responseCode,
      'cookies': cookies,
      'headers': headers,
      'timeout': timeout,
      'useProxy': useProxy,
      'capturedVariables': variables.getCapturedValues(),
      'logs': logs.map((log) => log.toJson()).toList(),
    };
  }
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.toString(),
      'message': message,
    };
  }
}

class Proxy {
  String host;
  int port;
  ProxyType type;
  String? username;
  String? password;

  Proxy({
    required this.host,
    required this.port,
    required this.type,
    this.username,
    this.password,
  });

  bool get needsAuthentication => username != null && password != null;

  @override
  String toString() {
    return '$host:$port';
  }
}

enum ProxyType {
  HTTP,
  SOCKS4,
  SOCKS5,
}
