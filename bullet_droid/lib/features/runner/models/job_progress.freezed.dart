// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ValidDataResult _$ValidDataResultFromJson(Map<String, dynamic> json) {
  return _ValidDataResult.fromJson(json);
}

/// @nodoc
mixin _$ValidDataResult {
  String get data => throw _privateConstructorUsedError;
  BotStatus get status => throw _privateConstructorUsedError;
  DateTime get completionTime => throw _privateConstructorUsedError;
  String? get proxy => throw _privateConstructorUsedError;
  Map<String, String>? get captures => throw _privateConstructorUsedError;
  String? get customStatus => throw _privateConstructorUsedError;

  /// Serializes this ValidDataResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ValidDataResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ValidDataResultCopyWith<ValidDataResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidDataResultCopyWith<$Res> {
  factory $ValidDataResultCopyWith(
          ValidDataResult value, $Res Function(ValidDataResult) then) =
      _$ValidDataResultCopyWithImpl<$Res, ValidDataResult>;
  @useResult
  $Res call(
      {String data,
      BotStatus status,
      DateTime completionTime,
      String? proxy,
      Map<String, String>? captures,
      String? customStatus});
}

/// @nodoc
class _$ValidDataResultCopyWithImpl<$Res, $Val extends ValidDataResult>
    implements $ValidDataResultCopyWith<$Res> {
  _$ValidDataResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ValidDataResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? status = null,
    Object? completionTime = null,
    Object? proxy = freezed,
    Object? captures = freezed,
    Object? customStatus = freezed,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BotStatus,
      completionTime: null == completionTime
          ? _value.completionTime
          : completionTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      proxy: freezed == proxy
          ? _value.proxy
          : proxy // ignore: cast_nullable_to_non_nullable
              as String?,
      captures: freezed == captures
          ? _value.captures
          : captures // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      customStatus: freezed == customStatus
          ? _value.customStatus
          : customStatus // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ValidDataResultImplCopyWith<$Res>
    implements $ValidDataResultCopyWith<$Res> {
  factory _$$ValidDataResultImplCopyWith(_$ValidDataResultImpl value,
          $Res Function(_$ValidDataResultImpl) then) =
      __$$ValidDataResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String data,
      BotStatus status,
      DateTime completionTime,
      String? proxy,
      Map<String, String>? captures,
      String? customStatus});
}

