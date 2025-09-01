// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

JobParams _$JobParamsFromJson(Map<String, dynamic> json) {
  return _JobParams.fromJson(json);
}

/// @nodoc
mixin _$JobParams {
  String get configId => throw _privateConstructorUsedError;
  String get configPath => throw _privateConstructorUsedError;
  List<String> get dataLines => throw _privateConstructorUsedError;
  int get startIndex => throw _privateConstructorUsedError;
  int get threads => throw _privateConstructorUsedError;
  int get timeout => throw _privateConstructorUsedError;
  List<String> get proxies => throw _privateConstructorUsedError;
  bool get useProxies => throw _privateConstructorUsedError;
  int get proxyRetryCount => throw _privateConstructorUsedError;
  Map<String, dynamic>? get customInputs => throw _privateConstructorUsedError;

  /// Serializes this JobParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JobParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JobParamsCopyWith<JobParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobParamsCopyWith<$Res> {
  factory $JobParamsCopyWith(JobParams value, $Res Function(JobParams) then) =
      _$JobParamsCopyWithImpl<$Res, JobParams>;
  @useResult
  $Res call(
      {String configId,
      String configPath,
      List<String> dataLines,
      int startIndex,
      int threads,
      int timeout,
      List<String> proxies,
      bool useProxies,
      int proxyRetryCount,
      Map<String, dynamic>? customInputs});
}

