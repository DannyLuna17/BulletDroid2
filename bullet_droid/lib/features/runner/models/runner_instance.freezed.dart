// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'runner_instance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RunnerInstance _$RunnerInstanceFromJson(Map<String, dynamic> json) {
  return _RunnerInstance.fromJson(json);
}

/// @nodoc
mixin _$RunnerInstance {
  String get runnerId => throw _privateConstructorUsedError;
  String? get jobId => throw _privateConstructorUsedError;
  bool get isRunning => throw _privateConstructorUsedError;
  bool get isInitialized =>
      throw _privateConstructorUsedError; // Runner parameters
  String? get selectedConfigId => throw _privateConstructorUsedError;
  String? get selectedWordlistId => throw _privateConstructorUsedError;
  String get selectedProxies => throw _privateConstructorUsedError;
  bool get useProxies => throw _privateConstructorUsedError;
  int get startCount => throw _privateConstructorUsedError;
  int get botsCount =>
      throw _privateConstructorUsedError; // Real-time execution data
  List<BotExecutionResult> get botResults => throw _privateConstructorUsedError;
  Map<String, int> get proxyStats => throw _privateConstructorUsedError;
  Map<String, int> get dataStats => throw _privateConstructorUsedError;
  int get currentCpm =>
      throw _privateConstructorUsedError; // Lifecycle tracking
  DateTime get lastActivity => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  JobProgress? get currentJobProgress => throw _privateConstructorUsedError;
  JobProgress? get finalJobProgress => throw _privateConstructorUsedError;

  /// Serializes this RunnerInstance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RunnerInstance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RunnerInstanceCopyWith<RunnerInstance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RunnerInstanceCopyWith<$Res> {
  factory $RunnerInstanceCopyWith(
          RunnerInstance value, $Res Function(RunnerInstance) then) =
      _$RunnerInstanceCopyWithImpl<$Res, RunnerInstance>;
  @useResult
  $Res call(
      {String runnerId,
      String? jobId,
      bool isRunning,
      bool isInitialized,
      String? selectedConfigId,
      String? selectedWordlistId,
      String selectedProxies,
      bool useProxies,
      int startCount,
      int botsCount,
      List<BotExecutionResult> botResults,
      Map<String, int> proxyStats,
      Map<String, int> dataStats,
      int currentCpm,
      DateTime lastActivity,
      String? error,
      JobProgress? currentJobProgress,
      JobProgress? finalJobProgress});

  $JobProgressCopyWith<$Res>? get currentJobProgress;
  $JobProgressCopyWith<$Res>? get finalJobProgress;
}