/// @nodoc
class __$$ValidDataResultImplCopyWithImpl<$Res>
    extends _$ValidDataResultCopyWithImpl<$Res, _$ValidDataResultImpl>
    implements _$$ValidDataResultImplCopyWith<$Res> {
  __$$ValidDataResultImplCopyWithImpl(
      _$ValidDataResultImpl _value, $Res Function(_$ValidDataResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of ValidDataResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? status = null,
    Object? completionTime = null,
    Object? proxy = freezed,
    Object? captures = freezed,
    Object? customStatus = freezed,
  }) {
    return _then(_$ValidDataResultImpl(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BotStatus,
      completionTime: null == completionTime
          ? _value.completionTime
          : completionTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      proxy: freezed == proxy
          ? _value.proxy
          : proxy // ignore: cast_nullable_to_non_nullable
              as String?,
      captures: freezed == captures
          ? _value._captures
          : captures // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      customStatus: freezed == customStatus
          ? _value.customStatus
          : customStatus // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidDataResultImpl implements _ValidDataResult {
  const _$ValidDataResultImpl(
      {required this.data,
      required this.status,
      required this.completionTime,
      this.proxy,
      final Map<String, String>? captures,
      this.customStatus})
      : _captures = captures;

  factory _$ValidDataResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ValidDataResultImplFromJson(json);

  @override
  final String data;
  @override
  final BotStatus status;
  @override
  final DateTime completionTime;
  @override
  final String? proxy;
  final Map<String, String>? _captures;
  @override
  Map<String, String>? get captures {
    final value = _captures;
    if (value == null) return null;
    if (_captures is EqualUnmodifiableMapView) return _captures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? customStatus;

  @override
  String toString() {
    return 'ValidDataResult(data: $data, status: $status, completionTime: $completionTime, proxy: $proxy, captures: $captures, customStatus: $customStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidDataResultImpl &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.completionTime, completionTime) ||
                other.completionTime == completionTime) &&
            (identical(other.proxy, proxy) || other.proxy == proxy) &&
            const DeepCollectionEquality().equals(other._captures, _captures) &&
            (identical(other.customStatus, customStatus) ||
                other.customStatus == customStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, data, status, completionTime,
      proxy, const DeepCollectionEquality().hash(_captures), customStatus);

  /// Create a copy of ValidDataResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidDataResultImplCopyWith<_$ValidDataResultImpl> get copyWith =>
      __$$ValidDataResultImplCopyWithImpl<_$ValidDataResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidDataResultImplToJson(
      this,
    );
  }
}

abstract class _ValidDataResult implements ValidDataResult {
  const factory _ValidDataResult(
      {required final String data,
      required final BotStatus status,
      required final DateTime completionTime,
      final String? proxy,
      final Map<String, String>? captures,
      final String? customStatus}) = _$ValidDataResultImpl;

  factory _ValidDataResult.fromJson(Map<String, dynamic> json) =
      _$ValidDataResultImpl.fromJson;

  @override
  String get data;
  @override
  BotStatus get status;
  @override
  DateTime get completionTime;
  @override
  String? get proxy;
  @override
  Map<String, String>? get captures;
  @override
  String? get customStatus;

  /// Create a copy of ValidDataResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidDataResultImplCopyWith<_$ValidDataResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JobProgress _$JobProgressFromJson(Map<String, dynamic> json) {
  return _JobProgress.fromJson(json);
}

/// @nodoc
mixin _$JobProgress {
  String get jobId => throw _privateConstructorUsedError;
  String? get runnerId => throw _privateConstructorUsedError;
  String get configId => throw _privateConstructorUsedError;
  JobStatus get status => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  int get totalLines => throw _privateConstructorUsedError;
  int get processedLines => throw _privateConstructorUsedError;
  List<ValidDataResult> get hits => throw _privateConstructorUsedError;
  List<ValidDataResult> get fails => throw _privateConstructorUsedError;
  List<ValidDataResult> get customs => throw _privateConstructorUsedError;
  List<ValidDataResult> get toChecks => throw _privateConstructorUsedError;
  int get cpm => throw _privateConstructorUsedError;
  List<BlockExecution> get blockExecutions =>
      throw _privateConstructorUsedError;
  String? get currentBlock => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Map<String, dynamic> get results => throw _privateConstructorUsedError;

  /// Serializes this JobProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JobProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobProgressCopyWith<JobProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobProgressCopyWith<$Res> {
  factory $JobProgressCopyWith(
          JobProgress value, $Res Function(JobProgress) then) =
      _$JobProgressCopyWithImpl<$Res, JobProgress>;
  @useResult
  $Res call(
      {String jobId,
      String? runnerId,
      String configId,
      JobStatus status,
      DateTime startTime,
      DateTime? endTime,
      int totalLines,
      int processedLines,
      List<ValidDataResult> hits,
      List<ValidDataResult> fails,
      List<ValidDataResult> customs,
      List<ValidDataResult> toChecks,
      int cpm,
      List<BlockExecution> blockExecutions,
      String? currentBlock,
      String? error,
      Map<String, dynamic> results});
}

/// @nodoc
class _$JobProgressCopyWithImpl<$Res, $Val extends JobProgress>
    implements $JobProgressCopyWith<$Res> {
  _$JobProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? runnerId = freezed,
    Object? configId = null,
    Object? status = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? totalLines = null,
    Object? processedLines = null,
    Object? hits = null,
    Object? fails = null,
    Object? customs = null,
    Object? toChecks = null,
    Object? cpm = null,
    Object? blockExecutions = null,
    Object? currentBlock = freezed,
    Object? error = freezed,
    Object? results = null,
  }) {
    return _then(_value.copyWith(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      runnerId: freezed == runnerId
          ? _value.runnerId
          : runnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      configId: null == configId
          ? _value.configId
          : configId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as JobStatus,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalLines: null == totalLines
          ? _value.totalLines
          : totalLines // ignore: cast_nullable_to_non_nullable
              as int,
      processedLines: null == processedLines
          ? _value.processedLines
          : processedLines // ignore: cast_nullable_to_non_nullable
              as int,
      hits: null == hits
          ? _value.hits
          : hits // ignore: cast_nullable_to_non_nullable
              as List<ValidDataResult>,
      fails: null == fails
          ? _value.fails
          : fails // ignore: cast_nullable_to_non_nullable
              as List<ValidDataResult>,
      customs: null == customs
          ? _value.customs
          : customs // ignore: cast_nullable_to_non_nullable
              as List<ValidDataResult>,
      toChecks: null == toChecks
          ? _value.toChecks
          : toChecks // ignore: cast_nullable_to_non_nullable
              as List<ValidDataResult>,
      cpm: null == cpm
          ? _value.cpm
          : cpm // ignore: cast_nullable_to_non_nullable
              as int,
      blockExecutions: null == blockExecutions
          ? _value.blockExecutions
          : blockExecutions // ignore: cast_nullable_to_non_nullable
              as List<BlockExecution>,
      currentBlock: freezed == currentBlock
          ? _value.currentBlock
          : currentBlock // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      results: null == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JobProgressImplCopyWith<$Res>
    implements $JobProgressCopyWith<$Res> {
  factory _$$JobProgressImplCopyWith(
          _$JobProgressImpl value, $Res Function(_$JobProgressImpl) then) =
      __$$JobProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String jobId,
      String? runnerId,
      String configId,
      JobStatus status,
      DateTime startTime,
      DateTime? endTime,
      int totalLines,
      int processedLines,
      List<ValidDataResult> hits,
      List<ValidDataResult> fails,
      List<ValidDataResult> customs,
      List<ValidDataResult> toChecks,
      int cpm,
      List<BlockExecution> blockExecutions,
      String? currentBlock,
      String? error,
      Map<String, dynamic> results});
}

/// @nodoc
class __$$JobProgressImplCopyWithImpl<$Res>
    extends _$JobProgressCopyWithImpl<$Res, _$JobProgressImpl>
    implements _$$JobProgressImplCopyWith<$Res> {
  __$$JobProgressImplCopyWithImpl(
      _$JobProgressImpl _value, $Res Function(_$JobProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of JobProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? runnerId = freezed,
    Object? configId = null,
    Object? status = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? totalLines = null,
    Object? processedLines = null,
    Object? hits = null,
    Object? fails = null,
    Object? customs = null,
    Object? toChecks = null,
    Object? cpm = null,
    Object? blockExecutions = null,
    Object? currentBlock = freezed,
    Object? error = freezed,
    Object? results = null,
  }) {
    return _then(_$JobProgressImpl(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      runnerId: freezed == runnerId
          ? _value.runnerId
          : runnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      configId: null == configId
          ? _value.configId
          : configId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as JobStatus,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalLines: null == totalLines
          ? _value.totalLines
          : totalLines // ignore: cast_nullable_to_non_nullable
              as int,
      processedLines: null == processedLines
          ? _value.processedLines
          : processedLines // ignore: cast_nullable_to_non_nullable
              as int,
      hits: null == hits
          ? _value._hits
          : hits // ignore: cast_nullable_to_non_nullable
              as List<ValidDataResult>,
      fails: null == fails
          ? _value._fails
          : fails // ignore: cast_nullable_to_non_nullable
              as List<ValidDataResult>,
      customs: null == customs
          ? _value._customs
          : customs // ignore: cast_nullable_to_non_nullable
              as List<ValidDataResult>,
      toChecks: null == toChecks
          ? _value._toChecks
          : toChecks // ignore: cast_nullable_to_non_nullable
              as List<ValidDataResult>,
      cpm: null == cpm
          ? _value.cpm
          : cpm // ignore: cast_nullable_to_non_nullable
              as int,
      blockExecutions: null == blockExecutions
          ? _value._blockExecutions
          : blockExecutions // ignore: cast_nullable_to_non_nullable
              as List<BlockExecution>,
      currentBlock: freezed == currentBlock
          ? _value.currentBlock
          : currentBlock // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JobProgressImpl implements _JobProgress {
  const _$JobProgressImpl(
      {required this.jobId,
      this.runnerId,
      required this.configId,
      required this.status,
      required this.startTime,
      this.endTime,
      this.totalLines = 0,
      this.processedLines = 0,
      final List<ValidDataResult> hits = const [],
      final List<ValidDataResult> fails = const [],
      final List<ValidDataResult> customs = const [],
      final List<ValidDataResult> toChecks = const [],
      this.cpm = 0,
      final List<BlockExecution> blockExecutions = const [],
      this.currentBlock,
      this.error,
      final Map<String, dynamic> results = const {}})
      : _hits = hits,
        _fails = fails,
        _customs = customs,
        _toChecks = toChecks,
        _blockExecutions = blockExecutions,
        _results = results;

  factory _$JobProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobProgressImplFromJson(json);

  @override
  final String jobId;
  @override
  final String? runnerId;
  @override
  final String configId;
  @override
  final JobStatus status;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  @JsonKey()
  final int totalLines;
  @override
  @JsonKey()
  final int processedLines;
  final List<ValidDataResult> _hits;
  @override
  @JsonKey()
  List<ValidDataResult> get hits {
    if (_hits is EqualUnmodifiableListView) return _hits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hits);
  }

  final List<ValidDataResult> _fails;
  @override
  @JsonKey()
  List<ValidDataResult> get fails {
    if (_fails is EqualUnmodifiableListView) return _fails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fails);
  }

  final List<ValidDataResult> _customs;
  @override
  @JsonKey()
  List<ValidDataResult> get customs {
    if (_customs is EqualUnmodifiableListView) return _customs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customs);
  }

  final List<ValidDataResult> _toChecks;
  @override
  @JsonKey()
  List<ValidDataResult> get toChecks {
    if (_toChecks is EqualUnmodifiableListView) return _toChecks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_toChecks);
  }

  @override
  @JsonKey()
  final int cpm;
  final List<BlockExecution> _blockExecutions;
  @override
  @JsonKey()
  List<BlockExecution> get blockExecutions {
    if (_blockExecutions is EqualUnmodifiableListView) return _blockExecutions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blockExecutions);
  }

  @override
  final String? currentBlock;
  @override
  final String? error;
  final Map<String, dynamic> _results;
  @override
  @JsonKey()
  Map<String, dynamic> get results {
    if (_results is EqualUnmodifiableMapView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_results);
  }

  @override
  String toString() {
    return 'JobProgress(jobId: $jobId, runnerId: $runnerId, configId: $configId, status: $status, startTime: $startTime, endTime: $endTime, totalLines: $totalLines, processedLines: $processedLines, hits: $hits, fails: $fails, customs: $customs, toChecks: $toChecks, cpm: $cpm, blockExecutions: $blockExecutions, currentBlock: $currentBlock, error: $error, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobProgressImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.runnerId, runnerId) ||
                other.runnerId == runnerId) &&
            (identical(other.configId, configId) ||
                other.configId == configId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.totalLines, totalLines) ||
                other.totalLines == totalLines) &&
            (identical(other.processedLines, processedLines) ||
                other.processedLines == processedLines) &&
            const DeepCollectionEquality().equals(other._hits, _hits) &&
            const DeepCollectionEquality().equals(other._fails, _fails) &&
            const DeepCollectionEquality().equals(other._customs, _customs) &&
            const DeepCollectionEquality().equals(other._toChecks, _toChecks) &&
            (identical(other.cpm, cpm) || other.cpm == cpm) &&
            const DeepCollectionEquality()
                .equals(other._blockExecutions, _blockExecutions) &&
            (identical(other.currentBlock, currentBlock) ||
                other.currentBlock == currentBlock) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      jobId,
      runnerId,
      configId,
      status,
      startTime,
      endTime,
      totalLines,
      processedLines,
      const DeepCollectionEquality().hash(_hits),
      const DeepCollectionEquality().hash(_fails),
      const DeepCollectionEquality().hash(_customs),
      const DeepCollectionEquality().hash(_toChecks),
      cpm,
      const DeepCollectionEquality().hash(_blockExecutions),
      currentBlock,
      error,
      const DeepCollectionEquality().hash(_results));

  /// Create a copy of JobProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobProgressImplCopyWith<_$JobProgressImpl> get copyWith =>
      __$$JobProgressImplCopyWithImpl<_$JobProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobProgressImplToJson(
      this,
    );
  }
}

