/// Application configuration
class AppConfiguration {
  static bool debugMode = false;
  static String logLevel = 'INFO';

  // Timeouts
  static int defaultTimeout = 30000;
  static int blockTimeout = 20000;
  static int httpTimeout = 20000;

  // Execution settings
  static int maxConcurrency = 10;
  static int maxLoopIterations = 1000;

  // HTTP settings
  static String defaultUserAgent = 'LunaLib/1.0.0';
  static bool followRedirects = true;
  static int maxRedirects = 10;

  // Feature flags
  static bool enableCustomInputs = true;
  static bool safeMode = false;
  static bool allowFileAccess = true;
  static bool allowNetworkAccess = true;

  // Performance settings
  static int memoryLimitMB = 4096;
  static int cacheSize = 1024;
  static bool enableCaching = true;

  // Logging settings
  static bool logToFile = false;
  static String logFilePath = 'logs/LunaLib.log';
  static int logMaxSizeMB = 10;
  static int logRotationCount = 5;

  /// Constructor for setting multiple values at once
  AppConfiguration({
    bool? debugMode,
    String? logLevel,
    int? defaultTimeout,
    int? blockTimeout,
    int? httpTimeout,
    int? maxConcurrency,
    int? maxLoopIterations,
    String? defaultUserAgent,
    bool? followRedirects,
    int? maxRedirects,
    bool? enableCustomInputs,
    bool? safeMode,
    bool? allowFileAccess,
    bool? allowNetworkAccess,
    int? memoryLimitMB,
    int? cacheSize,
    bool? enableCaching,
    bool? logToFile,
    String? logFilePath,
    int? logMaxSizeMB,
    int? logRotationCount,
  }) {
    if (debugMode != null) AppConfiguration.debugMode = debugMode;
    if (logLevel != null) AppConfiguration.logLevel = logLevel;
    if (defaultTimeout != null)
      AppConfiguration.defaultTimeout = defaultTimeout;
    if (blockTimeout != null) AppConfiguration.blockTimeout = blockTimeout;
    if (httpTimeout != null) AppConfiguration.httpTimeout = httpTimeout;
    if (maxConcurrency != null)
      AppConfiguration.maxConcurrency = maxConcurrency;
    if (maxLoopIterations != null)
      AppConfiguration.maxLoopIterations = maxLoopIterations;
    if (defaultUserAgent != null)
      AppConfiguration.defaultUserAgent = defaultUserAgent;
    if (followRedirects != null)
      AppConfiguration.followRedirects = followRedirects;
    if (maxRedirects != null) AppConfiguration.maxRedirects = maxRedirects;
    if (enableCustomInputs != null)
      AppConfiguration.enableCustomInputs = enableCustomInputs;
    if (safeMode != null) AppConfiguration.safeMode = safeMode;
    if (allowFileAccess != null)
      AppConfiguration.allowFileAccess = allowFileAccess;
    if (allowNetworkAccess != null)
      AppConfiguration.allowNetworkAccess = allowNetworkAccess;
    if (memoryLimitMB != null) AppConfiguration.memoryLimitMB = memoryLimitMB;
    if (cacheSize != null) AppConfiguration.cacheSize = cacheSize;
    if (enableCaching != null) AppConfiguration.enableCaching = enableCaching;
    if (logToFile != null) AppConfiguration.logToFile = logToFile;
    if (logFilePath != null) AppConfiguration.logFilePath = logFilePath;
    if (logMaxSizeMB != null) AppConfiguration.logMaxSizeMB = logMaxSizeMB;
    if (logRotationCount != null)
      AppConfiguration.logRotationCount = logRotationCount;
  }

  /// Reset all settings to defaults
  static void resetToDefaults() {
    debugMode = false;
    logLevel = 'INFO';
    defaultTimeout = 30000;
    blockTimeout = 10000;
    httpTimeout = 10000;
    maxConcurrency = 10;
    maxLoopIterations = 1000;
    defaultUserAgent = 'LunaLib/1.0.0';
    followRedirects = true;
    maxRedirects = 5;
    enableCustomInputs = false;
    safeMode = false;
    allowFileAccess = true;
    allowNetworkAccess = true;
    memoryLimitMB = 512;
    cacheSize = 1000;
    enableCaching = true;
    logToFile = false;
    logFilePath = 'logs/LunaLib.log';
    logMaxSizeMB = 10;
    logRotationCount = 5;
  }

  /// Get current configuration as a map
  static Map<String, dynamic> toMap() {
    return {
      'debugMode': debugMode,
      'logLevel': logLevel,
      'defaultTimeout': defaultTimeout,
      'blockTimeout': blockTimeout,
      'httpTimeout': httpTimeout,
      'maxConcurrency': maxConcurrency,
      'maxLoopIterations': maxLoopIterations,
      'defaultUserAgent': defaultUserAgent,
      'followRedirects': followRedirects,
      'maxRedirects': maxRedirects,
      'enableCustomInputs': enableCustomInputs,
      'safeMode': safeMode,
      'allowFileAccess': allowFileAccess,
      'allowNetworkAccess': allowNetworkAccess,
      'memoryLimitMB': memoryLimitMB,
      'cacheSize': cacheSize,
      'enableCaching': enableCaching,
      'logToFile': logToFile,
      'logFilePath': logFilePath,
      'logMaxSizeMB': logMaxSizeMB,
      'logRotationCount': logRotationCount,
    };
  }

  /// Load configuration from a map
  static void fromMap(Map<String, dynamic> map) {
    debugMode = map['debugMode'] ?? debugMode;
    logLevel = map['logLevel'] ?? logLevel;
    defaultTimeout = map['defaultTimeout'] ?? defaultTimeout;
    blockTimeout = map['blockTimeout'] ?? blockTimeout;
    httpTimeout = map['httpTimeout'] ?? httpTimeout;
    maxConcurrency = map['maxConcurrency'] ?? maxConcurrency;
    maxLoopIterations = map['maxLoopIterations'] ?? maxLoopIterations;
    defaultUserAgent = map['defaultUserAgent'] ?? defaultUserAgent;
    followRedirects = map['followRedirects'] ?? followRedirects;
    maxRedirects = map['maxRedirects'] ?? maxRedirects;
    enableCustomInputs = map['enableCustomInputs'] ?? enableCustomInputs;
    safeMode = map['safeMode'] ?? safeMode;
    allowFileAccess = map['allowFileAccess'] ?? allowFileAccess;
    allowNetworkAccess = map['allowNetworkAccess'] ?? allowNetworkAccess;
    memoryLimitMB = map['memoryLimitMB'] ?? memoryLimitMB;
    cacheSize = map['cacheSize'] ?? cacheSize;
    enableCaching = map['enableCaching'] ?? enableCaching;
    logToFile = map['logToFile'] ?? logToFile;
    logFilePath = map['logFilePath'] ?? logFilePath;
    logMaxSizeMB = map['logMaxSizeMB'] ?? logMaxSizeMB;
    logRotationCount = map['logRotationCount'] ?? logRotationCount;
  }
}