/// @nodoc
class _$RunnerInstanceCopyWithImpl<$Res, $Val extends RunnerInstance>
    implements $RunnerInstanceCopyWith<$Res> {
  _$RunnerInstanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RunnerInstance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? runnerId = null,
    Object? jobId = freezed,
    Object? isRunning = null,
    Object? isInitialized = null,
    Object? selectedConfigId = freezed,
    Object? selectedWordlistId = freezed,
    Object? selectedProxies = null,
    Object? useProxies = null,
    Object? startCount = null,
    Object? botsCount = null,
    Object? botResults = null,
    Object? proxyStats = null,
    Object? dataStats = null,
    Object? currentCpm = null,
    Object? lastActivity = null,
    Object? error = freezed,
    Object? currentJobProgress = freezed,
    Object? finalJobProgress = freezed,
  }) {
    return _then(_value.copyWith(
      runnerId: null == runnerId
          ? _value.runnerId
          : runnerId // ignore: cast_nullable_to_non_nullable
              as String,
      jobId: freezed == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String?,
      isRunning: null == isRunning
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedConfigId: freezed == selectedConfigId
          ? _value.selectedConfigId
          : selectedConfigId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedWordlistId: freezed == selectedWordlistId
          ? _value.selectedWordlistId
          : selectedWordlistId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedProxies: null == selectedProxies
          ? _value.selectedProxies
          : selectedProxies // ignore: cast_nullable_to_non_nullable
              as String,
      useProxies: null == useProxies
          ? _value.useProxies
          : useProxies // ignore: cast_nullable_to_non_nullable
              as bool,
      startCount: null == startCount
          ? _value.startCount
          : startCount // ignore: cast_nullable_to_non_nullable
              as int,
      botsCount: null == botsCount
          ? _value.botsCount
          : botsCount // ignore: cast_nullable_to_non_nullable
              as int,
      botResults: null == botResults
          ? _value.botResults
          : botResults // ignore: cast_nullable_to_non_nullable
              as List<BotExecutionResult>,
      proxyStats: null == proxyStats
          ? _value.proxyStats
          : proxyStats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      dataStats: null == dataStats
          ? _value.dataStats
          : dataStats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      currentCpm: null == currentCpm
          ? _value.currentCpm
          : currentCpm // ignore: cast_nullable_to_non_nullable
              as int,
      lastActivity: null == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentJobProgress: freezed == currentJobProgress
          ? _value.currentJobProgress
          : currentJobProgress // ignore: cast_nullable_to_non_nullable
              as JobProgress?,
      finalJobProgress: freezed == finalJobProgress
          ? _value.finalJobProgress
          : finalJobProgress // ignore: cast_nullable_to_non_nullable
              as JobProgress?,
    ) as $Val);
  }

  /// Create a copy of RunnerInstance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $JobProgressCopyWith<$Res>? get currentJobProgress {
    if (_value.currentJobProgress == null) {
      return null;
    }

    return $JobProgressCopyWith<$Res>(_value.currentJobProgress!, (value) {
      return _then(_value.copyWith(currentJobProgress: value) as $Val);
    });
  }

  /// Create a copy of RunnerInstance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $JobProgressCopyWith<$Res>? get finalJobProgress {
    if (_value.finalJobProgress == null) {
      return null;
    }

    return $JobProgressCopyWith<$Res>(_value.finalJobProgress!, (value) {
      return _then(_value.copyWith(finalJobProgress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RunnerInstanceImplCopyWith<$Res>
    implements $RunnerInstanceCopyWith<$Res> {
  factory _$$RunnerInstanceImplCopyWith(_$RunnerInstanceImpl value,
          $Res Function(_$RunnerInstanceImpl) then) =
      __$$RunnerInstanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String runnerId,
      String? jobId,
      bool isRunning,
      bool isInitialized,
      String? selectedConfigId,
      String? selectedWordlistId,
      String selectedProxies,
      bool useProxies,
      int startCount,
      int botsCount,
      List<BotExecutionResult> botResults,
      Map<String, int> proxyStats,
      Map<String, int> dataStats,
      int currentCpm,
      DateTime lastActivity,
      String? error,
      JobProgress? currentJobProgress,
      JobProgress? finalJobProgress});

  @override
  $JobProgressCopyWith<$Res>? get currentJobProgress;
  @override
  $JobProgressCopyWith<$Res>? get finalJobProgress;
}

/// @nodoc
class __$$RunnerInstanceImplCopyWithImpl<$Res>
    extends _$RunnerInstanceCopyWithImpl<$Res, _$RunnerInstanceImpl>
    implements _$$RunnerInstanceImplCopyWith<$Res> {
  __$$RunnerInstanceImplCopyWithImpl(
      _$RunnerInstanceImpl _value, $Res Function(_$RunnerInstanceImpl) _then)
      : super(_value, _then);

  /// Create a copy of RunnerInstance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? runnerId = null,
    Object? jobId = freezed,
    Object? isRunning = null,
    Object? isInitialized = null,
    Object? selectedConfigId = freezed,
    Object? selectedWordlistId = freezed,
    Object? selectedProxies = null,
    Object? useProxies = null,
    Object? startCount = null,
    Object? botsCount = null,
    Object? botResults = null,
    Object? proxyStats = null,
    Object? dataStats = null,
    Object? currentCpm = null,
    Object? lastActivity = null,
    Object? error = freezed,
    Object? currentJobProgress = freezed,
    Object? finalJobProgress = freezed,
  }) {
    return _then(_$RunnerInstanceImpl(
      runnerId: null == runnerId
          ? _value.runnerId
          : runnerId // ignore: cast_nullable_to_non_nullable
              as String,
      jobId: freezed == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String?,
      isRunning: null == isRunning
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedConfigId: freezed == selectedConfigId
          ? _value.selectedConfigId
          : selectedConfigId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedWordlistId: freezed == selectedWordlistId
          ? _value.selectedWordlistId
          : selectedWordlistId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedProxies: null == selectedProxies
          ? _value.selectedProxies
          : selectedProxies // ignore: cast_nullable_to_non_nullable
              as String,
      useProxies: null == useProxies
          ? _value.useProxies
          : useProxies // ignore: cast_nullable_to_non_nullable
              as bool,
      startCount: null == startCount
          ? _value.startCount
          : startCount // ignore: cast_nullable_to_non_nullable
              as int,
      botsCount: null == botsCount
          ? _value.botsCount
          : botsCount // ignore: cast_nullable_to_non_nullable
              as int,
      botResults: null == botResults
          ? _value._botResults
          : botResults // ignore: cast_nullable_to_non_nullable
              as List<BotExecutionResult>,
      proxyStats: null == proxyStats
          ? _value._proxyStats
          : proxyStats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      dataStats: null == dataStats
          ? _value._dataStats
          : dataStats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      currentCpm: null == currentCpm
          ? _value.currentCpm
          : currentCpm // ignore: cast_nullable_to_non_nullable
              as int,
      lastActivity: null == lastActivity
          ? _value.lastActivity
          : lastActivity // ignore: cast_nullable_to_non_nullable
              as DateTime,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      currentJobProgress: freezed == currentJobProgress
          ? _value.currentJobProgress
          : currentJobProgress // ignore: cast_nullable_to_non_nullable
              as JobProgress?,
      finalJobProgress: freezed == finalJobProgress
          ? _value.finalJobProgress
          : finalJobProgress // ignore: cast_nullable_to_non_nullable
              as JobProgress?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RunnerInstanceImpl implements _RunnerInstance {
  const _$RunnerInstanceImpl(
      {required this.runnerId,
      this.jobId,
      this.isRunning = false,
      this.isInitialized = false,
      this.selectedConfigId,
      this.selectedWordlistId,
      this.selectedProxies = 'Default',
      this.useProxies = false,
      this.startCount = 1,
      this.botsCount = 1,
      final List<BotExecutionResult> botResults = const [],
      final Map<String, int> proxyStats = const {
        'untested': 0,
        'good': 0,
        'bad': 0,
        'banned': 0
      },
      final Map<String, int> dataStats = const {
        'pending': 0,
        'success': 0,
        'custom': 0,
        'failed': 0,
        'tocheck': 0,
        'retry': 0
      },
      this.currentCpm = 0,
      required this.lastActivity,
      this.error,
      this.currentJobProgress,
      this.finalJobProgress})
      : _botResults = botResults,
        _proxyStats = proxyStats,
        _dataStats = dataStats;

  factory _$RunnerInstanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$RunnerInstanceImplFromJson(json);

  @override
  final String runnerId;
  @override
  final String? jobId;
  @override
  @JsonKey()
  final bool isRunning;
  @override
  @JsonKey()
  final bool isInitialized;
// Runner parameters
  @override
  final String? selectedConfigId;
  @override
  final String? selectedWordlistId;
  @override
  @JsonKey()
  final String selectedProxies;
  @override
  @JsonKey()
  final bool useProxies;
  @override
  @JsonKey()
  final int startCount;
  @override
  @JsonKey()
  final int botsCount;
// Real-time execution data
  final List<BotExecutionResult> _botResults;
// Real-time execution data
  @override
  @JsonKey()
  List<BotExecutionResult> get botResults {
    if (_botResults is EqualUnmodifiableListView) return _botResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_botResults);
  }

  final Map<String, int> _proxyStats;
  @override
  @JsonKey()
  Map<String, int> get proxyStats {
    if (_proxyStats is EqualUnmodifiableMapView) return _proxyStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_proxyStats);
  }

  final Map<String, int> _dataStats;
  @override
  @JsonKey()
  Map<String, int> get dataStats {
    if (_dataStats is EqualUnmodifiableMapView) return _dataStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dataStats);
  }

  @override
  @JsonKey()
  final int currentCpm;
// Lifecycle tracking
  @override
  final DateTime lastActivity;
  @override
  final String? error;
  @override
  final JobProgress? currentJobProgress;
  @override
  final JobProgress? finalJobProgress;

  @override
  String toString() {
    return 'RunnerInstance(runnerId: $runnerId, jobId: $jobId, isRunning: $isRunning, isInitialized: $isInitialized, selectedConfigId: $selectedConfigId, selectedWordlistId: $selectedWordlistId, selectedProxies: $selectedProxies, useProxies: $useProxies, startCount: $startCount, botsCount: $botsCount, botResults: $botResults, proxyStats: $proxyStats, dataStats: $dataStats, currentCpm: $currentCpm, lastActivity: $lastActivity, error: $error, currentJobProgress: $currentJobProgress, finalJobProgress: $finalJobProgress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RunnerInstanceImpl &&
            (identical(other.runnerId, runnerId) ||
                other.runnerId == runnerId) &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.isRunning, isRunning) ||
                other.isRunning == isRunning) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.selectedConfigId, selectedConfigId) ||
                other.selectedConfigId == selectedConfigId) &&
            (identical(other.selectedWordlistId, selectedWordlistId) ||
                other.selectedWordlistId == selectedWordlistId) &&
            (identical(other.selectedProxies, selectedProxies) ||
                other.selectedProxies == selectedProxies) &&
            (identical(other.useProxies, useProxies) ||
                other.useProxies == useProxies) &&
            (identical(other.startCount, startCount) ||
                other.startCount == startCount) &&
            (identical(other.botsCount, botsCount) ||
                other.botsCount == botsCount) &&
            const DeepCollectionEquality()
                .equals(other._botResults, _botResults) &&
            const DeepCollectionEquality()
                .equals(other._proxyStats, _proxyStats) &&
            const DeepCollectionEquality()
                .equals(other._dataStats, _dataStats) &&
            (identical(other.currentCpm, currentCpm) ||
                other.currentCpm == currentCpm) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.currentJobProgress, currentJobProgress) ||
                other.currentJobProgress == currentJobProgress) &&
            (identical(other.finalJobProgress, finalJobProgress) ||
                other.finalJobProgress == finalJobProgress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      runnerId,
      jobId,
      isRunning,
      isInitialized,
      selectedConfigId,
      selectedWordlistId,
      selectedProxies,
      useProxies,
      startCount,
      botsCount,
      const DeepCollectionEquality().hash(_botResults),
      const DeepCollectionEquality().hash(_proxyStats),
      const DeepCollectionEquality().hash(_dataStats),
      currentCpm,
      lastActivity,
      error,
      currentJobProgress,
      finalJobProgress);

  /// Create a copy of RunnerInstance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RunnerInstanceImplCopyWith<_$RunnerInstanceImpl> get copyWith =>
      __$$RunnerInstanceImplCopyWithImpl<_$RunnerInstanceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RunnerInstanceImplToJson(
      this,
    );
  }
}