abstract class _JobProgress implements JobProgress {
  const factory _JobProgress(
      {required final String jobId,
      final String? runnerId,
      required final String configId,
      required final JobStatus status,
      required final DateTime startTime,
      final DateTime? endTime,
      final int totalLines,
      final int processedLines,
      final List<ValidDataResult> hits,
      final List<ValidDataResult> fails,
      final List<ValidDataResult> customs,
      final List<ValidDataResult> toChecks,
      final int cpm,
      final List<BlockExecution> blockExecutions,
      final String? currentBlock,
      final String? error,
      final Map<String, dynamic> results}) = _$JobProgressImpl;

  factory _JobProgress.fromJson(Map<String, dynamic> json) =
      _$JobProgressImpl.fromJson;

  @override
  String get jobId;
  @override
  String? get runnerId;
  @override
  String get configId;
  @override
  JobStatus get status;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  int get totalLines;
  @override
  int get processedLines;
  @override
  List<ValidDataResult> get hits;
  @override
  List<ValidDataResult> get fails;
  @override
  List<ValidDataResult> get customs;
  @override
  List<ValidDataResult> get toChecks;
  @override
  int get cpm;
  @override
  List<BlockExecution> get blockExecutions;
  @override
  String? get currentBlock;
  @override
  String? get error;
  @override
  Map<String, dynamic> get results;

