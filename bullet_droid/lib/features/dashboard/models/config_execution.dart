class ConfigExecution {
  final String id;
  final String configId;
  final String configName;
  final int totalBots;
  final int processedBots;
  final int totalData;
  final int processedData;
  final int cpm;
  final int good;
  final int custom;
  final int bad;
  final int toCheck;
  final bool isRunning;
  final bool isPlaceholder;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? runnerId;
  final bool isConfigured;
  final String? validationError;
  final String? selectedWordlistId;

  ConfigExecution({
    required this.id,
    required this.configId,
    required this.configName,
    required this.totalBots,
    required this.processedBots,
    required this.totalData,
    required this.processedData,
    required this.cpm,
    required this.good,
    required this.custom,
    required this.bad,
    required this.toCheck,
    required this.isRunning,
    this.isPlaceholder = false,
    this.startTime,
    this.endTime,
    this.runnerId,
    this.isConfigured = false,
    this.validationError,
    this.selectedWordlistId,
  });

  double get progressPercentage {
    if (totalData == 0) return 0;
    return (processedData / totalData) * 100;
  }

  String get progressFraction => '$processedData/$totalData';

  String get progressPercentageString =>
      '${progressPercentage.toStringAsFixed(0)}%';

  ConfigExecution copyWith({
    String? id,
    String? configId,
    String? configName,
    int? totalBots,
    int? processedBots,
    int? totalData,
    int? processedData,
    int? cpm,
    int? good,
    int? custom,
    int? bad,
    int? toCheck,
    bool? isRunning,
    bool? isPlaceholder,
    DateTime? startTime,
    DateTime? endTime,
    String? runnerId,
    bool? isConfigured,
    String? validationError,
    String? selectedWordlistId,
  }) {
    return ConfigExecution(
      id: id ?? this.id,
      configId: configId ?? this.configId,
      configName: configName ?? this.configName,
      totalBots: totalBots ?? this.totalBots,
      processedBots: processedBots ?? this.processedBots,
      totalData: totalData ?? this.totalData,
      processedData: processedData ?? this.processedData,
      cpm: cpm ?? this.cpm,
      good: good ?? this.good,
      custom: custom ?? this.custom,
      bad: bad ?? this.bad,
      toCheck: toCheck ?? this.toCheck,
      isRunning: isRunning ?? this.isRunning,
      isPlaceholder: isPlaceholder ?? this.isPlaceholder,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      runnerId: runnerId ?? this.runnerId,
      isConfigured: isConfigured ?? this.isConfigured,
      validationError: validationError ?? this.validationError,
      selectedWordlistId: selectedWordlistId ?? this.selectedWordlistId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'configId': configId,
      'configName': configName,
      'totalBots': totalBots,
      'processedBots': processedBots,
      'totalData': totalData,
      'processedData': processedData,
      'cpm': cpm,
      'good': good,
      'custom': custom,
      'bad': bad,
      'toCheck': toCheck,
      'isRunning': isRunning,
      'isPlaceholder': isPlaceholder,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'runnerId': runnerId,
      'isConfigured': isConfigured,
      'validationError': validationError,
      'selectedWordlistId': selectedWordlistId,
    };
  }

  factory ConfigExecution.fromJson(Map<String, dynamic> json) {
    return ConfigExecution(
      id: json['id'] as String,
      configId: json['configId'] as String,
      configName: json['configName'] as String,
      totalBots: json['totalBots'] as int,
      processedBots: json['processedBots'] as int,
      totalData: json['totalData'] as int,
      processedData: json['processedData'] as int,
      cpm: json['cpm'] as int,
      good: json['good'] as int,
      custom: json['custom'] as int,
      bad: json['bad'] as int,
      toCheck: json['toCheck'] as int,
      isRunning: json['isRunning'] as bool,
      isPlaceholder: json['isPlaceholder'] as bool? ?? false,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      runnerId: json['runnerId'] as String?,
      isConfigured: json['isConfigured'] as bool? ?? false,
      validationError: json['validationError'] as String?,
      selectedWordlistId: json['selectedWordlistId'] as String?,
    );
  }
}