abstract class _RunnerInstance implements RunnerInstance {
  const factory _RunnerInstance(
      {required final String runnerId,
      final String? jobId,
      final bool isRunning,
      final bool isInitialized,
      final String? selectedConfigId,
      final String? selectedWordlistId,
      final String selectedProxies,
      final bool useProxies,
      final int startCount,
      final int botsCount,
      final List<BotExecutionResult> botResults,
      final Map<String, int> proxyStats,
      final Map<String, int> dataStats,
      final int currentCpm,
      required final DateTime lastActivity,
      final String? error,
      final JobProgress? currentJobProgress,
      final JobProgress? finalJobProgress}) = _$RunnerInstanceImpl;

  factory _RunnerInstance.fromJson(Map<String, dynamic> json) =
      _$RunnerInstanceImpl.fromJson;

  @override
  String get runnerId;
  @override
  String? get jobId;
  @override
  bool get isRunning;
  @override
  bool get isInitialized; // Runner parameters
  @override
  String? get selectedConfigId;
  @override
  String? get selectedWordlistId;
  @override
  String get selectedProxies;
  @override
  bool get useProxies;
  @override
  int get startCount;
  @override
  int get botsCount; // Real-time execution data
  @override
  List<BotExecutionResult> get botResults;
  @override
  Map<String, int> get proxyStats;
  @override
  Map<String, int> get dataStats;
  @override
  int get currentCpm; // Lifecycle tracking
  @override
  DateTime get lastActivity;
  @override
  String? get error;
  @override
  JobProgress? get currentJobProgress;
  @override
  JobProgress? get finalJobProgress;

  /// Create a copy of RunnerInstance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RunnerInstanceImplCopyWith<_$RunnerInstanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