  /// Create a copy of JobProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobProgressImplCopyWith<_$JobProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BlockExecution _$BlockExecutionFromJson(Map<String, dynamic> json) {
  return _BlockExecution.fromJson(json);
}

/// @nodoc
mixin _$BlockExecution {
  String get blockName => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;

  /// Serializes this BlockExecution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BlockExecution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlockExecutionCopyWith<BlockExecution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockExecutionCopyWith<$Res> {
  factory $BlockExecutionCopyWith(
          BlockExecution value, $Res Function(BlockExecution) then) =
      _$BlockExecutionCopyWithImpl<$Res, BlockExecution>;
  @useResult
  $Res call(
      {String blockName,
      DateTime startTime,
      DateTime? endTime,
      bool success,
      String? error,
      Map<String, dynamic>? data});
}

/// @nodoc
class _$BlockExecutionCopyWithImpl<$Res, $Val extends BlockExecution>
    implements $BlockExecutionCopyWith<$Res> {
  _$BlockExecutionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlockExecution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? blockName = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? success = null,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      blockName: null == blockName
          ? _value.blockName
          : blockName // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BlockExecutionImplCopyWith<$Res>
    implements $BlockExecutionCopyWith<$Res> {
  factory _$$BlockExecutionImplCopyWith(_$BlockExecutionImpl value,
          $Res Function(_$BlockExecutionImpl) then) =
      __$$BlockExecutionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String blockName,
      DateTime startTime,
      DateTime? endTime,
      bool success,
      String? error,
      Map<String, dynamic>? data});
}

/// @nodoc
class __$$BlockExecutionImplCopyWithImpl<$Res>
    extends _$BlockExecutionCopyWithImpl<$Res, _$BlockExecutionImpl>
    implements _$$BlockExecutionImplCopyWith<$Res> {
  __$$BlockExecutionImplCopyWithImpl(
      _$BlockExecutionImpl _value, $Res Function(_$BlockExecutionImpl) _then)
      : super(_value, _then);

  /// Create a copy of BlockExecution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? blockName = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? success = null,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_$BlockExecutionImpl(
      blockName: null == blockName
          ? _value.blockName
          : blockName // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BlockExecutionImpl implements _BlockExecution {
  const _$BlockExecutionImpl(
      {required this.blockName,
      required this.startTime,
      this.endTime,
      required this.success,
      this.error,
      final Map<String, dynamic>? data})
      : _data = data;

  factory _$BlockExecutionImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlockExecutionImplFromJson(json);

  @override
  final String blockName;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final bool success;
  @override
  final String? error;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'BlockExecution(blockName: $blockName, startTime: $startTime, endTime: $endTime, success: $success, error: $error, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockExecutionImpl &&
            (identical(other.blockName, blockName) ||
                other.blockName == blockName) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, blockName, startTime, endTime,
      success, error, const DeepCollectionEquality().hash(_data));

  /// Create a copy of BlockExecution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockExecutionImplCopyWith<_$BlockExecutionImpl> get copyWith =>
      __$$BlockExecutionImplCopyWithImpl<_$BlockExecutionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BlockExecutionImplToJson(
      this,
    );
  }
}

abstract class _BlockExecution implements BlockExecution {
  const factory _BlockExecution(
      {required final String blockName,
      required final DateTime startTime,
      final DateTime? endTime,
      required final bool success,
      final String? error,
      final Map<String, dynamic>? data}) = _$BlockExecutionImpl;

  factory _BlockExecution.fromJson(Map<String, dynamic> json) =
      _$BlockExecutionImpl.fromJson;

  @override
  String get blockName;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  bool get success;
  @override
  String? get error;
  @override
  Map<String, dynamic>? get data;

  /// Create a copy of BlockExecution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlockExecutionImplCopyWith<_$BlockExecutionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BotExecutionResult _$BotExecutionResultFromJson(Map<String, dynamic> json) {
  return _BotExecutionResult.fromJson(json);
}