/// @nodoc
class _$JobParamsCopyWithImpl<$Res, $Val extends JobParams>
    implements $JobParamsCopyWith<$Res> {
  _$JobParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JobParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? configId = null,
    Object? configPath = null,
    Object? dataLines = null,
    Object? startIndex = null,
    Object? threads = null,
    Object? timeout = null,
    Object? proxies = null,
    Object? useProxies = null,
    Object? proxyRetryCount = null,
    Object? customInputs = freezed,
  }) {
    return _then(_value.copyWith(
      configId: null == configId
          ? _value.configId
          : configId // ignore: cast_nullable_to_non_nullable
              as String,
      configPath: null == configPath
          ? _value.configPath
          : configPath // ignore: cast_nullable_to_non_nullable
              as String,
      dataLines: null == dataLines
          ? _value.dataLines
          : dataLines // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startIndex: null == startIndex
          ? _value.startIndex
          : startIndex // ignore: cast_nullable_to_non_nullable
              as int,
      threads: null == threads
          ? _value.threads
          : threads // ignore: cast_nullable_to_non_nullable
              as int,
      timeout: null == timeout
          ? _value.timeout
          : timeout // ignore: cast_nullable_to_non_nullable
              as int,
      proxies: null == proxies
          ? _value.proxies
          : proxies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      useProxies: null == useProxies
          ? _value.useProxies
          : useProxies // ignore: cast_nullable_to_non_nullable
              as bool,
      proxyRetryCount: null == proxyRetryCount
          ? _value.proxyRetryCount
          : proxyRetryCount // ignore: cast_nullable_to_non_nullable
              as int,
      customInputs: freezed == customInputs
          ? _value.customInputs
          : customInputs // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JobParamsImplCopyWith<$Res>
    implements $JobParamsCopyWith<$Res> {
  factory _$$JobParamsImplCopyWith(
          _$JobParamsImpl value, $Res Function(_$JobParamsImpl) then) =
      __$$JobParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String configId,
      String configPath,
      List<String> dataLines,
      int startIndex,
      int threads,
      int timeout,
      List<String> proxies,
      bool useProxies,
      int proxyRetryCount,
      Map<String, dynamic>? customInputs});
}

/// @nodoc
class __$$JobParamsImplCopyWithImpl<$Res>
    extends _$JobParamsCopyWithImpl<$Res, _$JobParamsImpl>
    implements _$$JobParamsImplCopyWith<$Res> {
  __$$JobParamsImplCopyWithImpl(
      _$JobParamsImpl _value, $Res Function(_$JobParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of JobParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? configId = null,
    Object? configPath = null,
    Object? dataLines = null,
    Object? startIndex = null,
    Object? threads = null,
    Object? timeout = null,
    Object? proxies = null,
    Object? useProxies = null,
    Object? proxyRetryCount = null,
    Object? customInputs = freezed,
  }) {
    return _then(_$JobParamsImpl(
      configId: null == configId
          ? _value.configId
          : configId // ignore: cast_nullable_to_non_nullable
              as String,
      configPath: null == configPath
          ? _value.configPath
          : configPath // ignore: cast_nullable_to_non_nullable
              as String,
      dataLines: null == dataLines
          ? _value._dataLines
          : dataLines // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startIndex: null == startIndex
          ? _value.startIndex
          : startIndex // ignore: cast_nullable_to_non_nullable
              as int,
      threads: null == threads
          ? _value.threads
          : threads // ignore: cast_nullable_to_non_nullable
              as int,
      timeout: null == timeout
          ? _value.timeout
          : timeout // ignore: cast_nullable_to_non_nullable
              as int,
      proxies: null == proxies
          ? _value._proxies
          : proxies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      useProxies: null == useProxies
          ? _value.useProxies
          : useProxies // ignore: cast_nullable_to_non_nullable
              as bool,
      proxyRetryCount: null == proxyRetryCount
          ? _value.proxyRetryCount
          : proxyRetryCount // ignore: cast_nullable_to_non_nullable
              as int,
      customInputs: freezed == customInputs
          ? _value._customInputs
          : customInputs // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JobParamsImpl implements _JobParams {
  const _$JobParamsImpl(
      {required this.configId,
      required this.configPath,
      required final List<String> dataLines,
      this.startIndex = 0,
      this.threads = 1,
      this.timeout = 60,
      final List<String> proxies = const [],
      this.useProxies = true,
      this.proxyRetryCount = 3,
      final Map<String, dynamic>? customInputs})
      : _dataLines = dataLines,
        _proxies = proxies,
        _customInputs = customInputs;

  factory _$JobParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobParamsImplFromJson(json);

  @override
  final String configId;
  @override
  final String configPath;
  final List<String> _dataLines;
  @override
  List<String> get dataLines {
    if (_dataLines is EqualUnmodifiableListView) return _dataLines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dataLines);
  }

  @override
  @JsonKey()
  final int startIndex;
  @override
  @JsonKey()
  final int threads;
  @override
  @JsonKey()
  final int timeout;
  final List<String> _proxies;
  @override
  @JsonKey()
  List<String> get proxies {
    if (_proxies is EqualUnmodifiableListView) return _proxies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_proxies);
  }

  @override
  @JsonKey()
  final bool useProxies;
  @override
  @JsonKey()
  final int proxyRetryCount;
  final Map<String, dynamic>? _customInputs;
  @override
  Map<String, dynamic>? get customInputs {
    final value = _customInputs;
    if (value == null) return null;
    if (_customInputs is EqualUnmodifiableMapView) return _customInputs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'JobParams(configId: $configId, configPath: $configPath, dataLines: $dataLines, startIndex: $startIndex, threads: $threads, timeout: $timeout, proxies: $proxies, useProxies: $useProxies, proxyRetryCount: $proxyRetryCount, customInputs: $customInputs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobParamsImpl &&
            (identical(other.configId, configId) ||
                other.configId == configId) &&
            (identical(other.configPath, configPath) ||
                other.configPath == configPath) &&
            const DeepCollectionEquality()
                .equals(other._dataLines, _dataLines) &&
            (identical(other.startIndex, startIndex) ||
                other.startIndex == startIndex) &&
            (identical(other.threads, threads) || other.threads == threads) &&
            (identical(other.timeout, timeout) || other.timeout == timeout) &&
            const DeepCollectionEquality().equals(other._proxies, _proxies) &&
            (identical(other.useProxies, useProxies) ||
                other.useProxies == useProxies) &&
            (identical(other.proxyRetryCount, proxyRetryCount) ||
                other.proxyRetryCount == proxyRetryCount) &&
            const DeepCollectionEquality()
                .equals(other._customInputs, _customInputs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      configId,
      configPath,
      const DeepCollectionEquality().hash(_dataLines),
      startIndex,
      threads,
      timeout,
      const DeepCollectionEquality().hash(_proxies),
      useProxies,
      proxyRetryCount,
      const DeepCollectionEquality().hash(_customInputs));

  /// Create a copy of JobParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JobParamsImplCopyWith<_$JobParamsImpl> get copyWith =>
      __$$JobParamsImplCopyWithImpl<_$JobParamsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobParamsImplToJson(
      this,
    );
  }
}

abstract class _JobParams implements JobParams {
  const factory _JobParams(
      {required final String configId,
      required final String configPath,
      required final List<String> dataLines,
      final int startIndex,
      final int threads,
      final int timeout,
      final List<String> proxies,
      final bool useProxies,
      final int proxyRetryCount,
      final Map<String, dynamic>? customInputs}) = _$JobParamsImpl;

  factory _JobParams.fromJson(Map<String, dynamic> json) =
      _$JobParamsImpl.fromJson;

  @override
  String get configId;
  @override
  String get configPath;
  @override
  List<String> get dataLines;
  @override
  int get startIndex;
  @override
  int get threads;
  @override
  int get timeout;
  @override
  List<String> get proxies;
  @override
  bool get useProxies;
  @override
  int get proxyRetryCount;
  @override
  Map<String, dynamic>? get customInputs;

  /// Create a copy of JobParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JobParamsImplCopyWith<_$JobParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