/// @nodoc
mixin _$BotExecutionResult {
  int get botId => throw _privateConstructorUsedError;
  String get data => throw _privateConstructorUsedError;
  BotStatus get status => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get proxy => throw _privateConstructorUsedError;
  Duration? get elapsed => throw _privateConstructorUsedError;
  Map<String, String>? get captures => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  int? get retryCount => throw _privateConstructorUsedError;
  String? get customStatus => throw _privateConstructorUsedError;
  String? get currentStatus =>
      throw _privateConstructorUsedError; // Real-time status showing current block being processed
  int? get currentDataIndex => throw _privateConstructorUsedError;

  /// Serializes this BotExecutionResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BotExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BotExecutionResultCopyWith<BotExecutionResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BotExecutionResultCopyWith<$Res> {
  factory $BotExecutionResultCopyWith(
          BotExecutionResult value, $Res Function(BotExecutionResult) then) =
      _$BotExecutionResultCopyWithImpl<$Res, BotExecutionResult>;
  @useResult
  $Res call(
      {int botId,
      String data,
      BotStatus status,
      DateTime timestamp,
      String? proxy,
      Duration? elapsed,
      Map<String, String>? captures,
      String? errorMessage,
      int? retryCount,
      String? customStatus,
      String? currentStatus,
      int? currentDataIndex});
}

/// @nodoc
class _$BotExecutionResultCopyWithImpl<$Res, $Val extends BotExecutionResult>
    implements $BotExecutionResultCopyWith<$Res> {
  _$BotExecutionResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BotExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? botId = null,
    Object? data = null,
    Object? status = null,
    Object? timestamp = null,
    Object? proxy = freezed,
    Object? elapsed = freezed,
    Object? captures = freezed,
    Object? errorMessage = freezed,
    Object? retryCount = freezed,
    Object? customStatus = freezed,
    Object? currentStatus = freezed,
    Object? currentDataIndex = freezed,
  }) {
    return _then(_value.copyWith(
      botId: null == botId
          ? _value.botId
          : botId // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BotStatus,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      proxy: freezed == proxy
          ? _value.proxy
          : proxy // ignore: cast_nullable_to_non_nullable
              as String?,
      elapsed: freezed == elapsed
          ? _value.elapsed
          : elapsed // ignore: cast_nullable_to_non_nullable
              as Duration?,
      captures: freezed == captures
          ? _value.captures
          : captures // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      retryCount: freezed == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int?,
      customStatus: freezed == customStatus
          ? _value.customStatus
          : customStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      currentStatus: freezed == currentStatus
          ? _value.currentStatus
          : currentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      currentDataIndex: freezed == currentDataIndex
          ? _value.currentDataIndex
          : currentDataIndex // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BotExecutionResultImplCopyWith<$Res>
    implements $BotExecutionResultCopyWith<$Res> {
  factory _$$BotExecutionResultImplCopyWith(_$BotExecutionResultImpl value,
          $Res Function(_$BotExecutionResultImpl) then) =
      __$$BotExecutionResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int botId,
      String data,
      BotStatus status,
      DateTime timestamp,
      String? proxy,
      Duration? elapsed,
      Map<String, String>? captures,
      String? errorMessage,
      int? retryCount,
      String? customStatus,
      String? currentStatus,
      int? currentDataIndex});
}

/// @nodoc
class __$$BotExecutionResultImplCopyWithImpl<$Res>
    extends _$BotExecutionResultCopyWithImpl<$Res, _$BotExecutionResultImpl>
    implements _$$BotExecutionResultImplCopyWith<$Res> {
  __$$BotExecutionResultImplCopyWithImpl(_$BotExecutionResultImpl _value,
      $Res Function(_$BotExecutionResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of BotExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? botId = null,
    Object? data = null,
    Object? status = null,
    Object? timestamp = null,
    Object? proxy = freezed,
    Object? elapsed = freezed,
    Object? captures = freezed,
    Object? errorMessage = freezed,
    Object? retryCount = freezed,
    Object? customStatus = freezed,
    Object? currentStatus = freezed,
    Object? currentDataIndex = freezed,
  }) {
    return _then(_$BotExecutionResultImpl(
      botId: null == botId
          ? _value.botId
          : botId // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BotStatus,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      proxy: freezed == proxy
          ? _value.proxy
          : proxy // ignore: cast_nullable_to_non_nullable
              as String?,
      elapsed: freezed == elapsed
          ? _value.elapsed
          : elapsed // ignore: cast_nullable_to_non_nullable
              as Duration?,
      captures: freezed == captures
          ? _value._captures
          : captures // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      retryCount: freezed == retryCount
          ? _value.retryCount
          : retryCount // ignore: cast_nullable_to_non_nullable
              as int?,
      customStatus: freezed == customStatus
          ? _value.customStatus
          : customStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      currentStatus: freezed == currentStatus
          ? _value.currentStatus
          : currentStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      currentDataIndex: freezed == currentDataIndex
          ? _value.currentDataIndex
          : currentDataIndex // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BotExecutionResultImpl implements _BotExecutionResult {
  const _$BotExecutionResultImpl(
      {required this.botId,
      required this.data,
      required this.status,
      required this.timestamp,
      this.proxy,
      this.elapsed,
      final Map<String, String>? captures,
      this.errorMessage,
      this.retryCount,
      this.customStatus,
      this.currentStatus,
      this.currentDataIndex})
      : _captures = captures;

  factory _$BotExecutionResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$BotExecutionResultImplFromJson(json);

  @override
  final int botId;
  @override
  final String data;
  @override
  final BotStatus status;
  @override
  final DateTime timestamp;
  @override
  final String? proxy;
  @override
  final Duration? elapsed;
  final Map<String, String>? _captures;
  @override
  Map<String, String>? get captures {
    final value = _captures;
    if (value == null) return null;
    if (_captures is EqualUnmodifiableMapView) return _captures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? errorMessage;
  @override
  final int? retryCount;
  @override
  final String? customStatus;
  @override
  final String? currentStatus;
// Real-time status showing current block being processed
  @override
  final int? currentDataIndex;

  @override
  String toString() {
    return 'BotExecutionResult(botId: $botId, data: $data, status: $status, timestamp: $timestamp, proxy: $proxy, elapsed: $elapsed, captures: $captures, errorMessage: $errorMessage, retryCount: $retryCount, customStatus: $customStatus, currentStatus: $currentStatus, currentDataIndex: $currentDataIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BotExecutionResultImpl &&
            (identical(other.botId, botId) || other.botId == botId) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.proxy, proxy) || other.proxy == proxy) &&
            (identical(other.elapsed, elapsed) || other.elapsed == elapsed) &&
            const DeepCollectionEquality().equals(other._captures, _captures) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.customStatus, customStatus) ||
                other.customStatus == customStatus) &&
            (identical(other.currentStatus, currentStatus) ||
                other.currentStatus == currentStatus) &&
            (identical(other.currentDataIndex, currentDataIndex) ||
                other.currentDataIndex == currentDataIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      botId,
      data,
      status,
      timestamp,
      proxy,
      elapsed,
      const DeepCollectionEquality().hash(_captures),
      errorMessage,
      retryCount,
      customStatus,
      currentStatus,
      currentDataIndex);

  /// Create a copy of BotExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BotExecutionResultImplCopyWith<_$BotExecutionResultImpl> get copyWith =>
      __$$BotExecutionResultImplCopyWithImpl<_$BotExecutionResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BotExecutionResultImplToJson(
      this,
    );
  }
}

abstract class _BotExecutionResult implements BotExecutionResult {
  const factory _BotExecutionResult(
      {required final int botId,
      required final String data,
      required final BotStatus status,
      required final DateTime timestamp,
      final String? proxy,
      final Duration? elapsed,
      final Map<String, String>? captures,
      final String? errorMessage,
      final int? retryCount,
      final String? customStatus,
      final String? currentStatus,
      final int? currentDataIndex}) = _$BotExecutionResultImpl;

  factory _BotExecutionResult.fromJson(Map<String, dynamic> json) =
      _$BotExecutionResultImpl.fromJson;

  @override
  int get botId;
  @override
  String get data;
  @override
  BotStatus get status;
  @override
  DateTime get timestamp;
  @override
  String? get proxy;
  @override
  Duration? get elapsed;
  @override
  Map<String, String>? get captures;
  @override
  String? get errorMessage;
  @override
  int? get retryCount;
  @override
  String? get customStatus;
  @override
  String?
      get currentStatus; // Real-time status showing current block being processed
  @override
  int? get currentDataIndex;

  /// Create a copy of BotExecutionResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BotExecutionResultImplCopyWith<_$BotExecutionResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProxyStatus _$ProxyStatusFromJson(Map<String, dynamic> json) {
  return _ProxyStatus.fromJson(json);
}

/// @nodoc
mixin _$ProxyStatus {
  String get proxy => throw _privateConstructorUsedError;
  ProxyState get state => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;
  DateTime? get lastUsed => throw _privateConstructorUsedError;

  /// Serializes this ProxyStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProxyStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProxyStatusCopyWith<ProxyStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProxyStatusCopyWith<$Res> {
  factory $ProxyStatusCopyWith(
          ProxyStatus value, $Res Function(ProxyStatus) then) =
      _$ProxyStatusCopyWithImpl<$Res, ProxyStatus>;
  @useResult
  $Res call(
      {String proxy, ProxyState state, int usageCount, DateTime? lastUsed});
}

/// @nodoc
class _$ProxyStatusCopyWithImpl<$Res, $Val extends ProxyStatus>
    implements $ProxyStatusCopyWith<$Res> {
  _$ProxyStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProxyStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? proxy = null,
    Object? state = null,
    Object? usageCount = null,
    Object? lastUsed = freezed,
  }) {
    return _then(_value.copyWith(
      proxy: null == proxy
          ? _value.proxy
          : proxy // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as ProxyState,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastUsed: freezed == lastUsed
          ? _value.lastUsed
          : lastUsed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProxyStatusImplCopyWith<$Res>
    implements $ProxyStatusCopyWith<$Res> {
  factory _$$ProxyStatusImplCopyWith(
          _$ProxyStatusImpl value, $Res Function(_$ProxyStatusImpl) then) =
      __$$ProxyStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String proxy, ProxyState state, int usageCount, DateTime? lastUsed});
}

/// @nodoc
class __$$ProxyStatusImplCopyWithImpl<$Res>
    extends _$ProxyStatusCopyWithImpl<$Res, _$ProxyStatusImpl>
    implements _$$ProxyStatusImplCopyWith<$Res> {
  __$$ProxyStatusImplCopyWithImpl(
      _$ProxyStatusImpl _value, $Res Function(_$ProxyStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProxyStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? proxy = null,
    Object? state = null,
    Object? usageCount = null,
    Object? lastUsed = freezed,
  }) {
    return _then(_$ProxyStatusImpl(
      proxy: null == proxy
          ? _value.proxy
          : proxy // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as ProxyState,
      usageCount: null == usageCount
          ? _value.usageCount
          : usageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastUsed: freezed == lastUsed
          ? _value.lastUsed
          : lastUsed // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProxyStatusImpl implements _ProxyStatus {
  const _$ProxyStatusImpl(
      {required this.proxy,
      required this.state,
      required this.usageCount,
      this.lastUsed});

  factory _$ProxyStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProxyStatusImplFromJson(json);

  @override
  final String proxy;
  @override
  final ProxyState state;
  @override
  final int usageCount;
  @override
  final DateTime? lastUsed;

  @override
  String toString() {
    return 'ProxyStatus(proxy: $proxy, state: $state, usageCount: $usageCount, lastUsed: $lastUsed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProxyStatusImpl &&
            (identical(other.proxy, proxy) || other.proxy == proxy) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            (identical(other.lastUsed, lastUsed) ||
                other.lastUsed == lastUsed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, proxy, state, usageCount, lastUsed);

  /// Create a copy of ProxyStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProxyStatusImplCopyWith<_$ProxyStatusImpl> get copyWith =>
      __$$ProxyStatusImplCopyWithImpl<_$ProxyStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProxyStatusImplToJson(
      this,
    );
  }
}

abstract class _ProxyStatus implements ProxyStatus {
  const factory _ProxyStatus(
      {required final String proxy,
      required final ProxyState state,
      required final int usageCount,
      final DateTime? lastUsed}) = _$ProxyStatusImpl;

  factory _ProxyStatus.fromJson(Map<String, dynamic> json) =
      _$ProxyStatusImpl.fromJson;

  @override
  String get proxy;
  @override
  ProxyState get state;
  @override
  int get usageCount;
  @override
  DateTime? get lastUsed;

  /// Create a copy of ProxyStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProxyStatusImplCopyWith<_$ProxyStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BotResultUpdate _$BotResultUpdateFromJson(Map<String, dynamic> json) {
  return _BotResultUpdate.fromJson(json);
}

/// @nodoc
mixin _$BotResultUpdate {
  String get jobId => throw _privateConstructorUsedError;
  String? get runnerId => throw _privateConstructorUsedError;
  List<BotExecutionResult> get botResults => throw _privateConstructorUsedError;

  /// Serializes this BotResultUpdate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BotResultUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BotResultUpdateCopyWith<BotResultUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BotResultUpdateCopyWith<$Res> {
  factory $BotResultUpdateCopyWith(
          BotResultUpdate value, $Res Function(BotResultUpdate) then) =
      _$BotResultUpdateCopyWithImpl<$Res, BotResultUpdate>;
  @useResult
  $Res call(
      {String jobId, String? runnerId, List<BotExecutionResult> botResults});
}

/// @nodoc
class _$BotResultUpdateCopyWithImpl<$Res, $Val extends BotResultUpdate>
    implements $BotResultUpdateCopyWith<$Res> {
  _$BotResultUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BotResultUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? runnerId = freezed,
    Object? botResults = null,
  }) {
    return _then(_value.copyWith(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      runnerId: freezed == runnerId
          ? _value.runnerId
          : runnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      botResults: null == botResults
          ? _value.botResults
          : botResults // ignore: cast_nullable_to_non_nullable
              as List<BotExecutionResult>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BotResultUpdateImplCopyWith<$Res>
    implements $BotResultUpdateCopyWith<$Res> {
  factory _$$BotResultUpdateImplCopyWith(_$BotResultUpdateImpl value,
          $Res Function(_$BotResultUpdateImpl) then) =
      __$$BotResultUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String jobId, String? runnerId, List<BotExecutionResult> botResults});
}

/// @nodoc
class __$$BotResultUpdateImplCopyWithImpl<$Res>
    extends _$BotResultUpdateCopyWithImpl<$Res, _$BotResultUpdateImpl>
    implements _$$BotResultUpdateImplCopyWith<$Res> {
  __$$BotResultUpdateImplCopyWithImpl(
      _$BotResultUpdateImpl _value, $Res Function(_$BotResultUpdateImpl) _then)
      : super(_value, _then);

  /// Create a copy of BotResultUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? runnerId = freezed,
    Object? botResults = null,
  }) {
    return _then(_$BotResultUpdateImpl(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      runnerId: freezed == runnerId
          ? _value.runnerId
          : runnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      botResults: null == botResults
          ? _value._botResults
          : botResults // ignore: cast_nullable_to_non_nullable
              as List<BotExecutionResult>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BotResultUpdateImpl implements _BotResultUpdate {
  const _$BotResultUpdateImpl(
      {required this.jobId,
      this.runnerId,
      required final List<BotExecutionResult> botResults})
      : _botResults = botResults;

  factory _$BotResultUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$BotResultUpdateImplFromJson(json);

  @override
  final String jobId;
  @override
  final String? runnerId;
  final List<BotExecutionResult> _botResults;
  @override
  List<BotExecutionResult> get botResults {
    if (_botResults is EqualUnmodifiableListView) return _botResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_botResults);
  }

  @override
  String toString() {
    return 'BotResultUpdate(jobId: $jobId, runnerId: $runnerId, botResults: $botResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BotResultUpdateImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.runnerId, runnerId) ||
                other.runnerId == runnerId) &&
            const DeepCollectionEquality()
                .equals(other._botResults, _botResults));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, jobId, runnerId,
      const DeepCollectionEquality().hash(_botResults));

  /// Create a copy of BotResultUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BotResultUpdateImplCopyWith<_$BotResultUpdateImpl> get copyWith =>
      __$$BotResultUpdateImplCopyWithImpl<_$BotResultUpdateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BotResultUpdateImplToJson(
      this,
    );
  }
}

abstract class _BotResultUpdate implements BotResultUpdate {
  const factory _BotResultUpdate(
          {required final String jobId,
          final String? runnerId,
          required final List<BotExecutionResult> botResults}) =
      _$BotResultUpdateImpl;

  factory _BotResultUpdate.fromJson(Map<String, dynamic> json) =
      _$BotResultUpdateImpl.fromJson;

  @override
  String get jobId;
  @override
  String? get runnerId;
  @override
  List<BotExecutionResult> get botResults;

  /// Create a copy of BotResultUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BotResultUpdateImplCopyWith<_$BotResultUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProxyUpdate _$ProxyUpdateFromJson(Map<String, dynamic> json) {
  return _ProxyUpdate.fromJson(json);
}

/// @nodoc
mixin _$ProxyUpdate {
  String get jobId => throw _privateConstructorUsedError;
  String? get runnerId => throw _privateConstructorUsedError;
  List<ProxyStatus> get proxies => throw _privateConstructorUsedError;

  /// Serializes this ProxyUpdate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProxyUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProxyUpdateCopyWith<ProxyUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProxyUpdateCopyWith<$Res> {
  factory $ProxyUpdateCopyWith(
          ProxyUpdate value, $Res Function(ProxyUpdate) then) =
      _$ProxyUpdateCopyWithImpl<$Res, ProxyUpdate>;
  @useResult
  $Res call({String jobId, String? runnerId, List<ProxyStatus> proxies});
}

/// @nodoc
class _$ProxyUpdateCopyWithImpl<$Res, $Val extends ProxyUpdate>
    implements $ProxyUpdateCopyWith<$Res> {
  _$ProxyUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProxyUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? runnerId = freezed,
    Object? proxies = null,
  }) {
    return _then(_value.copyWith(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      runnerId: freezed == runnerId
          ? _value.runnerId
          : runnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      proxies: null == proxies
          ? _value.proxies
          : proxies // ignore: cast_nullable_to_non_nullable
              as List<ProxyStatus>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProxyUpdateImplCopyWith<$Res>
    implements $ProxyUpdateCopyWith<$Res> {
  factory _$$ProxyUpdateImplCopyWith(
          _$ProxyUpdateImpl value, $Res Function(_$ProxyUpdateImpl) then) =
      __$$ProxyUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String jobId, String? runnerId, List<ProxyStatus> proxies});
}

/// @nodoc
class __$$ProxyUpdateImplCopyWithImpl<$Res>
    extends _$ProxyUpdateCopyWithImpl<$Res, _$ProxyUpdateImpl>
    implements _$$ProxyUpdateImplCopyWith<$Res> {
  __$$ProxyUpdateImplCopyWithImpl(
      _$ProxyUpdateImpl _value, $Res Function(_$ProxyUpdateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProxyUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? jobId = null,
    Object? runnerId = freezed,
    Object? proxies = null,
  }) {
    return _then(_$ProxyUpdateImpl(
      jobId: null == jobId
          ? _value.jobId
          : jobId // ignore: cast_nullable_to_non_nullable
              as String,
      runnerId: freezed == runnerId
          ? _value.runnerId
          : runnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      proxies: null == proxies
          ? _value._proxies
          : proxies // ignore: cast_nullable_to_non_nullable
              as List<ProxyStatus>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProxyUpdateImpl implements _ProxyUpdate {
  const _$ProxyUpdateImpl(
      {required this.jobId,
      this.runnerId,
      required final List<ProxyStatus> proxies})
      : _proxies = proxies;

  factory _$ProxyUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProxyUpdateImplFromJson(json);

  @override
  final String jobId;
  @override
  final String? runnerId;
  final List<ProxyStatus> _proxies;
  @override
  List<ProxyStatus> get proxies {
    if (_proxies is EqualUnmodifiableListView) return _proxies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_proxies);
  }

  @override
  String toString() {
    return 'ProxyUpdate(jobId: $jobId, runnerId: $runnerId, proxies: $proxies)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProxyUpdateImpl &&
            (identical(other.jobId, jobId) || other.jobId == jobId) &&
            (identical(other.runnerId, runnerId) ||
                other.runnerId == runnerId) &&
            const DeepCollectionEquality().equals(other._proxies, _proxies));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, jobId, runnerId,
      const DeepCollectionEquality().hash(_proxies));

  /// Create a copy of ProxyUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProxyUpdateImplCopyWith<_$ProxyUpdateImpl> get copyWith =>
      __$$ProxyUpdateImplCopyWithImpl<_$ProxyUpdateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProxyUpdateImplToJson(
      this,
    );
  }
}

abstract class _ProxyUpdate implements ProxyUpdate {
  const factory _ProxyUpdate(
      {required final String jobId,
      final String? runnerId,
      required final List<ProxyStatus> proxies}) = _$ProxyUpdateImpl;

  factory _ProxyUpdate.fromJson(Map<String, dynamic> json) =
      _$ProxyUpdateImpl.fromJson;

  @override
  String get jobId;
  @override
  String? get runnerId;
  @override
  List<ProxyStatus> get proxies;

  /// Create a copy of ProxyUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProxyUpdateImplCopyWith<_$ProxyUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
